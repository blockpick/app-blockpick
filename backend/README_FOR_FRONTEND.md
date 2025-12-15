# 🔑 암호화 키 생성 테스트 플로우

> **기준**: `test-encryption-key-full-flow.sh` 스크립트  
> **업데이트**: 2025-12-11

---

## 🎯 전체 플로우

```
1. 로그인 → JWT 토큰 획득
2. 게임 목록 조회 → contractAddress 확인
3. userIndex 생성 → SHA256(userId + gameId)
4. 암호화 키 요청 → GraphQL Mutation
5. 3초 대기 → 블록체인 트랜잭션 완료
6. 스마트 컨트랙트에서 키 조회 → Web3/Ethers
```

---

## 📦 설치

```bash
npm install @apollo/client graphql ethers crypto-js
```

---

## 💻 Step 1: 로그인

```typescript
const LOGIN = gql`
  mutation Login($input: LoginInput!) {
    login(input: $input) {
      success
      accessToken
      user {
        id
        email
      }
    }
  }
`;

const {data} = await login({
  variables: {
    input: {
      email: "testuser@blockpick.com",
      password: "123456"
    }
  }
});

const accessToken = data.login.accessToken;
const userId = data.login.user.id;
```

---

## 💻 Step 2: 게임 목록 조회

```typescript
const GAME_LIST = gql`
  query GameList {
    gameList(page: 0, size: 10) {
      success
      games {
        id
        title
        onchainContractAddr
        status
      }
    }
  }
`;

const {data} = await client.query({
  query: GAME_LIST
});

// 컨트랙트가 배포된 게임 찾기
const game = data.gameList.games.find(g => g.onchainContractAddr);

const gameId = game.id;
const contractAddress = game.onchainContractAddr;
```

---

## 💻 Step 3: userIndex 생성

```typescript
import CryptoJS from 'crypto-js';

// 중요: userId + gameId 만 사용! (timestamp 없음)
const rawData = `${userId}${gameId}`;
const userIndex = CryptoJS.SHA256(rawData).toString();

console.log('userIndex:', userIndex);
```

**⚠️ 주의**: 테스트 스크립트는 `userId + gameId`만 사용합니다. timestamp를 추가하지 마세요!

---

## 💻 Step 4: 암호화 키 요청

```typescript
const REQUEST_KEY = gql`
  mutation RequestEncryptionKey($input: EncryptionKeyInput!) {
    requestEncryptionKey(input: $input) {
      success
      code
      message
      encryptionKey
      contractAddress
      txHash
      userAddress
      index
    }
  }
`;

const {data} = await requestKey({
  variables: {
    input: {
      gameId: gameId,
      userAddress: userWalletAddress,
      index: userIndex
    }
  },
  context: {
    headers: {
      Authorization: `Bearer ${accessToken}`
    }
  }
});

if (!data.requestEncryptionKey.success) {
  throw new Error(data.requestEncryptionKey.message);
}

console.log('✅ 암호화 키 요청 성공');
console.log('Request ID:', data.requestEncryptionKey.txHash);
```

---

## 💻 Step 5: 대기 (중요!)

```typescript
// 블록체인 트랜잭션 완료 대기
await new Promise(resolve => setTimeout(resolve, 3000));
console.log('✅ 3초 대기 완료');
```

---

## 💻 Step 6: 스마트 컨트랙트에서 키 조회

```typescript
import {ethers} from 'ethers';

const provider = new ethers.BrowserProvider(window.ethereum);
const contract = new ethers.Contract(
  contractAddress,
  ['function getEncryptionKey(string, address) view returns (string)'],
  provider
);

const encryptionKey = await contract.getEncryptionKey(
  userIndex,
  userWalletAddress
);

if (!encryptionKey || encryptionKey === '0x' || encryptionKey === '0x0') {
  throw new Error('암호화 키가 아직 생성되지 않았습니다');
}

console.log('✅ 암호화 키 조회 성공!');
console.log('Key:', encryptionKey);
```

---

## 🔄 재시도 로직 (권장)

