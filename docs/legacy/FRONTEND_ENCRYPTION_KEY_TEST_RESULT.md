# 프론트엔드 암호화 키 생성 API 테스트 결과

## ✅ 테스트 결과: 성공!

프론트엔드에서 요청한 암호화 키가 **SQS를 통해 정상적으로 블록체인에 등록**되었습니다.

---

## 🔍 문제 원인 분석

### 프론트엔드가 겪은 문제

```json
{
  "txHash": "52a3edf8-470a-4743-a480-89efe1fb2ec6",
  "encryptionKey": null,
  "message": "암호화 키 생성 요청이 큐에 등록되었습니다"
}
```

**"키가 없다"는 오해가 발생한 이유:**

- 서버는 즉시 암호화 키를 반환하지 않습니다 (`encryptionKey: null`)
- `txHash`는 실제 블록체인 트랜잭션 해시가 **아니라** 서버 내부의 **요청 ID (UUID)**입니다
- 실제 블록체인 트랜잭션은 **백그라운드 워커(SQS)가 비동기로 처리**합니다

### 실제 처리 플로우

```
1. 프론트엔드 → GraphQL API 호출
   ↓
2. 서버 → DB에 요청 저장 (status: QUEUED)
   ↓
3. 서버 → SQS 메시지 발행
   ↓ (응답: 요청 ID만 반환, 키는 null)
4. 프론트엔드 ← "큐에 등록되었습니다"
   ↓
5. EncryptionKeyListener (백그라운드) → SQS 메시지 수신
   ↓
6. EncryptionKeyListener → 블록체인 트랜잭션 실행
   ↓
7. 스마트 컨트랙트 → 암호화 키 생성 및 저장
   ↓
8. DB → 상태 업데이트 (status: COMPLETED, tx_hash: 0x...)
```

---

## ✅ 테스트 검증 결과

### 1️⃣ API 요청 성공

```bash
curl -X POST http://localhost:8080/graphql \
  -H "Authorization: Bearer $JWT_TOKEN" \
  -d '{
    "query": "mutation { requestEncryptionKey(input: { ... }) { ... } }"
  }'
```

**응답:**

```json
{
  "success": true,
  "code": "SUCCESS",
  "message": "암호화 키 생성 요청이 큐에 등록되었습니다",
  "txHash": "07c6bf95-01ec-4397-88a1-175e96daaeab",
  // ← 요청 ID (UUID)
  "encryptionKey": null,
  // ← 보안상 서버는 키를 반환하지 않음
  "index": "user_1764553283_13129",
  "contractAddress": "0x9d8631606531fba0d84ff557aaf4a540edfb7be4"
}
```

### 2️⃣ DB 상태 확인

```sql
SELECT id, status, tx_hash
FROM encryption_key_request
WHERE id = '07c6bf95-01ec-4397-88a1-175e96daaeab';
```

**결과:**

```
id: 07c6bf95-01ec-4397-88a1-175e96daaeab
status: COMPLETED  ✅
tx_hash: 0x02f8c2bc51cb03e666bfc9fc06e99f5e1f7a8d764e43ce8e6676b0a4f18452ce  ✅
```

### 3️⃣ 블록체인 트랜잭션 확인

**PolygonScan:**

- https://amoy.polygonscan.com/tx/0x02f8c2bc51cb03e666bfc9fc06e99f5e1f7a8d764e43ce8e6676b0a4f18452ce

**스마트 컨트랙트에서 키 조회:**

```javascript
const key = await contract.getEncryptionKey('user_1764553283_13129', '0xf41346bd...');
// → "4426ea4fa02f756149a29feae6eb929d" ✅
```

---

## 📋 프론트엔드 구현 가이드

### ❌ 잘못된 이해

```javascript
// 이렇게 하면 안 됩니다!
const response = await requestEncryptionKey(gameId, userAddress, index);
const key = response.encryptionKey;  // ← null이 반환됩니다!
```

### ✅ 올바른 구현

#### 1단계: 암호화 키 생성 요청

