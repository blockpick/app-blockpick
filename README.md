# BlockPick Flutter

BlockPick 게임의 Flutter 버전입니다. Next.js 웹앱을 모바일 앱으로 마이그레이션한 프로젝트입니다.

## 프로젝트 개요

BlockPick은 대형 그리드(최대 1000x1000) 기반의 블록 선택 게임으로, 사용자가 그리드에서 블록을 선택하여 게임에 참여하는 시스템입니다.

### 주요 기능

- ✅ **대형 그리드 렌더링**: 10x10부터 1000x1000까지 다양한 크기의 그리드 지원
- ✅ **고성능 렌더링**: CustomPaint 기반 최적화, LOD 시스템, Sparse Grid
- ✅ **직관적인 제스처**: 핀치 투 줌, 팬(데스크톱 전용), 탭 선택
- ✅ **반응형 디자인**: 모바일, 태블릿, 데스크톱 지원
- ✅ **플랫폼별 최적화**: 모바일에서는 팬 제스처 비활성화로 UX 개선
- ✅ **상태 관리**: Riverpod 기반 안정적인 상태 관리
- ✅ **디자인 시스템**: UI 명세서 기반 완전한 디자인 시스템

## 기술 스택

- **Flutter**: 3.35.6
- **Dart**: 3.9.2
- **상태 관리**: Riverpod 2.6.1
- **아이콘**: Lucide Icons
- **애니메이션**: Flutter Animate

## 프로젝트 구조

```
lib/
├── core/                    # 핵심 시스템
│   ├── theme/              # 테마 및 디자인 시스템
│   │   ├── app_colors.dart       # 색상 팔레트
│   │   ├── app_text_styles.dart  # 타이포그래피
│   │   └── app_theme.dart        # 전체 테마
│   ├── constants/          # 상수
│   │   └── app_constants.dart
│   └── utils/              # 유틸리티
│
├── features/               # 기능별 모듈
│   ├── grid/              # 그리드 렌더링
│   │   ├── grid_painter.dart       # CustomPainter
│   │   └── game_grid_widget.dart   # 그리드 위젯
│   ├── game/              # 게임 화면
│   │   └── game_screen.dart
│   └── ui/                # UI 컴포넌트
│
├── models/                # 데이터 모델
│   └── block_model.dart
│
├── providers/             # 상태 관리
│   └── grid_state_provider.dart
│
├── widgets/               # 공통 위젯
│
└── main.dart             # 앱 진입점
```

## 설치 및 실행

### 1. 패키지 설치

```bash
# 패키지 설치
flutter pub get

# 패키지 업데이트
flutter pub upgrade

# 특정 패키지 추가
flutter pub add <package_name>

# 개발용 패키지 추가
flutter pub add --dev <package_name>
```

### 2. 앱 실행

```bash
# 사용 가능한 디바이스 확인
flutter devices

# 개발 모드 (디버그)
flutter run

# 릴리즈 모드 (최적화됨)
flutter run --release

# 프로필 모드 (성능 측정용)
flutter run --profile
```

#### 플랫폼별 실행

```bash
# Chrome 웹 브라우저
flutter run -d chrome

# macOS 데스크톱
flutter run -d macos

# Android 에뮬레이터
flutter run -d emulator-5554

# 특정 포트로 웹 실행
flutter run -d chrome --web-port=8080

# 웹 서버 모드 (자동 새로고침)
flutter run -d web-server

# 웹 렌더러 선택 (html/canvaskit)
flutter run -d chrome --web-renderer canvaskit
```

### 3. 빌드

```bash
# 빌드 결과물 정리
flutter clean

# Android APK 빌드
flutter build apk

# Android App Bundle 빌드 (Google Play용)
flutter build appbundle

# iOS 빌드
flutter build ios

# macOS 빌드
flutter build macos

# 웹 빌드
flutter build web

# 웹 빌드 (렌더러 선택)
flutter build web --web-renderer canvaskit
```

### 4. 테스트 & 분석

```bash
# 모든 테스트 실행
flutter test

# 특정 테스트 실행
flutter test test/widget_test.dart

# 코드 분석 (lint)
flutter analyze

# 코드 포맷팅
flutter format .

# 코드 포맷팅 체크만
flutter format --set-exit-if-changed .
```

### 5. 코드 생성 (Riverpod, Freezed 등)

```bash
# build_runner로 코드 생성
dart run build_runner build

# watch 모드 (자동 재생성)
dart run build_runner watch

# 기존 생성 파일 삭제 후 재생성
dart run build_runner build --delete-conflicting-outputs
```

