# BlockPick 앱 인수인계 문서

이 문서는 BlockPick 앱을 처음 맡는 개발자가 프로젝트의 목적, 기능, 구조, API, 실행 방법, 미완성 지점을 빠르게 이해하도록 만든 단일 인수인계 문서입니다.

## 1. 프로젝트 한 줄 설명

BlockPick은 사용자가 이벤트/상품 단위의 격자에서 특정 블록을 선택해 응모하고, 포인트/미션/광고/추천/당첨 흐름을 통해 참여를 확장하는 Flutter 모바일 앱입니다.  
현재 앱은 Flutter로 작성되어 있고, 서버 통신은 주로 GraphQL API(`https://api-dev.blockpick.net/graphql`)를 사용합니다.

## 2. 사용자가 앱에서 할 수 있는 일

### 핵심 기능

- 블록픽 목록 조회
- 블록픽 상세 조회
- 격자에서 블록 선택
- 티켓을 사용해 블록픽 참여
- 내 참여 내역 조회
- 당첨 내역 조회 및 배송지 입력
- 포인트 지갑/거래 내역 조회
- 출석체크, 미니게임으로 포인트 획득
- 미션 완료 후 티켓 획득
- 광고 시청 후 티켓 보상
- 친구 초대 코드 조회/공유/적용
- 알림 목록 조회 및 읽음 처리
- 알림 설정 변경
- 로그인, 회원가입, 이메일/SMS 인증, 소셜 로그인
- 파트너 웹 게임 WebView 실행
- Kakao 공유, Mixpanel 분석, Sentry 에러 모니터링, FCM 푸시, AdMob 보상형 광고 연동 준비

### 아직 mock/임시인 기능

아래 기능은 화면은 있지만 실제 API 연동이 없거나 일부만 연결되어 있습니다.

- 소원/Wish 전체: `lib/providers/wish_provider.dart`가 mock 데이터를 사용
- 일부 My 페이지: 거래내역, 주문내역, 쿠폰, 공지사항, 리뷰 관리, 구형 당첨/참여 내역
- 쇼핑몰/몰 화면: 대부분 정적 또는 외부 이미지 기반 mock
- 위너/리뷰 영역 일부: `MockWinnerData`, `MockReviewData`
- 프로필 수정의 닉네임 중복 확인/이미지 변경 일부
- 전화번호/이메일 변경 화면 일부
- Unity 3D 연동: `flutter_embed_unity` 비활성화 상태
- Tapjoy/AdGem 네이티브 SDK: 어댑터 골격만 있고 실제 SDK 연동은 TODO
- FCM 토큰 서버 등록: `registerPushToken` GraphQL mutation 필요

## 3. 기술 스택

- Flutter / Dart
- 상태관리: Riverpod, riverpod_generator
- 라우팅: go_router
- API: graphql_flutter + Dio 커스텀 HTTP 클라이언트
- 인증 토큰 저장: flutter_secure_storage
- 로컬 저장: shared_preferences, Hive
- Firebase: FCM
- 에러 모니터링: Sentry
- 분석: Mixpanel
- 공유: Kakao SDK, share_plus fallback
- 광고: Google Mobile Ads
- WebView: webview_flutter
- 블록체인/암호화: web3dart, encrypt, crypto, bip39
- E2E: Patrol

`pubspec.yaml` 기준 SDK는 Dart `^3.9.2`이고 README에는 Flutter `3.35.6` 기준으로 적혀 있습니다. GitHub Actions E2E workflow는 Flutter `3.29.2`를 사용하므로, CI와 로컬 Flutter 버전 차이는 먼저 정리하는 것이 좋습니다.

## 4. 저장소 구조

