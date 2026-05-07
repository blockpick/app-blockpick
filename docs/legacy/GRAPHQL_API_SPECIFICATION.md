# GraphQL API 명세서

> Blockpick 앱의 GraphQL API 완전 명세

**최종 업데이트**: 2026-01-12
**API 엔드포인트**: (설정된 GraphQL 엔드포인트)
**스키마 버전**: v2.0

---

## 목차

1. [개요](#개요)
2. [인증](#인증)
3. [쿼리 (Queries)](#쿼리-queries)
   - [사용자 관련](#사용자-관련)
   - [게임 관련](#게임-관련)
   - [게임 참여 상태](#게임-참여-상태)
   - [암호화 키 상태](#암호화-키-상태)
4. [뮤테이션 (Mutations)](#뮤테이션-mutations)
   - [인증 관련](#인증-관련)
   - [SMS 인증](#sms-인증)
   - [사용자 프로필](#사용자-프로필)
   - [게임 참여](#게임-참여)
   - [암호화 키](#암호화-키)
5. [타입 정의](#타입-정의)
6. [Enum 타입](#enum-타입)

---

## 개요

Blockpick의 GraphQL API는 다음 기능을 제공합니다:

- 사용자 인증 및 관리
- SMS 인증
- 게임 조회 및 관리
- 게임 참여 및 결과 확인
- 상품 정보 조회
- 블록체인 암호화 키 관리
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
      phoneNumber
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
      phoneNumber
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

#### checkPhoneNumber
전화번호 가입 여부를 확인합니다.

```graphql
query {
  checkPhoneNumber(input: {
    phoneNumber: "01012345678"
  }) {
    success
    code
    message
    exists
  }
}
```

**입력 타입**: `CheckPhoneNumberRequest`
```graphql
input CheckPhoneNumberRequest {
  phoneNumber: String!
}
```

**인증 필요**: ❌ No

**응답 타입**: `CheckPhoneNumberResponse`

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
      mainProductName
      type
      gameType
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
      visibleFrom
      startTime
      endTime
      allowDuplicate
      enableNotification
      isRecommended
      customRules
      autoEndOnMax
      autoEndOnTime
      onchainTxHash
      onchainContractAddr
      createdAt
      updatedAt
      gameProducts {
        id
        sequence
        active
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
      mainProductName
      type
      gameType
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
      visibleFrom
      startTime
      endTime
      allowDuplicate
      enableNotification
      isRecommended
      customRules
      autoEndOnMax
      autoEndOnTime
      onchainTxHash
      onchainContractAddr
      createdAt
      updatedAt
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
      description
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
      onchainTxHash
      onchainContractAddr
      createdAt
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
          description
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

### 게임 참여 상태

#### entryStatus
게임 참여 상태를 조회합니다 (폴링용).

```graphql
query {
  entryStatus(entryId: "entry-uuid") {
    success
    entryId
    status
    txIntents {
      intentId
      status
      txHash
      errorCode
      errorMessage
      createdAt
      updatedAt
    }
    errorMessage
  }
}
```

**파라미터**:
- `entryId` (String!, required): 참여 엔트리 ID

**인증 필요**: ✅ Yes

**응답 타입**: `EntryStatusResponse`

---

### 암호화 키 상태

#### encryptionKeyStatus
암호화 키 요청 상태를 조회합니다 (폴링용).

```graphql
query {
  encryptionKeyStatus(requestId: "request-uuid") {
    success
    requestId
    status
    txHash
    errorCode
    errorMessage
  }
}
```

**파라미터**:
- `requestId` (String!, required): 암호화 키 요청 ID

**인증 필요**: ✅ Yes

**응답 타입**: `EncryptionKeyStatusResponse`

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
      phoneNumber
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
    phoneNumber: "01012345678"
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
      phoneNumber
    }
  }
}
```

**입력 타입**: `SignUpRequest`
```graphql
input SignUpRequest {
  email: String!
  password: String
  phoneNumber: String
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

### SMS 인증

#### sendSmsVerificationCode
SMS 인증 코드를 발송합니다.

```graphql
mutation {
  sendSmsVerificationCode(input: {
    phoneNumber: "01012345678"
    verifyType: SIGN_UP
  }) {
    success
    code
    message
  }
}
```

**입력 타입**: `SendSmsVerificationRequest`
```graphql
input SendSmsVerificationRequest {
  phoneNumber: String!
  verifyType: SmsVerifyType!
}
```

**인증 필요**: ❌ No

**응답 타입**: `CommonResponse`

---

#### verifySmsCode
SMS 인증 코드를 검증합니다.

```graphql
mutation {
  verifySmsCode(input: {
    phoneNumber: "01012345678"
    code: "123456"
    verifyType: SIGN_UP
  }) {
    success
    message
  }
}
```

**입력 타입**: `VerifySmsCodeRequest`
```graphql
input VerifySmsCodeRequest {
  phoneNumber: String!
  code: String!
  verifyType: SmsVerifyType!
}
```

**인증 필요**: ❌ No

**응답 타입**: `VerifySmsCodeResponse`

---

#### findEmail
전화번호로 이메일을 찾습니다 (SMS 인증 완료 후).

```graphql
mutation {
  findEmail(input: {
    phoneNumber: "01012345678"
  }) {
    success
    code
    message
    email
  }
}
```

**입력 타입**: `FindEmailRequest`
```graphql
input FindEmailRequest {
  phoneNumber: String!
}
```

**인증 필요**: ❌ No (SMS 인증 완료 필요)

**응답 타입**: `FindEmailResponse`

---

### 사용자 프로필

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

### 게임 참여

#### joinGame
게임에 참여합니다.

```graphql
mutation {
  joinGame(input: {
    gameId: "game-uuid"
    selectedGameProductId: "product-uuid"
    coordCiphertext: "encrypted-coordinates"
    idempotencyKey: "unique-key"
    signerWallet: "0x..."
    contractAddress: "0x..."
    userIndex: "0"
  }) {
    success
    code
    message
    entryId
    status
    txHash
    errorCode
  }
}
```

**입력 타입**: `JoinGameInput`
```graphql
input JoinGameInput {
  gameId: String!
  selectedGameProductId: String!
  coordCiphertext: String           # 암호화된 좌표 데이터
  idempotencyKey: String            # 중복 요청 방지 키
  signerWallet: String              # 서명 지갑 주소
  contractAddress: String           # 컨트랙트 주소
  userIndex: String                 # 사용자 인덱스
}
```

**인증 필요**: ✅ Yes

**응답 타입**: `JoinGameResponse`

---

#### cancelEntry
게임 참여를 취소합니다.

```graphql
mutation {
  cancelEntry(entryId: "entry-uuid") {
    success
    code
    message
  }
}
```

**파라미터**:
- `entryId` (String!, required): 참여 엔트리 ID

**인증 필요**: ✅ Yes

**응답 타입**: `CommonResponse`

---

### 암호화 키

#### requestEncryptionKey
블록체인 암호화 키를 요청합니다 (API 서버가 가스비 지불).

```graphql
mutation {
  requestEncryptionKey(input: {
    gameId: "game-uuid"
    userAddress: "0x..."
    index: "0"
  }) {
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
```

**입력 타입**: `RequestEncryptionKeyInput`
```graphql
input RequestEncryptionKeyInput {
  gameId: String!           # 게임 ID
  userAddress: String!      # 사용자 지갑 주소
  index: String!            # 사용자 암호화 키 인덱스 (스마트컨트랙트 조회용)
}
```

**인증 필요**: ✅ Yes

**응답 타입**: `EncryptionKeyResponse`

---

## 타입 정의

### User
사용자 정보

```graphql
type User {
  id: String!
  email: String!
  nickname: String
  phoneNumber: String           # 전화번호 (신규)
  avatar: String
  createdAt: String!
  updatedAt: String
  balance: Float                # 보유 잔액
  totalGamesPlayed: Int         # 총 플레이 게임 수
  totalWins: Int                # 총 승리 수
  winRate: Float                # 승률 (0.0 ~ 1.0)
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
  mainProductName: String       # 메인 상품명 (신규)
  type: GameType!               # 게임 타입 (신규)
  gameType: GameType!           # 게임 타입
  category: String              # 카테고리 (신규)
  status: GameStatus!           # SCHEDULED, IN_PROGRESS, PAUSED, SETTLING, ENDED, FAILED
  entryFee: Int!                # 참가비
  currency: String!             # 통화 (신규)
  minEntries: Int!              # 최소 참여자 수 (신규)
  maxEntries: Int               # 최대 참여자 수 (신규)
  maxEntriesPerUser: Int!       # 사용자당 최대 참여 횟수 (신규)
  rewardPoint: Int              # 리워드 포인트 (신규)
  gridRows: Int                 # 그리드 행 수 (신규)
  gridCols: Int                 # 그리드 열 수 (신규)
  visibleFrom: String           # 노출 시작 시간 (신규)
  startTime: String             # ISO 8601 포맷
  endTime: String               # ISO 8601 포맷
  allowDuplicate: Boolean!      # 중복 참여 허용 (신규)
  enableNotification: Boolean!  # 알림 활성화 (신규)
  isRecommended: Boolean!       # 추천 게임 (신규)
  customRules: String           # 커스텀 규칙 (신규)
  autoEndOnMax: Boolean!        # 최대 참여 시 자동 종료 (신규)
  autoEndOnTime: Boolean!       # 시간 도달 시 자동 종료 (신규)
  onchainTxHash: String         # 블록체인 트랜잭션 해시
  onchainContractAddr: String   # 블록체인 컨트랙트 주소
  createdAt: String!
  updatedAt: String!
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
  currentEntries: Int!          # 현재 참여자 수
  maxEntriesPerUser: Int!
  rewardPoint: Int!
  gridRows: Int!                # 그리드 행 수
  gridCols: Int!                # 그리드 열 수
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
  sequence: Int!                # 상품 순서
  active: Boolean!
  isGrandPrize: Boolean!        # 대상 상품 여부
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
  position: Int                 # 그리드 위치
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
  sku: String                   # 상품 코드
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
  joinedAt: String!             # ISO 8601 포맷
  status: UserGameStatus!       # JOINED, PLAYING, COMPLETED, WITHDRAWN
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
  rank: Int                     # 순위
  reward: Float                 # 보상 금액
  createdAt: String!
}
```

---

### EntryStatus
게임 참여 상태 정보

```graphql
type EntryStatus {
  entryId: String!
  status: String!
  txHash: String
  blockNumber: String
  confirmedAt: String
}
```

---

### TxIntentDetail
트랜잭션 인텐트 상세 정보

```graphql
type TxIntentDetail {
  intentId: String!
  status: String!
  txHash: String
  errorCode: String
  errorMessage: String
  createdAt: String!
  updatedAt: String!
}
```

---

### PaginationInfo
페이지네이션 정보

```graphql
type PaginationInfo {
  currentPage: Int!             # 현재 페이지 (0부터 시작)
  pageSize: Int!                # 페이지 크기
  totalPages: Int!              # 총 페이지 수
  totalElements: Int!           # 총 요소 수
  hasNext: Boolean!             # 다음 페이지 존재 여부
  hasPrevious: Boolean!         # 이전 페이지 존재 여부
}
```

---

### Response Types

#### CommonResponse
```graphql
type CommonResponse {
  success: Boolean!
  code: String!
  message: String!
}
```

#### LoginResponse
```graphql
type LoginResponse {
  success: Boolean!
  code: String!
  message: String!
  accessToken: String
  refreshToken: String
  user: User
}
```

#### JoinGameResponse
```graphql
type JoinGameResponse {
  success: Boolean!
  code: String!
  message: String!
  entryId: String
  status: String
  txHash: String
  errorCode: String
}
```

#### EntryStatusResponse
```graphql
type EntryStatusResponse {
  success: Boolean!
  entryId: String!
  status: String!
  txIntents: [TxIntentDetail!]
  errorMessage: String
}
```

#### EncryptionKeyResponse
```graphql
type EncryptionKeyResponse {
  success: Boolean!             # 요청 성공 여부
  code: String!                 # 응답 코드
  message: String!              # 응답 메시지
  encryptionKey: String         # 생성/조회된 암호화 키
  contractAddress: String       # 컨트랙트 주소
  txHash: String                # 트랜잭션 해시 (키 생성 시)
  userAddress: String           # 사용자 지갑 주소
  index: String                 # 인덱스
}
```

#### EncryptionKeyStatusResponse
```graphql
type EncryptionKeyStatusResponse {
  success: Boolean!
  requestId: String!
  status: String!
  txHash: String
  errorCode: String
  errorMessage: String
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
이메일 인증 타입

```graphql
enum VerifyType {
  SIGN_UP           # 회원가입
  CHANGE_PASSWORD   # 비밀번호 변경
  WITHDRAW          # 회원탈퇴
}
```

---

### SmsVerifyType
SMS 인증 타입

```graphql
enum SmsVerifyType {
  SIGN_UP           # 회원가입
  FIND_EMAIL        # 이메일 찾기
  CHANGE_PASSWORD   # 비밀번호 변경
  WITHDRAW          # 회원탈퇴
}
```

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

### 게임 참여 플로우
1. `requestEncryptionKey` 뮤테이션으로 암호화 키 요청
2. `encryptionKeyStatus` 쿼리로 키 생성 상태 폴링
3. `joinGame` 뮤테이션으로 게임 참여 요청
4. `entryStatus` 쿼리로 참여 상태 폴링
5. 트랜잭션 확정 시 참여 완료

---

**문서 버전**: 2.0
**마지막 검증**: 2026-01-12
