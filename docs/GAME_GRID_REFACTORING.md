# 게임 그리드 줌/픽 UX 개선 시스템

## 📋 개요

이 문서는 BlockPick 앱의 게임판 줌/픽 UX 개선을 위한 리팩토링 내용을 설명합니다.

### 문제점
1. **축소 상태에서 픽 위치 확인 어려움** - 작은 아이콘이 어디 있는지 잘 안 보임
2. **줌 후 픽 위치 찾기 어려움** - 확대하면 어디를 픽했는지 찾을 수 없음
3. **그리드 크기별 줌 대응 부족** - 100x100과 10000x10000이 같은 방식으로 처리됨

### 해결 방안
1. ✅ **계층적 픽 표시 시스템** - 줌 레벨에 따라 다르게 표시
2. ✅ **클러스터링** - 축소 시 인접한 픽들을 그룹화
3. ✅ **미니맵** - 전체 그리드 + 현재 위치 표시
4. ✅ **리스트-그리드 연동** - 리스트 탭 → 해당 픽으로 이동
5. ✅ **그리드 크기별 적응형 줌** - baseZoom 자동 계산

---

## 🏗️ 아키텍처

### 새로운 파일 구조

```
lib/
├── utils/
│   └── zoom_calculator.dart          # 줌 레벨 계산 유틸리티
├── models/
│   └── pick_cluster_model.dart       # 클러스터링 모델 & 알고리즘
├── widgets/
│   ├── pick_marker_widget.dart       # 적응형 마커 위젯
│   └── minimap_widget.dart           # 미니맵 컴포넌트
├── features/
│   ├── grid/
│   │   └── game_grid_widget_v2.dart  # 리팩토링된 그리드 위젯
│   └── game/
│       └── game_detail_screen_v3.dart # 리팩토링된 게임 상세 화면
└── providers/
    └── grid_state_provider.dart      # GridState에 baseZoom 추가
```

---

## 📊 줌 레벨 시스템

### ZoomLevel enum

```dart
enum ZoomLevel {
  ultraZoomedOut,  // 매우 축소 (클러스터 마커)
  zoomedOut,       // 축소 (고정 크기 마커)
  medium,          // 중간 (적응형 마커)
  zoomedIn,        // 확대 (전체 셀 마커)
  ultraZoomedIn,   // 매우 확대 (상세 정보)
}
```

### baseZoom 계산

각 그리드 크기에 맞는 기준 줌 레벨을 자동으로 계산:

```dart
double baseZoom = ZoomCalculator.calculateBaseZoom(
  gridWidth: 10000,
  gridHeight: 10000,
  screenWidth: screenWidth,
  screenHeight: screenHeight,
);
// 결과: 0.0108 (10000x10000 그리드의 경우)
```

### 줌 레벨별 동작

| 줌 레벨 | 표시 방식 | 마커 크기 | 클러스터링 |
|---------|-----------|-----------|------------|
| Ultra Zoomed Out | 클러스터 배지 (숫자) | 28px 고정 | ✅ 40px 임계값 |
| Zoomed Out | 원형 마커 | 24px 고정 | ✅ 30px 임계값 |
| Medium | SVG 아이콘 | 최소 16px | ❌ |
| Zoomed In | SVG 아이콘 | 셀의 95% | ❌ |
| Ultra Zoomed In | SVG 아이콘 + 상세 | 셀의 95% | ❌ |

---

## 🎯 마커 시스템

### 1. 축소 시 - 원형 마커 (고정 크기)

```dart
PickMarkerWidget(
  block: block,
  markerSize: 24.0,  // 고정 크기
  zoomLevel: ZoomLevel.zoomedOut,
)
```

**특징:**
- 줌과 무관하게 항상 24px로 표시
- 흰색 테두리 + 그림자 효과
- 포커스 시 노란색으로 변경

### 2. 매우 축소 시 - 클러스터 마커