```text
lib/
  main.dart                         앱 부트스트랩
  core/
    auth/                           인증 도메인, 토큰 저장, 로그인/회원가입 API
    graphql/                        GraphQL 클라이언트 설정
    router/                         go_router 라우트 정의
    analytics/                      Mixpanel
    notification/                   FCM
    observability/                  Sentry
    sharing/                        Kakao 공유
    theme/                          색상/타이포/테마
  data/
    blockpick/                      블록픽 목록/상세 API 모델 및 데이터소스
    entry/                          참여/티켓 API
    point/                          포인트 API
    mission/                        미션 API
    ad_reward/                      광고 보상 API
    referral/                       친구초대 API
    winning/                        당첨 API
    delivery_address/               배송지 API
    notification/                   알림 API
    offerwall/                      오퍼월 API + mock fallback
    mock_*.dart                     아직 API 미연동인 화면의 목 데이터
  features/
    auth/                           로그인/회원가입 화면
    blockpick, blockpick_list/detail 블록픽 홈/목록/상세
    entry_flow/                     블록 선택 -> 참여 결과
    game/                           기존 게임 화면/그리드/참여 흐름
    point, mission, ad_reward       포인트/미션/광고 보상
    referral                        친구초대
    winning                         당첨/배송지
    my, settings                    마이페이지/설정
    wish, winners, mall             일부 mock 중심 영역
    partner                         파트너 웹 게임 WebView
    more                            추가 게임 모드/Unity placeholder
  providers/                        Riverpod provider 묶음
  services/                         광고, 지갑, 스마트컨트랙트, 암호화, 오퍼월
  widgets/, components/             공통 UI

android/, ios/                      네이티브 설정
integration_test/                   Patrol E2E 대상 테스트
test/                               단위/위젯 테스트
docs/                               기획/외부 SDK/API/테스트 문서
backend/                            백엔드 연동 참고 문서와 로그
```

## 5. 앱 시작 흐름

진입점은 `lib/main.dart`입니다.

1. `main()`에서 `SentryConfig.init(_bootstrap)`으로 전체 앱을 Sentry zone 안에서 실행합니다.
2. `_bootstrap()`에서 Flutter binding을 초기화합니다.
3. 웹에서 `usePathUrlStrategy()`로 hash 없는 URL을 사용합니다.
4. Firebase 초기화를 시도합니다. `google-services.json` 또는 `GoogleService-Info.plist`가 없으면 로그만 남기고 계속 진행합니다.
5. FCM, Kakao SDK, Mixpanel, AdMob을 순서대로 초기화합니다.
6. `ProviderScope`로 Riverpod을 열고 `BlockPickApp`을 실행합니다.
7. `BlockPickApp`은 `routerProvider`를 읽어 `MaterialApp.router`로 앱을 띄웁니다.
8. 첫 프레임 뒤 `DeepLinkService.init(router: router)`가 실행됩니다.

초기 라우트는 `/splash`입니다.

## 6. 인증/라우팅 정책

라우터는 `lib/core/router/router.dart`에 있습니다.

인증 상태는 `isAuthenticatedProvider`로 판단합니다. 보호 라우트는 아래입니다.

- `/block-select`
- `/block-stage`
- `/block-vibe`
- `/my-pick`
- `/my-wallet`
- `/my-profile`

보호 라우트에 비로그인으로 접근하면 `/login?redirect=...`로 보냅니다. 로그인 상태에서 `/splash`, `/auth/email-login`, `/login`으로 들어오면 홈(`/`) 또는 redirect로 이동합니다.

주요 라우트:

