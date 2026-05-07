# GraphQL 쿼리 예제 모음

> Blockpick 앱에서 자주 사용되는 GraphQL 쿼리/뮤테이션 예제

**최종 업데이트**: 2025-10-28

---

## 목차

1. [인증 관련](#인증-관련)
2. [사용자 정보 조회](#사용자-정보-조회)
3. [게임 조회](#게임-조회)
4. [게임 참여 및 결과](#게임-참여-및-결과)
5. [프로필 관리](#프로필-관리)
6. [실제 데이터 예시](#실제-데이터-예시)

---

## 인증 관련

### 1. 이메일 로그인

```graphql
mutation Login {
  login(input: {
    email: "user@example.com"
    password: "password123"
  }) {
    success
    code
    message
    accessToken
    refreshToken
    user {
      id
      email
      nickname
      avatar
      balance
      totalGamesPlayed
      totalWins
      winRate
    }
  }
}
```

**응답 예시**:
```json
{
  "data": {
    "login": {
      "success": true,
      "code": "SUCCESS",
      "message": "로그인에 성공했습니다.",
      "accessToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
      "refreshToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
      "user": {
        "id": "550e8400-e29b-41d4-a716-446655440000",
        "email": "user@example.com",
        "nickname": "플레이어123",
        "avatar": "https://example.com/avatar.jpg",
        "balance": 50000.0,
        "totalGamesPlayed": 15,
        "totalWins": 5,
        "winRate": 0.33
      }
    }
  }
}
```

---

### 2. 카카오 소셜 로그인

```graphql
mutation KakaoLogin {
  socialLogin(input: {
    provider: "KAKAO"
    socialId: "1234567890"
    email: "user@kakao.com"
    name: "홍길동"
    profileImageUrl: "https://k.kakaocdn.net/..."
  }) {
    success
    code
    message
    accessToken
    refreshToken
    user {
      id
      email
      nickname
      avatar
    }
  }
}
```

---

### 3. 회원가입

```graphql
mutation SignUp {
  signUp(input: {
    email: "newuser@example.com"
    password: "securePassword123!"
    nickname: "신규유저"
    profileImageUrl: "https://example.com/profile.jpg"
  }) {
    success
    code
    message
    user {
      id
      email
      nickname
      createdAt
    }
  }
}
```

---

### 4. 이메일 인증 코드 발송 (회원가입용)

```graphql
mutation SendVerificationCode {
  sendVerificationCode(
    email: "newuser@example.com"
    verifyType: SIGN_UP
  ) {
    success
    code
    message
  }
}
```

**응답 예시**:
```json
{
  "data": {
    "sendVerificationCode": {
      "success": true,
      "code": "SUCCESS",
      "message": "인증 코드가 이메일로 발송되었습니다."
    }
  }
}
```

---

### 5. 인증 코드 확인

```graphql
mutation VerifyCode {
  verifyCode(input: {
    email: "newuser@example.com"
    code: "123456"
    verifyType: SIGN_UP
  }) {
    success
    code
    message
  }
}
```

---

### 6. 토큰 갱신

```graphql
mutation RefreshToken {
  refreshToken(refreshToken: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...") {
    success
    code
    message
    accessToken
    refreshToken
    user {
      id
      email
    }
  }
}
```

---

### 7. 비밀번호 변경

```graphql
mutation ChangePassword {
  changePassword(input: {
    currentPassword: "oldPassword123"
    newPassword: "newSecurePassword456!"
  }) {
    success
    code
    message
  }
}
```

---

### 8. 비밀번호 재설정

```graphql
mutation ResetPassword {
  resetPassword(input: {
    email: "user@example.com"
    verificationCode: "654321"
    newPassword: "resetPassword789!"
  }) {
    success
    code
    message
  }
}
```

---

## 사용자 정보 조회

### 9. 내 정보 조회

```graphql
query Me {
  me {
    success
    code
    message
    user {
      id
      email
      nickname
      avatar
      createdAt
      updatedAt
      balance
      totalGamesPlayed
      totalWins
      winRate
    }
  }
}
```

**응답 예시**:
```json
{
  "data": {
    "me": {
      "success": true,
      "code": "SUCCESS",
      "message": "사용자 정보를 성공적으로 조회했습니다.",
      "user": {
        "id": "550e8400-e29b-41d4-a716-446655440000",
        "email": "user@example.com",
        "nickname": "플레이어123",
        "avatar": "https://example.com/avatar.jpg",
        "createdAt": "2025-01-15T10:30:00Z",
        "updatedAt": "2025-10-28T08:00:00Z",
        "balance": 75000.0,
        "totalGamesPlayed": 25,
        "totalWins": 8,
        "winRate": 0.32
      }
    }
  }
}
```

---

### 10. 특정 사용자 프로필 조회

```graphql
query GetUserProfile {
  getUserProfile(userId: "550e8400-e29b-41d4-a716-446655440000") {
    success
    code
    message
    user {
      id
      email
      nickname
      avatar
      totalGamesPlayed
      totalWins
      winRate
    }
  }
}
```

---

### 11. 프로필 업데이트

```graphql
mutation UpdateProfile {
  updateUserProfile(input: {
    nickname: "새로운닉네임"
    email: "newemail@example.com"
  }) {
    success
    code
    message
    user {
      id
      email
      nickname
      updatedAt
    }
  }
}
```

---

### 12. 회원 탈퇴

```graphql
mutation WithdrawUser {
  withdrawUser(input: {
    password: "userPassword123"
    reason: "더 이상 사용하지 않음"
  }) {
    success
    code
    message
  }
}
```

---

## 게임 조회

### 13. 모든 게임 목록 조회

```graphql
query GetGames {
  getGames {
    success
    code
    message
    games {
      id
      title
      description
      gameType
      status
      maxPlayers
      currentPlayers
      entryFee
      prizePool
      startTime
      endTime
      onchainTxHash
      onchainContractAddr
      createdAt
      gameProducts {
        id
        sequence
        isGrandPrize
        product {
          id
          name
          brand
          sku
          defaultImage
          price
          originalPrice
        }
      }
    }
  }
}
```

---

### 14. 특정 게임 상세 조회

```graphql
query GetGame {
  getGame(id: "01a18547-64cc-4e9e-9816-3161f0278018") {
    success
    code
    message
    game {
      id
      title
      description
      gameType
      status
      maxPlayers
      currentPlayers
      entryFee
      prizePool
      startTime
      endTime
      rules
      onchainTxHash
      onchainContractAddr
      gameProducts {
        id
        sequence
        active
        isGrandPrize
        product {
          id
          name
          brand
          description
          category
          sku
          defaultImage
          imageUrl
          thumbnailUrl
          price
          originalPrice
          countryCode
        }
      }
    }
  }
}
```

---

### 15. 진행중인 게임만 조회

```graphql
query GetActiveGames {
  getActiveGames {
    success
    code
    message
    games {
      id
      title
      status
      entryFee
      prizePool
      startTime
      endTime
      currentPlayers
      maxPlayers
      gameProducts {
        isGrandPrize
        product {
          name
          brand
          defaultImage
        }
      }
    }
  }
}
```

---

### 16. 페이지네이션을 사용한 게임 목록 조회

```graphql
query GameListPaginated {
  gameList(
    page: 0
    size: 10
    sortBy: "createdAt"
    sortDirection: "DESC"
  ) {
    success
    code
    message
    games {
      id
      title
      type
      category
      status
      entryFee
      currency
      minEntries
      maxEntries
      maxEntriesPerUser
      rewardPoint
      gridRows
      gridCols
      startTime
      endTime
      isRecommended
      gameProducts {
        id
        position
        sequence
        isGrandPrize
        product {
          id
          sku
          brand
          name
          defaultImage
        }
      }
    }
    pageInfo {
      currentPage
      pageSize
      totalPages
      totalElements
      hasNext
      hasPrevious
    }
  }
}
```

**⚠️ 주의**: 현재 `currentEntries` 필드를 포함하면 에러 발생

---

### 17. 필터링된 게임 조회 (진행중 + 추천)

```graphql
query FilteredGames {
  gameList(
    page: 0
    size: 20
    status: IN_PROGRESS
    isRecommended: true
    sortBy: "startTime"
    sortDirection: "ASC"
  ) {
    success
    message
    games {
      id
      title
      status
      isRecommended
      startTime
      endTime
      entryFee
    }
    pageInfo {
      totalElements
      hasNext
    }
  }
}
```

---

### 18. 카테고리별 게임 조회

```graphql
query GamesByCategory {
  gameList(
    page: 0
    size: 20
    category: "electronics"
    sortBy: "entryFee"
    sortDirection: "ASC"
  ) {
    success
    games {
      id
      title
      category
      entryFee
      gameProducts {
        product {
          name
          brand
          category
        }
      }
    }
    pageInfo {
      totalElements
    }
  }
}
```

---

## 게임 참여 및 결과

### 19. 게임 참여자 목록 조회

```graphql
query GetGameParticipants {
  getGameParticipants(
    gameId: "01a18547-64cc-4e9e-9816-3161f0278018"
    page: 0
    size: 20
  ) {
    success
    code
    message
    participants {
      id
      joinedAt
      status
      user {
        id
        email
        nickname
        avatar
        totalGamesPlayed
        totalWins
        winRate
      }
      game {
        id
        title
        status
      }
    }
    pageInfo {
      currentPage
      pageSize
      totalPages
      totalElements
      hasNext
      hasPrevious
    }
  }
}
```

**⚠️ 주의**: 현재 백엔드에서 null 반환 이슈

---

### 20. 게임 결과 조회

```graphql
query GetGameResults {
  getGameResults(
    gameId: "01a18547-64cc-4e9e-9816-3161f0278018"
    page: 0
    size: 20
  ) {
    success
    code
    message
    results {
      id
      score
      rank
      reward
      createdAt
      user {
        id
        nickname
        avatar
      }
      game {
        id
        title
      }
    }
    pageInfo {
      currentPage
      totalPages
      totalElements
    }
  }
}
```

**⚠️ 주의**: 현재 백엔드에서 null 반환 이슈

---

### 21. 사용자의 게임 참여 내역 조회

```graphql
query GetUserGames {
  getUserGames(userId: "550e8400-e29b-41d4-a716-446655440000") {
    success
    code
    message
    userGames {
      id
      joinedAt
      status
      user {
        id
        nickname
      }
      game {
        id
        title
        status
        entryFee
        startTime
        endTime
        gameProducts {
          product {
            name
            defaultImage
          }
        }
      }
    }
  }
}
```

---

## 프로필 관리

### 22. 최소 정보로 프로필 조회

```graphql
query MinimalProfile {
  me {
    success
    user {
      id
      nickname
      avatar
      balance
    }
  }
}
```

---

### 23. 게임 통계 포함 프로필 조회

```graphql
query ProfileWithStats {
  me {
    success
    user {
      id
      nickname
      avatar
      balance
      totalGamesPlayed
      totalWins
      winRate
    }
  }
}
```

---

## 실제 데이터 예시

### 24. 실제 서버의 게임 데이터 (2025-10-28 기준)

```graphql
query RealGameData {
  getGames {
    success
    code
    message
    games {
      id
      title
      description
      status
      entryFee
      startTime
      endTime
      onchainTxHash
      onchainContractAddr
      gameProducts {
        product {
          name
          brand
          sku
          defaultImage
        }
      }
    }
  }
}
```

**실제 응답 데이터**:
```json
{
  "data": {
    "getGames": {
      "success": true,
      "code": "SUCCESS",
      "message": "게임 목록을 성공적으로 조회했습니다.",
      "games": [
        {
          "id": "01a18547-64cc-4e9e-9816-3161f0278018",
          "title": "상품 픽 게임 #3 20251028_092611",
          "description": "1:1 상품 게임",
          "status": "IN_PROGRESS",
          "entryFee": 1000.0,
          "startTime": "2025-10-28T01:26:11Z",
          "endTime": "2025-10-30T00:26:11Z",
          "onchainTxHash": "0x16e084aa0597da7eb08cb7abbb3c4a96652470c298857bc1fb53b82e70cc0563",
          "onchainContractAddr": "0x63d469d778f46eaa870b3ea689ad980bac94c6ad",
          "gameProducts": [
            {
              "product": {
                "name": "iPad Pro 12.9\" (JPG)",
                "brand": "Apple",
                "sku": "IPAD-PRO-JPG-001",
                "defaultImage": "https://blockpick-dev-storage.s3.us-west-2.amazonaws.com/products/2025/10/27/8e758de6_iPad Pro_1500.jpg"
              }
            }
          ]
        },
        {
          "id": "3907f3f0-6a8f-4209-993b-56133138fbac",
          "title": "상품 픽 게임 #2 20251028_092609",
          "description": "1:1 상품 게임",
          "status": "IN_PROGRESS",
          "entryFee": 1000.0,
          "startTime": "2025-10-28T01:26:09Z",
          "endTime": "2025-10-30T00:26:09Z",
          "onchainTxHash": "0x6f365da9baee69ec1695d686ac38069e77512ff255156a6591db725e882d2fbc",
          "onchainContractAddr": "0x0281716790532a1aa3e692285a502b3e40cb7da7",
          "gameProducts": [
            {
              "product": {
                "name": "iPad Pro 12.9\" (PNG)",
                "brand": "Apple",
                "sku": "IPAD-PRO-PNG-001",
                "defaultImage": "https://blockpick-dev-storage.s3.us-west-2.amazonaws.com/products/2025/10/27/0bbfe087_iPad Pro_1500.png"
              }
            }
          ]
        },
        {
          "id": "6df030a4-e086-4cc8-a9f4-17c538ec9ba5",
          "title": "상품 픽 게임 #1 20251028_092606",
          "description": "1:1 상품 게임",
          "status": "IN_PROGRESS",
          "entryFee": 1000.0,
          "startTime": "2025-10-28T01:26:06Z",
          "endTime": "2025-10-30T00:26:06Z",
          "onchainTxHash": "0x9293899b2df2d708e9a2a07513bf34dc7d7dcb51e0c60c8aa4d627e159593b6b",
          "onchainContractAddr": "0x2f78ab6d5f84fbf594ea273e4cf4a00b4ad2033f",
          "gameProducts": [
            {
              "product": {
                "name": "iPad Pro 12.9\" (WEBP)",
                "brand": "Apple",
                "sku": "IPAD-PRO-WEBP-001",
                "defaultImage": "https://blockpick-dev-storage.s3.us-west-2.amazonaws.com/products/2025/10/27/001a7836_ipad Pro_1500.webp"
              }
            }
          ]
        }
      ]
    }
  }
}
```

---

## 복합 쿼리 예제

### 25. 게임 상세 + 상품 정보 전체 조회

```graphql
query FullGameDetails {
  getGame(id: "01a18547-64cc-4e9e-9816-3161f0278018") {
    success
    game {
      # 게임 기본 정보
      id
      title
      description
      status

      # 게임 설정
      gameType
      maxPlayers
      currentPlayers
      entryFee
      prizePool

      # 시간 정보
      startTime
      endTime
      createdAt
      updatedAt

      # 블록체인 정보
      onchainTxHash
      onchainContractAddr

      # 게임 규칙
      rules

      # 상품 정보
      gameProducts {
        id
        sequence
        active
        isGrandPrize

        product {
          id
          name
          description
          brand
          category
          sku

          # 이미지
          defaultImage
          imageUrl
          thumbnailUrl

          # 가격
          price
          originalPrice

          # 기타
          countryCode
          active
          createdAt
          updatedAt
        }
      }
    }
  }
}
```

---

### 26. 홈 화면용 데이터 조회

```graphql
query HomeScreenData {
  # 진행중인 게임
  activeGames: getActiveGames {
    success
    games {
      id
      title
      status
      entryFee
      startTime
      endTime
      gameProducts {
        isGrandPrize
        product {
          name
          brand
          defaultImage
        }
      }
    }
  }

  # 내 정보
  myProfile: me {
    success
    user {
      nickname
      avatar
      balance
      totalGamesPlayed
      totalWins
    }
  }
}
```

---

## 에러 처리 예제

### 27. 인증 실패 응답

```json
{
  "data": {
    "me": {
      "success": false,
      "code": "UNAUTHORIZED",
      "message": "인증되지 않은 사용자입니다.",
      "user": null
    }
  }
}
```

---

### 28. 유효하지 않은 입력 응답

```json
{
  "data": {
    "login": {
      "success": false,
      "code": "INVALID_CREDENTIALS",
      "message": "이메일 또는 비밀번호가 올바르지 않습니다.",
      "accessToken": null,
      "refreshToken": null,
      "user": null
    }
  }
}
```

---

### 29. GraphQL 에러 응답

```json
{
  "errors": [
    {
      "message": "The field at path '/gameList/games[0]/currentEntries' was declared as a non null type, but the code involved in retrieving data has wrongly returned a null value.",
      "path": ["gameList", "games", 0, "currentEntries"],
      "extensions": {
        "classification": "NullValueInNonNullableField"
      }
    }
  ],
  "data": null
}
```

---

## 유용한 팁

### Fragment 사용 예제

```graphql
fragment UserBasicInfo on User {
  id
  email
  nickname
  avatar
}

fragment GameBasicInfo on Game {
  id
  title
  status
  entryFee
  startTime
  endTime
}

query ProfileWithGames {
  me {
    success
    user {
      ...UserBasicInfo
      balance
      totalGamesPlayed
    }
  }

  getUserGames(userId: "user-id") {
    success
    userGames {
      game {
        ...GameBasicInfo
      }
    }
  }
}
```

---

### Variables 사용 예제

```graphql
query GetGameWithVariables($gameId: String!, $includeProducts: Boolean!) {
  getGame(id: $gameId) {
    success
    game {
      id
      title
      status
      entryFee
      gameProducts @include(if: $includeProducts) {
        product {
          name
          defaultImage
        }
      }
    }
  }
}
```

**Variables**:
```json
{
  "gameId": "01a18547-64cc-4e9e-9816-3161f0278018",
  "includeProducts": true
}
```

---

**문서 버전**: 1.0
**마지막 업데이트**: 2025-10-28