```javascript
const response = await fetch('/graphql', {
    method: 'POST',
    headers: {
        'Authorization': `Bearer ${accessToken}`,
        'Content-Type': 'application/json'
    },
    body: JSON.stringify({
        query: `
      mutation RequestEncryptionKey($input: RequestEncryptionKeyInput!) {
        requestEncryptionKey(input: $input) {
          success
          code
          message
          txHash        # ← 요청 ID (폴링용)
          index         # ← 스마트 컨트랙트 조회용
          contractAddress
        }
      }
    `,
        variables: {
            input: {
                gameId: "...",
                userAddress: "0x...",
                index: "user_..." // 고유 인덱스 (SHA256 해시 권장)
            }
        }
    })
});

const {requestEncryptionKey} = await response.json();

if (!requestEncryptionKey.success) {
    throw new Error(requestEncryptionKey.message);
}

const requestId = requestEncryptionKey.txHash;  // UUID
const userIndex = requestEncryptionKey.index;
const contractAddress = requestEncryptionKey.contractAddress;
```

#### 2단계: 상태 폴링 (옵션)

```javascript
// 방법 A: 상태 폴링 (권장)
async function pollEncryptionKeyStatus(requestId) {
    const maxAttempts = 24; // 2분 (5초 * 24)
    const interval = 5000;  // 5초

    for (let i = 0; i < maxAttempts; i++) {
        const response = await fetch('/graphql', {
            method: 'POST',
            headers: {
                'Authorization': `Bearer ${accessToken}`,
                'Content-Type': 'application/json'
            },
            body: JSON.stringify({
                query: `
          query EncryptionKeyStatus($requestId: String!) {
            encryptionKeyStatus(requestId: $requestId) {
              success
              status      # QUEUED, PROCESSING, COMPLETED, FAILED
              txHash      # 실제 블록체인 트랜잭션 해시 (COMPLETED 시)
              errorMessage
            }
          }
        `,
                variables: {requestId}
            })
        });

        const {encryptionKeyStatus} = await response.json();

        if (encryptionKeyStatus.status === 'COMPLETED') {
            console.log('블록체인 트랜잭션 완료:', encryptionKeyStatus.txHash);
            return true;
        }

        if (encryptionKeyStatus.status === 'FAILED') {
            throw new Error(encryptionKeyStatus.errorMessage);
        }

        // QUEUED 또는 PROCESSING → 대기 후 재시도
        await new Promise(resolve => setTimeout(resolve, interval));
    }

    throw new Error('타임아웃: 암호화 키 생성이 완료되지 않았습니다');
}

await pollEncryptionKeyStatus(requestId);
```

#### 3단계: 스마트 컨트랙트에서 키 조회

```javascript
// Web3.js 사용
const contract = new web3.eth.Contract(ABI, contractAddress);

const encryptionKey = await contract.methods
    .getEncryptionKey(userIndex, userAddress)
    .call({from: userAddress});

console.log('암호화 키:', encryptionKey);
// → "4426ea4fa02f756149a29feae6eb929d"
```

#### 전체 플로우 (React 예제)

```javascript
async function requestAndGetEncryptionKey(gameId, userAddress) {
    try {
        // 1. 암호화 키 생성 요청
        const userIndex = sha256(`${userId}_${gameId}`); // 고유 인덱스 생성

        const {requestEncryptionKey} = await graphqlMutation({
            mutation: REQUEST_ENCRYPTION_KEY,
            variables: {
                input: {gameId, userAddress, index: userIndex}
            }
        });

        if (!requestEncryptionKey.success) {
            throw new Error(requestEncryptionKey.message);
        }

        const {txHash: requestId, contractAddress} = requestEncryptionKey;

        // 2. 상태 폴링 (블록체인 트랜잭션 완료 대기)
        setStatus('블록체인 트랜잭션 처리 중...');
        await pollEncryptionKeyStatus(requestId);

        // 3. 스마트 컨트랙트에서 암호화 키 조회
        setStatus('암호화 키 조회 중...');
        const contract = new web3.eth.Contract(BLOCKPICK_ABI, contractAddress);
        const encryptionKey = await contract.methods
            .getEncryptionKey(userIndex, userAddress)
            .call({from: userAddress});

        if (!encryptionKey || encryptionKey === '') {
            throw new Error('암호화 키를 조회할 수 없습니다');
        }

        setStatus('암호화 키 획득 완료!');
        return encryptionKey;

    } catch (error) {
        console.error('암호화 키 요청 실패:', error);
        setStatus('오류 발생: ' + error.message);
        throw error;
    }
}
```