- `/splash`, `/permission`, `/onboarding`
- `/`, 홈/블록픽 메인
- `/login`, `/signup`
- `/auth/email-login`, `/auth/signup-select`, `/auth/phone-verify`, `/auth/email-signup`, `/auth/terms-agree`, `/auth/email-verify`, `/auth/password-setup`, `/auth/signup-complete`
- `/find-email`, `/find-email-result`, `/find-password`
- `/game/:gameId`, 게임 타입별 dispatcher
- `/game-grid/:gameId`, 기존 그리드 게임 화면
- `/optimal/:gameId`
- `/blockpicks`, `/blockpick/:id`
- `/entry/select`, `/entry/result`
- `/participation`
- `/referral`, `/referral/history`, `/referral/guide`, `/referral/faq`
- `/mission`, `/mission/complete`
- `/ad-reward/:blockpickId`, `/ad-reward/complete`
- `/winnings`, `/winning/detail`
- `/delivery-address/new`, `/delivery-address/edit`
- `/notifications`, `/settings/notifications`
- `/point/wallet`, `/point/check-in`, `/point/mini-game`
- `/offerwall`
- `/webview`
- `/more/*`, `/more/unity`, `/unity-game/:gameId`

## 7. API 기본 구조

GraphQL 클라이언트는 `lib/core/graphql/graphql_client.dart`입니다.

기본 endpoint:

```text
https://api-dev.blockpick.net/graphql
```

빌드 시 변경:

```bash
flutter run --dart-define=BLOCKPICK_GRAPHQL_ENDPOINT=https://api.blockpick.net/graphql
```

특징:

- Dio를 감싼 커스텀 `DioHttpClient`를 `HttpLink`에 연결합니다.
- 모든 요청/응답을 상세 로그로 출력합니다.
- GraphQL query 안의 `__typename`을 제거하는 로직이 있습니다.
- 토큰이 있으면 `Authorization: Bearer <token>` 헤더를 자동 추가합니다.
- 401 발생 시 refresh token으로 `refreshToken` mutation을 호출하고 원 요청을 재시도합니다.
- GraphQL cache 정규화는 꺼져 있습니다.
- query/mutation fetch policy는 기본 `networkOnly`입니다.
- query timeout은 블록체인 트랜잭션 대기 때문에 60초입니다.

토큰 저장소는 `lib/core/auth/data/datasources/token_local_datasource.dart`이며, secure storage를 사용합니다.

## 8. GraphQL API 목록

### 인증 API

파일: `lib/core/auth/data/datasources/auth_remote_datasource.dart`

| Operation | 용도 |
|---|---|
| `Login` | 이메일/비밀번호 로그인, accessToken/refreshToken/user 반환 |
| `SendVerificationCode` | 이메일 인증 코드 발송 |
| `VerifyCode` | 이메일 인증 코드 검증 |
| `SignUp` | 회원가입 |
| `ResetPassword` | 비밀번호 재설정 |
| `RefreshToken` | access/refresh token 갱신 |
| `ChangePassword` | 비밀번호 변경 |
| `WithdrawUser` | 회원 탈퇴 |
| `SocialLogin` | 소셜 로그인/가입 |
| `Me` | 내 사용자 정보 조회 |
| `SendSmsVerificationCode` | SMS 인증 코드 발송 |
| `VerifySmsCode` | SMS 인증 코드 검증 |
| `FindEmail` | 전화번호 인증 후 이메일 찾기 |
| `CheckPhoneNumber` | 전화번호 가입 여부 확인 |

SMS 인증 상세는 `API_SMS_VERIFICATION.md`에 별도 문서가 있습니다. 전화번호는 E.164 형식(`+8210...`)을 사용합니다.

### 블록픽 조회 API

파일: `lib/data/blockpick/blockpick_remote_datasource.dart`

| Operation | 용도 |
|---|---|
| `Blockpicks` | 블록픽 목록 조회. `BlockpickFilterInput`으로 필터링 |
| `Blockpick` | 블록픽 상세 조회 |
| `BlockpickCategories` | 카테고리 목록 조회 |

상세 응답에는 `gridRows`, `gridCols`, `maxEntriesPerUser`, `freeEntryQuota`, `startTime`, `endTime`, `status`, `referralEnabled`, `adRewardEnabled`, `missionEnabled`, `onchainContractAddr`, `prizes`, `partner`, `category` 등이 들어옵니다.