```typescript
async function getKeyWithRetry(
  contract: ethers.Contract,
  userIndex: string,
  userAddress: string,
  maxRetries = 5
): Promise<string> {
  for (let i = 0; i < maxRetries; i++) {
    try {
      const key = await contract.getEncryptionKey(userIndex, userAddress);
      if (key && key !== '0x' && key !== '0x0') {
        console.log(`✅ 키 조회 성공 (시도 ${i + 1}/${maxRetries})`);
        return key;
      }
    } catch (error) {
      console.log(`재시도 ${i + 1}/${maxRetries}...`);
    }
    await new Promise(resolve => setTimeout(resolve, 2000));
  }
  throw new Error('암호화 키 조회 실패 (최대 재시도 초과)');
}

// 사용
const key = await getKeyWithRetry(contract, userIndex, userWalletAddress);
```

---

## 📋 전체 통합 예제

```typescript
async function testEncryptionKeyFlow() {
  // 1. 로그인
  const {data: loginData} = await login({
    variables: {input: {email: "testuser@blockpick.com", password: "123456"}}
  });
  const {accessToken, user} = loginData.login;
  const userId = user.id;
  console.log('✅ Step 1: 로그인 성공');

  // 2. 게임 조회
  const {data: gameData} = await client.query({query: GAME_LIST});
  const game = gameData.gameList.games.find(g => g.onchainContractAddr);
  const gameId = game.id;
  const contractAddress = game.onchainContractAddr;
  console.log('✅ Step 2: 게임 조회 성공');

  // 3. userIndex 생성
  const userIndex = CryptoJS.SHA256(`${userId}${gameId}`).toString();
  console.log('✅ Step 3: userIndex 생성');

  // 4. 암호화 키 요청
  const {data: keyData} = await requestKey({
    variables: {
      input: {gameId, userAddress: userWalletAddress, index: userIndex}
    },
    context: {
      headers: {Authorization: `Bearer ${accessToken}`}
    }
  });

  if (!keyData.requestEncryptionKey.success) {
    throw new Error(keyData.requestEncryptionKey.message);
  }
  console.log('✅ Step 4: 암호화 키 요청 성공');

  // 5. 대기
  await new Promise(resolve => setTimeout(resolve, 3000));
  console.log('✅ Step 5: 3초 대기 완료');

  // 6. 스마트 컨트랙트에서 키 조회
  const provider = new ethers.BrowserProvider(window.ethereum);
  const contract = new ethers.Contract(
    contractAddress,
    ['function getEncryptionKey(string, address) view returns (string)'],
    provider
  );

  const encryptionKey = await getKeyWithRetry(
    contract,
    userIndex,
    userWalletAddress
  );

  console.log('✅ Step 6: 암호화 키 조회 성공!');
  console.log('🔑 Key:', encryptionKey);

  return encryptionKey;
}
```

---

## ⚠️ 중요 포인트

### 1. userIndex 생성 방식

```typescript
// ✅ 올바른 방법 (테스트 스크립트와 동일)
const userIndex = CryptoJS.SHA256(`${userId}${gameId}`).toString();

// ❌ 잘못된 방법 (timestamp 추가하면 안됨!)
const userIndex = CryptoJS.SHA256(`${userId}_${gameId}_${Date.now()}`).toString();
```

### 2. Authorization 헤더

```typescript
// ✅ 올바른 방법
context: {
  headers: {
    Authorization: `Bearer ${accessToken}`
  }
}
```

### 3. 대기 시간

- **최소 3초** 대기 필수
- 재시도 로직 사용 권장

---

## ✅ 체크리스트

- [ ] JWT 토큰 정상 획득
- [ ] 게임에 `onchainContractAddr` 존재 확인
- [ ] userIndex = SHA256(userId + gameId)
- [ ] Authorization 헤더 포함
- [ ] 3초 대기 후 키 조회
- [ ] MetaMask Polygon Amoy 네트워크 연결

---

## 📞 문의

- **GraphQL Playground**: http://localhost:8080/graphiql
- **테스트 스크립트**: `./scripts/test-encryption-key-full-flow.sh`
- **문의**: 백엔드 팀

---

**이 플로우대로 구현하면 테스트 스크립트와 100% 동일하게 작동합니다!** ✅