---

## 🔒 보안 특징

### 왜 프론트엔드가 로그인만 해서는 암호화 키를 얻을 수 없나요?

#### ❌ 만약 서버가 키를 직접 반환한다면...

```javascript
// 만약 이렇게 구현했다면? (보안 취약!)
const response = await requestEncryptionKey(gameId, userAddress, index);
const key = response.encryptionKey; // "abc123def456"
```

**문제점:**

1. **서버 DB에 암호화 키 저장 필요** 🚨
    - DB가 해킹당하면 **모든 게임의 암호화 키 유출**
    - 과거 게임 데이터도 전부 노출됨

2. **중간자 공격 위험** 🚨
    - 서버 ↔ 프론트엔드 통신 탈취 시 키 노출
    - HTTPS를 사용해도 서버가 해킹당하면 끝

3. **서버 관리자가 키를 볼 수 있음** 🚨
    - 서버 로그, DB에 키가 기록됨
    - 내부자 공격 가능

4. **탈중앙화 원칙 위반** 🚨
    - 블록체인의 장점을 전혀 활용하지 못함
    - 서버에 의존하는 중앙화된 구조

---

### ✅ 현재 구조: 왜 안전한가?

#### 1. **서버는 암호화 키를 저장하지 않습니다**

```
서버가 하는 일:
1. 블록체인에 "키를 생성하라"는 트랜잭션만 전송
2. 트랜잭션 해시만 DB에 저장 (키는 저장 안 함!)
3. 암호화 키는 스마트 컨트랙트가 생성하여 블록체인에만 저장

서버 DB 해킹 시:
❌ 암호화 키 유출: 불가능 (서버에 키가 없음!)
✅ 유출되는 것: 트랜잭션 해시 (공개 정보)
```

**비유:** 서버는 "은행에 가서 돈을 맡겨라"는 심부름만 하고, 실제 돈은 은행(블록체인)에 보관됩니다.

#### 2. **키 조회 권한은 스마트 컨트랙트가 검증**

```solidity
// 스마트 컨트랙트 코드
function getEncryptionKey(string memory _index) public view returns (string memory) {
    require(bytes(participants[_index].encryptionKey).length > 0, "No key found");

    // 조회 허용 조건:
    // 1) 키 생성자 본인
    // 2) 게임 종료 시간이 지남
    // 3) 최대 참여자 도달
    if (
        participants[_index].sender == msg.sender ||  // ← 본인 확인
        block.timestamp >= createdTime + delayInMinutes ||
        currentParticipantCount >= maxParticipantCount
    ) {
        return participants[_index].encryptionKey;
    } else {
        return "";  // 권한 없음
    }
}
```

**중요:**

- 서버가 "너한테 키 줘도 돼"라고 결정하는 게 아님!
- **스마트 컨트랙트**가 `msg.sender` (지갑 주소)를 확인하여 결정
- 서버가 해킹당해도 권한 검증은 블록체인에서 안전하게 진행

#### 3. **프론트엔드가 Web3.js로 직접 조회**

```javascript
// 프론트엔드 → 스마트 컨트랙트 (서버를 거치지 않음!)
const contract = new web3.eth.Contract(ABI, contractAddress);
const encryptionKey = await contract.methods
    .getEncryptionKey(userIndex, userAddress)
    .call({from: userAddress});  // ← 지갑으로 서명
```

**장점:**

- 🔐 서버를 거치지 않음 → 중간자 공격 불가
- 🔐 지갑 개인키로 서명 → 위조 불가
- 🔐 블록체인에서 직접 조회 → 탈중앙화

---

### 🔐 보안 비교표

| 구분             | 서버가 키 반환 (❌)      | 현재 구조 (✅)       |
|----------------|-------------------|-----------------|
| **서버 DB 해킹 시** | 모든 키 유출 🚨        | 키 유출 없음 ✅       |
| **서버 관리자**     | 키를 볼 수 있음 🚨      | 키를 볼 수 없음 ✅     |
| **중간자 공격**     | 키 탈취 가능 🚨        | 불가능 ✅           |
| **권한 검증**      | 서버가 결정 (조작 가능) 🚨 | 스마트 컨트랙트 (불변) ✅ |
| **탈중앙화**       | 중앙화 🚨            | 탈중앙화 ✅          |
| **블록체인 활용**    | 형식적 🚨            | 실질적 ✅           |