주의: 백엔드 스키마에 `gameType`, `maxEntries`, `participants`, `entryFee` 등 일부 게임 UI용 필드가 아직 부족해 `lib/data/blockpick/blockpick_to_game_adapter.dart`에서 mock/계산값으로 보정하고 있습니다.

### 참여/티켓 API

파일: `lib/data/entry/entry_remote_datasource.dart`

| Operation | 용도 |
|---|---|
| `JoinBlockpick` | 티켓으로 블록픽 참여. `blockpickId`, `ticketId`, `selectedRow`, `selectedCol`, 선택적으로 `encryptedCoordinates` 전송 |
| `MyEntries` | 내 참여 목록 조회 |
| `Entry` | 참여 단건 조회 |
| `MyTickets` | 내 티켓 목록 조회 |

새 IA의 참여 흐름은 `/entry/select` -> `/entry/result`입니다.

### 기존 게임/블록체인 참여 API

파일: `lib/providers/game_provider.dart`, `lib/providers/game_participation_provider.dart`, `lib/providers/game_result_provider.dart`

| Operation | 용도 |
|---|---|
| `GetGames` | 구 게임 목록 조회 |
| `GetActiveGames` | 활성 게임 목록 조회 |
| `GetGame` | 게임 상세 조회 |
| `RequestEncryptionKey` | 참여 좌표 암호화 키 요청 |
| `JoinGame` | 기존 게임 참여 mutation |
| `GetGameParticipants` | 게임 참가자 조회 |
| `GetGameResults` | 게임 결과 조회 |

암호화 키 플로우:

1. 로그인 후 JWT 확보
2. 게임 조회 후 `onchainContractAddr` 확인
3. `userIndex = SHA256(userId + gameId)` 생성
4. `requestEncryptionKey` mutation 호출
5. 블록체인 트랜잭션 완료 대기
6. 스마트 컨트랙트 `getEncryptionKey(index, userAddress)` 조회
7. 키로 좌표를 암호화해 참여 처리

이 플로우는 `backend/README_FOR_FRONTEND.md`, `features/game/POLLING_USAGE.md`, `SERVER_ERROR_REPORT.md`를 같이 봐야 합니다. 특히 과거 `requestEncryptionKey`에서 서버 `INTERNAL_ERROR`가 발생한 기록이 있습니다.

### 포인트 API

파일: `lib/data/point/point_remote_datasource.dart`

| Operation | 용도 |
|---|---|
| `PointWallet` | 포인트 지갑 조회 |
| `PointTransactions` | 포인트 거래 내역 조회 |
| `ClaimDailyCheckIn` | 출석체크 포인트 적립 |
| `PlayMiniGame` | 미니게임 결과 제출 및 포인트 적립 |

### 미션 API

파일: `lib/data/mission/mission_remote_datasource.dart`

| Operation | 용도 |
|---|---|
| `MyMissions` | 내 미션 목록 조회 |
| `CompleteMission` | 미션 완료 처리 및 티켓 발급 |

### 광고 보상 API

파일: `lib/data/ad_reward/ad_reward_remote_datasource.dart`

| Operation | 용도 |
|---|---|
| `ClaimAdReward` | 광고 시청 완료 후 보상 청구 |
| `MyAdRewards` | 특정 블록픽의 내 광고 보상 내역 조회 |

AdMob 구현 파일:

- `lib/services/admob_service.dart`
- `lib/providers/ad_reward_provider_v2.dart`
- `lib/features/ad_reward/ad_reward_screen.dart`
- `docs/admob-integration.md`

현재는 클라이언트가 광고 시청 완료 후 `claimAdReward`를 호출합니다. 프로덕션에서는 AdMob SSV(Server-Side Verification) 백엔드 엔드포인트가 필요합니다.

### 친구초대 API

파일: `lib/data/referral/referral_remote_datasource.dart`

| Operation | 용도 |
|---|---|
| `MyInviteCode` | 내 초대 코드 조회 |
| `MyReferrals` | 내 추천/초대 이력 조회 |
| `ApplyInviteCode` | 초대 코드 적용 |

