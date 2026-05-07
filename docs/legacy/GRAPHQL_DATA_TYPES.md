# GraphQL 데이터 타입 상세 명세

> Blockpick GraphQL API의 모든 데이터 타입과 구조 정의

**최종 업데이트**: 2025-10-28

---

## 목차

1. [사용자 관련 타입](#사용자-관련-타입)
2. [게임 관련 타입](#게임-관련-타입)
3. [상품 관련 타입](#상품-관련-타입)
4. [응답 타입](#응답-타입)
5. [입력 타입](#입력-타입)
6. [Enum 타입](#enum-타입)
7. [공통 타입](#공통-타입)
8. [타입 관계도](#타입-관계도)

---

## 사용자 관련 타입

### User

사용자 정보를 나타내는 메인 타입

```graphql
type User {
  id: String!                 # 사용자 고유 ID (UUID)
  email: String!              # 이메일 주소
  nickname: String            # 닉네임
  avatar: String              # 프로필 이미지 URL
  createdAt: String!          # 생성 시간 (ISO 8601)
  updatedAt: String           # 수정 시간 (ISO 8601)
  balance: Float              # 보유 잔액
  totalGamesPlayed: Int       # 총 플레이한 게임 수
  totalWins: Int              # 총 승리 수
  winRate: Float              # 승률 (0.0 ~ 1.0)
}
```

**필드 설명**:

| 필드 | 타입 | Nullable | 설명 |
|------|------|----------|------|
| `id` | String | ❌ | UUID 형식의 사용자 고유 식별자 |
| `email` | String | ❌ | 사용자 이메일 주소 (로그인 ID) |
| `nickname` | String | ✅ | 사용자 닉네임 (최대 20자) |
| `avatar` | String | ✅ | 프로필 이미지 URL |
| `createdAt` | String | ❌ | 계정 생성 일시 (ISO 8601 포맷) |
| `updatedAt` | String | ✅ | 마지막 수정 일시 |
| `balance` | Float | ✅ | 보유 캐시/포인트 잔액 |
| `totalGamesPlayed` | Int | ✅ | 참여한 총 게임 수 |
| `totalWins` | Int | ✅ | 승리한 게임 수 |
| `winRate` | Float | ✅ | 승률 (totalWins / totalGamesPlayed) |

**예시**:
```json
{
  "id": "550e8400-e29b-41d4-a716-446655440000",
  "email": "user@example.com",
  "nickname": "플레이어123",
  "avatar": "https://cdn.blockpick.com/avatars/user123.jpg",
  "createdAt": "2025-01-15T10:30:00Z",
  "updatedAt": "2025-10-28T08:00:00Z",
  "balance": 75000.0,
  "totalGamesPlayed": 25,
  "totalWins": 8,
  "winRate": 0.32
}
```

---

## 게임 관련 타입

### Game

게임 정보를 나타내는 메인 타입

```graphql
type Game {
  id: String!                 # 게임 고유 ID (UUID)
  title: String!              # 게임 제목
  description: String         # 게임 설명
  gameType: GameType          # 게임 타입 (DAILY, SELECT, VIBE)
  status: GameStatus!         # 게임 상태
  maxPlayers: Int             # 최대 참가자 수
  currentPlayers: Int         # 현재 참가자 수
  entryFee: Float             # 참가비
  prizePool: Float            # 상금 풀
  startTime: String           # 시작 시간 (ISO 8601)
  endTime: String             # 종료 시간 (ISO 8601)
  rules: String               # 게임 규칙
  onchainTxHash: String       # 블록체인 트랜잭션 해시
  onchainContractAddr: String # 블록체인 컨트랙트 주소
  createdAt: String!          # 생성 시간
  updatedAt: String           # 수정 시간
  gameProducts: [GameProduct!]! # 게임 상품 목록
}
```

**필드 설명**:

| 필드 | 타입 | Nullable | 설명 |
|------|------|----------|------|
| `id` | String | ❌ | UUID 형식의 게임 고유 식별자 |
| `title` | String | ❌ | 게임 제목 |
| `description` | String | ✅ | 게임 상세 설명 |
| `gameType` | GameType | ✅ | 게임 타입 (DAILY/SELECT/VIBE) |
| `status` | GameStatus | ❌ | 현재 게임 상태 |
| `maxPlayers` | Int | ✅ | 최대 참가 가능 인원 |
| `currentPlayers` | Int | ✅ | 현재 참가한 인원 |
| `entryFee` | Float | ✅ | 게임 참가비 (단위: 원) |
| `prizePool` | Float | ✅ | 총 상금 풀 |
| `startTime` | String | ✅ | 게임 시작 시간 |
| `endTime` | String | ✅ | 게임 종료 시간 |
| `rules` | String | ✅ | 게임 규칙 설명 |
| `onchainTxHash` | String | ✅ | 블록체인 배포 트랜잭션 해시 (0x...) |
| `onchainContractAddr` | String | ✅ | 스마트 컨트랙트 주소 (0x...) |
| `createdAt` | String | ❌ | 게임 생성 일시 |
| `updatedAt` | String | ✅ | 게임 수정 일시 |
| `gameProducts` | [GameProduct!] | ❌ | 게임에 포함된 상품 목록 |

**예시**:
```json
{
  "id": "01a18547-64cc-4e9e-9816-3161f0278018",
  "title": "상품 픽 게임 #3",
  "description": "1:1 상품 게임",
  "gameType": null,
  "status": "IN_PROGRESS",
  "maxPlayers": null,
  "currentPlayers": null,
  "entryFee": 1000.0,
  "prizePool": null,
  "startTime": "2025-10-28T01:26:11Z",
  "endTime": "2025-10-30T00:26:11Z",
  "rules": null,
  "onchainTxHash": "0x16e084aa0597da7eb08cb7abbb3c4a96652470c298857bc1fb53b82e70cc0563",
  "onchainContractAddr": "0x63d469d778f46eaa870b3ea689ad980bac94c6ad",
  "createdAt": "2025-10-28T00:26:11.832543Z",
  "updatedAt": "2025-10-28T00:26:44.151537Z",
  "gameProducts": [...]
}
```

---

### GameItem

게임 목록 조회용 타입 (gameList 쿼리에서 사용)

```graphql
type GameItem {
  id: String!
  title: String!
  description: String
  type: String!               # 게임 타입
  category: String!           # 카테고리
  status: String!             # 상태
  entryFee: Int!              # 참가비
  currency: String!           # 화폐 단위
  minEntries: Int!            # 최소 참가자 수
  maxEntries: Int!            # 최대 참가자 수
  currentEntries: Int!        # 현재 참가자 수 (⚠️ 백엔드 이슈)
  maxEntriesPerUser: Int!     # 사용자당 최대 참가 횟수
  rewardPoint: Int!           # 보상 포인트
  gridRows: Int!              # 그리드 행 수
  gridCols: Int!              # 그리드 열 수
  startTime: String!          # 시작 시간
  endTime: String!            # 종료 시간
  isRecommended: Boolean!     # 추천 게임 여부
  onchainTxHash: String       # 블록체인 트랜잭션 해시
  onchainContractAddr: String # 블록체인 컨트랙트 주소
  createdAt: String!          # 생성 시간
  gameProducts: [GameProductItem!] # 게임 상품 목록
}
```

**Game vs GameItem 차이점**:
- `GameItem`은 리스트 조회에 최적화된 타입
- 그리드 정보 (`gridRows`, `gridCols`) 포함
- 추천 여부 (`isRecommended`) 포함
- 화폐 단위 (`currency`) 명시
- 최소/최대 참가자 정보 상세화

---

### GameProduct

게임에 포함된 상품 정보

```graphql
type GameProduct {
  id: String!
  sequence: Int!              # 상품 순서 (0부터 시작)
  active: Boolean!            # 활성화 여부
  isGrandPrize: Boolean!      # 대상 상품 여부
  product: Product!           # 상품 상세 정보
  createdAt: String!          # 추가된 시간
  updatedAt: String!          # 수정된 시간
}
```

**필드 설명**:
- `sequence`: 게임 내 상품 표시 순서 (0, 1, 2, ...)
- `active`: 현재 활성화된 상품인지 여부
- `isGrandPrize`: 메인/대상 상품인지 여부 (그리드 게임에서 중요)

**예시**:
```json
{
  "id": "246ae527-0df1-4bb6-9782-c82db6728fcc",
  "sequence": 0,
  "active": true,
  "isGrandPrize": false,
  "product": {...},
  "createdAt": "2025-10-28T00:26:14.160211Z",
  "updatedAt": "2025-10-28T00:26:14.160211Z"
}
```

---

### GameProductItem

게임 목록용 상품 정보

```graphql
type GameProductItem {
  id: String!
  position: Int               # 그리드 위치 (0~35 등)
  sequence: Int               # 상품 순서
  isGrandPrize: Boolean!      # 대상 상품 여부
  product: ProductItem!       # 간소화된 상품 정보
}
```

**필드 설명**:
- `position`: 그리드에서의 위치 (예: 6x6 그리드에서 0~35)
- `product`: `Product` 대신 간소화된 `ProductItem` 사용

---

### UserGame

사용자-게임 참여 관계

```graphql
type UserGame {
  id: String!
  user: User!                 # 참여한 사용자
  game: Game!                 # 참여한 게임
  joinedAt: String!           # 참여 시간 (ISO 8601)
  status: UserGameStatus!     # 참여 상태
}
```

**UserGameStatus 값**:
- `JOINED`: 참여함
- `PLAYING`: 플레이중
- `COMPLETED`: 완료
- `WITHDRAWN`: 철회

**예시**:
```json
{
  "id": "usergame-uuid",
  "user": {
    "id": "user-uuid",
    "nickname": "플레이어123"
  },
  "game": {
    "id": "game-uuid",
    "title": "상품 픽 게임 #1"
  },
  "joinedAt": "2025-10-28T02:00:00Z",
  "status": "PLAYING"
}
```

---

### GameResult

게임 결과 정보

```graphql
type GameResult {
  id: String!
  game: Game!                 # 게임 정보
  user: User!                 # 사용자 정보
  score: Int                  # 점수
  rank: Int                   # 순위
  reward: Float               # 보상 금액
  createdAt: String!          # 결과 생성 시간
}
```

**필드 설명**:
- `score`: 게임에서 획득한 점수
- `rank`: 최종 순위 (1위, 2위, ...)
- `reward`: 받은 보상 금액 (원 단위)

---

## 상품 관련 타입

### Product

상품 상세 정보

```graphql
type Product {
  id: String!
  name: String!               # 상품명
  description: String         # 상품 설명
  brand: String               # 브랜드
  category: String            # 카테고리
  sku: String                 # 상품 코드 (Stock Keeping Unit)
  defaultImage: String        # 기본 이미지 URL
  imageUrl: String            # 이미지 URL
  thumbnailUrl: String        # 썸네일 URL
  price: Int                  # 판매가
  originalPrice: Int          # 정가
  countryCode: String         # 국가 코드 (KR, US, ...)
  active: Boolean             # 활성화 여부
  createdAt: String!          # 생성 시간
  updatedAt: String!          # 수정 시간
}
```

**이미지 필드 차이**:
- `defaultImage`: 기본 표시 이미지 (대표 이미지)
- `imageUrl`: 상세 이미지 URL
- `thumbnailUrl`: 썸네일 이미지 URL (작은 크기)

**예시**:
```json
{
  "id": "9feb5623-24bb-443f-94ef-f69a09162046",
  "name": "iPad Pro 12.9\" (JPG)",
  "description": "iPad Pro 12.9인치 - 이미지 형식: JPG (로딩 속도 및 해상도 테스트용)",
  "brand": "Apple",
  "category": null,
  "sku": "IPAD-PRO-JPG-001",
  "defaultImage": "https://blockpick-dev-storage.s3.us-west-2.amazonaws.com/products/2025/10/27/8e758de6_iPad Pro_1500.jpg",
  "imageUrl": "https://blockpick-dev-storage.s3.us-west-2.amazonaws.com/products/2025/10/27/8e758de6_iPad Pro_1500.jpg",
  "thumbnailUrl": "https://blockpick-dev-storage.s3.us-west-2.amazonaws.com/products/2025/10/27/8526027f_iPad Pro_1500_thumb.jpg",
  "price": null,
  "originalPrice": null,
  "countryCode": null,
  "active": null
}
```

---

### ProductItem

간소화된 상품 정보 (목록용)

```graphql
type ProductItem {
  id: String!
  sku: String!                # 상품 코드
  brand: String!              # 브랜드
  name: String!               # 상품명
  description: String         # 간단한 설명
  defaultImage: String        # 기본 이미지 URL
}
```

**Product vs ProductItem**:
- `ProductItem`은 리스트 표시용으로 최소한의 정보만 포함
- 가격 정보 제외
- 단일 이미지 URL만 포함

---

## 응답 타입

### CommonResponse

기본 응답 타입

```graphql
type CommonResponse {
  success: Boolean!           # 성공 여부
  code: String!               # 응답 코드
  message: String!            # 응답 메시지
}
```

**응답 코드 예시**:
- `SUCCESS`: 성공
- `UNAUTHORIZED`: 인증 실패
- `INVALID_CREDENTIALS`: 잘못된 인증 정보
- `NOT_FOUND`: 찾을 수 없음
- `VALIDATION_ERROR`: 유효성 검증 실패

---

### LoginResponse

로그인 응답 타입

```graphql
type LoginResponse {
  success: Boolean!
  code: String!
  message: String!
  accessToken: String         # JWT 액세스 토큰
  refreshToken: String        # JWT 리프레시 토큰
  user: User                  # 사용자 정보
}
```

**토큰 정보**:
- `accessToken`: API 호출에 사용 (짧은 만료 시간)
- `refreshToken`: 액세스 토큰 갱신용 (긴 만료 시간)

---

### UserResponse

사용자 정보 응답 타입

```graphql
type UserResponse {
  success: Boolean!
  code: String!
  message: String!
  user: User                  # 사용자 정보
}
```

---

### GamesResponse

게임 목록 응답 타입

```graphql
type GamesResponse {
  success: Boolean!
  code: String!
  message: String!
  games: [Game!]!             # 게임 목록
}
```

---

### GameResponse

단일 게임 응답 타입

```graphql
type GameResponse {
  success: Boolean!
  code: String!
  message: String!
  game: Game                  # 게임 정보
}
```

---

### GameListResponse

페이지네이션된 게임 목록 응답

```graphql
type GameListResponse {
  success: Boolean!
  code: String!
  message: String!
  games: [GameItem!]!         # 게임 아이템 목록
  pageInfo: PaginationInfo!   # 페이지 정보
}
```

---

### GameParticipantsResponse

게임 참여자 목록 응답

```graphql
type GameParticipantsResponse {
  success: Boolean!
  code: String!
  message: String!
  participants: [UserGame!]!  # 참여자 목록
  pageInfo: PaginationInfo!   # 페이지 정보
}
```

---

### GameResultsResponse

게임 결과 목록 응답

```graphql
type GameResultsResponse {
  success: Boolean!
  code: String!
  message: String!
  results: [GameResult!]!     # 결과 목록
  pageInfo: PaginationInfo!   # 페이지 정보
}
```

---

### UserGamesResponse

사용자 게임 참여 내역 응답

```graphql
type UserGamesResponse {
  success: Boolean!
  code: String!
  message: String!
  userGames: [UserGame!]!     # 참여 게임 목록
}
```

---

### SignUpResponse

회원가입 응답 타입

```graphql
type SignUpResponse {
  success: Boolean!
  code: String!
  message: String!
  user: User                  # 생성된 사용자 정보
}
```

---

### UserProfileUpdateResult

프로필 업데이트 응답 타입

```graphql
type UserProfileUpdateResult {
  success: Boolean!
  code: String!
  message: String!
  user: User                  # 업데이트된 사용자 정보
}
```

---

### VerifyCodeResponse

코드 인증 응답 타입

```graphql
type VerifyCodeResponse {
  success: Boolean!
  code: String!
  message: String!
}
```

---

## 입력 타입

### LoginRequest

로그인 요청

```graphql
input LoginRequest {
  email: String!              # 이메일 주소
  password: String!           # 비밀번호
}
```

---

### SocialLoginRequest

소셜 로그인 요청

```graphql
input SocialLoginRequest {
  provider: String!           # 제공자 (KAKAO, NAVER, GOOGLE, FACEBOOK)
  socialId: String!           # 소셜 플랫폼 사용자 ID
  email: String!              # 이메일
  name: String                # 이름
  profileImageUrl: String     # 프로필 이미지 URL
}
```

---

### SignUpRequest

회원가입 요청

```graphql
input SignUpRequest {
  email: String!              # 이메일 주소
  password: String            # 비밀번호 (소셜 로그인 시 선택)
  nickname: String            # 닉네임
  profileImageUrl: String     # 프로필 이미지 URL

  # 소셜 로그인용 (선택적)
  socialProvider: SocialProvider
  socialId: String
  socialEmail: String
  socialName: String
}
```

---

### VerifyCodeRequest

코드 인증 요청

```graphql
input VerifyCodeRequest {
  email: String!              # 이메일 주소
  code: String!               # 인증 코드 (6자리 숫자)
  verifyType: VerifyType!     # 인증 타입
}
```

---

### ChangePasswordRequest

비밀번호 변경 요청

```graphql
input ChangePasswordRequest {
  currentPassword: String!    # 현재 비밀번호
  newPassword: String!        # 새 비밀번호
}
```

---

### ResetPasswordRequest

비밀번호 재설정 요청

```graphql
input ResetPasswordRequest {
  email: String!              # 이메일 주소
  verificationCode: String!   # 인증 코드
  newPassword: String!        # 새 비밀번호
}
```

---

### WithdrawUserRequest

회원 탈퇴 요청

```graphql
input WithdrawUserRequest {
  password: String!           # 비밀번호 확인
  reason: String              # 탈퇴 사유 (선택)
}
```

---

### UserProfileInput

프로필 업데이트 요청

```graphql
input UserProfileInput {
  nickname: String            # 새 닉네임
  email: String               # 새 이메일
}
```

---

### CreateGameInput

게임 생성 요청

```graphql
input CreateGameInput {
  title: String!
  description: String
  gameType: GameType!
  maxPlayers: Int!
  entryFee: Float
  prizePool: Float
  startTime: String
  endTime: String
  rules: String
}
```

---

### GameResultInput

게임 결과 입력

```graphql
input GameResultInput {
  gameId: String!
  userId: String!
  score: Int
  rank: Int
  reward: Float
}
```

---

## Enum 타입

### GameType

게임 타입

```graphql
enum GameType {
  DAILY    # 데일리 게임 (매일 진행)
  SELECT   # 셀렉트 게임 (선택형)
  VIBE     # 바이브 게임 (분위기 게임)
}
```

---

### GameStatus

게임 상태

```graphql
enum GameStatus {
  SCHEDULED    # 예정됨 (시작 전)
  IN_PROGRESS  # 진행중
  PAUSED       # 일시정지
  SETTLING     # 정산중 (게임 종료 후 결과 처리중)
  ENDED        # 종료됨
  FAILED       # 실패 (에러 등으로 게임 진행 불가)
}
```

**상태 전이**:
```
SCHEDULED → IN_PROGRESS → SETTLING → ENDED
                ↓
              PAUSED → IN_PROGRESS
                ↓
              FAILED
```

---

### UserGameStatus

사용자-게임 참여 상태

```graphql
enum UserGameStatus {
  JOINED      # 참여함 (게임 참가 완료)
  PLAYING     # 플레이중 (게임 진행중)
  COMPLETED   # 완료 (게임 종료)
  WITHDRAWN   # 철회 (참가 취소)
}
```

---

### SocialProvider

소셜 로그인 제공자

```graphql
enum SocialProvider {
  KAKAO       # 카카오
  NAVER       # 네이버
  GOOGLE      # 구글
  FACEBOOK    # 페이스북
}
```

---

### VerifyType

인증 타입

```graphql
enum VerifyType {
  SIGN_UP           # 회원가입 인증
  CHANGE_PASSWORD   # 비밀번호 변경 인증
  WITHDRAW          # 회원탈퇴 인증
}
```

---

## 공통 타입

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

**예시**:
```json
{
  "currentPage": 0,
  "pageSize": 20,
  "totalPages": 5,
  "totalElements": 98,
  "hasNext": true,
  "hasPrevious": false
}
```

---

### PageInfo

페이지 정보 (커서 기반)

```graphql
type PageInfo {
  hasNextPage: Boolean!       # 다음 페이지 존재 여부
  hasPreviousPage: Boolean!   # 이전 페이지 존재 여부
  startCursor: String         # 시작 커서
  endCursor: String           # 종료 커서
}
```

---

### Error

에러 정보

```graphql
type Error {
  code: String!               # 에러 코드
  message: String!            # 에러 메시지
  field: String               # 에러가 발생한 필드
}
```

**에러 코드 예시**:
- `INVALID_INPUT`: 잘못된 입력
- `DUPLICATE_EMAIL`: 중복된 이메일
- `WEAK_PASSWORD`: 약한 비밀번호
- `INVALID_CODE`: 잘못된 인증 코드

---

## 타입 관계도

### 사용자-게임 관계

```
User ──────┐
           │
           ├──> UserGame <──┐
           │                 │
           └──> GameResult   │
                             │
                           Game ──> GameProduct ──> Product
```

### 응답 타입 관계

```
CommonResponse (기본)
  │
  ├── LoginResponse (+ accessToken, refreshToken, user)
  ├── UserResponse (+ user)
  ├── GameResponse (+ game)
  ├── GamesResponse (+ games[])
  ├── GameListResponse (+ games[], pageInfo)
  ├── GameParticipantsResponse (+ participants[], pageInfo)
  └── GameResultsResponse (+ results[], pageInfo)
```

### 게임-상품 관계

```
Game
  └── gameProducts: [GameProduct!]!
        ├── id: String!
        ├── sequence: Int!
        ├── isGrandPrize: Boolean!
        └── product: Product!
              ├── id: String!
              ├── name: String!
              ├── brand: String
              ├── images (defaultImage, imageUrl, thumbnailUrl)
              └── prices (price, originalPrice)
```

---

## 필드 네이밍 규칙

### 날짜/시간 필드
- `createdAt`: 생성 시간
- `updatedAt`: 수정 시간
- `joinedAt`: 참여 시간
- `startTime`: 시작 시간
- `endTime`: 종료 시간

모두 **ISO 8601** 형식 사용: `2025-10-28T01:26:11Z`

### ID 필드
- 모든 ID는 **UUID** 형식 (36자, 하이픈 포함)
- 예: `550e8400-e29b-41d4-a716-446655440000`

### 블록체인 관련 필드
- `onchainTxHash`: 트랜잭션 해시 (0x + 64자)
- `onchainContractAddr`: 컨트랙트 주소 (0x + 40자)

### 불린 필드
- `is-` 접두사: `isGrandPrize`, `isRecommended`
- `has-` 접두사: `hasNext`, `hasPrevious`

### 카운트 필드
- `total-` 접두사: `totalGamesPlayed`, `totalWins`
- `current-` 접두사: `currentPlayers`, `currentEntries`
- `max-` 접두사: `maxPlayers`, `maxEntries`
- `min-` 접두사: `minEntries`

---

## 타입 사용 시 주의사항

### 1. Nullable 필드 처리

많은 필드가 nullable이므로 null 체크 필수:

```typescript
// ✅ Good
const balance = user.balance ?? 0;
const nickname = user.nickname ?? '익명';

// ❌ Bad
const balance = user.balance; // null일 수 있음
```

### 2. Enum 값 사용

Enum은 문자열로 전달:

```graphql
# ✅ Good
query {
  gameList(status: IN_PROGRESS) { ... }
}

# ❌ Bad
query {
  gameList(status: "IN_PROGRESS") { ... }
}
```

### 3. ISO 8601 날짜 파싱

날짜 문자열은 ISO 8601 형식:

```typescript
// ✅ Good
const startDate = new Date(game.startTime);

// Display
const formatted = new Date(game.startTime).toLocaleString('ko-KR');
```

### 4. 페이지네이션 처리

페이지는 0부터 시작:

```graphql
# 첫 페이지
gameList(page: 0, size: 20)

# 두 번째 페이지
gameList(page: 1, size: 20)
```

---

**문서 버전**: 1.0
**마지막 업데이트**: 2025-10-28
