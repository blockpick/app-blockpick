## **📋 개요**

사용자가 광고를 시청하고 **참여 포인트(Participation Point)**를 획득할 수 있는 시스템입니다.

✅ 날짜: 2026-01-22

---

## **🎯 지원하는 광고 컨텍스트 (4가지)**

| **컨텍스트** | **설명** | **보상 포인트** | **제한** |
| --- | --- | --- | --- |
| `ATTENDANCE_BOOST` | 출석 2배 보상 | 200pt (100+100) | 1일 1회 |
| `TX_WAIT_BOOST` | 트랜잭션 대기 중 고보상 | 100pt (50+50) | **무제한** |
| `POST_RESULT_BOOST` | 게임 결과 후 회복 보상 | 30pt | **무제한** |
| `HOME_DAILY` | 홈 화면 일일 보상 | 20pt | 1일 5회 |

---

## **🔄 광고 보상 플로우**

```
1. 사용자가 광고 버튼 클릭
   ↓
2. [앱] startAdRewardSession 호출 → 세션 시작
   ↓
3. [앱] 광고 SDK로 광고 표시
   ↓
4. [사용자] 광고 시청 완료
   ↓
5. [앱] completeAdRewardSession 호출 → 포인트 지급
   ↓
6. [서버] 참여 포인트 지급 완료

```

---

## **📡 GraphQL API**

### **1️⃣ 광고 세션 시작**

**Mutation: `startAdRewardSession`**

```graphql
mutation StartAdReward {
  startAdRewardSession(input: {
    contextType: ATTENDANCE_BOOST
    idempotencyKey: "user-12345-attendance-20260122"
    provider: "admob"
    adUnitId: "ca-app-pub-xxx"
  }) {
    rewardSessionId
    verificationToken
    rewardPreviewAmount
    expiresAt
    status
  }
}

```

**입력 파라미터:**

| **필드** | **타입** | **필수** | **설명** |
| --- | --- | --- | --- |
| `contextType` | Enum | ✅ | 광고 컨텍스트 타입 |
| `idempotencyKey` | String | ✅ | 중복 방지 키 (고유값) |
| `gameId` | String | ⬜ | 게임 ID (POST_RESULT_BOOST 시) |
| `entryId` | String | ⬜ | 엔트리 ID (TX_WAIT_BOOST 시) |
| `provider` | String | ⬜ | 광고 제공자 (예: admob, applovin) |
| `adUnitId` | String | ⬜ | 광고 유닛 ID |

**응답:**

```json
{
	"data":{
		"startAdRewardSession":{
		"rewardSessionId":"550e8400-e29b-41d4-a716-446655440000",
		"verificationToken":"dGVzdC10b2tlbi0xMjM0NQ==",
		"rewardPreviewAmount":200,
		"expiresAt":"2026-01-22T10:45:00",
		"status":"INITIATED"
		}
	}
}

```

**⚠️ 중요:**

- `rewardSessionId`와 `verificationToken`을 **반드시 저장**하세요
- 세션은 **10분 후 자동 만료**됩니다

---

### **2️⃣ 광고 시청 완료 및 보상 지급**

**Mutation: `completeAdRewardSession`**

```graphql
mutation CompleteAdReward {
  completeAdRewardSession(input: {
    rewardSessionId: "550e8400-e29b-41d4-a716-446655440000"
    idempotencyKey: "user-12345-attendance-20260122"
    verificationToken: "dGVzdC10b2tlbi0xMjM0NQ=="
    providerPayload: "{\"adNetworkId\":\"admob\",\"rewardItem\":\"coin\"}"
  }) {
    status
    grantedAmount
    reasonCode
    walletSnapshot {
      userId
      shoppingCash
      eventPoint
      participationPoint
    }
  }
}

```

**입력 파라미터:**

| **필드** | **타입** | **필수** | **설명** |
| --- | --- | --- | --- |
| `rewardSessionId` | String | ✅ | 세션 ID (start에서 받은 값) |
| `idempotencyKey` | String | ✅ | 중복 방지 키 (start와 동일) |
| `verificationToken` | String | ✅ | 검증 토큰 (start에서 받은 값) |
| `providerPayload` | String | ⬜ | 광고 제공자 응답 데이터 (JSON) |
| `providerRewardEventId` | String | ⬜ | 광고 제공자 이벤트 ID |

**성공 응답:**

```json
{
	"data":{
		"completeAdRewardSession":{
		"status":"GRANTED",
		"grantedAmount":200,
		"reasonCode":null,
			"walletSnapshot":{
			"userId":"user-uuid",
			"shoppingCash":1000,
			"eventPoint":500,
			"participationPoint":1200
			}
		}
	}
}

```

**실패 응답 (일일 제한 초과):**

```json
{
	"data":{
		"completeAdRewardSession":{
		"status":"REJECTED",
		"grantedAmount":0,
		"reasonCode":"LIMIT_DAILY",
		"walletSnapshot":null
		}
	}
}

```