Kakao 공유는 `lib/core/sharing/kakao_share_service.dart`에서 처리합니다. Kakao 키가 없으면 `share_plus` fallback으로 동작합니다.

### 당첨/배송 API

파일:

- `lib/data/winning/winning_remote_datasource.dart`
- `lib/data/delivery_address/delivery_address_remote_datasource.dart`

| Operation | 용도 |
|---|---|
| `MyWinnings` | 내 당첨 목록 조회 |
| `ClaimWinning` | 당첨 수령 처리 |
| `MyDeliveryAddresses` | 내 배송지 목록 |
| `CreateDeliveryAddress` | 배송지 생성 |
| `UpdateDeliveryAddress` | 배송지 수정 |
| `DeleteDeliveryAddress` | 배송지 삭제 |

### 알림 API

파일: `lib/data/notification/notification_remote_datasource.dart`

| Operation | 용도 |
|---|---|
| `MyNotifications` | 내 알림 목록 조회 |
| `MarkNotificationRead` | 알림 읽음 처리 |
| `NotificationSetting` | 알림 설정 조회 |
| `UpdateNotificationSetting` | 알림 설정 수정 |

FCM 토큰 등록은 아직 TODO입니다. `lib/core/notification/fcm_config.dart`에 `registerPushToken` GraphQL mutation 구현 필요 주석이 있습니다.

### 오퍼월 API

파일: `lib/data/offerwall/offerwall_remote_datasource.dart`

| Operation | 용도 |
|---|---|
| `OfferwallOffers` | 오퍼월 목록 조회 |
| `StartOfferwallOffer` | 오퍼월 참여 시작 |

백엔드 미구현 또는 GraphQL field not found 시 mock 데이터 fallback을 반환합니다. 네이티브 Tapjoy/AdGem SDK는 아직 실제 구현 전입니다.

## 9. 주요 화면과 데이터 흐름

### 블록픽 목록/상세/참여

1. `/blockpicks`에서 블록픽 목록 조회
2. `/blockpick/:id`에서 상세 조회
3. 상세에서 참여 버튼 클릭
4. `/entry/select`로 이동하면서 `BlockpickDetail`을 `extra`로 전달
5. 사용자가 격자에서 행/열 선택
6. `JoinBlockpick` mutation 호출
7. `/entry/result`로 결과 전달

### 기존 게임 dispatcher

`/game/:gameId`는 `GameDispatcherScreen`으로 들어갑니다. 게임 타입에 따라 Daily/Select/Vibe/Prime 등 다른 화면으로 분기합니다. 백엔드의 `gameType` 필드가 아직 완전하지 않아 일부는 adapter/mock 로직에 의존합니다.

### 포인트

`/point/wallet`에서 지갑/거래 내역을 봅니다. `/point/check-in`은 출석체크, `/point/mini-game`은 미니게임 결과 제출과 연결됩니다.

### 광고 보상

`/ad-reward/:blockpickId`에서 보상형 광고를 보여주고, 완료 시 `ClaimAdReward`를 호출한 뒤 `/ad-reward/complete`로 이동합니다.

### 친구초대

`/referral`에서 초대 코드를 조회하고 공유합니다. Kakao SDK 키가 없으면 일반 공유로 fallback합니다.

### 파트너 웹 게임

`lib/features/partner/partner_game_webview.dart`는 WebView로 웹 게임을 엽니다.

기본 URL:

```text
https://web-blockpick.vercel.app
```

빌드 시 변경:

```bash
flutter run --dart-define=PARTNER_WEB_BASE_URL=https://...
```

앱은 URL에 `source=app&token=<JWT>`를 붙입니다. 웹 -> 앱 통신은 `BlockPickBridge` JavaScript channel을 사용합니다.

## 10. 환경 변수와 외부 SDK 키

