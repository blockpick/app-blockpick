# 오퍼월 SDK 통합 가이드

## 개요

오퍼월은 사용자가 광고주의 미션(앱 다운로드, 회원가입, 금융 상품 신청 등)을 완료하고 포인트를 적립하는 기능입니다.

**아키텍처 원칙:**
- 클라이언트: 오퍼 진입(URL 클릭) + 목록 조회만 담당
- 포인트 적립: 백엔드가 광고 네트워크의 서버사이드 postback을 수신하여 `PointService.grant()` 호출 (S01에서 구현)
- SDK 교체: 어댑터 패턴으로 추상화되어 `OfferwallFactory`에서 dart-define으로 선택

---

## 현재 구조

```
lib/
├── data/offerwall/
│   ├── offerwall_models.dart          # DTO: OfferwallOffer, OfferwallCategory, OfferwallFilter
│   └── offerwall_remote_datasource.dart  # GraphQL + mock fallback
├── providers/
│   └── offerwall_provider.dart        # offerwallOffersProvider, startOfferwallOfferProvider
├── features/offerwall/
│   ├── offerwall_screen.dart          # 메인 화면 (카테고리 필터 + 카드 리스트 + 포인트 헤더)
│   └── widgets/
│       ├── category_filter.dart       # 카테고리 탭 필터
│       └── offer_card.dart            # 개별 오퍼 카드
└── services/offerwall/
    ├── offerwall_adapter.dart         # 어댑터 인터페이스
    ├── tapjoy_adapter.dart            # Tapjoy placeholder
    ├── adgem_adapter.dart             # AdGem placeholder
    ├── web_offerwall_adapter.dart     # 웹뷰 fallback (현재 기본값)
    └── offerwall_factory.dart         # dart-define 기반 어댑터 선택
```

---

## 진입 라우트

```
/offerwall
```

`block_select_screen.dart`의 참여권 부족 CTA에서 진입:

```dart
context.push('/offerwall');
```

---

## 백엔드 GraphQL Operations

백엔드 미구현 시 자동으로 mock 데이터를 반환합니다.

### Query: offerwallOffers

```graphql
query OfferwallOffers($filter: OfferwallFilterInput) {
  offerwallOffers(filter: $filter) {
    success
    code
    message
    items {
      id
      title
      description
      pointReward
      category        # SMALL | MEDIUM | LARGE | EVENT
      sponsorLogoUrl
      clickUrl
      status          # ACTIVE | COMPLETED | EXPIRED
    }
  }
}
```

### Mutation: startOfferwallOffer

오퍼 클릭 트래킹 + 외부 URL 획득 (postback URL 세팅 포함):

```graphql
mutation StartOfferwallOffer($offerId: ID!) {
  startOfferwallOffer(offerId: $offerId) {
    success
    code
    message
    externalUrl   # 광고주에게 넘길 최종 URL (postback 파라미터 포함)
  }
}
```

**서버사이드 postback 처리 (백엔드 구현 필요):**
1. `startOfferwallOffer` 호출 시 서버가 광고 네트워크에 postback URL 등록
2. 사용자가 미션 완료 시 광고 네트워크 → 백엔드 postback 호출
3. 백엔드가 `PointService.grant(userId, reason: OFFERWALL, amount: ...)` 호출

---

## SDK 교체 방법

### 1단계: 사업자 선정 후 어댑터 구현

**Tapjoy 선택 시** — `lib/services/offerwall/tapjoy_adapter.dart`:

```dart
@override
Future<void> showOfferwall({required String url, String? title}) async {
  // TODO를 실제 SDK 호출로 교체:
  // await Tapjoy.showOfferwall();
}
```

**AdGem 선택 시** — `lib/services/offerwall/adgem_adapter.dart`:

```dart
@override
Future<void> showOfferwall({required String url, String? title}) async {
  // TODO를 실제 SDK 호출로 교체:
  // await AdGem.showOfferwall(appId: '...', userId: '...');
}
```

### 2단계: 빌드 시 어댑터 선택

```bash
# Tapjoy 사용
flutter run --dart-define=OFFERWALL_ADAPTER=tapjoy

# AdGem 사용
flutter run --dart-define=OFFERWALL_ADAPTER=adgem

# 기본값 (웹뷰 fallback)
flutter run --dart-define=OFFERWALL_ADAPTER=web
```

CI/CD에서는 `--dart-define-from-file=.env.json` 방식을 권장합니다.

### 3단계: pubspec.yaml에 SDK 추가

사업자 선정 후 해당 SDK 패키지를 추가합니다:

```yaml
dependencies:
  # Tapjoy 선택 시
  # tapjoy_flutter: ^x.x.x

  # AdGem 선택 시
  # adgem_flutter: ^x.x.x
```

---

## 포인트 카테고리 기준 (기획문서 기준)

| 카테고리 | 포인트 범위 | 예시 |
|---------|------------|------|
| 소형 (SMALL) | 20~40P | 앱 다운로드, 설문조사 |
| 중형 (MEDIUM) | 50~100P | 쇼핑몰 첫 구매, 카드 신청 |
| 대형 (LARGE) | 120~300P+ | 보험 상담, 대출 조회 |
| 이벤트 (EVENT) | 500P+ | 특별 이벤트 미션 |

---

## 분석 이벤트

| 이벤트 | 속성 | 시점 |
|--------|------|------|
| `offerwall_opened` | — | 화면 진입 시 |
| `offer_clicked` | `offerId`, `pointReward`, `category` | 오퍼 시작하기 탭 시 |