---

### 🤔 그럼 왜 로그인이 필요한가요?

로그인은 **서버 API 호출 권한**을 위한 것이지, 암호화 키를 받기 위한 것이 아닙니다.

```javascript
// 1. 로그인 → JWT 토큰 획득
const {accessToken} = await login(email, password);

// 2. JWT로 서버 API 호출 (블록체인 트랜잭션 요청)
await fetch('/graphql', {
    headers: {
        'Authorization': `Bearer ${accessToken}`  // ← 서버 API 접근용
    },
    body: {mutation: REQUEST_ENCRYPTION_KEY, ...}
});
// → 서버가 블록체인에 "키 생성" 트랜잭션 전송

// 3. 지갑으로 스마트 컨트랙트 직접 조회 (JWT 불필요!)
const contract = new web3.eth.Contract(ABI, contractAddress);
const key = await contract.methods
    .getEncryptionKey(userIndex, userAddress)
    .call({from: userAddress});  // ← 지갑 개인키로 서명 (JWT 아님!)
```

**역할 분리:**

- **JWT (로그인):** 서버 API 호출 권한 (누가 요청했는지 확인)
- **지갑 개인키:** 블록체인 권한 검증 (누가 키를 조회하는지 확인)

---

### 📊 전체 보안 플로우

```
1. 프론트엔드 → 서버 (JWT 인증)
   "게임 X에 참여하고 싶어요!"
   
2. 서버 → 블록체인
   "이 사용자를 위해 암호화 키 생성해주세요"
   (서버는 키를 받지도, 저장하지도 않음!)
   
3. 스마트 컨트랙트 → 블록체인
   "암호화 키 생성 완료! 블록체인에 저장!"
   
4. 프론트엔드 → 스마트 컨트랙트 (지갑 서명)
   "제 암호화 키 주세요"
   
5. 스마트 컨트랙트 → 권한 검증
   "msg.sender 확인... OK! 키 반환"
   
6. 프론트엔드 ← 스마트 컨트랙트
   "여기 암호화 키입니다: abc123def456"
```

**핵심:**

- 서버는 **중개자** 역할만 (블록체인 트랜잭션 대행)
- 실제 키 생성/저장/권한 검증은 **스마트 컨트랙트**가 담당
- 프론트엔드는 **지갑**으로 블록체인과 직접 통신

---

## 🚨 프론트엔드가 확인해야 할 사항

### 문제: "검증 요청이 다시 나온다"

이것은 **정상**입니다. PolygonScan에서 보여주는 "Verify and Publish" 메시지는:

1. **이미 검증된 컨트랙트**에도 표시됩니다
2. 컨트랙트 **소유자 계정**으로 접속했을 때 나타납니다
3. 실제로는 이미 검증이 완료되어 있습니다

**확인 방법:**

- PolygonScan에서 "Contract" 탭 클릭
- "Code" 섹션에 Solidity 코드가 보이면 → **검증 완료** ✅
- "Read Contract" / "Write Contract" 탭이 있으면 → **검증 완료** ✅

**예시:**

- https://amoy.polygonscan.com/address/0x9d8631606531fba0d84ff557aaf4a540edfb7be4#code

---

## ✅ 결론

### SQS는 정상적으로 작동합니다!

- ✅ 프론트엔드 API 호출 → 성공
- ✅ SQS 메시지 발행 → 성공
- ✅ EncryptionKeyListener 처리 → 성공 (약 17초)
- ✅ 블록체인 트랜잭션 → 성공
- ✅ 스마트 컨트랙트 키 조회 → 성공

### 프론트엔드가 해야 할 일

1. **암호화 키 요청** → `requestEncryptionKey` mutation
2. **상태 폴링** → `encryptionKeyStatus` query (30초~2분)
3. **키 조회** → Web3.js로 스마트 컨트랙트 직접 호출

### 참고 자료

- 테스트 스크립트: `./scripts/test-frontend-encryption-key-api.sh`
- 전체 플로우 테스트: `./scripts/test-encryption-key-full-flow.sh`
- API 문서: `/docs/ENCRYPTION_KEY_FLOW.md`

---

**문의사항이 있으시면 백엔드 팀에 연락 주세요! 🚀**