대부분 `--dart-define`으로 주입합니다.

| 키 | 용도 | 기본값/동작 |
|---|---|---|
| `BLOCKPICK_GRAPHQL_ENDPOINT` | GraphQL endpoint | `https://api-dev.blockpick.net/graphql` |
| `SENTRY_DSN` | Sentry DSN | 없으면 Sentry skip |
| `SENTRY_ENV` | Sentry 환경 | `development` |
| `KAKAO_NATIVE_KEY` | Kakao native key | 없으면 Kakao skip, share_plus fallback |
| `MIXPANEL_TOKEN` | Mixpanel token | 없으면 analytics no-op |
| `ADMOB_REWARDED_UNIT_ID` | AdMob 보상형 광고 단위 ID | 없으면 Google 테스트 광고 ID |
| `OFFERWALL_ADAPTER` | `web`, `tapjoy`, `adgem` | `web` |
| `PARTNER_WEB_BASE_URL` | 파트너 WebView base URL | `https://web-blockpick.vercel.app` |

예시:

```bash
flutter run \
  --dart-define=BLOCKPICK_GRAPHQL_ENDPOINT=https://api-dev.blockpick.net/graphql \
  --dart-define=SENTRY_ENV=development \
  --dart-define=SENTRY_DSN=... \
  --dart-define=KAKAO_NATIVE_KEY=... \
  --dart-define=MIXPANEL_TOKEN=... \
  --dart-define=ADMOB_REWARDED_UNIT_ID=...
```

Firebase는 dart-define이 아니라 네이티브 파일이 필요합니다.

- Android: `android/app/google-services.json`
- iOS: `ios/Runner/GoogleService-Info.plist`

현재 `ios/Runner/GoogleService-Info.plist`는 저장소에 존재합니다. Android의 `google-services.json`은 확인되지 않았습니다. 보안 정책상 실제 Firebase 파일은 보통 git에 커밋하지 않는 것이 맞습니다.

외부 SDK 키 발급 가이드는 `docs/external-sdk-keys.md`를 보세요.

## 11. 로컬 실행

```bash
flutter doctor
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter run
```

디바이스 지정:

```bash
flutter devices
flutter run -d chrome
flutter run -d ios
flutter run -d android
```

웹:

```bash
flutter run -d chrome --web-port=8080
```

빌드:

```bash
flutter build apk
flutter build appbundle
flutter build ios
flutter build web
```

코드 생성이 필요한 파일:

- `*.g.dart`
- `*.freezed.dart`
- `riverpod_generator` 산출물

모델/provider를 바꾸면 반드시:

```bash
dart run build_runner build --delete-conflicting-outputs
```

## 12. 테스트/검증

기본:

```bash
flutter analyze
flutter test
```

E2E:

```bash
dart pub global activate patrol_cli
patrol test --target integration_test/auth_flow_test.dart
```

E2E 테스트 파일:

- `integration_test/auth_flow_test.dart`
- `integration_test/discovery_test.dart`
- `integration_test/entry_flow_test.dart`
- `integration_test/points_test.dart`
- `integration_test/referral_test.dart`

GitHub Actions:

- `.github/workflows/e2e.yml`
- iOS/Android Patrol E2E를 실행
- 필요한 secret:
  - `BLOCKPICK_STAGING_URL`
  - `BLOCKPICK_TEST_EMAIL`
  - `BLOCKPICK_TEST_PASSWORD`

테스트 케이스 문서는 `docs/test-cases/` 아래에 정리되어 있습니다.

## 13. 네이티브 설정 주의사항

### Android

- 패키지명은 문서 기준 `net.blockpick.app`
- Google Services plugin 사용
- AdMob app id는 `android/app/src/main/AndroidManifest.xml` 확인
- `android/unityLibrary`가 포함되어 있어 빌드가 무거울 수 있습니다.
- Unity 연동은 현재 비활성화된 placeholder 상태입니다.