---

### **3️⃣ 내 광고 보상 이력 조회**

**Query: `myAdRewardLedgers`**

```graphql
query MyAdRewardHistory {
  myAdRewardLedgers(page: { page: 0, size: 20 }) {
    content {
      id
      contextType
      rewardAmount
      status
      createdAt
      grantedAt
    }
    totalElements
    totalPages
    currentPage
  }
}

```

**응답:**

```json
{
	"data":{
		"myAdRewardLedgers":{
			"content":[
				{
					"id":"ledger-uuid",
					"contextType":"ATTENDANCE_BOOST",
					"rewardAmount":200,
					"status":"GRANTED",
					"createdAt":"2026-01-22T09:00:00",
					"grantedAt":"2026-01-22T09:00:15"
				}
			],
			"totalElements":15,
			"totalPages":1,
			"currentPage":0
		}
	}
}

```

---

### **4️⃣ 광고 보상 정책 조회**

**Query: `adRewardPolicy`**

```graphql
query GetAdPolicy {
  adRewardPolicy(contextType: ATTENDANCE_BOOST) {
    contextType
    enabled
    baseRewardAmount
    bonusRewardAmount
    dailyLimit
    cooldownSeconds
    perEntryLimit
    perGameLimit
  }
}

```

---

## **🔑 Idempotency Key 생성 규칙**

중복 요청을 방지하기 위한 고유 키입니다.

**권장 형식:**

```
"user-{userId}-{contextType}-{uniqueValue}"
```

**예시:**

| **컨텍스트** | **Idempotency Key 예시** |
| --- | --- |
| 출석 2배 | `user-12345-attendance-20260122` |
| TX 대기 | `user-12345-txwait-entryId-abc123` |
| 게임 결과 후 | `user-12345-postresult-gameId-xyz789` |
| 홈 일일 | `user-12345-home-20260122-001` |

**⚠️ 중요:**

- `start`와 `complete` 호출 시 **동일한 키** 사용
- 유니크해야 함 (같은 키로 재요청 시 기존 세션 반환)

---

## **🎨 UI/UX 구현 가이드**

### **1. 출석 2배 보상 (ATTENDANCE_BOOST)**

**화면:** 출석 체크 화면

```tsx
// 예시 코드 (TypeScript)
asyncfunction onAttendanceAdClick(){
const userId= getCurrentUserId();
const today=new Date().toISOString().split('T')[0].replace(/-/g,'');
const idempotencyKey=`user-${userId}-attendance-${today}`;

try{
// 1. 세션 시작
const session=await startAdRewardSession({
      contextType:'ATTENDANCE_BOOST',
      idempotencyKey,
      provider:'admob',
      adUnitId:'ca-app-pub-xxx'
});

// 2. 광고 표시
await showRewardedAd({
      onAdCompleted: async(providerPayload)=>{
// 3. 보상 지급
const result=await completeAdRewardSession({
          rewardSessionId: session.rewardSessionId,
          idempotencyKey,
          verificationToken: session.verificationToken,
          providerPayload: JSON.stringify(providerPayload)
});

if(result.status==='GRANTED'){
          showToast(`${result.grantedAmount}P 지급되었습니다!`);
}
},
      onAdFailed:(error)=>{
        showToast('광고를 불러올 수 없습니다.');
}
});

}catch(error){
if(error.message.includes('Daily limit exceeded')){
      showToast('오늘은 이미 출석 2배 보상을 받으셨습니다.');
}
}
}

```

---

### **2. TX 대기 고보상 (TX_WAIT_BOOST)**

**화면:** 게임 참여 후 트랜잭션 대기 화면

**참여 제한:** 무제한 (이벤트 포인트를 소모하여 참여하므로 제한 없음)

```tsx
asyncfunction onTransactionWaitingAd(entryId: string){
const userId= getCurrentUserId();
const timestamp= Date.now();// 무제한이므로 timestamp 사용
const idempotencyKey=`user-${userId}-txwait-${entryId}-${timestamp}`;

try{
const session=await startAdRewardSession({
      contextType:'TX_WAIT_BOOST',
      idempotencyKey,
      entryId,
      provider:'admob'
});

await showRewardedAd({
      onAdCompleted: async(providerPayload)=>{
const result=await completeAdRewardSession({
          rewardSessionId: session.rewardSessionId,
          idempotencyKey,
          verificationToken: session.verificationToken,
          providerPayload: JSON.stringify(providerPayload)
});

if(result.status==='GRANTED'){
          showToast(`${result.grantedAmount}P 지급! 🎉`);
}
}
});

}catch(error){
    handleAdError(error);
}
}

```

---

### **3. 게임 결과 후 회복 보상 (POST_RESULT_BOOST)**

**화면:** 게임 결과 확인 화면

**참여 제한:** 무제한 (이벤트 포인트를 소모하여 참여하므로 제한 없음)