```dart
ClusterMarkerWidget(
  cluster: cluster,  // 여러 픽을 포함
  markerSize: 28.0,
)
```

**특징:**
- 인접한 픽들을 하나로 묶어서 숫자로 표시
- 픽 개수에 따라 색상 강도 변화
  - 1-3개: 밝은 파랑
  - 4-10개: 중간 파랑
  - 11+개: 진한 파랑

### 3. 확대 시 - SVG 아이콘

```dart
PickMarkerWidget(
  block: block,
  markerSize: cellSize * 0.95,
  zoomLevel: ZoomLevel.zoomedIn,
)
```

**특징:**
- 기존 SVG 아이콘 사용
- 블록 상태에 따라 다른 아이콘
- 포커스 시 펄스 애니메이션

---

## 🗺️ 미니맵

### 기능

1. **전체 그리드 보기** - 축소된 전체 그리드 표시
2. **픽 위치 표시** - 모든 픽을 파란 점으로 표시
3. **현재 뷰포트** - 보고 있는 영역을 박스로 표시
4. **빠른 이동** - 미니맵 탭 → 해당 위치로 이동
5. **확대/축소** - 탭으로 미니맵 크기 변경 (100px ↔ 160px)

### 사용법

```dart
MinimapWidget(
  gridConfig: gridConfig,
  screenWidth: size.width,
  screenHeight: size.height,
)
```

### 위치

- 모바일: 우측 하단 (bottom: 192px, right: 16px)
- 데스크톱: 우측 하단 (그리드 영역 내)

---

## 🔗 리스트-그리드 연동

### 동작

1. **리스트 아이템 탭** → 해당 픽으로 자동 이동 + 줌
2. **포커스 표시** → 파란 타겟 아이콘 + 배경색 변경
3. **펄스 애니메이션** → 그리드 상의 픽이 깜빡임
4. **재탭으로 포커스 해제**

### 구현

```dart
void _handleListItemTap(BlockModel block) {
  final size = MediaQuery.of(context).size;

  ref.read(gridStateProvider(_gridConfig).notifier).navigateToBlock(
    block,
    screenWidth: size.width,
    screenHeight: size.height,
    targetZoom: _gridConfig.baseZoom * 2.0, // 적당히 확대
  );
}
```

---

## 🚀 클러스터링 알고리즘

### 간단한 그리드 기반 클러스터링

임계값 이내의 픽들을 하나로 묶음:

```dart
List<PickCluster> clusters = PickClusteringAlgorithm.clusterPicks(
  picks: selectedBlocks,
  zoom: currentZoom,
  panX: panX,
  panY: panY,
  cellSize: AppConstants.cellSize,
  threshold: 40.0, // 40px 이내면 클러스터링
);
```

### DBSCAN 클러스터링

더 정교한 클러스터링 (선택 사항):

```dart
List<PickCluster> clusters = PickClusteringAlgorithm.dbscanCluster(
  picks: selectedBlocks,
  zoom: currentZoom,
  panX: panX,
  panY: panY,
  cellSize: AppConstants.cellSize,
  epsilon: 40.0,
  minPoints: 1,
);
```

---

## 📱 사용 방법

### 기존 코드 마이그레이션

#### Before (V2)

```dart
GameDetailScreenV2(
  gameId: gameId,
)
```

#### After (V3)

```dart
GameDetailScreenV3(
  gameId: gameId,
)
```

### 새로운 GridConfig

기존에는 `gameId`만 전달했지만, 이제는 `GridConfig`를 사용:

```dart
final gridConfig = GridConfig(
  gameId: widget.gameId,
  gridWidth: gridSize,
  gridHeight: gridSize,
  baseZoom: baseZoom,
);

// Provider 사용
ref.watch(gridStateProvider(gridConfig))
ref.read(gridStateProvider(gridConfig).notifier)
```

---

## 🎨 UI/UX 개선 사항

### 1. 축소 상태
- ✅ 고정 크기 마커 → 항상 잘 보임
- ✅ 클러스터링 → 여러 픽을 숫자로 표시
- ✅ 미니맵 → 전체 구조 파악

