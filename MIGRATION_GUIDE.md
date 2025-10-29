# GridState 마이그레이션 가이드

## 문제 상황

`GridStateProvider`가 `String` (gameId)에서 `GridConfig`로 변경되어 기존 코드가 작동하지 않습니다.

## 빠른 해결 방법

### 옵션 1: 새 코드 사용 (권장)

`GameDetailScreenV3`와 `GameGridWidgetV2`를 사용하세요. 이 버전들은 완전히 새로운 시스템을 사용합니다.

```dart
// 사용 예시
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => GameDetailScreenV3(
      gameId: 'your-game-id',
    ),
  ),
);
```

### 옵션 2: 기존 코드 임시 호환 (임시 방편)

`providers/grid_state_provider.dart`에 임시 호환 레이어를 추가합니다:

```dart
// 임시 호환성 프로바이더 추가
final gridStateProviderLegacy =
    StateNotifierProvider.family<GridStateNotifier, GridState, String>((ref, gameId) {
  // 기본값 사용 (100x100 그리드, baseZoom = 0.27)
  return GridStateNotifier(
    gridWidth: 100,
    gridHeight: 100,
    baseZoom: 0.27,
  );
});
```

그리고 기존 코드에서:

```dart
// Before
ref.watch(gridStateProvider(gameId))

// After (임시)
ref.watch(gridStateProviderLegacy(gameId))
```

## 완전한 마이그레이션 (권장)

### 1. GridConfig 생성

```dart
// MediaQuery로 화면 크기 가져오기
final screenSize = MediaQuery.of(context).size;

// baseZoom 계산
final baseZoom = ZoomCalculator.calculateBaseZoom(
  gridWidth: gridWidth,
  gridHeight: gridHeight,
  screenWidth: screenSize.width,
  screenHeight: screenSize.height,
);

// GridConfig 생성
final gridConfig = GridConfig(
  gameId: gameId,
  gridWidth: gridWidth,
  gridHeight: gridHeight,
  baseZoom: baseZoom,
);
```

### 2. Provider 사용

```dart
// Before
ref.watch(gridStateProvider(gameId))
ref.read(gridStateProvider(gameId).notifier)

// After
ref.watch(gridStateProvider(gridConfig))
ref.read(gridStateProvider(gridConfig).notifier)
```

### 3. 컴포넌트에 GridConfig 전달

```dart
// Before
SelectedBlocksSheet(gameId: gameId)
GameGridWidget(gameId: gameId, ...)

// After
SelectedBlocksSheet(gridConfig: gridConfig)
GameGridWidgetV2(gameId: gameId, ...) // V2 사용
```

## 파일별 수정 사항

### ✅ 수정 완료
- `lib/features/game/game_screen.dart`
- `lib/features/game/selected_blocks_sheet.dart`

### ❌ 수정 필요
- `lib/features/grid/game_grid_widget.dart` (기존 버전)
  - → V2 버전 사용 권장

## 자동 마이그레이션 스크립트

추후 제공 예정

## 롤백 방법

만약 문제가 생기면 `grid_state_provider.dart`를 다음과 같이 임시로 되돌립니다:

```dart
// 전체 파일을 git에서 복구
git checkout HEAD -- lib/providers/grid_state_provider.dart
```

그러나 새로운 기능들(클러스터링, 미니맵 등)은 작동하지 않습니다.
