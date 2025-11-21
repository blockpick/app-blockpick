# BlockPick API 명세서 (GraphQL)

**문서 버전**: 1.0
**작성일**: 2025-11-20
**문서 유형**: API 상세 명세서
**프로토콜**: GraphQL over HTTP
**엔드포인트**: `https://api.blockpick.com/graphql`

---

## 목차

1. [문서 개요](#1-문서-개요)
2. [GraphQL 기본 정보](#2-graphql-기본-정보)
3. [인증 및 인가](#3-인증-및-인가)
4. [Query (조회)](#4-query-조회)
5. [Mutation (변경)](#5-mutation-변경)
6. [Subscription (실시간)](#6-subscription-실시간)
7. [타입 정의](#7-타입-정의)
8. [입력 타입](#8-입력-타입)
9. [열거형 (Enum)](#9-열거형-enum)
10. [에러 처리](#10-에러-처리)
11. [페이지네이션](#11-페이지네이션)
12. [Rate Limiting](#12-rate-limiting)
13. [캐싱 전략](#13-캐싱-전략)
14. [API 사용 예제](#14-api-사용-예제)

---

## 1. 문서 개요

### 1.1 목적

본 문서는 BlockPick 모바일 애플리케이션과 백엔드 서버 간의 모든 API 통신을 정의합니다. GraphQL을 사용하여 유연하고 효율적인 데이터 쿼리를 지원하며, 클라이언트는 필요한 데이터만 요청할 수 있습니다.

### 1.2 GraphQL 선택 이유

- **유연한 데이터 요청**: 클라이언트가 필요한 필드만 선택 가능
- **단일 엔드포인트**: 모든 요청이 `/graphql`로 통합
- **강력한 타입 시스템**: 스키마 기반 자동 검증 및 문서화
- **효율적인 네트워크 사용**: Over-fetching/Under-fetching 방지
- **실시간 데이터**: Subscription을 통한 WebSocket 지원

### 1.3 버전 관리

GraphQL은 스키마 진화(Schema Evolution)를 지원하므로, API 버전을 명시적으로 관리하지 않습니다. 대신:
- 필드 추가: 기존 클라이언트에 영향 없음
- 필드 제거: `@deprecated` 디렉티브로 표시 후 충분한 기간 이후 제거
- 타입 변경: 새로운 필드 추가 후 기존 필드 deprecated

---

## 2. GraphQL 기본 정보

### 2.1 엔드포인트

**Production**: `https://api.blockpick.com/graphql`
**Staging**: `https://staging-api.blockpick.com/graphql`
**Development**: `http://localhost:4000/graphql`

### 2.2 HTTP 헤더

**필수 헤더**:
```
Content-Type: application/json
```

**인증 헤더** (로그인 필요한 요청):
```
Authorization: Bearer <access_token>
```

**선택 헤더**:
```
X-Device-ID: <device_uuid>
X-App-Version: <app_version>
X-Platform: android | ios
```

### 2.3 요청 형식

```json
{
  "query": "query { ... }",
  "variables": { ... },
  "operationName": "OperationName"
}
```

### 2.4 응답 형식

**성공 시**:
```json
{
  "data": {
    "fieldName": { ... }
  }
}
```

**에러 시**:
```json
{
  "errors": [
    {
      "message": "Error message",
      "locations": [{ "line": 2, "column": 3 }],
      "path": ["fieldName"],
      "extensions": {
        "code": "UNAUTHENTICATED",
        "timestamp": "2025-11-20T10:30:00Z"
      }
    }
  ],
  "data": null
}
```

---

## 3. 인증 및 인가

### 3.1 JWT 토큰 구조

**Access Token** (유효기간: 30분):
```json
{
  "sub": "user_id",
  "email": "user@example.com",
  "role": "USER",
  "iat": 1700000000,
  "exp": 1700001800
}
```

**Refresh Token** (유효기간: 7일):
```json
{
  "sub": "user_id",
  "type": "REFRESH",
  "iat": 1700000000,
  "exp": 1700604800
}
```

### 3.2 토큰 갱신 플로우

1. Access Token 만료 시 401 Unauthorized 응답
2. 클라이언트가 `refreshToken` Mutation 호출
3. 유효한 Refresh Token으로 새로운 Access Token 발급
4. Refresh Token도 만료 시 재로그인 필요

### 3.3 권한 레벨

- **PUBLIC**: 인증 불필요 (게임 목록 조회 등)
- **USER**: 일반 사용자 (게임 참가 등)
- **ADMIN**: 관리자 (게임 생성, 당첨자 선정 등)
- **SYSTEM**: 시스템 내부 호출 (자동 프로세스)

---

## 4. Query (조회)

### 4.1 사용자 (User)

#### 4.1.1 현재 사용자 정보 조회

```graphql
query GetCurrentUser {
  me {
    id
    email
    name
    profileImageUrl
    phoneNumber
    birthDate
    eventCash
    shoppingCash
    walletAddress
    createdAt
    emailVerified
  }
}
```

**권한**: USER
**캐싱**: 5분

**응답 예시**:
```json
{
  "data": {
    "me": {
      "id": "usr_1a2b3c4d",
      "email": "user@example.com",
      "name": "홍길동",
      "profileImageUrl": "https://cdn.blockpick.com/profiles/abc.jpg",
      "phoneNumber": "010-1234-5678",
      "birthDate": "1990-01-15",
      "eventCash": 15000,
      "shoppingCash": 5000,
      "walletAddress": "0x742d35Cc6634C0532925a3b844Bc9e7595f0bEb",
      "createdAt": "2025-01-10T10:30:00Z",
      "emailVerified": true
    }
  }
}
```

---

#### 4.1.2 사용자 거래 내역 조회

```graphql
query GetTransactionHistory(
  $first: Int = 20
  $after: String
  $type: TransactionType
) {
  me {
    transactions(first: $first, after: $after, type: $type) {
      edges {
        node {
          id
          type
          amount
          description
          relatedId
          createdAt
        }
        cursor
      }
      pageInfo {
        hasNextPage
        endCursor
      }
      totalCount
    }
  }
}
```

**권한**: USER
**캐싱**: 1분

**Variables 예시**:
```json
{
  "first": 20,
  "type": "CHARGE"
}
```

---

### 4.2 게임 (Game)

#### 4.2.1 게임 목록 조회

```graphql
query GetGames(
  $filter: GameFilterInput
  $sort: GameSortInput
  $first: Int = 20
  $after: String
) {
  games(filter: $filter, sort: $sort, first: $first, after: $after) {
    edges {
      node {
        id
        title
        description
        gameType
        category
        status
        productName
        productImageUrl
        productImages
        retailPrice
        entryFee
        currentParticipants
        maxParticipants
        refundRate
        startDate
        endDate
        createdAt
      }
      cursor
    }
    pageInfo {
      hasNextPage
      hasPreviousPage
      startCursor
      endCursor
    }
    totalCount
  }
}
```

**권한**: PUBLIC
**캐싱**: 30초

**Variables 예시**:
```json
{
  "filter": {
    "gameType": "DAILY",
    "category": "DIGITAL",
    "status": "ONGOING"
  },
  "sort": {
    "field": "ENDING_SOON",
    "order": "ASC"
  },
  "first": 20
}
```

---

#### 4.2.2 게임 상세 조회

```graphql
query GetGameDetail($gameId: ID!) {
  game(id: $gameId) {
    id
    title
    description
    gameType
    category
    status
    productName
    productDescription
    productImageUrl
    productImages
    retailPrice
    entryFee
    currentParticipants
    maxParticipants
    refundRate
    startDate
    endDate
    # 당첨 정보 (게임 종료 후)
    winner {
      id
      name
      profileImageUrl
    }
    winningBlocks {
      x
      y
    }
    randomSeed
    # 통계
    participationRate
    averageBlockDensity
    createdAt
    updatedAt
  }
}
```

**권한**: PUBLIC
**캐싱**: 10초 (진행 중), 1시간 (종료됨)

---

#### 4.2.3 게임 그리드 상태 조회

```graphql
query GetGameGridStatus($gameId: ID!) {
  game(id: $gameId) {
    id
    gridStatus {
      totalBlocks
      occupiedBlocks
      availableBlocks
      occupancyRate
    }
  }
}
```

**권한**: PUBLIC
**캐싱**: 5초

---

#### 4.2.4 블록 선택 가능 여부 확인

```graphql
query CheckBlockAvailability(
  $gameId: ID!
  $centerBlock: BlockCoordinateInput!
) {
  checkBlockAvailability(gameId: $gameId, centerBlock: $centerBlock) {
    available
    occupiedBlocks {
      x
      y
    }
    message
  }
}
```

**권한**: PUBLIC
**캐싱**: 없음 (실시간 확인)

**Variables 예시**:
```json
{
  "gameId": "gam_abc123",
  "centerBlock": {
    "x": 500,
    "y": 500
  }
}
```

---

### 4.3 참여 내역 (Participation)

#### 4.3.1 나의 참여 내역 조회

```graphql
query GetMyParticipations(
  $filter: ParticipationFilterInput
  $first: Int = 20
  $after: String
) {
  me {
    participations(filter: $filter, first: $first, after: $after) {
      edges {
        node {
          id
          game {
            id
            title
            productImageUrl
            gameType
          }
          selectedBlocks {
            x
            y
          }
          entryFee
          isWinner
          refundAmount
          transactionHash
          encryptedCoordinates
          createdAt
          # 당첨 정보 (당첨 시)
          prizeDeliveryStatus
          prizeDeliveryAddress
          prizeDeliveredAt
        }
        cursor
      }
      pageInfo {
        hasNextPage
        endCursor
      }
      totalCount
    }
  }
}
```

**권한**: USER
**캐싱**: 1분

**Variables 예시**:
```json
{
  "filter": {
    "status": "ONGOING"
  },
  "first": 20
}
```

---

#### 4.3.2 특정 참여 상세 조회

```graphql
query GetParticipationDetail($participationId: ID!) {
  participation(id: $participationId) {
    id
    game {
      id
      title
      productName
      productImageUrl
      gameType
      status
      endDate
      # 당첨 정보 (게임 종료 후)
      winningBlocks {
        x
        y
      }
    }
    user {
      id
      name
    }
    selectedBlocks {
      x
      y
    }
    entryFee
    isWinner
    refundAmount
    transactionHash
    blockchainExplorerUrl
    createdAt
  }
}
```

**권한**: USER (본인 참여만)
**캐싱**: 5분

---

### 4.4 블록체인 지갑 (Wallet)

#### 4.4.1 내 지갑 정보 조회

```graphql
query GetMyWallet {
  me {
    wallet {
      address
      balance
      networkName
      explorerUrl
      createdAt
      hasBackedUp
    }
  }
}
```

**권한**: USER
**캐싱**: 1분

---

### 4.5 알림 (Notification)

#### 4.5.1 알림 목록 조회

```graphql
query GetNotifications(
  $first: Int = 20
  $after: String
  $unreadOnly: Boolean = false
) {
  me {
    notifications(first: $first, after: $after, unreadOnly: $unreadOnly) {
      edges {
        node {
          id
          title
          body
          category
          isRead
          data
          createdAt
        }
        cursor
      }
      pageInfo {
        hasNextPage
        endCursor
      }
      unreadCount
    }
  }
}
```

**권한**: USER
**캐싱**: 없음

---

#### 4.5.2 알림 설정 조회

```graphql
query GetNotificationSettings {
  me {
    notificationSettings {
      pushEnabled
      emailEnabled
      smsEnabled
      categories {
        gameStart
        gameEnding
        gameResult
        eventPromo
      }
      quietHours {
        enabled
        startTime
        endTime
      }
    }
  }
}
```

**권한**: USER
**캐싱**: 5분

---

## 5. Mutation (변경)

### 5.1 사용자 인증 (Authentication)

#### 5.1.1 이메일 회원가입

```graphql
mutation SignUpWithEmail($input: SignUpInput!) {
  signUpWithEmail(input: $input) {
    success
    user {
      id
      email
      name
    }
    accessToken
    refreshToken
    message
  }
}
```

**권한**: PUBLIC

**Input 예시**:
```json
{
  "input": {
    "email": "user@example.com",
    "password": "SecurePass123!",
    "name": "홍길동",
    "phoneNumber": "010-1234-5678",
    "birthDate": "1990-01-15",
    "agreeToTerms": true,
    "agreeToPrivacy": true,
    "agreeToMarketing": false
  }
}
```

**응답 예시**:
```json
{
  "data": {
    "signUpWithEmail": {
      "success": true,
      "user": {
        "id": "usr_1a2b3c4d",
        "email": "user@example.com",
        "name": "홍길동"
      },
      "accessToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
      "refreshToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
      "message": "회원가입이 완료되었습니다. 환영합니다!"
    }
  }
}
```

**에러 예시**:
```json
{
  "errors": [
    {
      "message": "이미 사용 중인 이메일입니다",
      "extensions": {
        "code": "EMAIL_ALREADY_EXISTS",
        "field": "email"
      }
    }
  ]
}
```

---

#### 5.1.2 이메일 로그인

```graphql
mutation SignInWithEmail($input: SignInInput!) {
  signInWithEmail(input: $input) {
    success
    user {
      id
      email
      name
      profileImageUrl
    }
    accessToken
    refreshToken
    message
  }
}
```

**권한**: PUBLIC

**Input 예시**:
```json
{
  "input": {
    "email": "user@example.com",
    "password": "SecurePass123!"
  }
}
```

---

#### 5.1.3 소셜 로그인 (Google, Apple, Kakao)

```graphql
mutation SignInWithSocial($input: SocialSignInInput!) {
  signInWithSocial(input: $input) {
    success
    user {
      id
      email
      name
      profileImageUrl
    }
    accessToken
    refreshToken
    isNewUser
    message
  }
}
```

**권한**: PUBLIC

**Input 예시**:
```json
{
  "input": {
    "provider": "GOOGLE",
    "idToken": "eyJhbGciOiJSUzI1NiIsImtpZCI6Ij...",
    "accessToken": "ya29.a0AfH6SMCP..."
  }
}
```

---

#### 5.1.4 토큰 갱신

```graphql
mutation RefreshToken($refreshToken: String!) {
  refreshToken(refreshToken: $refreshToken) {
    success
    accessToken
    refreshToken
  }
}
```

**권한**: PUBLIC

---

#### 5.1.5 로그아웃

```graphql
mutation SignOut {
  signOut {
    success
    message
  }
}
```

**권한**: USER

---

#### 5.1.6 비밀번호 재설정 요청

```graphql
mutation RequestPasswordReset($email: String!) {
  requestPasswordReset(email: $email) {
    success
    message
  }
}
```

**권한**: PUBLIC

**응답 예시**:
```json
{
  "data": {
    "requestPasswordReset": {
      "success": true,
      "message": "비밀번호 재설정 링크를 이메일로 발송했습니다"
    }
  }
}
```

---

#### 5.1.7 비밀번호 재설정

```graphql
mutation ResetPassword($input: ResetPasswordInput!) {
  resetPassword(input: $input) {
    success
    message
  }
}
```

**권한**: PUBLIC

**Input 예시**:
```json
{
  "input": {
    "token": "reset_token_from_email",
    "newPassword": "NewSecurePass456!"
  }
}
```

---

### 5.2 사용자 프로필 (Profile)

#### 5.2.1 프로필 수정

```graphql
mutation UpdateProfile($input: UpdateProfileInput!) {
  updateProfile(input: $input) {
    success
    user {
      id
      name
      profileImageUrl
      phoneNumber
      birthDate
    }
    message
  }
}
```

**권한**: USER

**Input 예시**:
```json
{
  "input": {
    "name": "홍길동",
    "phoneNumber": "010-9876-5432",
    "birthDate": "1990-01-15"
  }
}
```

---

#### 5.2.2 프로필 이미지 업로드

```graphql
mutation UploadProfileImage($file: Upload!) {
  uploadProfileImage(file: $file) {
    success
    imageUrl
    message
  }
}
```

**권한**: USER

**Note**: 파일 업로드는 `multipart/form-data`로 전송되며, GraphQL Multipart Request Spec을 따릅니다.

---

#### 5.2.3 계정 탈퇴

```graphql
mutation DeleteAccount($input: DeleteAccountInput!) {
  deleteAccount(input: $input) {
    success
    message
  }
}
```

**권한**: USER

**Input 예시**:
```json
{
  "input": {
    "password": "CurrentPassword123!",
    "reason": "서비스가 필요 없어서",
    "feedback": "더 나은 서비스를 기대합니다"
  }
}
```

---

### 5.3 게임 참여 (Participation)

#### 5.3.1 게임 참가

```graphql
mutation JoinGame($input: JoinGameInput!) {
  joinGame(input: $input) {
    success
    participation {
      id
      game {
        id
        title
      }
      selectedBlocks {
        x
        y
      }
      entryFee
      transactionHash
    }
    remainingCash
    message
  }
}
```

**권한**: USER

**Input 예시**:
```json
{
  "input": {
    "gameId": "gam_abc123",
    "selectedBlocks": [
      { "x": 500, "y": 500 },
      { "x": 501, "y": 500 },
      { "x": 502, "y": 500 },
      { "x": 500, "y": 501 },
      { "x": 501, "y": 501 },
      { "x": 502, "y": 501 },
      { "x": 500, "y": 502 },
      { "x": 501, "y": 502 },
      { "x": 502, "y": 502 }
    ]
  }
}
```

**응답 예시**:
```json
{
  "data": {
    "joinGame": {
      "success": true,
      "participation": {
        "id": "prt_xyz789",
        "game": {
          "id": "gam_abc123",
          "title": "iPhone 16 Pro 럭키드로우"
        },
        "selectedBlocks": [...],
        "entryFee": 3000,
        "transactionHash": "0x1a2b3c4d5e6f..."
      },
      "remainingCash": 12000,
      "message": "게임 참가가 완료되었습니다!"
    }
  }
}
```

**에러 예시**:
```json
{
  "errors": [
    {
      "message": "Event Cash가 부족합니다. 현재 잔액: 2,000원",
      "extensions": {
        "code": "INSUFFICIENT_CASH",
        "currentBalance": 2000,
        "required": 3000
      }
    }
  ]
}
```

---

#### 5.3.2 게임 참가 취소

```graphql
mutation CancelParticipation($participationId: ID!) {
  cancelParticipation(participationId: $participationId) {
    success
    refundAmount
    remainingCash
    message
  }
}
```

**권한**: USER

**응답 예시**:
```json
{
  "data": {
    "cancelParticipation": {
      "success": true,
      "refundAmount": 2700,
      "remainingCash": 14700,
      "message": "참가가 취소되었습니다. 참가비의 90%가 환불되었습니다"
    }
  }
}
```

---

### 5.4 Event Cash 관리

#### 5.4.1 Event Cash 충전

```graphql
mutation ChargeEventCash($input: ChargeEventCashInput!) {
  chargeEventCash(input: $input) {
    success
    paymentId
    chargedAmount
    bonusAmount
    currentCash
    message
  }
}
```

**권한**: USER

**Input 예시**:
```json
{
  "input": {
    "amount": 50000,
    "paymentMethod": "CARD",
    "paymentInfo": {
      "cardNumber": "1234-5678-9012-3456",
      "expiryDate": "12/25",
      "cvv": "123",
      "cardholderName": "홍길동"
    }
  }
}
```

**응답 예시**:
```json
{
  "data": {
    "chargeEventCash": {
      "success": true,
      "paymentId": "pay_abc123",
      "chargedAmount": 50000,
      "bonusAmount": 5000,
      "currentCash": 70000,
      "message": "50,000원이 충전되었습니다. 보너스 5,000원을 받았습니다!"
    }
  }
}
```

---

#### 5.4.2 Event Cash ↔ Shopping Cash 전환

```graphql
mutation ConvertCash($input: ConvertCashInput!) {
  convertCash(input: $input) {
    success
    eventCash
    shoppingCash
    message
  }
}
```

**권한**: USER

**Input 예시**:
```json
{
  "input": {
    "amount": 10000,
    "direction": "EVENT_TO_SHOPPING"
  }
}
```

---

#### 5.4.3 Event Cash 환불 요청

```graphql
mutation RequestCashRefund($input: RequestCashRefundInput!) {
  requestCashRefund(input: $input) {
    success
    refundId
    refundAmount
    feeAmount
    estimatedCompletionDate
    message
  }
}
```

**권한**: USER

**Input 예시**:
```json
{
  "input": {
    "amount": 20000,
    "reason": "서비스 이용 종료",
    "bankAccount": {
      "bankName": "국민은행",
      "accountNumber": "123-456-789012",
      "accountHolder": "홍길동"
    }
  }
}
```

---

### 5.5 블록체인 지갑

#### 5.5.1 지갑 생성

```graphql
mutation CreateWallet {
  createWallet {
    success
    wallet {
      address
      networkName
    }
    mnemonic
    message
  }
}
```

**권한**: USER

**응답 예시**:
```json
{
  "data": {
    "createWallet": {
      "success": true,
      "wallet": {
        "address": "0x742d35Cc6634C0532925a3b844Bc9e7595f0bEb",
        "networkName": "Polygon Mainnet"
      },
      "mnemonic": "abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon about",
      "message": "지갑이 생성되었습니다. 복구 문구를 안전한 곳에 보관하세요"
    }
  }
}
```

---

#### 5.5.2 지갑 복구

```graphql
mutation RecoverWallet($mnemonic: String!) {
  recoverWallet(mnemonic: $mnemonic) {
    success
    wallet {
      address
      networkName
    }
    message
  }
}
```

**권한**: USER

---

#### 5.5.3 지갑 백업 완료 표시

```graphql
mutation MarkWalletBackedUp {
  markWalletBackedUp {
    success
    message
  }
}
```

**권한**: USER

---

### 5.6 알림 (Notification)

#### 5.6.1 알림 읽음 표시

```graphql
mutation MarkNotificationAsRead($notificationId: ID!) {
  markNotificationAsRead(notificationId: $notificationId) {
    success
    notification {
      id
      isRead
    }
  }
}
```

**권한**: USER

---

#### 5.6.2 모든 알림 읽음 표시

```graphql
mutation MarkAllNotificationsAsRead {
  markAllNotificationsAsRead {
    success
    count
    message
  }
}
```

**권한**: USER

---

#### 5.6.3 알림 설정 업데이트

```graphql
mutation UpdateNotificationSettings($input: NotificationSettingsInput!) {
  updateNotificationSettings(input: $input) {
    success
    settings {
      pushEnabled
      emailEnabled
      categories {
        gameStart
        gameEnding
        gameResult
        eventPromo
      }
    }
    message
  }
}
```

**권한**: USER

**Input 예시**:
```json
{
  "input": {
    "pushEnabled": true,
    "emailEnabled": false,
    "categories": {
      "gameStart": true,
      "gameEnding": true,
      "gameResult": true,
      "eventPromo": false
    },
    "quietHours": {
      "enabled": true,
      "startTime": "22:00",
      "endTime": "08:00"
    }
  }
}
```

---

#### 5.6.4 FCM 디바이스 토큰 등록

```graphql
mutation RegisterDeviceToken($token: String!, $platform: Platform!) {
  registerDeviceToken(token: $token, platform: $platform) {
    success
    message
  }
}
```

**권한**: USER

**Input 예시**:
```json
{
  "token": "fcm_device_token_here",
  "platform": "ANDROID"
}
```

---

### 5.7 관리자 전용 (Admin Only)

#### 5.7.1 게임 생성

```graphql
mutation CreateGame($input: CreateGameInput!) {
  createGame(input: $input) {
    success
    game {
      id
      title
      gameType
      status
    }
    message
  }
}
```

**권한**: ADMIN

**Input 예시**:
```json
{
  "input": {
    "title": "iPhone 16 Pro 럭키드로우",
    "description": "최신 아이폰을 럭키드로우로 만나보세요!",
    "gameType": "DAILY",
    "category": "DIGITAL",
    "productName": "iPhone 16 Pro 256GB Natural Titanium",
    "productDescription": "6.7인치 Super Retina XDR 디스플레이...",
    "productImages": [
      "https://cdn.blockpick.com/products/iphone16pro_1.jpg",
      "https://cdn.blockpick.com/products/iphone16pro_2.jpg"
    ],
    "retailPrice": 1550000,
    "entryFee": 3000,
    "maxParticipants": 500,
    "refundRate": 10,
    "startDate": "2025-11-21T00:00:00Z",
    "endDate": "2025-11-22T00:00:00Z"
  }
}
```

---

#### 5.7.2 당첨자 선정

```graphql
mutation SelectWinner($gameId: ID!) {
  selectWinner(gameId: $gameId) {
    success
    winner {
      id
      name
    }
    winningBlocks {
      x
      y
    }
    randomSeed
    message
  }
}
```

**권한**: ADMIN

---

## 6. Subscription (실시간)

### 6.1 게임 참여자 수 실시간 업데이트

```graphql
subscription OnGameParticipantCountChanged($gameId: ID!) {
  gameParticipantCountChanged(gameId: $gameId) {
    gameId
    currentParticipants
    maxParticipants
    participationRate
  }
}
```

**권한**: PUBLIC

**사용 예시**:
```javascript
const subscription = client.subscribe({
  query: gql`
    subscription OnGameParticipantCountChanged($gameId: ID!) {
      gameParticipantCountChanged(gameId: $gameId) {
        gameId
        currentParticipants
        maxParticipants
        participationRate
      }
    }
  `,
  variables: { gameId: 'gam_abc123' }
});

subscription.subscribe({
  next(data) {
    console.log('참여자 수 업데이트:', data);
  }
});
```

---

### 6.2 알림 실시간 수신

```graphql
subscription OnNotificationReceived {
  notificationReceived {
    id
    title
    body
    category
    data
    createdAt
  }
}
```

**권한**: USER

---

### 6.3 당첨자 발표 실시간 수신

```graphql
subscription OnWinnerAnnounced($gameId: ID!) {
  winnerAnnounced(gameId: $gameId) {
    gameId
    winner {
      id
      name
      profileImageUrl
    }
    winningBlocks {
      x
      y
    }
    announcedAt
  }
}
```

**권한**: PUBLIC

---

## 7. 타입 정의

### 7.1 User (사용자)

```graphql
type User {
  id: ID!
  email: String!
  name: String!
  profileImageUrl: String
  phoneNumber: String
  birthDate: Date
  eventCash: Int!
  shoppingCash: Int!
  walletAddress: String
  emailVerified: Boolean!
  role: UserRole!
  createdAt: DateTime!
  updatedAt: DateTime!

  # Relations
  wallet: Wallet
  participations(
    filter: ParticipationFilterInput
    first: Int
    after: String
  ): ParticipationConnection!
  transactions(
    type: TransactionType
    first: Int
    after: String
  ): TransactionConnection!
  notifications(
    unreadOnly: Boolean
    first: Int
    after: String
  ): NotificationConnection!
  notificationSettings: NotificationSettings!
}
```

---

### 7.2 Game (게임)

```graphql
type Game {
  id: ID!
  title: String!
  description: String!
  gameType: GameType!
  category: GameCategory!
  status: GameStatus!

  # Product Info
  productName: String!
  productDescription: String
  productImageUrl: String!
  productImages: [String!]!
  retailPrice: Int!

  # Game Settings
  entryFee: Int!
  maxParticipants: Int!
  currentParticipants: Int!
  refundRate: Float!

  # Dates
  startDate: DateTime!
  endDate: DateTime!
  createdAt: DateTime!
  updatedAt: DateTime!

  # Winner Info (available after game ends)
  winner: User
  winningBlocks: [BlockCoordinate!]
  randomSeed: String

  # Statistics
  participationRate: Float!
  averageBlockDensity: Float
  gridStatus: GridStatus!

  # Relations
  participations(first: Int, after: String): ParticipationConnection!
}
```

---

### 7.3 Participation (참여)

```graphql
type Participation {
  id: ID!
  user: User!
  game: Game!
  selectedBlocks: [BlockCoordinate!]!
  entryFee: Int!
  isWinner: Boolean!
  refundAmount: Int
  transactionHash: String!
  encryptedCoordinates: String!
  blockchainExplorerUrl: String!
  createdAt: DateTime!

  # Prize Delivery (for winners)
  prizeDeliveryStatus: PrizeDeliveryStatus
  prizeDeliveryAddress: Address
  prizeDeliveredAt: DateTime
}
```

---

### 7.4 Transaction (거래)

```graphql
type Transaction {
  id: ID!
  user: User!
  type: TransactionType!
  amount: Int!
  description: String!
  relatedId: String
  createdAt: DateTime!
}
```

---

### 7.5 Wallet (지갑)

```graphql
type Wallet {
  address: String!
  balance: String!
  networkName: String!
  explorerUrl: String!
  createdAt: DateTime!
  hasBackedUp: Boolean!
}
```

---

### 7.6 Notification (알림)

```graphql
type Notification {
  id: ID!
  user: User!
  title: String!
  body: String!
  category: NotificationCategory!
  isRead: Boolean!
  data: JSON
  createdAt: DateTime!
}
```

---

### 7.7 보조 타입들

```graphql
type BlockCoordinate {
  x: Int!
  y: Int!
}

type GridStatus {
  totalBlocks: Int!
  occupiedBlocks: Int!
  availableBlocks: Int!
  occupancyRate: Float!
}

type Address {
  recipient: String!
  phone: String!
  postalCode: String!
  address: String!
  addressDetail: String
}

type NotificationSettings {
  pushEnabled: Boolean!
  emailEnabled: Boolean!
  smsEnabled: Boolean!
  categories: NotificationCategories!
  quietHours: QuietHours
}

type NotificationCategories {
  gameStart: Boolean!
  gameEnding: Boolean!
  gameResult: Boolean!
  eventPromo: Boolean!
}

type QuietHours {
  enabled: Boolean!
  startTime: String!
  endTime: String!
}
```

---

## 8. 입력 타입

### 8.1 SignUpInput

```graphql
input SignUpInput {
  email: String!
  password: String!
  name: String!
  phoneNumber: String
  birthDate: Date
  agreeToTerms: Boolean!
  agreeToPrivacy: Boolean!
  agreeToMarketing: Boolean
}
```

---

### 8.2 SignInInput

```graphql
input SignInInput {
  email: String!
  password: String!
}
```

---

### 8.3 SocialSignInInput

```graphql
input SocialSignInInput {
  provider: SocialProvider!
  idToken: String!
  accessToken: String
}
```

---

### 8.4 UpdateProfileInput

```graphql
input UpdateProfileInput {
  name: String
  phoneNumber: String
  birthDate: Date
}
```

---

### 8.5 JoinGameInput

```graphql
input JoinGameInput {
  gameId: ID!
  selectedBlocks: [BlockCoordinateInput!]!
}
```

---

### 8.6 BlockCoordinateInput

```graphql
input BlockCoordinateInput {
  x: Int!
  y: Int!
}
```

---

### 8.7 ChargeEventCashInput

```graphql
input ChargeEventCashInput {
  amount: Int!
  paymentMethod: PaymentMethod!
  paymentInfo: PaymentInfoInput!
}
```

---

### 8.8 PaymentInfoInput

```graphql
input PaymentInfoInput {
  # For CARD
  cardNumber: String
  expiryDate: String
  cvv: String
  cardholderName: String

  # For ACCOUNT_TRANSFER
  bankCode: String
  accountNumber: String
}
```

---

### 8.9 ConvertCashInput

```graphql
input ConvertCashInput {
  amount: Int!
  direction: CashConversionDirection!
}
```

---

### 8.10 GameFilterInput

```graphql
input GameFilterInput {
  gameType: GameType
  category: GameCategory
  status: GameStatus
  minEntryFee: Int
  maxEntryFee: Int
}
```

---

### 8.11 GameSortInput

```graphql
input GameSortInput {
  field: GameSortField!
  order: SortOrder!
}
```

---

### 8.12 ParticipationFilterInput

```graphql
input ParticipationFilterInput {
  status: ParticipationStatus
  isWinner: Boolean
  gameType: GameType
}
```

---

### 8.13 NotificationSettingsInput

```graphql
input NotificationSettingsInput {
  pushEnabled: Boolean
  emailEnabled: Boolean
  smsEnabled: Boolean
  categories: NotificationCategoriesInput
  quietHours: QuietHoursInput
}
```

---

### 8.14 NotificationCategoriesInput

```graphql
input NotificationCategoriesInput {
  gameStart: Boolean
  gameEnding: Boolean
  gameResult: Boolean
  eventPromo: Boolean
}
```

---

### 8.15 QuietHoursInput

```graphql
input QuietHoursInput {
  enabled: Boolean!
  startTime: String!
  endTime: String!
}
```

---

## 9. 열거형 (Enum)

### 9.1 GameType

```graphql
enum GameType {
  DAILY      # 데일리 게임
  SELECT     # 셀렉트 게임
  VIBE       # 바이브 게임
  PRIME      # 프라임 게임 (가격 맞추기)
}
```

---

### 9.2 GameCategory

```graphql
enum GameCategory {
  DIGITAL      # 디지털/전자기기
  FASHION      # 패션/의류
  BEAUTY       # 뷰티/화장품
  FOOD         # 식품
  GIFT         # 기프트/기타
  HOME_LIVING  # 홈/리빙
}
```

---

### 9.3 GameStatus

```graphql
enum GameStatus {
  UPCOMING   # 시작 전
  ONGOING    # 진행 중
  ENDED      # 종료됨
  CANCELLED  # 취소됨
}
```

---

### 9.4 GameSortField

```graphql
enum GameSortField {
  MOST_POPULAR    # 인기순
  NEWEST          # 최신순
  ENDING_SOON     # 마감 임박순
  PRICE_LOW       # 낮은 가격순
  PRICE_HIGH      # 높은 가격순
}
```

---

### 9.5 ParticipationStatus

```graphql
enum ParticipationStatus {
  ONGOING     # 진행 중
  COMPLETED   # 완료 (당첨/낙첨 결정됨)
  CANCELLED   # 취소됨
}
```

---

### 9.6 TransactionType

```graphql
enum TransactionType {
  CHARGE              # 충전
  USE                 # 사용 (게임 참가비)
  REFUND              # 환불
  CASH_BACK           # 낙첨 환급
  CONVERSION          # Event ↔ Shopping 전환
  BONUS               # 보너스
  PRIZE_CASH          # 현금성 상품 당첨
}
```

---

### 9.7 UserRole

```graphql
enum UserRole {
  USER    # 일반 사용자
  ADMIN   # 관리자
  SYSTEM  # 시스템
}
```

---

### 9.8 PaymentMethod

```graphql
enum PaymentMethod {
  CARD              # 신용/체크카드
  ACCOUNT_TRANSFER  # 계좌이체
  TOSS_PAY          # 토스페이
  KAKAO_PAY         # 카카오페이
  NAVER_PAY         # 네이버페이
}
```

---

### 9.9 CashConversionDirection

```graphql
enum CashConversionDirection {
  EVENT_TO_SHOPPING    # Event Cash → Shopping Cash
  SHOPPING_TO_EVENT    # Shopping Cash → Event Cash
}
```

---

### 9.10 SocialProvider

```graphql
enum SocialProvider {
  GOOGLE
  APPLE
  KAKAO
}
```

---

### 9.11 NotificationCategory

```graphql
enum NotificationCategory {
  GAME_START      # 게임 시작 알림
  GAME_ENDING     # 마감 임박 알림
  GAME_RESULT     # 결과 발표 알림
  EVENT_PROMO     # 이벤트/프로모션 알림
  SYSTEM          # 시스템 알림
}
```

---

### 9.12 PrizeDeliveryStatus

```graphql
enum PrizeDeliveryStatus {
  PENDING       # 배송 준비 중
  SHIPPED       # 배송 중
  DELIVERED     # 배송 완료
  FAILED        # 배송 실패
}
```

---

### 9.13 Platform

```graphql
enum Platform {
  ANDROID
  IOS
  WEB
}
```

---

### 9.14 SortOrder

```graphql
enum SortOrder {
  ASC    # 오름차순
  DESC   # 내림차순
}
```

---

## 10. 에러 처리

### 10.1 에러 코드

| 코드 | 설명 | HTTP 상태 |
|------|------|-----------|
| `UNAUTHENTICATED` | 인증 필요 | 401 |
| `UNAUTHORIZED` | 권한 없음 | 403 |
| `NOT_FOUND` | 리소스 없음 | 404 |
| `VALIDATION_ERROR` | 입력 검증 실패 | 400 |
| `EMAIL_ALREADY_EXISTS` | 이메일 중복 | 400 |
| `INVALID_CREDENTIALS` | 잘못된 인증 정보 | 401 |
| `ACCOUNT_LOCKED` | 계정 잠김 | 403 |
| `INSUFFICIENT_CASH` | 잔액 부족 | 400 |
| `GAME_FULL` | 참여자 수 초과 | 400 |
| `GAME_ENDED` | 게임 종료됨 | 400 |
| `BLOCK_OCCUPIED` | 블록 이미 선택됨 | 400 |
| `PAYMENT_FAILED` | 결제 실패 | 400 |
| `BLOCKCHAIN_ERROR` | 블록체인 오류 | 500 |
| `INTERNAL_SERVER_ERROR` | 서버 내부 오류 | 500 |
| `RATE_LIMIT_EXCEEDED` | 요청 제한 초과 | 429 |

---

### 10.2 에러 응답 형식

```json
{
  "errors": [
    {
      "message": "사람이 읽을 수 있는 에러 메시지",
      "locations": [{ "line": 2, "column": 3 }],
      "path": ["fieldName", "nestedField"],
      "extensions": {
        "code": "ERROR_CODE",
        "timestamp": "2025-11-20T10:30:00Z",
        "requestId": "req_abc123",
        "field": "email",
        "details": {
          "additionalInfo": "..."
        }
      }
    }
  ],
  "data": null
}
```

---

### 10.3 에러 처리 예시 (Flutter)

```dart
try {
  final result = await client.mutate(
    MutationOptions(
      document: gql(joinGameMutation),
      variables: {'input': input},
    ),
  );

  if (result.hasException) {
    final exception = result.exception!;

    if (exception.graphqlErrors.isNotEmpty) {
      final error = exception.graphqlErrors.first;
      final code = error.extensions?['code'];

      switch (code) {
        case 'INSUFFICIENT_CASH':
          final currentBalance = error.extensions?['currentBalance'];
          showDialog('잔액 부족', '현재 잔액: $currentBalance원');
          break;
        case 'GAME_FULL':
          showDialog('참여 불가', '참여 가능 인원이 모두 찼습니다');
          break;
        default:
          showDialog('오류', error.message);
      }
    } else if (exception.linkException != null) {
      showDialog('네트워크 오류', '인터넷 연결을 확인해주세요');
    }
  } else {
    // Success
    final data = result.data!['joinGame'];
    showDialog('성공', '게임 참가가 완료되었습니다!');
  }
} catch (e) {
  showDialog('오류', '알 수 없는 오류가 발생했습니다');
}
```

---

## 11. 페이지네이션

### 11.1 Cursor-based Pagination

BlockPick API는 Relay 스타일의 커서 기반 페이지네이션을 사용합니다.

**Connection 타입**:
```graphql
type GameConnection {
  edges: [GameEdge!]!
  pageInfo: PageInfo!
  totalCount: Int!
}

type GameEdge {
  node: Game!
  cursor: String!
}

type PageInfo {
  hasNextPage: Boolean!
  hasPreviousPage: Boolean!
  startCursor: String
  endCursor: String
}
```

---

### 11.2 페이지네이션 사용 예시

**첫 페이지 로드**:
```graphql
query GetGames {
  games(first: 20) {
    edges {
      node {
        id
        title
      }
      cursor
    }
    pageInfo {
      hasNextPage
      endCursor
    }
    totalCount
  }
}
```

**다음 페이지 로드**:
```graphql
query GetGames {
  games(first: 20, after: "cursor_from_previous_page") {
    edges {
      node {
        id
        title
      }
      cursor
    }
    pageInfo {
      hasNextPage
      endCursor
    }
    totalCount
  }
}
```

---

## 12. Rate Limiting

### 12.1 제한 정책

| 사용자 타입 | 분당 요청 | 시간당 요청 | 일일 요청 |
|-------------|-----------|-------------|-----------|
| 비인증 | 30 | 300 | 1,000 |
| 인증 (USER) | 60 | 1,000 | 10,000 |
| 관리자 (ADMIN) | 300 | 5,000 | 무제한 |

---

### 12.2 응답 헤더

```
X-RateLimit-Limit: 60
X-RateLimit-Remaining: 45
X-RateLimit-Reset: 1700000000
```

---

### 12.3 제한 초과 시 응답

```json
{
  "errors": [
    {
      "message": "요청 한도를 초과했습니다. 잠시 후 다시 시도해주세요",
      "extensions": {
        "code": "RATE_LIMIT_EXCEEDED",
        "retryAfter": 60
      }
    }
  ]
}
```

**HTTP 상태**: 429 Too Many Requests

---

## 13. 캐싱 전략

### 13.1 캐시 제어 헤더

각 쿼리는 적절한 캐시 정책을 가집니다:

| 쿼리 | 캐시 시간 | 이유 |
|------|-----------|------|
| `me` | 5분 | 사용자 정보는 자주 변경되지 않음 |
| `games` (ONGOING) | 30초 | 참여자 수가 실시간으로 변경됨 |
| `games` (ENDED) | 1시간 | 종료된 게임은 변경되지 않음 |
| `game(id)` | 10초 | 실시간 업데이트 필요 |
| `transactions` | 1분 | 거래 내역은 자주 변경되지 않음 |

---

### 13.2 Cache-Control 헤더 예시

```
Cache-Control: public, max-age=300
Cache-Control: private, max-age=60
Cache-Control: no-cache
```

---

### 13.3 클라이언트 캐싱 (Apollo Client)

```dart
// Apollo Client 캐시 설정
final cache = GraphQLCache(
  store: HiveStore(),
);

final client = GraphQLClient(
  link: httpLink,
  cache: cache,
  defaultPolicies: DefaultPolicies(
    query: Policies(
      fetch: FetchPolicy.cacheFirst,
    ),
    mutate: Policies(
      fetch: FetchPolicy.networkOnly,
    ),
  ),
);

// 특정 쿼리에 대한 캐시 정책 지정
final result = await client.query(
  QueryOptions(
    document: gql(getGamesQuery),
    fetchPolicy: FetchPolicy.cacheAndNetwork,
  ),
);
```

---

## 14. API 사용 예제

### 14.1 회원가입 → 로그인 → 게임 참가 전체 플로우

```dart
import 'package:graphql_flutter/graphql_flutter.dart';

class BlockPickAPI {
  final GraphQLClient client;

  BlockPickAPI(this.client);

  // 1. 회원가입
  Future<SignUpResult> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    const mutation = '''
      mutation SignUpWithEmail(\$input: SignUpInput!) {
        signUpWithEmail(input: \$input) {
          success
          user { id email name }
          accessToken
          refreshToken
          message
        }
      }
    ''';

    final result = await client.mutate(
      MutationOptions(
        document: gql(mutation),
        variables: {
          'input': {
            'email': email,
            'password': password,
            'name': name,
            'agreeToTerms': true,
            'agreeToPrivacy': true,
          },
        },
      ),
    );

    if (result.hasException) {
      throw result.exception!;
    }

    final data = result.data!['signUpWithEmail'];
    return SignUpResult.fromJson(data);
  }

  // 2. 게임 목록 조회
  Future<List<Game>> getGames({
    GameType? gameType,
    GameCategory? category,
  }) async {
    const query = '''
      query GetGames(\$filter: GameFilterInput, \$first: Int) {
        games(filter: \$filter, first: \$first) {
          edges {
            node {
              id
              title
              gameType
              productImageUrl
              entryFee
              currentParticipants
              maxParticipants
              endDate
            }
          }
        }
      }
    ''';

    final result = await client.query(
      QueryOptions(
        document: gql(query),
        variables: {
          'filter': {
            if (gameType != null) 'gameType': gameType.name.toUpperCase(),
            if (category != null) 'category': category.name.toUpperCase(),
            'status': 'ONGOING',
          },
          'first': 20,
        },
        fetchPolicy: FetchPolicy.networkOnly,
      ),
    );

    if (result.hasException) {
      throw result.exception!;
    }

    final edges = result.data!['games']['edges'] as List;
    return edges.map((e) => Game.fromJson(e['node'])).toList();
  }

  // 3. 게임 참가
  Future<JoinGameResult> joinGame({
    required String gameId,
    required List<BlockCoordinate> selectedBlocks,
  }) async {
    const mutation = '''
      mutation JoinGame(\$input: JoinGameInput!) {
        joinGame(input: \$input) {
          success
          participation {
            id
            transactionHash
          }
          remainingCash
          message
        }
      }
    ''';

    final result = await client.mutate(
      MutationOptions(
        document: gql(mutation),
        variables: {
          'input': {
            'gameId': gameId,
            'selectedBlocks': selectedBlocks
              .map((b) => {'x': b.x, 'y': b.y})
              .toList(),
          },
        },
      ),
    );

    if (result.hasException) {
      throw result.exception!;
    }

    final data = result.data!['joinGame'];
    return JoinGameResult.fromJson(data);
  }

  // 4. 참여 내역 조회
  Future<List<Participation>> getMyParticipations({
    ParticipationStatus? status,
  }) async {
    const query = '''
      query GetMyParticipations(\$filter: ParticipationFilterInput) {
        me {
          participations(filter: \$filter, first: 50) {
            edges {
              node {
                id
                game {
                  id
                  title
                  productImageUrl
                  gameType
                  status
                }
                selectedBlocks { x y }
                entryFee
                isWinner
                refundAmount
                createdAt
              }
            }
          }
        }
      }
    ''';

    final result = await client.query(
      QueryOptions(
        document: gql(query),
        variables: {
          if (status != null) 'filter': {'status': status.name.toUpperCase()},
        },
      ),
    );

    if (result.hasException) {
      throw result.exception!;
    }

    final edges = result.data!['me']['participations']['edges'] as List;
    return edges.map((e) => Participation.fromJson(e['node'])).toList();
  }
}
```

---

### 14.2 실시간 Subscription 사용 예시

```dart
import 'package:graphql_flutter/graphql_flutter.dart';

class GameRealtimeUpdates {
  final GraphQLClient client;

  GameRealtimeUpdates(this.client);

  // 게임 참여자 수 실시간 업데이트
  Stream<int> watchParticipantCount(String gameId) {
    const subscription = '''
      subscription OnGameParticipantCountChanged(\$gameId: ID!) {
        gameParticipantCountChanged(gameId: \$gameId) {
          currentParticipants
        }
      }
    ''';

    return client
      .subscribe(
        SubscriptionOptions(
          document: gql(subscription),
          variables: {'gameId': gameId},
        ),
      )
      .map((result) {
        if (result.hasException) {
          throw result.exception!;
        }
        return result.data!['gameParticipantCountChanged']['currentParticipants'] as int;
      });
  }

  // 알림 실시간 수신
  Stream<Notification> watchNotifications() {
    const subscription = '''
      subscription OnNotificationReceived {
        notificationReceived {
          id
          title
          body
          category
          createdAt
        }
      }
    ''';

    return client
      .subscribe(
        SubscriptionOptions(
          document: gql(subscription),
        ),
      )
      .map((result) {
        if (result.hasException) {
          throw result.exception!;
        }
        return Notification.fromJson(result.data!['notificationReceived']);
      });
  }
}

// 사용 예시
void listenToGameUpdates(String gameId) {
  final updates = GameRealtimeUpdates(client);

  updates.watchParticipantCount(gameId).listen(
    (count) {
      print('현재 참여자 수: $count');
      // UI 업데이트
    },
    onError: (error) {
      print('Error: $error');
    },
  );
}
```

---

### 14.3 에러 처리 Best Practice

```dart
class APIErrorHandler {
  static void handle(OperationException exception, {
    required Function(String) onError,
    Function? onUnauthenticated,
    Function? onNetworkError,
  }) {
    if (exception.graphqlErrors.isNotEmpty) {
      final error = exception.graphqlErrors.first;
      final code = error.extensions?['code'] as String?;

      switch (code) {
        case 'UNAUTHENTICATED':
          onUnauthenticated?.call();
          break;
        case 'VALIDATION_ERROR':
          final field = error.extensions?['field'];
          onError('$field: ${error.message}');
          break;
        case 'INSUFFICIENT_CASH':
          final currentBalance = error.extensions?['currentBalance'];
          onError('잔액이 부족합니다. 현재: ${currentBalance}원');
          break;
        default:
          onError(error.message);
      }
    } else if (exception.linkException != null) {
      if (exception.linkException is NetworkException) {
        onNetworkError?.call();
      } else {
        onError('알 수 없는 오류가 발생했습니다');
      }
    }
  }
}

// 사용 예시
try {
  await api.joinGame(gameId: gameId, selectedBlocks: blocks);
} on OperationException catch (e) {
  APIErrorHandler.handle(
    e,
    onError: (message) => showSnackbar(message),
    onUnauthenticated: () => navigateToLogin(),
    onNetworkError: () => showSnackbar('인터넷 연결을 확인해주세요'),
  );
}
```

---

## 부록 A: GraphQL 스키마 전체

전체 스키마는 GraphQL Playground에서 확인할 수 있습니다:
- **Production**: https://api.blockpick.com/graphql
- **Staging**: https://staging-api.blockpick.com/graphql

또는 Introspection 쿼리로 스키마 다운로드:
```graphql
query IntrospectionQuery {
  __schema {
    queryType { name }
    mutationType { name }
    subscriptionType { name }
    types {
      ...FullType
    }
  }
}

fragment FullType on __Type {
  kind
  name
  description
  fields(includeDeprecated: true) {
    name
    description
    args {
      ...InputValue
    }
    type {
      ...TypeRef
    }
  }
}

fragment InputValue on __InputValue {
  name
  description
  type { ...TypeRef }
  defaultValue
}

fragment TypeRef on __Type {
  kind
  name
  ofType {
    kind
    name
  }
}
```

---

## 부록 B: 버전 히스토리

| 버전 | 날짜 | 변경 내용 |
|------|------|-----------|
| 1.0 | 2025-11-20 | 초기 작성 |

---

## 부록 C: 참고 문서

- [GraphQL 공식 문서](https://graphql.org/)
- [Relay Cursor Connections Specification](https://relay.dev/graphql/connections.htm)
- [GraphQL Best Practices](https://graphql.org/learn/best-practices/)
- [Apollo Client for Flutter](https://pub.dev/packages/graphql_flutter)

---

**문서 작성자**: BlockPick Backend Team
**문서 승인자**: CTO
**다음 리뷰**: 2025-12-20
