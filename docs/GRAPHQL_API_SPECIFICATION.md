# GraphQL API 명세서

> Blockpick 앱의 GraphQL API 완전 명세

**최종 업데이트**: 2025-10-28
**API 엔드포인트**: (설정된 GraphQL 엔드포인트)
**스키마 버전**: v1.0

---

## 목차

1. [개요](#개요)
2. [인증](#인증)
3. [쿼리 (Queries)](#쿼리-queries)
4. [뮤테이션 (Mutations)](#뮤테이션-mutations)
5. [타입 정의](#타입-정의)
6. [Enum 타입](#enum-타입)
7. [현재 이슈](#현재-이슈)

---

## 개요

Blockpick의 GraphQL API는 다음 기능을 제공합니다:

- 사용자 인증 및 관리
- 게임 조회 및 관리
- 게임 참여 및 결과 확인
- 상품 정보 조회
- 블록체인 연동 정보

---

## 인증

대부분의 API는 JWT 토큰 기반 인증을 사용합니다.

### 인증 헤더
```
Authorization: Bearer <access_token>
```

### 토큰 갱신
`refreshToken` mutation을 사용하여 만료된 액세스 토큰을 갱신할 수 있습니다.

---

## 쿼리 (Queries)

### 사용자 관련

#### me
현재 로그인한 사용자 정보를 조회합니다.

```graphql
query {
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

**인증 필요**: ✅ Yes

**응답 타입**: `UserResponse`

**응답 예시**:
```json
{
  "data": {
    "me": {
      "success": true,
      "code": "SUCCESS",
      "message": "사용자 정보를 성공적으로 조회했습니다.",
      "user": {
        "id": "user-uuid",
        "email": "user@example.com",
        "nickname": "닉네임",
        "avatar": "https://...",
        "balance": 50000.0,
        "totalGamesPlayed": 10,
        "totalWins": 3,
        "winRate": 0.3
      }
    }
  }
}
```

---

#### getUserProfile
특정 사용자의 프로필을 조회합니다.

```graphql
query {
  getUserProfile(userId: "user-uuid") {
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

**파라미터**:
- `userId` (String!, required): 조회할 사용자 ID

**인증 필요**: ✅ Yes

**응답 타입**: `UserResponse`

---

### 게임 관련

#### getGames
모든 게임 목록을 조회합니다.

```graphql
query {
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
        }
      }
    }
  }
}
```

**인증 필요**: ❌ No

**응답 타입**: `GamesResponse`

**응답 예시**:
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
          "title": "상품 픽 게임 #3",
          "status": "IN_PROGRESS",
          "entryFee": 1000.0,
          "startTime": "2025-10-28T01:26:11Z",
          "endTime": "2025-10-30T00:26:11Z",
          "onchainTxHash": "0x16e084aa...",
          "onchainContractAddr": "0x63d469d7...",
          "gameProducts": [...]
        }
      ]
    }
  }
}
```

---

#### getGame
특정 게임의 상세 정보를 조회합니다.

```graphql
query {
  getGame(id: "game-uuid") {
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
          defaultImage
          price
          originalPrice
        }
      }
    }
  }
}
```

**파라미터**:
- `id` (String!, required): 게임 ID

**인증 필요**: ❌ No

**응답 타입**: `GameResponse`

---

#### getActiveGames
현재 진행 중인 게임 목록을 조회합니다.

```graphql
query {
  getActiveGames {
    success
    code
    message
    games {
      id
      title
      status
      entryFee
      startTime
      endTime
      currentPlayers
      maxPlayers
      gameProducts {
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

**인증 필요**: ❌ No

**응답 타입**: `GamesResponse`

---

#### gameList
페이지네이션 및 필터링을 지원하는 게임 목록 조회

```graphql
query {
  gameList(
    page: 0
    size: 20
    status: IN_PROGRESS
    type: "DAILY"
    category: "electronics"
    isRecommended: true
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
      currentEntries
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

**파라미터**:
- `page` (Int, default: 0): 페이지 번호 (0부터 시작)
- `size` (Int, default: 20): 페이지 크기
- `status` (GameStatus): 게임 상태 필터
- `type` (String): 게임 타입 필터
- `category` (String): 카테고리 필터
- `isRecommended` (Boolean): 추천 게임 필터
- `sortBy` (String, default: "createdAt"): 정렬 기준
- `sortDirection` (String, default: "DESC"): 정렬 방향

**인증 필요**: ❌ No

**응답 타입**: `GameListResponse`

**⚠️ 현재 이슈**: `currentEntries` 필드가 null을 반환하여 에러 발생

---

#### getGameParticipants
특정 게임의 참여자 목록을 조회합니다.

```graphql
query {
  getGameParticipants(gameId: "game-uuid", page: 0, size: 20) {
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

**파라미터**:
- `gameId` (String!, required): 게임 ID
- `page` (Int, default: 0): 페이지 번호
- `size` (Int, default: 20): 페이지 크기

**인증 필요**: ✅ Yes

**응답 타입**: `GameParticipantsResponse`

**⚠️ 현재 이슈**: 백엔드에서 null 반환

---

#### getGameResults
특정 게임의 결과 목록을 조회합니다.

```graphql
query {
  getGameResults(gameId: "game-uuid", page: 0, size: 20) {
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
      pageSize
      totalPages
      totalElements
      hasNext
      hasPrevious
    }
  }
}
```

**파라미터**:
- `gameId` (String!, required): 게임 ID
- `page` (Int, default: 0): 페이지 번호
- `size` (Int, default: 20): 페이지 크기

**인증 필요**: ✅ Yes

**응답 타입**: `GameResultsResponse`

**⚠️ 현재 이슈**: 백엔드에서 null 반환

---

#### getUserGames
특정 사용자의 게임 참여 내역을 조회합니다.

```graphql
query {
  getUserGames(userId: "user-uuid") {
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
      }
    }
  }
}
```

**파라미터**:
- `userId` (String!, required): 사용자 ID

**인증 필요**: ✅ Yes

**응답 타입**: `UserGamesResponse`

---

## 뮤테이션 (Mutations)

### 인증 관련

#### login
이메일/비밀번호로 로그인합니다.

```graphql
mutation {
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
    }
  }
}
```

**입력 타입**: `LoginRequest`
```graphql
input LoginRequest {
  email: String!
  password: String!
}
```

**응답 타입**: `LoginResponse`

**응답 예시**:
```json
{
  "data": {
    "login": {
      "success": true,
      "code": "SUCCESS",
      "message": "로그인에 성공했습니다.",
      "accessToken": "eyJhbGciOiJIUzI1NiIs...",
      "refreshToken": "eyJhbGciOiJIUzI1NiIs...",
      "user": {
        "id": "user-uuid",
        "email": "user@example.com",
        "nickname": "닉네임"
      }
    }
  }
}
```

---

#### socialLogin
소셜 로그인을 수행합니다.

```graphql
mutation {
  socialLogin(input: {
    provider: "KAKAO"
    socialId: "kakao-user-id"
    email: "user@kakao.com"
    name: "홍길동"
    profileImageUrl: "https://..."
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
    }
  }
}
```

**입력 타입**: `SocialLoginRequest`
```graphql
input SocialLoginRequest {
  provider: String!          # "KAKAO", "NAVER", "GOOGLE", "FACEBOOK"
  socialId: String!
  email: String!
  name: String
  profileImageUrl: String
}
```

**응답 타입**: `LoginResponse`

---

#### signUp
회원가입을 수행합니다.

```graphql
mutation {
  signUp(input: {
    email: "newuser@example.com"
    password: "password123"
    nickname: "새유저"
    profileImageUrl: "https://..."
  }) {
    success
    code
    message
    user {
      id
      email
      nickname
    }
  }
}
```

**입력 타입**: `SignUpRequest`
```graphql
input SignUpRequest {
  email: String!
  password: String
  nickname: String
  profileImageUrl: String
  # 소셜 로그인용 (선택적)
  socialProvider: SocialProvider
  socialId: String
  socialEmail: String
  socialName: String
}
```

**응답 타입**: `SignUpResponse`

---

#### sendVerificationCode
이메일 인증 코드를 발송합니다.

```graphql
mutation {
  sendVerificationCode(
    email: "user@example.com"
    verifyType: SIGN_UP
  ) {
    success
    code
    message
  }
}
```

**파라미터**:
- `email` (String!, required): 이메일 주소
- `verifyType` (VerifyType!, required): 인증 타입
  - `SIGN_UP`: 회원가입
  - `CHANGE_PASSWORD`: 비밀번호 변경
  - `WITHDRAW`: 회원탈퇴

**응답 타입**: `CommonResponse`

---

#### verifyCode
인증 코드를 검증합니다.

```graphql
mutation {
  verifyCode(input: {
    email: "user@example.com"
    code: "123456"
    verifyType: SIGN_UP
  }) {
    success
    code
    message
  }
}
```

**입력 타입**: `VerifyCodeRequest`
```graphql
input VerifyCodeRequest {
  email: String!
  code: String!
  verifyType: VerifyType!
}
```

**응답 타입**: `VerifyCodeResponse`

---

#### refreshToken
액세스 토큰을 갱신합니다.

```graphql
mutation {
  refreshToken(refreshToken: "refresh-token-here") {
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

**파라미터**:
- `refreshToken` (String!, required): 리프레시 토큰

**응답 타입**: `LoginResponse`

---

#### changePassword
비밀번호를 변경합니다.

```graphql
mutation {
  changePassword(input: {
    currentPassword: "oldPassword123"
    newPassword: "newPassword456"
  }) {
    success
    code
    message
  }
}
```

**입력 타입**: `ChangePasswordRequest`
```graphql
input ChangePasswordRequest {
  currentPassword: String!
  newPassword: String!
}
```

**인증 필요**: ✅ Yes

**응답 타입**: `CommonResponse`

---

#### resetPassword
비밀번호를 재설정합니다.

```graphql
mutation {
  resetPassword(input: {
    email: "user@example.com"
    verificationCode: "123456"
    newPassword: "newPassword123"
  }) {
    success
    code
    message
  }
}
```

**입력 타입**: `ResetPasswordRequest`
```graphql
input ResetPasswordRequest {
  email: String!
  verificationCode: String!
  newPassword: String!
}
```

**응답 타입**: `CommonResponse`

---

#### withdrawUser
회원 탈퇴를 수행합니다.

```graphql
mutation {
  withdrawUser(input: {
    password: "userPassword123"
    reason: "서비스가 만족스럽지 않음"
  }) {
    success
    code
    message
  }
}
```

**입력 타입**: `WithdrawUserRequest`
```graphql
input WithdrawUserRequest {
  password: String!
  reason: String
}
```

**인증 필요**: ✅ Yes

**응답 타입**: `CommonResponse`

---

#### updateUserProfile
사용자 프로필을 업데이트합니다.

```graphql
mutation {
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
      avatar
    }
  }
}
```

**입력 타입**: `UserProfileInput`
```graphql
input UserProfileInput {
  nickname: String
  email: String
}
```

**인증 필요**: ✅ Yes

**응답 타입**: `UserProfileUpdateResult`

---

## 타입 정의

### User
사용자 정보

```graphql
type User {
  id: String!
  email: String!
  nickname: String
  avatar: String
  createdAt: String!
  updatedAt: String
  balance: Float              # 보유 잔액
  totalGamesPlayed: Int       # 총 플레이 게임 수
  totalWins: Int              # 총 승리 수
  winRate: Float              # 승률 (0.0 ~ 1.0)
}
```

---

### Game
게임 정보

```graphql
type Game {
  id: String!
  title: String!
  description: String
  gameType: GameType          # DAILY, SELECT, VIBE
  status: GameStatus!         # SCHEDULED, IN_PROGRESS, PAUSED, SETTLING, ENDED, FAILED
  maxPlayers: Int
  currentPlayers: Int
  entryFee: Float             # 참가비
  prizePool: Float            # 상금 풀
  startTime: String           # ISO 8601 포맷
  endTime: String             # ISO 8601 포맷
  rules: String
  onchainTxHash: String       # 블록체인 트랜잭션 해시
  onchainContractAddr: String # 블록체인 컨트랙트 주소
  createdAt: String!
  updatedAt: String
  gameProducts: [GameProduct!]!
}
```

---

### GameItem
게임 목록용 아이템 (gameList 쿼리에서 사용)

```graphql
type GameItem {
  id: String!
  title: String!
  description: String
  type: String!
  category: String!
  status: String!
  entryFee: Int!
  currency: String!
  minEntries: Int!
  maxEntries: Int!
  currentEntries: Int!        # ⚠️ 백엔드에서 null 반환 이슈
  maxEntriesPerUser: Int!
  rewardPoint: Int!
  gridRows: Int!              # 그리드 행 수
  gridCols: Int!              # 그리드 열 수
  startTime: String!
  endTime: String!
  isRecommended: Boolean!
  onchainTxHash: String
  onchainContractAddr: String
  createdAt: String!
  gameProducts: [GameProductItem!]
}
```

---

### GameProduct
게임에 포함된 상품 정보

```graphql
type GameProduct {
  id: String!
  sequence: Int!              # 상품 순서
  active: Boolean!
  isGrandPrize: Boolean!      # 대상 상품 여부
  product: Product!
  createdAt: String!
  updatedAt: String!
}
```

---

### GameProductItem
게임 목록용 상품 정보

```graphql
type GameProductItem {
  id: String!
  position: Int               # 그리드 위치
  sequence: Int
  isGrandPrize: Boolean!
  product: ProductItem!
}
```

---

### Product
상품 정보

```graphql
type Product {
  id: String!
  name: String!
  description: String
  brand: String
  category: String
  sku: String                 # 상품 코드
  defaultImage: String
  imageUrl: String
  thumbnailUrl: String
  price: Int
  originalPrice: Int
  countryCode: String
  active: Boolean
  createdAt: String!
  updatedAt: String!
}
```

---

### ProductItem
간소화된 상품 정보

```graphql
type ProductItem {
  id: String!
  sku: String!
  brand: String!
  name: String!
  description: String
  defaultImage: String
}
```

---

### UserGame
사용자-게임 참여 정보

```graphql
type UserGame {
  id: String!
  user: User!
  game: Game!
  joinedAt: String!           # ISO 8601 포맷
  status: UserGameStatus!     # JOINED, PLAYING, COMPLETED, WITHDRAWN
}
```

---

### GameResult
게임 결과 정보

```graphql
type GameResult {
  id: String!
  game: Game!
  user: User!
  score: Int
  rank: Int                   # 순위
  reward: Float               # 보상 금액
  createdAt: String!
}
```

---

### PaginationInfo
페이지네이션 정보

```graphql
type PaginationInfo {
  currentPage: Int!           # 현재 페이지 (0부터 시작)
  pageSize: Int!              # 페이지 크기
  totalPages: Int!            # 총 페이지 수
  totalElements: Int!         # 총 요소 수
  hasNext: Boolean!           # 다음 페이지 존재 여부
  hasPrevious: Boolean!       # 이전 페이지 존재 여부
}
```

---

## Enum 타입

### GameType
게임 타입

```graphql
enum GameType {
  DAILY    # 데일리 게임
  SELECT   # 셀렉트 게임
  VIBE     # 바이브 게임
}
```

---

### GameStatus
게임 상태

```graphql
enum GameStatus {
  SCHEDULED    # 예정됨
  IN_PROGRESS  # 진행중
  PAUSED       # 일시정지
  SETTLING     # 정산중
  ENDED        # 종료됨
  FAILED       # 실패
}
```

---

### UserGameStatus
사용자-게임 참여 상태

```graphql
enum UserGameStatus {
  JOINED      # 참여함
  PLAYING     # 플레이중
  COMPLETED   # 완료
  WITHDRAWN   # 철회
}
```

---

### SocialProvider
소셜 로그인 제공자

```graphql
enum SocialProvider {
  KAKAO
  NAVER
  GOOGLE
  FACEBOOK
}
```

---

### VerifyType
인증 타입

```graphql
enum VerifyType {
  SIGN_UP           # 회원가입
  CHANGE_PASSWORD   # 비밀번호 변경
  WITHDRAW          # 회원탈퇴
}
```

---

## 현재 이슈

### 1. gameList 쿼리 - currentEntries 필드
**상태**: 🔴 에러 발생

**문제**: `currentEntries` 필드가 non-nullable로 정의되어 있으나 백엔드에서 null 반환

**에러 메시지**:
```
The field at path '/gameList/games[0]/currentEntries' was declared as a non null type,
but the code involved in retrieving data has wrongly returned a null value.
```

**영향**: gameList 쿼리 전체가 실패

**해결 방법**:
- 백엔드에서 currentEntries 값을 0 또는 실제 값으로 설정
- 또는 스키마에서 `currentEntries: Int` (nullable)로 변경

---

### 2. getGameParticipants 쿼리
**상태**: 🔴 에러 발생

**문제**: 전체 응답이 null 반환

**에러 메시지**:
```
The field at path '/getGameParticipants' was declared as a non null type,
but the code involved in retrieving data has wrongly returned a null value.
```

**영향**: 게임 참여자 목록 조회 불가

**해결 방법**: 백엔드에서 적절한 응답 객체 반환 구현 필요

---

### 3. getGameResults 쿼리
**상태**: 🔴 에러 발생

**문제**: 전체 응답이 null 반환

**에러 메시지**:
```
The field at path '/getGameResults' was declared as a non null type,
but the code involved in retrieving data has wrongly returned a null value.
```

**영향**: 게임 결과 조회 불가

**해결 방법**: 백엔드에서 적절한 응답 객체 반환 구현 필요

---

## 참고 사항

### 날짜/시간 포맷
모든 날짜와 시간은 **ISO 8601** 포맷을 사용합니다.

예시: `2025-10-28T01:26:11Z`

### 에러 처리
모든 응답은 다음 구조를 포함합니다:
```json
{
  "success": true/false,
  "code": "SUCCESS" | "ERROR_CODE",
  "message": "사용자 친화적인 메시지"
}
```

### 블록체인 연동
- `onchainTxHash`: 트랜잭션 해시 (0x로 시작하는 66자 문자열)
- `onchainContractAddr`: 컨트랙트 주소 (0x로 시작하는 42자 문자열)

---

**문서 버전**: 1.0
**마지막 검증**: 2025-10-28