### 6. 디버깅 & 개발 도구

```bash
# Flutter 환경 점검
flutter doctor

# 상세 환경 점검
flutter doctor -v

# 디바이스 로그 확인
flutter logs

# Flutter SDK 업그레이드
flutter upgrade

# Flutter 버전 확인
flutter --version
```

#### 실행 중 단축키

```
r - 핫 리로드
R - 핫 리스타트
p - 성능 오버레이 토글
i - 위젯 인스펙터 열기
q - 종료
```

### 7. 에뮬레이터 관리

```bash
# 사용 가능한 에뮬레이터 목록
flutter emulators

# 에뮬레이터 실행
flutter emulators --launch <emulator_id>
```

## 구현 완료 항목

### ✅ Phase 1: 디자인 시스템
- [x] 색상 팔레트 (14+ 색상)
- [x] 타이포그래피 시스템
- [x] 테마 시스템
- [x] 그라데이션 정의

### ✅ Phase 2: 핵심 그리드 시스템
- [x] CustomPaint 기반 렌더링
- [x] Sparse Grid 최적화
- [x] LOD (Level of Detail) 시스템
- [x] Viewport Culling
- [x] 제스처 처리 (핀치 줌, 팬, 탭)

### ✅ Phase 3: 상태 관리
- [x] Riverpod 설정
- [x] GridState 프로바이더
- [x] 블록 선택 상태 관리

### ✅ Phase 4: 메인 화면
- [x] 게임 화면 레이아웃
- [x] 정보 패널
- [x] 줌 컨트롤
- [x] 하단 컨트롤

## 향후 개발 예정

### 🚧 Phase 5: UI 컴포넌트
- [ ] 헤더 컴포넌트
- [ ] 사이드바 (데스크톱)
- [ ] 바텀시트 (모바일)
- [ ] 미니맵
- [ ] 플로팅 컨트롤

### 🚧 Phase 6: 애니메이션
- [ ] 슬라이드 애니메이션
- [ ] 스케일 애니메이션
- [ ] 진행률 바 애니메이션
- [ ] 리스트 애니메이션

### 🚧 Phase 7: 네트워크 & 데이터
- [ ] API 연동
- [ ] GraphQL 설정
- [ ] 로컬 저장소 (Hive)
- [ ] 게임 데이터 동기화

### 🚧 Phase 8: 최적화
- [ ] 성능 프로파일링
- [ ] 메모리 최적화
- [ ] 배터리 최적화

## 성능 목표

- **FPS**: 60fps 유지
- **그리드 렌더링**: < 60ms
- **줌 애니메이션**: 300ms
- **메모리**: < 100MB (1000x1000 그리드)
- **최대 가시 셀**: 25,000개

## 디자인 시스템

### 색상 팔레트

```dart
// Main Colors
AppColors.blue      // #5C72F5 - Primary CTA
AppColors.purple    // #6E5AE9 - Secondary
AppColors.pink      // #FF58BB - Alerts
AppColors.red       // #FF5D5C - Destructive
AppColors.green     // #10B981 - Success
AppColors.yellow    // #F59E0B - Warning

// Gradients
AppColors.gradientBlue
AppColors.gradientPink
AppColors.gradientPurple
AppColors.gradientBluePurplePink
```

### 타이포그래피

```dart
AppTextStyles.display     // 32px, bold
AppTextStyles.large       // 24px, bold
AppTextStyles.medium      // 18px, semibold
AppTextStyles.bodyLarge   // 16px, medium
AppTextStyles.body        // 14px, normal
AppTextStyles.bodySmall   // 12px, normal
AppTextStyles.caption     // 10px, normal
```

## 문서

프로젝트 문서는 `/docs` 폴더에 위치합니다:

- `UI_SPECIFICATION_INDEX.md`: 전체 UI 명세 인덱스
- `BLOCKPICK_UI_UX_SPECIFICATION.md`: 상세 UI/UX 명세 (1,280 lines)
- `UI_ANALYSIS_SUMMARY.md`: 분석 요약
- `BLOCKPICK_UI_SPEC.md`: 한글 상세 기획서 (2,377 lines)

## 라이선스

이 프로젝트는 Adrock의 소유입니다.

## 기여

이 프로젝트는 private 프로젝트입니다. 팀 멤버만 기여할 수 있습니다.

---

**개발 시작일**: 2025-10-22
**현재 버전**: 1.0.0
**상태**: 개발 중 (Phase 4 완료)