### 2. 확대 상태
- ✅ SVG 아이콘 → 기존과 동일
- ✅ 포커스 펄스 → 리스트에서 선택한 픽 강조

### 3. 네비게이션
- ✅ 리스트 탭 → 자동 이동
- ✅ 미니맵 탭 → 빠른 이동
- ✅ 적정 줌 레벨 자동 계산

### 4. 그리드 크기 대응
- ✅ 100x100: baseZoom = 0.27 (화면 가득)
- ✅ 1000x1000: baseZoom = 0.027
- ✅ 10000x10000: baseZoom = 0.0027

---

## 🧪 테스트 방법

### 1. 다양한 그리드 크기 테스트

```dart
// MockGameData에 다양한 크기 추가
GameRound(
  id: 'test-100',
  gridSize: 100,
  ...
),
GameRound(
  id: 'test-1000',
  gridSize: 1000,
  ...
),
GameRound(
  id: 'test-10000',
  gridSize: 10000,
  ...
),
```

### 2. 줌 레벨별 테스트

1. **매우 축소** - 클러스터 마커 확인
2. **축소** - 원형 마커 확인
3. **중간** - SVG 아이콘 확인
4. **확대** - 상세 표시 확인

### 3. 기능 테스트

- [ ] 픽 선택 → 마커 표시
- [ ] 리스트 탭 → 그리드로 이동
- [ ] 미니맵 탭 → 위치 이동
- [ ] 줌 in/out → 마커 변화
- [ ] 클러스터링 → 숫자 표시

---

## 🔧 설정 가능한 값

### AppConstants 추가

```dart
// Minimap
static const double minimapSize = 100.0;
static const double minimapSizeExpanded = 160.0;
static const double minimapBottom = 192.0;
static const double minimapRight = 16.0;
```

### ZoomCalculator 커스터마이징

```dart
// 마커 크기 조정
double calculateMarkerSize(double cellSize, ZoomLevel zoomLevel) {
  switch (zoomLevel) {
    case ZoomLevel.ultraZoomedOut:
      return 28.0; // ← 이 값 조정
    case ZoomLevel.zoomedOut:
      return 24.0; // ← 이 값 조정
    // ...
  }
}

// 클러스터링 임계값 조정
double getClusterThreshold(ZoomLevel zoomLevel) {
  switch (zoomLevel) {
    case ZoomLevel.ultraZoomedOut:
      return 40.0; // ← 이 값 조정 (더 크면 더 많이 묶임)
    case ZoomLevel.zoomedOut:
      return 30.0; // ← 이 값 조정
    default:
      return 0.0;
  }
}
```

---

## 📈 성능 최적화

### 1. Viewport Culling

화면 밖 마커는 렌더링하지 않음:

```dart
if (x + cellSize < -50 || x > size.width + 50 ||
    y + cellSize < -50 || y > size.height + 50) {
  continue; // 화면 밖이므로 건너뜀
}
```

### 2. 마커 렌더링 최소 크기

너무 작으면 렌더링 생략:

```dart
if (!ZoomCalculator.shouldRenderMarker(cellSize)) {
  return []; // 2px 이하면 렌더링 안 함
}
```

### 3. 클러스터링

매우 축소 시 개별 마커 대신 클러스터로 표시하여 렌더링 부하 감소

---

## 🎯 향후 개선 사항

1. **히트맵 오버레이** - 픽 밀도를 색상으로 표시
2. **구역별 그룹핑** - 리스트를 구역별로 나눔 (예: "상단 좌측: 3 picks")
3. **스마트 줌 타겟팅** - "내 픽 모두 보기" 버튼
4. **애니메이션 개선** - 픽 추가 시 파장 효과
5. **미니맵 스타일** - 다크 모드 지원

---

## 📞 문의

궁금한 점이나 개선 제안이 있으시면 이슈를 등록해주세요!