```tsx
asyncfunction onGameResultAdClick(gameId: string){
const userId= getCurrentUserId();
const timestamp= Date.now();// 무제한이므로 timestamp 사용
const idempotencyKey=`user-${userId}-postresult-${gameId}-${timestamp}`;

const session=await startAdRewardSession({
    contextType:'POST_RESULT_BOOST',
    idempotencyKey,
    gameId
});

// 광고 표시 및 완료 처리
// ...
}

```

---

### **4. 홈 일일 보상 (HOME_DAILY)**

**화면:** 홈 화면

```tsx
asyncfunction onHomeDailyAdClick(){
const userId= getCurrentUserId();
const timestamp= Date.now();
const idempotencyKey=`user-${userId}-home-${timestamp}`;

const session=await startAdRewardSession({
    contextType:'HOME_DAILY',
    idempotencyKey
});

// 광고 표시 및 완료 처리
// ...
}

```

---

## **⚠️ 에러 처리**

### **Status 종류**

| **Status** | **의미** | **처리 방법** |
| --- | --- | --- |
| `INITIATED` | 세션 시작됨 | 광고 표시 진행 |
| `GRANTED` | 지급 완료 | 성공 메시지 표시 |
| `REJECTED` | 거절됨 | reasonCode 확인 후 메시지 표시 |
| `EXPIRED` | 만료됨 | "시간이 초과되었습니다" 표시 |

### **Reason Code**

| **Code** | **의미** | **사용자 메시지** |
| --- | --- | --- |
| `LIMIT_DAILY` | 일일 제한 초과 | "오늘은 이미 보상을 받으셨습니다" |
| `LIMIT_ENTRY` | 엔트리당 제한 초과 | "이 참여건에 대해 이미 보상을 받으셨습니다" |
| `LIMIT_GAME` | 게임당 제한 초과 | "이 게임에서 이미 보상을 받으셨습니다" |
| `LIMIT_COOLDOWN` | 쿨다운 미충족 | "잠시 후 다시 시도해주세요" |
| `TOKEN_INVALID` | 검증 토큰 불일치 | "오류가 발생했습니다. 다시 시도해주세요" |
| `SESSION_EXPIRED` | 세션 만료 | "시간이 초과되었습니다. 다시 시도해주세요" |

---

## **🧪 테스트 방법**

### **1. GraphQL Playground에서 테스트**

```bash
# 로컬 환경
http://localhost:8080/graphiql

# 개발 환경
https://api-dev.blockpick.net/graphiql

```

### **2. 테스트 시나리오**

**시나리오 1: 출석 2배 보상 (정상)**

```graphql
# 1. 세션 시작
mutation {
  startAdRewardSession(input: {
    contextType: ATTENDANCE_BOOST
    idempotencyKey: "test-user-attendance-20260122"
  }) {
    rewardSessionId
    verificationToken
    rewardPreviewAmount
  }
}

# 2. 보상 지급
mutation {
  completeAdRewardSession(input: {
    rewardSessionId: "위에서 받은 ID"
    idempotencyKey: "test-user-attendance-20260122"
    verificationToken: "위에서 받은 토큰"
  }) {
    status
    grantedAmount
  }
}

```

**시나리오 2: 일일 제한 테스트**

```graphql
# 같은 idempotencyKey로 다시 start 호출
# → 기존 세션 반환됨

# 다른 idempotencyKey로 start 호출
# → "Daily limit exceeded" 에러 발생

```

---

## **📊 모니터링 & 디버깅**

### **내 보상 이력 확인**

```graphql
query {
  myAdRewardLedgers(page: { page: 0, size: 10 }) {
    content {
      contextType
      status
      reasonCode
      rewardAmount
      createdAt
    }
  }
}

```

### **정책 확인**

```graphql
query {
  adRewardPolicy(contextType: ATTENDANCE_BOOST) {
    enabled
    baseRewardAmount
    bonusRewardAmount
    dailyLimit
  }
}

```

---

## **🔐 보안 주의사항**

1. ✅ **Idempotency Key는 클라이언트에서 생성**
    - 고유해야 함
    - 예측 가능하지 않게 (timestamp 포함 권장)
2. ✅ **Verification Token은 서버에서 생성**
    - `start` 응답으로 받음
    - `complete` 호출 시 반드시 전달
3. ✅ **중복 지급 방지**
    - 같은 `idempotencyKey`로 재요청 시 기존 세션 반환
    - DB UNIQUE 제약으로 완전 차단
4. ✅ **세션 만료**
    - 10분 후 자동 만료
    - 만료된 세션으로 `complete` 호출 시 `EXPIRED` 반환

---

## **🎉 요약**

1. ✅ **세션 시작** → `startAdRewardSession`
2. ✅ **광고 표시** → 광고 SDK
3. ✅ **보상 지급** → `completeAdRewardSession`
4. ✅ **이력 조회** → `myAdRewardLedgers`

**중요:** Idempotency Key는 고유하게, Verification Token은 서버에서 받은 값을 그대로 사용하세요!

---
