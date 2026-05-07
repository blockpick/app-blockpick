# AdMob 보상형 광고 연동 가이드

## 개요

BlockPick 앱은 Google AdMob 보상형 광고(RewardedAd)를 통해 사용자에게 참여권을 지급합니다.
광고 시청 완료 시 `claimAdReward` GraphQL Mutation 을 호출하여 서버에서 보상을 처리합니다.

---

## 1. 광고 단위 ID 발급

### AdMob 콘솔 접속
1. [AdMob 콘솔](https://admob.google.com) → 앱 선택 (또는 앱 추가)
2. **광고 단위 추가** → 보상형(Rewarded) 선택
3. 광고 단위 이름: `blockpick_rewarded_ticket` (예시)
4. 발급된 광고 단위 ID 형식: `ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX`

### 앱 ID 등록 (플랫폼별)

| 플랫폼  | 파일                                         | 키                                              |
|---------|----------------------------------------------|-------------------------------------------------|
| Android | `android/app/src/main/AndroidManifest.xml`   | `com.google.android.gms.ads.APPLICATION_ID`     |
| iOS     | `ios/Runner/Info.plist`                      | `GADApplicationIdentifier`                      |

> 현재 두 파일 모두 Google 공식 테스트 앱 ID가 설정되어 있습니다.
> 프로덕션 배포 전 실제 앱 ID로 반드시 교체하세요.

---

## 2. 광고 단위 ID 주입 방법

### dart-define 방식 (권장)

```bash
# 개발 빌드
flutter run \
  --dart-define=ADMOB_REWARDED_UNIT_ID=ca-app-pub-XXXXXXXX/YYYYYYYY

# 프로덕션 빌드 (Android)
flutter build apk \
  --dart-define=ADMOB_REWARDED_UNIT_ID=ca-app-pub-XXXXXXXX/YYYYYYYY

# 프로덕션 빌드 (iOS)
flutter build ios \
  --dart-define=ADMOB_REWARDED_UNIT_ID=ca-app-pub-XXXXXXXX/YYYYYYYY
```

### ID 미주입 시 동작 (fallback)

`ADMOB_REWARDED_UNIT_ID` 환경변수가 없으면 자동으로 **Google 공식 테스트 ID** 를 사용합니다.

| 플랫폼  | 테스트 광고 단위 ID                          |
|---------|----------------------------------------------|
| Android | `ca-app-pub-3940256099942544/5224354917`     |
| iOS     | `ca-app-pub-3940256099942544/1712485313`     |

테스트 ID는 실제 광고 수익이 발생하지 않으며 시뮬레이터/실기기 모두 동작합니다.

---

## 3. 테스트 모드 설정

### 실기기 테스트 디바이스 등록

테스트 기기에서 실제 광고(프로덕션 ID)가 노출될 경우 AdMob 정책 위반이 될 수 있습니다.
디바이스 ID를 등록하면 해당 기기에서는 항상 테스트 광고가 노출됩니다.

```dart
// lib/services/admob_service.dart 초기화 시점에 추가 (개발 환경에서만)
// 디바이스 ID는 앱 실행 시 logcat/콘솔에서 확인 가능
MobileAds.instance.updateRequestConfiguration(
  RequestConfiguration(
    testDeviceIds: ['YOUR_DEVICE_ID_HERE'],
  ),
);
```

logcat 예시 출력:
```
I/Ads: Use RequestConfiguration.Builder.setTestDeviceIds(Arrays.asList("XXXXXXXX"))
```

---

## 4. SSV (Server-Side Verification) 설정

### 개요

AdMob SSV 는 광고 시청 완료 시 Google 서버가 직접 백엔드 엔드포인트를 호출하여
광고 시청 여부를 검증하는 방식입니다. 클라이언트 조작을 방지할 수 있습니다.

### 클라이언트 측 (현재 구현)

`externalNetworkRef` 필드에 고유 참조값을 전달합니다:
```
admob_{blockpickId}_{timestamp}
```

이 값은 SSV 콜백의 `custom_data` 파라미터와 매핑할 수 있습니다.

### 백엔드 엔드포인트 신설 필요 (TODO)

```
POST /admob/ssv
```

Google 이 호출하는 SSV 콜백 URL 파라미터:
| 파라미터          | 설명                              |
|-------------------|-----------------------------------|
| `ad_network`      | 광고 네트워크 ID                  |
| `ad_unit`         | 광고 단위 ID                      |
| `custom_data`     | 클라이언트가 설정한 커스텀 데이터  |
| `key_id`          | RSA 공개키 ID                     |
| `reward_amount`   | 보상 수량                         |
| `reward_item`     | 보상 아이템명                     |
| `signature`       | ECDSA 서명 (검증 필수)            |
| `timestamp`       | Unix 타임스탬프 (ms)              |
| `transaction_id`  | 거래 고유 ID                      |
| `user_id`         | 사용자 ID (앱에서 설정한 값)       |

#### SSV 콜백 URL 등록 방법
1. [AdMob 콘솔](https://admob.google.com) → 광고 단위 → 보상형 광고 단위 편집
2. **서버 쪽 검증** → 콜백 URL 입력:
   ```
   https://api.blockpick.app/admob/ssv
   ```
3. 사용자 ID 설정 방법:
   ```dart
   // 광고 로드 전 사용자 ID 설정 (SSV의 user_id 파라미터로 전달됨)
   // 현재 미구현 — 추후 적용 필요
   ```

#### ECDSA 서명 검증 (백엔드 구현 필요)
```
Google 공개키 URL: https://gstatic.com/admob/reward/verifier-keys.json
서명 알고리즘: ECDSA with SHA-256
```

---

## 5. iOS App Tracking Transparency (ATT)

iOS 14+ 에서 광고 추적 권한이 필요합니다.

### Info.plist 설명 문구 추가 (필요 시)

현재 `ios/Runner/Info.plist` 에는 ATT 권한 설명이 없습니다.
AdMob 을 통한 맞춤 광고를 사용하려면 다음을 추가하세요:

```xml
<key>NSUserTrackingUsageDescription</key>
<string>더 관련성 높은 광고를 표시하기 위해 광고 식별자를 사용합니다.</string>
```

### 권한 요청 코드 (추후 적용)

```dart
import 'package:app_tracking_transparency/app_tracking_transparency.dart';

Future<void> requestTrackingPermission() async {
  final status = await AppTrackingTransparency.requestTrackingAuthorization();
  debugPrint('[ATT] 추적 권한 상태: $status');
}
```

> 현재 `permission_handler` 패키지가 이미 추가되어 있으나,
> ATT 전용 처리는 `app_tracking_transparency` 패키지가 별도로 필요합니다.
> AdMob 맞춤형 광고가 아닌 일반 광고만 사용할 경우 ATT 권한은 선택 사항입니다.

---

## 6. 구현 파일 목록

| 파일                                              | 역할                                      |
|---------------------------------------------------|-------------------------------------------|
| `lib/services/admob_service.dart`                 | AdMob SDK 래퍼 (초기화, 로드, 표시)       |
| `lib/providers/ad_reward_provider_v2.dart`        | 광고 + 백엔드 청구 통합 Provider           |
| `lib/features/ad_reward/ad_reward_screen.dart`    | 광고 시청 UI                              |
| `lib/features/ad_reward/ad_reward_complete_screen.dart` | 보상 완료 UI                        |
| `lib/data/ad_reward/ad_reward_remote_datasource.dart`  | GraphQL claimAdReward / myAdRewards |
| `android/app/src/main/AndroidManifest.xml`        | AdMob 앱 ID (Android)                    |
| `ios/Runner/Info.plist`                           | AdMob 앱 ID + SKAdNetworkItems (iOS)     |

---

## 7. 프로덕션 체크리스트

- [ ] AdMob 콘솔에서 실제 앱 ID 발급
- [ ] 실제 보상형 광고 단위 ID 발급
- [ ] `android/app/src/main/AndroidManifest.xml` 앱 ID 교체
- [ ] `ios/Runner/Info.plist` 앱 ID 교체 (`GADApplicationIdentifier`)
- [ ] `SKAdNetworkItems` 에 광고 네트워크 ID 추가 ([참고](https://developers.google.com/admob/ios/quick-start#update_your_infoplist))
- [ ] 빌드 시 `--dart-define=ADMOB_REWARDED_UNIT_ID=...` 주입
- [ ] 백엔드 `/admob/ssv` 엔드포인트 신설 + ECDSA 서명 검증
- [ ] AdMob 콘솔에서 SSV 콜백 URL 등록
- [ ] iOS `NSUserTrackingUsageDescription` 추가 (맞춤 광고 사용 시)
- [ ] 실기기 테스트 디바이스 ID 제거 (프로덕션 빌드)
