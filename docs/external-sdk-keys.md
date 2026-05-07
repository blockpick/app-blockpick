# 외부 SDK 키 발급 가이드

> **S20 세션**에서 실제 키 발급 후 이 문서를 업데이트하세요.
> 모든 키는 `--dart-define` 방식으로 주입합니다. 소스코드에 직접 하드코딩하지 마세요.

---

## 필요 환경변수 목록

| 변수명 | 용도 | 발급처 | 상태 |
|---|---|---|---|
| `SENTRY_DSN` | 에러 모니터링 DSN | Sentry.io | TODO |
| `SENTRY_ENV` | Sentry 환경 구분 (`development` / `production`) | 직접 설정 | TODO |
| `KAKAO_NATIVE_KEY` | Kakao SDK 네이티브 앱키 | developers.kakao.com | TODO |
| `MIXPANEL_TOKEN` | Mixpanel 프로젝트 토큰 | mixpanel.com | TODO |

---

## flutter run / build 사용 예시

```bash
# 개발 실행 (모든 SDK 주입)
flutter run \
  --dart-define=SENTRY_DSN=https://abc123@o123456.ingest.sentry.io/789 \
  --dart-define=SENTRY_ENV=development \
  --dart-define=KAKAO_NATIVE_KEY=abcdef1234567890 \
  --dart-define=MIXPANEL_TOKEN=your_mixpanel_token

# 프로덕션 빌드 (iOS)
flutter build ipa \
  --dart-define=SENTRY_DSN=https://abc123@o123456.ingest.sentry.io/789 \
  --dart-define=SENTRY_ENV=production \
  --dart-define=KAKAO_NATIVE_KEY=abcdef1234567890 \
  --dart-define=MIXPANEL_TOKEN=your_mixpanel_token

# 프로덕션 빌드 (Android)
flutter build appbundle \
  --dart-define=SENTRY_DSN=https://abc123@o123456.ingest.sentry.io/789 \
  --dart-define=SENTRY_ENV=production \
  --dart-define=KAKAO_NATIVE_KEY=abcdef1234567890 \
  --dart-define=MIXPANEL_TOKEN=your_mixpanel_token

# 키 없이 실행 (각 SDK가 SKIP됨 — 개발 환경 safe)
flutter run
```

---

## 1. Sentry (에러 모니터링)

### 발급 방법
1. https://sentry.io 가입 / 로그인
2. **Projects** → **Create Project** → Flutter 선택
3. DSN 복사 (형식: `https://<key>@o<org>.ingest.sentry.io/<project>`)

### 필요 파일
- 별도 네이티브 파일 불필요 (Flutter SDK만으로 동작)

### 주의사항
- `SENTRY_ENV`는 `development` / `staging` / `production` 중 하나 사용
- 릴리즈 빌드에서는 소스맵 업로드 권장 (`sentry-cli` 사용)

---

## 2. Firebase (FCM 푸시 알림)

### 발급 방법
1. https://console.firebase.google.com → 프로젝트 생성 또는 기존 프로젝트 사용
2. **프로젝트 설정** → **앱 추가**

#### Android
- 패키지명: `net.blockpick.app`
- `google-services.json` 다운로드
- 파일 위치: `android/app/google-services.json`

#### iOS
- 번들 ID: `net.blockpick.app` (Xcode에서 확인)
- `GoogleService-Info.plist` 다운로드
- 파일 위치: `ios/Runner/GoogleService-Info.plist`
- Xcode에서 **Runner 타겟에 파일 추가** (단순 파일 복사가 아닌 Xcode 프로젝트에 링크 필요)

### APNs 인증서 설정 (iOS Push 필수)
1. Apple Developer Console → **Certificates** → **APNs Key** 생성
2. Firebase 콘솔 → 프로젝트 설정 → 클라우드 메시징 → APNs 인증 키 업로드
3. Key ID / Team ID 입력

### 환경변수
- Firebase는 `--dart-define` 불필요 (google-services 파일로 설정)
- `google-services.json` / `GoogleService-Info.plist`는 **절대 git에 커밋하지 마세요**
- `.gitignore`에 추가:
  ```
  android/app/google-services.json
  ios/Runner/GoogleService-Info.plist
  ```

---

## 3. Kakao SDK (공유)

### 발급 방법
1. https://developers.kakao.com → 애플리케이션 추가
2. **앱 키** 탭 → **네이티브 앱 키** 복사 → `KAKAO_NATIVE_KEY`로 사용

### iOS 추가 설정
`ios/Runner/Info.plist`에서 Kakao scheme 교체:
```xml
<!-- kakao + 네이티브앱키 (예: 네이티브앱키가 abcdef1234 이면) -->
<string>kakaoabcdef1234</string>
```
현재 placeholder: `kakaoTODO_REPLACE_WITH_NATIVE_KEY`

### Android 추가 설정
- AndroidManifest.xml은 이미 카카오톡 queries 설정 완료
- 별도 scheme 등록 불필요 (flutter SDK가 처리)

### 카카오 메시지 템플릿
1. Kakao Developers → **도구** → **메시지 템플릿**
2. 초대 메시지 템플릿 생성 (변수: `invite_code`, `invite_url`)
3. 템플릿 ID를 `KakaoShareService.shareInviteLink(templateId: <ID>)`에 입력

---

## 4. Mixpanel (이벤트 분석)

### 발급 방법
1. https://mixpanel.com → 프로젝트 생성
2. **Settings** → **Project Details** → **Project Token** 복사 → `MIXPANEL_TOKEN`으로 사용

### 이벤트 목록
`AnalyticsService` 상수 참조:
- `game_joined` — 게임 참여
- `block_selected` — 블록 선택
- `invite_sent` — 초대 발송
- `ad_watched` — 광고 시청
- `sign_in` / `sign_out` — 로그인/아웃
- `kakao_share_tapped` — 카카오 공유 버튼 탭
- `push_received` — 푸시 수신
- `deep_link_opened` — 딥링크 열림

---

## 5. 딥링크 (App Links / Universal Links)

### Android App Links
- 도메인 소유권 인증 필요: `https://blockpick.app/.well-known/assetlinks.json` 호스팅
- `AndroidManifest.xml`에서 `android:autoVerify="true"` 추가 (현재 TODO 주석 처리)

### iOS Universal Links
- Apple Developer Console → **Associated Domains** 추가: `applinks:blockpick.app`
- 도메인에 `/.well-known/apple-app-site-association` 파일 호스팅
- Xcode → **Signing & Capabilities** → **Associated Domains** 추가

### 커스텀 스킴 (즉시 사용 가능)
- `blockpick://blockpick/:id` → 블록픽 상세
- `blockpick://invite/:code` → 초대 코드 처리

---

## S20 세션 체크리스트

- [ ] Firebase 프로젝트 생성 + google-services 파일 추가
- [ ] APNs 인증 키 발급 + Firebase 등록
- [ ] Sentry 프로젝트 생성 + DSN 발급
- [ ] Kakao Developers 앱 등록 + 네이티브 앱키 발급
- [ ] Kakao 메시지 템플릿 생성 + templateId 코드에 반영
- [ ] Info.plist의 `kakaoTODO_REPLACE_WITH_NATIVE_KEY` → 실제 키로 교체
- [ ] Mixpanel 프로젝트 생성 + 토큰 발급
- [ ] CI/CD 파이프라인에 dart-define 환경변수 등록
- [ ] FCM 백엔드 `registerPushToken` GraphQL mutation 구현
- [ ] App Links / Universal Links 도메인 설정