### iOS

- `ios/Runner/Info.plist`에 Kakao scheme placeholder가 있습니다.
- `KAKAO_NATIVE_KEY` 발급 후 `kakaoTODO_REPLACE_WITH_NATIVE_KEY` 형태의 placeholder를 실제 값으로 교체해야 합니다.
- AdMob iOS app id와 SKAdNetwork 설정은 `docs/admob-integration.md`를 따릅니다.
- Firebase FCM을 쓰려면 `GoogleService-Info.plist`가 Xcode Runner target에 연결되어 있어야 합니다.

## 14. 외부 문서 위치

다음 문서는 새 개발자가 같이 보면 좋습니다.

- `README.md`: Flutter 프로젝트 기본 설명
- `API_SMS_VERIFICATION.md`: SMS 인증 API 상세
- `backend/README_FOR_FRONTEND.md`: 암호화 키/블록체인 플로우
- `SERVER_ERROR_REPORT.md`: `requestEncryptionKey` 서버 에러 재현/분석
- `docs/external-sdk-keys.md`: Sentry/Firebase/Kakao/Mixpanel 키 발급
- `docs/admob-integration.md`: AdMob 보상형 광고/SSV 연동
- `docs/offerwall-integration.md`: 오퍼월 연동
- `docs/test-cases/`: E2E 테스트 케이스
- `docs/blockpick_summary_field_request.md`: 백엔드 필드 보강 요청
- `docs/game_provider_migration_design.md`: 구 game provider -> 새 blockpick provider 마이그레이션 설계
- `plans/policies/10-API명세서.md`: 기획/API 명세
- `plans/policies/12-블록체인명세서.md`: 블록체인 정책

## 15. 현재 개발자가 헷갈리기 쉬운 지점

### 새 Blockpick 도메인과 구 Game 도메인이 공존합니다

새 IA는 `blockpick`, `entry`, `point`, `mission`, `referral`, `winning` 도메인을 씁니다.  
구 화면은 `game_provider`, `GameModel`, `GameScreen`, `GameDispatcherScreen`을 씁니다.

새 개발자는 먼저 “내가 건드리는 화면이 새 IA인지 구 game 화면인지”를 확인해야 합니다.

### API 연동과 mock 화면이 섞여 있습니다

파일명에 `mock_`가 붙은 데이터와 TODO가 많은 My/Wish/Winners/Mall 영역은 실제 운영 데이터가 아닐 수 있습니다. 새 기능을 붙일 때는 먼저 해당 화면이 실제 GraphQL provider를 쓰는지 확인해야 합니다.

### GraphQL 스키마와 앱 모델이 완전히 맞지 않습니다

특히 `BlockpickSummary` 쪽에는 게임 UI에 필요한 필드가 부족해 adapter에서 임시 값을 넣습니다. 백엔드 필드가 추가되면 `blockpick_to_game_adapter.dart`, `blockpick_provider.dart`, `game_provider.dart`를 같이 정리해야 합니다.

### 암호화 키/블록체인 참여 플로우는 서버 의존성이 큽니다

`requestEncryptionKey`는 서버에서 블록체인 트랜잭션까지 처리하는 흐름입니다. 과거 서버 내부 트랜잭션 에러 기록이 있으므로, 게임 참여가 안 되면 클라이언트만 보지 말고 `SERVER_ERROR_REPORT.md`와 서버 로그를 같이 봐야 합니다.

### 외부 SDK는 키가 없으면 대부분 skip/fallback합니다

Sentry, Kakao, Mixpanel은 키가 없으면 앱 실행 자체는 됩니다. Firebase도 native 파일이 없으면 초기화 실패 로그만 남기고 계속 진행합니다. 따라서 “로컬에서는 되는데 운영 기능이 안 됨”이 발생할 수 있습니다.

## 16. 다음 개발자가 먼저 해야 할 일

1. `flutter pub get` 후 앱이 뜨는지 확인합니다.
2. `flutter analyze`를 돌려 현재 warning/error 상태를 확인합니다.
3. `.env` 백업 또는 전달받은 `--dart-define` 값으로 API endpoint를 맞춥니다.
4. 로그인 -> 블록픽 목록 -> 상세 -> 참여 흐름을 실제 계정으로 확인합니다.
5. `docs/test-cases/`와 `integration_test/`를 보고 현재 E2E가 어느 수준까지 통과하는지 확인합니다.
6. 현재 작업 범위가 새 IA인지 구 game 화면인지 먼저 판별합니다.
7. mock/TODO 영역을 실제 API로 바꿀 경우, 백엔드 스키마에 필요한 필드를 먼저 정리합니다.

## 17. 기능별 담당 파일 빠른 찾기

| 하고 싶은 작업 | 먼저 볼 파일 |
|---|---|
| API endpoint 변경 | `lib/core/graphql/graphql_client.dart` |
| 로그인/회원가입 수정 | `lib/core/auth/data/datasources/auth_remote_datasource.dart`, `lib/core/auth/domain/providers/auth_provider.dart`, `lib/features/auth/` |
| 라우트 추가/수정 | `lib/core/router/router.dart` |
| 블록픽 목록/상세 | `lib/data/blockpick/`, `lib/providers/blockpick_provider.dart`, `lib/features/blockpick_list/`, `lib/features/blockpick_detail/` |
| 참여 플로우 | `lib/data/entry/`, `lib/providers/entry_provider.dart`, `lib/features/entry_flow/` |
| 기존 게임 참여 | `lib/providers/game_participation_provider.dart`, `lib/services/coordinate_encryption_service.dart`, `lib/services/smart_contract_service.dart` |
| 포인트 | `lib/data/point/`, `lib/providers/point_provider.dart`, `lib/features/point/` |
| 미션 | `lib/data/mission/`, `lib/providers/mission_provider.dart`, `lib/features/mission/` |
| 광고 보상 | `lib/data/ad_reward/`, `lib/providers/ad_reward_provider_v2.dart`, `lib/services/admob_service.dart`, `lib/features/ad_reward/` |
| 친구초대 | `lib/data/referral/`, `lib/providers/referral_provider.dart`, `lib/features/referral/`, `lib/core/sharing/kakao_share_service.dart` |
| 당첨/배송 | `lib/data/winning/`, `lib/data/delivery_address/`, `lib/features/winning/` |
| 알림/푸시 | `lib/data/notification/`, `lib/core/notification/fcm_config.dart`, `lib/features/notification/` |
| 외부 SDK 키 | `docs/external-sdk-keys.md` |
| AdMob | `docs/admob-integration.md` |
| E2E | `.github/workflows/e2e.yml`, `integration_test/`, `docs/test-cases/` |

## 18. 인수인계 결론

이 프로젝트는 단순 Flutter UI가 아니라 블록픽 이벤트 참여, 포인트, 광고 보상, 미션, 추천, 당첨, WebView 게임, 블록체인 암호화 키 플로우가 얽힌 앱입니다.  
다만 현재 모든 영역이 같은 완성도는 아닙니다. 실제 GraphQL 연동이 완료된 핵심 도메인과 mock/TODO 영역이 섞여 있으므로, 다음 개발자는 작업 시작 전에 반드시 해당 화면의 데이터 출처를 확인해야 합니다.

가장 안전한 작업 순서는 다음입니다.

1. 앱 실행/로그인 확인
2. GraphQL endpoint와 인증 토큰 흐름 확인
3. 새 IA의 블록픽/참여/포인트/미션/광고/추천/당첨 API 확인
4. mock/TODO 영역을 실제 API 연동 대상으로 분류
5. 백엔드 필드 부족분을 정리한 뒤 화면 수정
6. `flutter analyze`, `flutter test`, 필요한 Patrol E2E로 검증
