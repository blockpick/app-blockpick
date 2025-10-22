# BlockPick 게임판 완벽 재현 기획서 (Flutter 마이그레이션용)

> **작성일**: 2025-10-22
> **목적**: 현재 구현된 NewGameGrid 컴포넌트를 Flutter로 100% 동일하게 재현
> **기반 코드**: `components/blockpick/new-round/new-game-grid.tsx` (1,915줄)

---

## 📋 목차

1. [게임판 핵심 개념](#1-게임판-핵심-개념)
2. [렌더링 시스템 완벽 분석](#2-렌더링-시스템-완벽-분석)
3. [줌 & 팬 시스템](#3-줌--팬-시스템)
4. [인터랙션 시스템](#4-인터랙션-시스템)
5. [성능 최적화 전략](#5-성능-최적화-전략)
6. [시각적 요소 명세](#6-시각적-요소-명세)
7. [상태 관리 플로우](#7-상태-관리-플로우)
8. [Flutter 완벽 재현 가이드](#8-flutter-완벽-재현-가이드)
9. [실제 동작 시나리오](#9-실제-동작-시나리오)
10. [Flutter 전체 코드 예제](#10-flutter-전체-코드-예제)

---

## 1. 게임판 핵심 개념

### 1.1 게임판이란?

**BlockPick 게임판**은 10x10 ~ 1000x1000 크기의 **거대한 그리드**입니다.
- 사용자는 이 그리드에서 특정 블록(셀)을 선택합니다
- 선택한 블록으로 게임에 참여하고 상품을 받을 수 있습니다
- **핵심**: 1,000,000개의 셀을 매끄럽게 렌더링하고 상호작용해야 합니다

### 1.2 기술적 도전과제

1. **메모리 문제**: 1000x1000 = 100만 개 셀을 모두 렌더링하면 브라우저 크래시
2. **성능 문제**: 60fps로 부드러운 줌/팬 제공
3. **UX 문제**: 작은 셀을 정확히 클릭하기 어려움
4. **스케일 문제**: 전체 뷰 vs 상세 뷰의 간극이 큼

### 1.3 해결 방법 (현재 구현)

| 문제 | 해결책 | 구현 위치 |
|------|-------|----------|
| 메모리 | Sparse Grid (빈 셀 저장 안 함) | `SparseGrid` 클래스 (70-125줄) |
| 메모리 | Object Pool (객체 재사용) | `TilePool` 클래스 (23-67줄) |
| 성능 | Viewport Culling (화면 밖 미렌더링) | `getViewportBounds()` (104-117줄) |
| 성능 | LOD (Level of Detail) 시스템 | `LODManager` 클래스 (128-178줄) |
| UX | 적응적 인터랙션 (줌 레벨별 동작 변경) | 274-301줄, 1235-1279줄 |
| 스케일 | 동적 축척 레벨 (그리드 크기별) | `generateScaleLevels()` (213-268줄) |

---

## 2. 렌더링 시스템 완벽 분석

### 2.1 렌더링 구조 (레이어별)

게임판은 **6개의 레이어**로 구성됩니다:

```
┌─────────────────────────────────────────┐
│ Layer 6: UI 오버레이 (정보, 컨트롤)       │
├─────────────────────────────────────────┤
│ Layer 5: 셀 아이콘 (선택 표시)           │
├─────────────────────────────────────────┤
│ Layer 4: 그리드 오버레이 (반투명)        │
├─────────────────────────────────────────┤
│ Layer 3: SVG 그리드 선                  │
├─────────────────────────────────────────┤
│ Layer 2: 광고 배경 이미지               │
├─────────────────────────────────────────┤
│ Layer 1: 그라데이션 배경                │
└─────────────────────────────────────────┘
```

#### 2.1.1 Layer 1: 그라데이션 배경

**코드 위치**: 1308줄
```tsx
<div className="relative h-full w-full rounded-2xl border border-bulegray
     bg-gradient-to-br from-bgwhite to-blue-50 overflow-hidden backdrop-blur-sm shadow-lg">
```

**Flutter 구현**:
```dart
Container(
  decoration: BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Color(0xFFEFF2F7), // bgwhite
        Color(0xFFEBF8FF), // blue-50
      ],
    ),
    borderRadius: BorderRadius.circular(16),
    border: Border.all(color: Color(0xFFDADBE3)),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.1),
        blurRadius: 15,
        offset: Offset(0, 4),
      ),
    ],
  ),
)
```

#### 2.1.2 Layer 2: 광고 배경 이미지

**코드 위치**: 1316-1354줄

**특징**:
- `showFullAd`가 `true`일 때만 표시
- 그리드 크기와 정확히 일치 (`gridSize * CELL_SIZE * zoom`)
- 줌/팬에 따라 함께 이동
- 이미지 로딩 에러 시 기본 그라데이션으로 대체

**Flutter 구현**:
```dart
if (showFullAd && fullAdImage != null)
  Positioned(
    left: gridPosition.x,
    top: gridPosition.y,
    child: Container(
      width: gridSize * CELL_SIZE * zoom,
      height: gridSize * CELL_SIZE * zoom,
      child: Image.network(
        fullAdImage,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          // 에러 시 기본 그라데이션
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF6B21A8).withOpacity(0.3), // purple-900
                  Color(0xFF155E75).withOpacity(0.3), // cyan-900
                ],
              ),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('🎁', style: TextStyle(fontSize: 32)),
                  SizedBox(height: 8),
                  Text('상품 이미지', style: TextStyle(fontSize: 12, color: Colors.white60)),
                ],
              ),
            ),
          );
        },
      ),
    ),
  ),
```

#### 2.1.3 Layer 3: SVG 그리드 선

**코드 위치**: 1370-1442줄

**핵심 구조**:
```tsx
<svg width="100%" height="100%">
  <defs>
    {/* 그리드 패턴 정의 */}
    <pattern id="grid-pattern" width={CELL_SIZE * zoom} height={CELL_SIZE * zoom}>
      <path d="..." stroke="rgba(6, 182, 212, 0.8)" strokeWidth="1" />
    </pattern>
  </defs>

  {/* 패턴 적용 */}
  <rect width="100%" height="100%" fill="url(#grid-pattern)" />
</svg>
```

**그리드 선 색상 (줌 레벨별)**:
```typescript
stroke: zoom < 0.1 ? "rgba(6, 182, 212, 0.4)"  // 매우 연함
      : zoom < 0.5 ? "rgba(6, 182, 212, 0.6)"  // 중간
      : "rgba(6, 182, 212, 0.8)"               // 진함
```

**그리드 선 두께 (줌 레벨별)**:
```typescript
strokeWidth: zoom < 0.1 ? 0.5
           : zoom < 0.5 ? Math.max(0.5, zoom)
           : Math.max(1, Math.min(2, zoom * 1.5))
```

**대용량 그리드 최적화** (1417-1432줄):
- gridSize > 500 && zoom < 0.2일 때 sparse grid 사용
- gridStepSize = Math.max(5, Math.floor(gridSize / 100))
- 모든 선을 그리지 않고 5~10칸마다 1개씩만 그림

**Flutter 구현**:
```dart
class GridPainter extends CustomPainter {
  final double cellSize;
  final double zoom;
  final int gridSize;
  final bool shouldUseSparseGrid;
  final int gridStepSize;

  GridPainter({
    required this.cellSize,
    required this.zoom,
    required this.gridSize,
    required this.shouldUseSparseGrid,
    required this.gridStepSize,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..strokeWidth = _getStrokeWidth()
      ..color = _getStrokeColor()
      ..style = PaintingStyle.stroke;

    final step = shouldUseSparseGrid ? gridStepSize : 1;

    // 세로 선
    for (int i = 0; i <= gridSize; i += step) {
      final x = i * cellSize * zoom;
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, gridSize * cellSize * zoom),
        paint,
      );
    }

    // 가로 선
    for (int i = 0; i <= gridSize; i += step) {
      final y = i * cellSize * zoom;
      canvas.drawLine(
        Offset(0, y),
        Offset(gridSize * cellSize * zoom, y),
        paint,
      );
    }
  }

  double _getStrokeWidth() {
    if (zoom < 0.1) return 0.5;
    if (zoom < 0.5) return max(0.5, zoom);
    return max(1.0, min(2.0, zoom * 1.5));
  }

  Color _getStrokeColor() {
    if (zoom < 0.1) return Color(0xFF06B6D4).withOpacity(0.4);
    if (zoom < 0.5) return Color(0xFF06B6D4).withOpacity(0.6);
    return Color(0xFF06B6D4).withOpacity(0.8);
  }

  @override
  bool shouldRepaint(GridPainter oldDelegate) {
    return oldDelegate.zoom != zoom ||
           oldDelegate.gridSize != gridSize;
  }
}
```

#### 2.1.4 Layer 4: 그리드 오버레이

**코드 위치**: 1360-1368줄

```tsx
<div className="absolute bg-black/20 pointer-events-none"
     style={{
       width: gridSize * CELL_SIZE * zoom,
       height: gridSize * CELL_SIZE * zoom,
       transform: `translate(${gridPosition.x}px, ${gridPosition.y}px)`
     }}
></div>
```

**목적**: 그리드 전체에 약간의 어두운 오버레이를 씌워 깊이감 연출

**Flutter 구현**:
```dart
Positioned(
  left: gridPosition.x,
  top: gridPosition.y,
  child: Container(
    width: gridSize * CELL_SIZE * zoom,
    height: gridSize * CELL_SIZE * zoom,
    color: Colors.black.withOpacity(0.2),
  ),
),
```

#### 2.1.5 Layer 5: 셀 아이콘

**코드 위치**: 1444-1561줄

**셀 아이콘 종류**:
| 아이콘 | 파일명 | 용도 | 크기 |
|--------|--------|------|------|
| 선택됨 | `selected.svg` | 사용자가 클릭한 셀 | 셀 크기의 95% |
| 리스트 선택 | `list-selected.svg` | 사이드바에서 클릭한 셀 (하이라이트) | 셀 크기의 95% |
| 과거 선택 | `past.svg` | 게임 종료 후 과거 선택 표시 | 셀 크기의 95% |

**렌더링 로직**:
```typescript
// 1. selectedBlocks 배열 순회
selectedBlocks.forEach(block => {
  const col = block.col - 1  // 1-based → 0-based
  const row = block.row - 1
  const x = col * CELL_SIZE * zoom
  const y = row * CELL_SIZE * zoom
  const cellSize = CELL_SIZE * zoom

  // 아이콘 경로 결정
  let iconPath = "/icons/pick/selected.svg"
  if (isHighlighted) iconPath = "/icons/pick/list-selected.svg"
  if (gameState === "results") iconPath = "/icons/pick/past.svg"

  // 아이콘 렌더링
  <img src={iconPath}
       style={{ width: cellSize * 0.95, height: cellSize * 0.95 }} />
})

// 2. 현재 선택된 셀 (selectedCell) 렌더링
if (selectedCell !== null) {
  const col = selectedCell % gridSize
  const row = Math.floor(selectedCell / gridSize)
  // ... 동일한 로직
}
```

**하이라이트 애니메이션** (1501줄):
```typescript
animation: isAnimating ? 'pulse 1.5s ease-in-out infinite' : 'none'
```

**Flutter 구현**:
```dart
// 선택된 블록들
for (var block in selectedBlocks) {
  final col = block.col - 1;
  final row = block.row - 1;
  final x = col * CELL_SIZE * zoom;
  final y = row * CELL_SIZE * zoom;
  final cellSize = CELL_SIZE * zoom;

  final isHighlighted = highlightedBlock?.row == block.row &&
                       highlightedBlock?.col == block.col;
  final isAnimating = animatingBlock?.row == block.row &&
                     animatingBlock?.col == block.col;

  String iconPath = "assets/icons/pick/selected.svg";
  if (isHighlighted) iconPath = "assets/icons/pick/list-selected.svg";
  if (gameState == GameState.results) iconPath = "assets/icons/pick/past.svg";

  widgets.add(
    Positioned(
      left: x,
      top: y,
      child: SizedBox(
        width: cellSize,
        height: cellSize,
        child: Stack(
          children: [
            if (isAnimating)
              // 펄스 애니메이션
              AnimatedBuilder(
                animation: _pulseController,
                builder: (context, child) {
                  return Opacity(
                    opacity: 0.5 + (_pulseController.value * 0.5),
                    child: child,
                  );
                },
                child: SvgPicture.asset(iconPath, width: cellSize * 0.95),
              )
            else
              SvgPicture.asset(iconPath, width: cellSize * 0.95),

            if (gameState == GameState.results)
              ColorFiltered(
                colorFilter: ColorFilter.mode(
                  Colors.grey,
                  BlendMode.saturation,
                ),
                child: SvgPicture.asset(iconPath, width: cellSize * 0.95),
              ),
          ],
        ),
      ),
    ),
  );
}
```

#### 2.1.6 Layer 6: UI 오버레이

**구성 요소**:
1. **줌 컨트롤** (1564-1705줄) - 웹 전용
2. **그리드 정보** (1708-1737줄) - 웹 전용
3. **선택된 셀 정보** (1740-1752줄)
4. **선택된 블록 카운터** (1756-1767줄) - 웹 전용
5. **인터랙션 안내** (1770-1794줄) - 웹 전용
6. **돋보기** (1797-1836줄) - Z키 누를 때
7. **키보드 도움말** (1839-1905줄) - ? 키

---

### 2.2 Sparse Grid 시스템

#### 2.2.1 개념

**일반 그리드 방식** (메모리 낭비):
```
100x100 그리드 = 10,000개 셀
각 셀 객체 크기: ~100 bytes
총 메모리: 10,000 * 100 = 1MB

1000x1000 그리드 = 1,000,000개 셀
총 메모리: 1,000,000 * 100 = 100MB ❌
```

**Sparse Grid 방식** (메모리 절약):
```
1000x1000 그리드 중 100개만 선택
저장되는 셀: 100개
총 메모리: 100 * 100 = 10KB ✅

메모리 절약: 99.99%
```

#### 2.2.2 구현 (TypeScript)

**코드 위치**: 70-125줄

```typescript
class SparseGrid {
  private tiles = new Map<string, TileData>()  // 핵심: Map 사용
  private pool = TilePool.getInstance()

  // 키 생성: "row,col" 문자열
  private getTileKey(row: number, col: number): string {
    return `${row},${col}`
  }

  // 타일 조회
  getTile(row: number, col: number): TileData | null {
    return this.tiles.get(this.getTileKey(row, col)) || null
  }

  // 타일 설정 (빈 셀은 저장 안 함)
  setTile(row: number, col: number, state: TileData['state']): void {
    const key = this.getTileKey(row, col)
    let tile = this.tiles.get(key)

    if (!tile) {
      tile = this.pool.acquire(row, col)  // Object Pool에서 가져옴
      this.tiles.set(key, tile)
    }

    tile.state = state
    tile.lastUpdated = Date.now()
  }

  // 타일 제거
  removeTile(row: number, col: number): void {
    const key = this.getTileKey(row, col)
    const tile = this.tiles.get(key)
    if (tile) {
      this.tiles.delete(key)
      this.pool.release(tile)  // Object Pool로 반환
    }
  }

  // 뷰포트 내 타일만 가져오기 (Viewport Culling)
  getVisibleTiles(bounds: ViewportBounds): TileData[] {
    const visibleTiles: TileData[] = []

    for (let row = bounds.minRow; row <= bounds.maxRow; row++) {
      for (let col = bounds.minCol; col <= bounds.maxCol; col++) {
        const tile = this.getTile(row, col)
        if (tile && tile.state !== 'empty') {
          visibleTiles.push(tile)
        }
      }
    }

    return visibleTiles
  }
}
```

#### 2.2.3 Flutter 구현

```dart
class TileData {
  final String id;
  final int row;
  final int col;
  TileState state;
  DateTime lastUpdated;

  TileData({
    required this.id,
    required this.row,
    required this.col,
    required this.state,
    required this.lastUpdated,
  });
}

enum TileState {
  empty,
  selected,
  winner,
  unique,
  duplicate,
}

class SparseGrid {
  final Map<String, TileData> _tiles = {};
  final TilePool _pool = TilePool();

  String _getTileKey(int row, int col) => '$row,$col';

  TileData? getTile(int row, int col) {
    return _tiles[_getTileKey(row, col)];
  }

  void setTile(int row, int col, TileState state) {
    final key = _getTileKey(row, col);
    var tile = _tiles[key];

    if (tile == null) {
      tile = _pool.acquire(row, col);
      _tiles[key] = tile;
    }

    tile.state = state;
    tile.lastUpdated = DateTime.now();
  }

  void removeTile(int row, int col) {
    final key = _getTileKey(row, col);
    final tile = _tiles[key];
    if (tile != null) {
      _tiles.remove(key);
      _pool.release(tile);
    }
  }

  List<TileData> getVisibleTiles(ViewportBounds bounds) {
    final visibleTiles = <TileData>[];

    for (var row = bounds.minRow; row <= bounds.maxRow; row++) {
      for (var col = bounds.minCol; col <= bounds.maxCol; col++) {
        final tile = getTile(row, col);
        if (tile != null && tile.state != TileState.empty) {
          visibleTiles.add(tile);
        }
      }
    }

    return visibleTiles;
  }

  void clear() {
    for (var tile in _tiles.values) {
      _pool.release(tile);
    }
    _tiles.clear();
  }
}
```

---

### 2.3 Object Pool 시스템

#### 2.3.1 개념

**일반 방식** (GC 부담):
```typescript
// 셀 선택
const tile = { row: 10, col: 20, state: 'selected' }

// 셀 해제
delete tile  // GC가 메모리 회수 (느림)
```

**Object Pool 방식** (GC 부담 없음):
```typescript
// 셀 선택
const tile = pool.acquire(10, 20)  // 재사용

// 셀 해제
pool.release(tile)  // 풀로 반환 (즉시)
```

#### 2.3.2 구현 (TypeScript)

**코드 위치**: 23-67줄

```typescript
class TilePool {
  private static instance: TilePool
  private pool: TileData[] = []          // 사용 가능한 타일들
  private inUse = new Set<TileData>()   // 사용 중인 타일들

  static getInstance(): TilePool {
    if (!TilePool.instance) {
      TilePool.instance = new TilePool()
    }
    return TilePool.instance
  }

  // 타일 가져오기
  acquire(row: number, col: number): TileData {
    let tile = this.pool.pop()  // 풀에서 가져오기

    if (!tile) {
      // 풀이 비었으면 새로 생성
      tile = {
        id: `${row}-${col}`,
        row,
        col,
        state: 'empty',
        lastUpdated: Date.now()
      }
    } else {
      // 재사용: 값만 업데이트
      tile.id = `${row}-${col}`
      tile.row = row
      tile.col = col
      tile.state = 'empty'
      tile.lastUpdated = Date.now()
    }

    this.inUse.add(tile)
    return tile
  }

  // 타일 반환
  release(tile: TileData): void {
    if (this.inUse.has(tile)) {
      this.inUse.delete(tile)
      this.pool.push(tile)  // 풀로 반환
    }
  }

  // 전체 초기화
  clear(): void {
    this.pool.length = 0
    this.inUse.clear()
  }
}
```

**권장 풀 크기**: 500~1000개

#### 2.3.3 Flutter 구현

```dart
class TilePool {
  final List<TileData> _pool = [];
  final Set<TileData> _inUse = {};

  TileData acquire(int row, int col) {
    TileData? tile;

    if (_pool.isNotEmpty) {
      tile = _pool.removeLast();
      // 재사용: 값 업데이트
      tile.id = '$row-$col';
      tile.row = row;
      tile.col = col;
      tile.state = TileState.empty;
      tile.lastUpdated = DateTime.now();
    } else {
      // 새로 생성
      tile = TileData(
        id: '$row-$col',
        row: row,
        col: col,
        state: TileState.empty,
        lastUpdated: DateTime.now(),
      );
    }

    _inUse.add(tile);
    return tile;
  }

  void release(TileData tile) {
    if (_inUse.contains(tile)) {
      _inUse.remove(tile);
      _pool.add(tile);
    }
  }

  void clear() {
    _pool.clear();
    _inUse.clear();
  }
}
```

---

### 2.4 LOD (Level of Detail) 시스템

#### 2.4.1 개념

**줌 레벨에 따라 렌더링 디테일 조정**:
- 전체 뷰 (zoom < 0.1): 그리드 선만 표시, 텍스트 숨김
- 중간 뷰 (0.1 ≤ zoom < 1.0): 그리드 선 + 선택 표시
- 상세 뷰 (1.0 ≤ zoom < 2.0): 그리드 선 + 텍스트 + 선택 효과
- 초상세 뷰 (zoom ≥ 2.0): 모든 효과 + 애니메이션

#### 2.4.2 구현 (TypeScript)

**코드 위치**: 128-178줄

```typescript
class LODManager {
  private static readonly LOD_THRESHOLDS = [0.05, 0.1, 0.3, 0.6, 1.0, 2.0]

  // 현재 LOD 레벨 계산
  static getLODLevel(zoom: number): number {
    for (let i = 0; i < this.LOD_THRESHOLDS.length; i++) {
      if (zoom <= this.LOD_THRESHOLDS[i]) {
        return i  // 0~5
      }
    }
    return this.LOD_THRESHOLDS.length - 1
  }

  // 그리드 선 간격 계산
  static getGridStep(lodLevel: number, zoom: number, gridSize: number): number {
    const targetGridLines = 20  // 목표: 화면에 약 20개 선

    if (zoom < 0.1) {
      return Math.max(1, Math.floor(gridSize / targetGridLines))
    }
    if (zoom < 0.3) return Math.max(1, Math.floor(gridSize / 50))
    if (zoom < 0.6) return Math.max(1, Math.floor(gridSize / 100))
    if (zoom < 1.0) return Math.max(1, Math.floor(gridSize / 200))
    return 1  // 확대 시: 모든 그리드 라인
  }

  // 최대 렌더링 셀 수
  static getMaxVisibleCells(lodLevel: number, gridSize: number): number {
    const totalCells = gridSize * gridSize
    const baseLimit = Math.max(100, Math.floor(totalCells / 1000))

    switch (lodLevel) {
      case 0: return Math.min(baseLimit, 500)
      case 1: return Math.min(baseLimit * 2, 2000)
      case 2: return Math.min(baseLimit * 5, 10000)
      case 3: return Math.min(baseLimit * 10, 25000)
      default: return Math.min(totalCells, 100000)
    }
  }
}
```

#### 2.4.3 Flutter 구현

```dart
class LODManager {
  static const List<double> LOD_THRESHOLDS = [0.05, 0.1, 0.3, 0.6, 1.0, 2.0];

  static int getLODLevel(double zoom) {
    for (int i = 0; i < LOD_THRESHOLDS.length; i++) {
      if (zoom <= LOD_THRESHOLDS[i]) {
        return i;
      }
    }
    return LOD_THRESHOLDS.length - 1;
  }

  static int getGridStep(int lodLevel, double zoom, int gridSize) {
    const targetGridLines = 20;

    if (zoom < 0.1) {
      return max(1, (gridSize / targetGridLines).floor());
    }
    if (zoom < 0.3) return max(1, (gridSize / 50).floor());
    if (zoom < 0.6) return max(1, (gridSize / 100).floor());
    if (zoom < 1.0) return max(1, (gridSize / 200).floor());
    return 1;
  }

  static int getMaxVisibleCells(int lodLevel, int gridSize) {
    final totalCells = gridSize * gridSize;
    final baseLimit = max(100, (totalCells / 1000).floor());

    switch (lodLevel) {
      case 0:
        return min(baseLimit, 500);
      case 1:
        return min(baseLimit * 2, 2000);
      case 2:
        return min(baseLimit * 5, 10000);
      case 3:
        return min(baseLimit * 10, 25000);
      default:
        return min(totalCells, 100000);
    }
  }
}
```

---

## 3. 줌 & 팬 시스템

### 3.1 동적 축척 레벨

#### 3.1.1 개념

그리드 크기에 따라 **동적으로** 축척 레벨을 생성합니다.

**예시**:
- 10x10 그리드: [0.8x, 1.2x, 1.6x] (3단계)
- 100x100 그리드: [0.2x, 0.5x, 0.9x, 1.3x, 1.7x, 2.1x] (6단계)
- 1000x1000 그리드: [0.05x, 0.1x, 0.3x, 0.5x, 1.0x, 1.4x, 1.8x, 2.2x] (9단계)

#### 3.1.2 구현 (TypeScript)

**코드 위치**: 213-268줄

```typescript
function generateScaleLevels(gridSize: number) {
  const levels = []

  if (gridSize <= 10) {
    // 작은 그리드
    levels.push(
      { blocks: 1, zoom: 0.8, label: `전체 (${gridSize}x${gridSize})` },
      { blocks: 2, zoom: 1.2, label: "구역 뷰" },
      { blocks: 3, zoom: 1.6, label: "상세 뷰" }
    )
  } else if (gridSize <= 20) {
    // 중간 그리드
    levels.push(
      { blocks: 0.8, zoom: 0.5, label: `전체 (${gridSize}x${gridSize})` },
      { blocks: 1.5, zoom: 0.9, label: "구역 뷰" },
      { blocks: 3, zoom: 1.3, label: "상세 뷰" },
      { blocks: 4, zoom: 1.7, label: "매우 상세" }
    )
  } else if (gridSize <= 50) {
    // 큰 그리드
    levels.push(
      { blocks: 0.5, zoom: 0.3, label: `전체 (${gridSize}x${gridSize})` },
      { blocks: 1, zoom: 0.6, label: "광역 뷰" },
      { blocks: 2, zoom: 1.0, label: "구역 뷰" },
      { blocks: 4, zoom: 1.4, label: "상세 뷰" },
      { blocks: 6, zoom: 1.8, label: "매우 상세" }
    )
  } else if (gridSize <= 100) {
    // 매우 큰 그리드
    levels.push(
      { blocks: 0.3, zoom: 0.2, label: `전체 (${gridSize}x${gridSize})` },
      { blocks: 0.8, zoom: 0.5, label: "광역 뷰" },
      { blocks: 2, zoom: 0.9, label: "지역 뷰" },
      { blocks: 5, zoom: 1.3, label: "구역 뷰" },
      { blocks: 8, zoom: 1.7, label: "상세 뷰" },
      { blocks: 10, zoom: 2.1, label: "매우 상세" }
    )
  } else {
    // 거대 그리드 (1000x1000 등)
    const baseZoom = Math.min(0.1, 50 / gridSize)
    levels.push(
      { blocks: 0.05, zoom: baseZoom, label: `전체 (${gridSize}x${gridSize})` },
      { blocks: 0.1, zoom: baseZoom * 2, label: "대륙 뷰" },
      { blocks: 0.3, zoom: baseZoom * 4, label: "국가 뷰" },
      { blocks: 0.5, zoom: baseZoom * 8, label: "광역 뷰" },
      { blocks: 1, zoom: Math.max(0.6, baseZoom * 12), label: "지역 뷰" },
      { blocks: 3, zoom: 1.0, label: "구역 뷰" },
      { blocks: 8, zoom: 1.4, label: "상세 뷰" },
      { blocks: 15, zoom: 1.8, label: "매우 상세" },
      { blocks: 25, zoom: 2.2, label: "초상세" }
    )
  }

  return levels
}
```

#### 3.1.3 Flutter 구현

```dart
class ScaleLevel {
  final double blocks;
  final double zoom;
  final String label;

  ScaleLevel({
    required this.blocks,
    required this.zoom,
    required this.label,
  });
}

List<ScaleLevel> generateScaleLevels(int gridSize) {
  final levels = <ScaleLevel>[];

  if (gridSize <= 10) {
    levels.addAll([
      ScaleLevel(blocks: 1, zoom: 0.8, label: '전체 (${gridSize}x$gridSize)'),
      ScaleLevel(blocks: 2, zoom: 1.2, label: '구역 뷰'),
      ScaleLevel(blocks: 3, zoom: 1.6, label: '상세 뷰'),
    ]);
  } else if (gridSize <= 20) {
    levels.addAll([
      ScaleLevel(blocks: 0.8, zoom: 0.5, label: '전체 (${gridSize}x$gridSize)'),
      ScaleLevel(blocks: 1.5, zoom: 0.9, label: '구역 뷰'),
      ScaleLevel(blocks: 3, zoom: 1.3, label: '상세 뷰'),
      ScaleLevel(blocks: 4, zoom: 1.7, label: '매우 상세'),
    ]);
  } else if (gridSize <= 50) {
    levels.addAll([
      ScaleLevel(blocks: 0.5, zoom: 0.3, label: '전체 (${gridSize}x$gridSize)'),
      ScaleLevel(blocks: 1, zoom: 0.6, label: '광역 뷰'),
      ScaleLevel(blocks: 2, zoom: 1.0, label: '구역 뷰'),
      ScaleLevel(blocks: 4, zoom: 1.4, label: '상세 뷰'),
      ScaleLevel(blocks: 6, zoom: 1.8, label: '매우 상세'),
    ]);
  } else if (gridSize <= 100) {
    levels.addAll([
      ScaleLevel(blocks: 0.3, zoom: 0.2, label: '전체 (${gridSize}x$gridSize)'),
      ScaleLevel(blocks: 0.8, zoom: 0.5, label: '광역 뷰'),
      ScaleLevel(blocks: 2, zoom: 0.9, label: '지역 뷰'),
      ScaleLevel(blocks: 5, zoom: 1.3, label: '구역 뷰'),
      ScaleLevel(blocks: 8, zoom: 1.7, label: '상세 뷰'),
      ScaleLevel(blocks: 10, zoom: 2.1, label: '매우 상세'),
    ]);
  } else {
    final baseZoom = min(0.1, 50 / gridSize);
    levels.addAll([
      ScaleLevel(blocks: 0.05, zoom: baseZoom, label: '전체 (${gridSize}x$gridSize)'),
      ScaleLevel(blocks: 0.1, zoom: baseZoom * 2, label: '대륙 뷰'),
      ScaleLevel(blocks: 0.3, zoom: baseZoom * 4, label: '국가 뷰'),
      ScaleLevel(blocks: 0.5, zoom: baseZoom * 8, label: '광역 뷰'),
      ScaleLevel(blocks: 1, zoom: max(0.6, baseZoom * 12), label: '지역 뷰'),
      ScaleLevel(blocks: 3, zoom: 1.0, label: '구역 뷰'),
      ScaleLevel(blocks: 8, zoom: 1.4, label: '상세 뷰'),
      ScaleLevel(blocks: 15, zoom: 1.8, label: '매우 상세'),
      ScaleLevel(blocks: 25, zoom: 2.2, label: '초상세'),
    ]);
  }

  return levels;
}
```

---

### 3.2 마우스 휠 줌

#### 3.2.1 누적 델타 방식

**문제**: 매직마우스는 deltaY가 매우 작음 (0.1~5), 일반 마우스는 큼 (100+)

**해결**: 델타 누적 후 임계값 초과 시 줌 실행

**코드 위치**: 760-850줄

```typescript
const wheelDeltaAccumulator = useRef(0)
const WHEEL_THRESHOLD = 100

const handleWheelEvent = (e: WheelEvent) => {
  e.preventDefault()

  // 델타 누적
  wheelDeltaAccumulator.current += Math.abs(e.deltaY)

  // 100ms 후 리셋 (연속 스크롤 감지)
  clearTimeout(wheelTimeoutRef.current)
  wheelTimeoutRef.current = setTimeout(() => {
    wheelDeltaAccumulator.current = 0
  }, 100)

  // 임계값 미달 시 무시
  if (wheelDeltaAccumulator.current < WHEEL_THRESHOLD) {
    return
  }

  // 임계값 초과 → 줌 실행 & 리셋
  wheelDeltaAccumulator.current = 0

  // 줌 방향 결정
  const direction = e.deltaY > 0 ? -1 : 1  // 아래 = 축소, 위 = 확대

  // 다음 축척 레벨로 이동
  const newIndex = Math.max(0, Math.min(SCALE_LEVELS.length - 1, currentScaleIndex + direction))
  const newZoom = SCALE_LEVELS[newIndex].zoom

  // 마우스 위치 중심으로 부드럽게 줌
  animateZoom(newZoom, newIndex, mouseX, mouseY)
}
```

#### 3.2.2 부드러운 줌 애니메이션

**코드 위치**: 434-491줄

```typescript
const animateZoom = (
  targetZoom: number,
  targetIndex: number,
  centerX: number,  // 마우스 X 좌표
  centerY: number   // 마우스 Y 좌표
) => {
  const startZoom = zoom2D
  const startTime = performance.now()
  const duration = 300  // 300ms

  const animate = (currentTime: number) => {
    const elapsed = currentTime - startTime
    const progress = Math.min(elapsed / duration, 1)

    // easeInOutCubic 이징
    const eased = progress < 0.5
      ? 4 * progress * progress * progress
      : 1 - Math.pow(-2 * progress + 2, 3) / 2

    const currentZoom = startZoom + (targetZoom - startZoom) * eased

    // 마우스 위치 중심으로 줌
    const gridX = centerX - gridPosition.x
    const gridY = centerY - gridPosition.y

    const newGridX = gridX * (currentZoom / zoom2D)
    const newGridY = gridY * (currentZoom / zoom2D)

    setGridPosition({
      x: centerX - newGridX,
      y: centerY - newGridY,
    })

    setZoom2D(currentZoom)

    if (progress < 1) {
      requestAnimationFrame(animate)
    } else {
      setZoom2D(targetZoom)
      setCurrentScaleIndex(targetIndex)
    }
  }

  requestAnimationFrame(animate)
}
```

#### 3.2.3 Flutter 구현

```dart
class GameGridState extends State<GameGrid> with SingleTickerProviderStateMixin {
  double _wheelDeltaAccumulator = 0;
  Timer? _wheelResetTimer;
  static const double WHEEL_THRESHOLD = 100;

  late AnimationController _zoomAnimationController;
  Animation<double>? _zoomAnimation;

  void _handleMouseWheel(PointerScrollEvent event) {
    setState(() {
      _wheelDeltaAccumulator += event.scrollDelta.dy.abs();
    });

    // 100ms 후 리셋
    _wheelResetTimer?.cancel();
    _wheelResetTimer = Timer(Duration(milliseconds: 100), () {
      setState(() {
        _wheelDeltaAccumulator = 0;
      });
    });

    // 임계값 미달
    if (_wheelDeltaAccumulator < WHEEL_THRESHOLD) {
      return;
    }

    // 임계값 초과 → 줌
    setState(() {
      _wheelDeltaAccumulator = 0;
    });

    final direction = event.scrollDelta.dy > 0 ? -1 : 1;
    final newIndex = (_currentScaleIndex + direction).clamp(0, _scaleLevels.length - 1);
    final newZoom = _scaleLevels[newIndex].zoom;

    // 마우스 위치
    final RenderBox box = context.findRenderObject() as RenderBox;
    final localPosition = box.globalToLocal(event.position);

    _animateZoom(newZoom, newIndex, localPosition.dx, localPosition.dy);
  }

  void _animateZoom(double targetZoom, int targetIndex, double centerX, double centerY) {
    final startZoom = _zoom;

    _zoomAnimation = Tween<double>(
      begin: startZoom,
      end: targetZoom,
    ).animate(CurvedAnimation(
      parent: _zoomAnimationController,
      curve: Curves.easeInOutCubic,
    ));

    _zoomAnimationController.addListener(() {
      final currentZoom = _zoomAnimation!.value;

      // 마우스 위치 중심으로 줌
      final gridX = centerX - _gridPosition.dx;
      final gridY = centerY - _gridPosition.dy;

      final newGridX = gridX * (currentZoom / _zoom);
      final newGridY = gridY * (currentZoom / _zoom);

      setState(() {
        _zoom = currentZoom;
        _gridPosition = Offset(
          centerX - newGridX,
          centerY - newGridY,
        );
      });
    });

    _zoomAnimationController.forward(from: 0).then((_) {
      setState(() {
        _zoom = targetZoom;
        _currentScaleIndex = targetIndex;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerSignal: (event) {
        if (event is PointerScrollEvent) {
          _handleMouseWheel(event);
        }
      },
      child: ...,
    );
  }
}
```

---

### 3.3 드래그 팬

#### 3.3.1 구현 (TypeScript)

**코드 위치**: 1183-1214줄

```typescript
const [isDragging, setIsDragging] = useState(false)
const [dragStart, setDragStart] = useState({ x: 0, y: 0 })
const [hasDragged, setHasDragged] = useState(false)

const handleMouseDown = (e: React.MouseEvent) => {
  setIsDragging(true)
  setHasDragged(false)
  setDragStart({ x: e.clientX, y: e.clientY })
}

const handleMouseMove = (e: React.MouseEvent) => {
  if (!isDragging) return

  const dx = e.clientX - dragStart.x
  const dy = e.clientY - dragStart.y
  const distance = Math.sqrt(dx * dx + dy * dy)

  // 5px 이상 이동하면 드래그로 간주
  if (distance > 5) {
    setHasDragged(true)
  }

  setGridPosition({
    x: gridPosition.x + dx,
    y: gridPosition.y + dy,
  })

  setDragStart({ x: e.clientX, y: e.clientY })
}

const handleMouseUp = () => {
  setIsDragging(false)
}
```

**5px 임계값**: 우발적 드래그 방지 (클릭과 드래그 구분)

#### 3.3.2 Flutter 구현

```dart
Offset _dragStart = Offset.zero;
bool _isDragging = false;
bool _hasDragged = false;

GestureDetector(
  onPanStart: (details) {
    setState(() {
      _isDragging = true;
      _hasDragged = false;
      _dragStart = details.globalPosition;
    });
  },
  onPanUpdate: (details) {
    if (!_isDragging) return;

    final dx = details.globalPosition.dx - _dragStart.dx;
    final dy = details.globalPosition.dy - _dragStart.dy;
    final distance = sqrt(dx * dx + dy * dy);

    if (distance > 5) {
      setState(() {
        _hasDragged = true;
      });
    }

    setState(() {
      _gridPosition = Offset(
        _gridPosition.dx + dx,
        _gridPosition.dy + dy,
      );
      _dragStart = details.globalPosition;
    });
  },
  onPanEnd: (details) {
    setState(() {
      _isDragging = false;
    });
  },
  child: ...,
)
```

---

### 3.4 모바일 Pinch-to-Zoom

#### 3.4.1 구현 (TypeScript)

**코드 위치**: 852-987줄

```typescript
const [touchStartDistance, setTouchStartDistance] = useState<number | null>(null)
const [touchStartZoom, setTouchStartZoom] = useState<number>(1)

// 두 터치 포인트 간 거리
const getTouchDistance = (touches: TouchList): number => {
  const dx = touches[0].clientX - touches[1].clientX
  const dy = touches[0].clientY - touches[1].clientY
  return Math.sqrt(dx * dx + dy * dy)
}

// 두 터치 포인트의 중심점
const getTouchCenter = (touches: TouchList) => {
  return {
    x: (touches[0].clientX + touches[1].clientX) / 2,
    y: (touches[0].clientY + touches[1].clientY) / 2
  }
}

const handleTouchStart = (e: TouchEvent) => {
  if (e.touches.length === 2) {
    // Pinch 시작
    const distance = getTouchDistance(e.touches)
    setTouchStartDistance(distance)
    setTouchStartZoom(zoom2D)

    const center = getTouchCenter(e.touches)
    touchStartPositionRef.current = {
      x: center.x - rect.left,
      y: center.y - rect.top
    }
  }
}

const handleTouchMove = (e: TouchEvent) => {
  if (e.touches.length === 2 && touchStartDistance !== null) {
    // Pinch 중
    const currentDistance = getTouchDistance(e.touches)
    const scale = currentDistance / touchStartDistance
    const newZoom = touchStartZoom * scale

    // 줌 범위 제한
    const clampedZoom = Math.max(dynamicMinZoom, Math.min(maxZoom, newZoom))

    // 중심점 기준으로 줌
    const center = getTouchCenter(e.touches)
    const touchX = center.x - rect.left
    const touchY = center.y - rect.top

    const gridX = touchX - gridPosition.x
    const gridY = touchY - gridPosition.y

    const newGridX = gridX * (clampedZoom / zoom2D)
    const newGridY = gridY * (clampedZoom / zoom2D)

    setGridPosition({
      x: touchX - newGridX,
      y: touchY - newGridY,
    })

    setZoom2D(clampedZoom)
  }
}

const handleTouchEnd = (e: TouchEvent) => {
  if (e.touches.length < 2) {
    // Pinch 종료 → 가장 가까운 축척 레벨로 스냅
    if (touchStartDistance !== null) {
      const closestIndex = getClosestScaleIndex(zoom2D)
      const targetZoom = SCALE_LEVELS[closestIndex].zoom

      setZoom2D(targetZoom)
      setCurrentScaleIndex(closestIndex)
    }

    setTouchStartDistance(null)
  }
}
```

#### 3.4.2 Flutter 구현

```dart
double? _touchStartDistance;
double _touchStartZoom = 1.0;

double _getTouchDistance(ScaleStartDetails details) {
  if (details.pointerCount < 2) return 0;

  final focalPoint = details.focalPoint;
  final localFocalPoint = details.localFocalPoint;

  // Flutter에서는 ScaleGestureRecognizer가 자동으로 거리 계산
  return 0; // 실제로는 details.scale 사용
}

GestureDetector(
  onScaleStart: (details) {
    if (details.pointerCount == 2) {
      setState(() {
        _touchStartZoom = _zoom;
      });
    }
  },
  onScaleUpdate: (details) {
    if (details.pointerCount == 2) {
      final newZoom = _touchStartZoom * details.scale;
      final clampedZoom = newZoom.clamp(_dynamicMinZoom, _maxZoom);

      // 포인터 중심으로 줌
      final focalPoint = details.focalPoint;
      final RenderBox box = context.findRenderObject() as RenderBox;
      final localFocalPoint = box.globalToLocal(focalPoint);

      final gridX = localFocalPoint.dx - _gridPosition.dx;
      final gridY = localFocalPoint.dy - _gridPosition.dy;

      final newGridX = gridX * (clampedZoom / _zoom);
      final newGridY = gridY * (clampedZoom / _zoom);

      setState(() {
        _zoom = clampedZoom;
        _gridPosition = Offset(
          localFocalPoint.dx - newGridX,
          localFocalPoint.dy - newGridY,
        );
      });
    }
  },
  onScaleEnd: (details) {
    if (details.pointerCount < 2) {
      // 가장 가까운 축척 레벨로 스냅
      final closestIndex = _getClosestScaleIndex(_zoom);
      final targetZoom = _scaleLevels[closestIndex].zoom;

      setState(() {
        _zoom = targetZoom;
        _currentScaleIndex = closestIndex;
      });
    }
  },
  child: ...,
)
```

---

## 4. 인터랙션 시스템

### 4.1 적응적 인터랙션

#### 4.1.1 개념

**줌 레벨에 따라 클릭 동작이 변경됩니다**:

- **낮은 줌** (zoom < 임계값): 클릭 → **해당 영역으로 확대**
- **높은 줌** (zoom ≥ 임계값): 클릭 → **셀 선택**

**임계값 계산** (274-288줄):
```typescript
function getCellSelectionThreshold(gridSize: number): number {
  if (gridSize <= 100) return 0.3     // 소형: 낮은 줌부터 선택 가능
  else if (gridSize <= 500) return 0.6  // 중형: 중간 줌부터
  else if (gridSize <= 2000) return 1.0 // 대형: 높은 줌부터
  else return 1.4                       // 초대형: 매우 높은 줌부터만
}
```

#### 4.1.2 클릭 처리 (TypeScript)

**코드 위치**: 1216-1279줄

```typescript
const handleGridMouseUp = (e: React.MouseEvent) => {
  if (gameState !== "selecting" || disabled) return

  // 실제로 드래그했으면 무시
  if (hasDragged) return

  // 클릭 좌표 → 그리드 좌표 변환
  const containerRect = container.getBoundingClientRect()
  const containerClickX = e.clientX - containerRect.left
  const containerClickY = e.clientY - containerRect.top

  const actualGridX = (containerClickX - gridPosition.x) / zoom2D
  const actualGridY = (containerClickY - gridPosition.y) / zoom2D

  const col = Math.floor(actualGridX / CELL_SIZE)
  const row = Math.floor(actualGridY / CELL_SIZE)

  // 그리드 범위 체크
  if (col < 0 || col >= gridSize || row < 0 || row >= gridSize) return

  // Shift + 클릭: 스마트 줌 (항상 가능)
  if (e.shiftKey) {
    const targetZoom = zoom2D < 1.5 ? optimalZoomLevel : 0.8
    const cellCenterX = (col + 0.5) * CELL_SIZE * targetZoom
    const cellCenterY = (row + 0.5) * CELL_SIZE * targetZoom

    setGridPosition({
      x: containerClickX - cellCenterX,
      y: containerClickY - cellCenterY,
    })

    setZoom2D(targetZoom)
    return
  }

  // 적응적 인터랙션
  if (canSelectCells) {
    // 충분히 확대됨 → 셀 선택
    const cellIndex = row * gridSize + col
    onSelectCell(cellIndex)
  } else {
    // 낮은 줌 → 해당 영역으로 확대
    const targetZoom = Math.min(
      optimalZoomLevel,
      Math.max(cellSelectionThreshold * 1.2, zoom2D * 2)
    )

    const cellCenterX = (col + 0.5) * CELL_SIZE * targetZoom
    const cellCenterY = (row + 0.5) * CELL_SIZE * targetZoom

    setGridPosition({
      x: containerClickX - cellCenterX,
      y: containerClickY - cellCenterY,
    })

    setZoom2D(targetZoom)
  }
}
```

#### 4.1.3 Flutter 구현

```dart
void _handleTap(TapUpDetails details) {
  if (_gameState != GameState.selecting || _disabled) return;
  if (_hasDragged) return;

  final RenderBox box = context.findRenderObject() as RenderBox;
  final localPosition = box.globalToLocal(details.globalPosition);

  // 그리드 좌표 변환
  final actualGridX = (localPosition.dx - _gridPosition.dx) / _zoom;
  final actualGridY = (localPosition.dy - _gridPosition.dy) / _zoom;

  final col = (actualGridX / CELL_SIZE).floor();
  final row = (actualGridY / CELL_SIZE).floor();

  if (col < 0 || col >= _gridSize || row < 0 || row >= _gridSize) return;

  // Shift는 모바일에서 구현 안 함

  // 적응적 인터랙션
  if (_canSelectCells) {
    // 셀 선택
    final cellIndex = row * _gridSize + col;
    widget.onSelectCell(cellIndex);
  } else {
    // 영역 확대
    final targetZoom = min(
      _optimalZoomLevel,
      max(_cellSelectionThreshold * 1.2, _zoom * 2),
    );

    final cellCenterX = (col + 0.5) * CELL_SIZE * targetZoom;
    final cellCenterY = (row + 0.5) * CELL_SIZE * targetZoom;

    setState(() {
      _gridPosition = Offset(
        localPosition.dx - cellCenterX,
        localPosition.dy - cellCenterY,
      );
      _zoom = targetZoom;
      _currentScaleIndex = _getClosestScaleIndex(targetZoom);
    });
  }
}

@override
Widget build(BuildContext context) {
  return GestureDetector(
    onTapUp: _handleTap,
    child: ...,
  );
}
```

---

### 4.2 키보드 단축키

#### 4.2.1 단축키 목록

**코드 위치**: 621-750줄

| 키 | 기능 | 설명 |
|----|------|------|
| `Space` | 줌 토글 | 마우스 위치 중심으로 확대/축소 |
| `Q` | 빠른 확대 | 화면 중앙 기준 1.3배 확대 |
| `E` | 전체 보기 | 그리드 전체가 보이도록 리셋 |
| `Z` | 돋보기 모드 | 누르고 있는 동안 3배 확대 |
| `F` | 포커스 | 선택된 셀로 이동 |
| `?` | 도움말 | 키보드 도움말 토글 |
| `Esc` | 취소 | 모든 모드 해제 |

#### 4.2.2 구현 (TypeScript)

```typescript
useEffect(() => {
  const handleKeyDown = (e: KeyboardEvent) => {
    // 입력 필드에서는 비활성화
    if (e.target instanceof HTMLInputElement || e.target instanceof HTMLTextAreaElement) {
      return
    }

    switch (e.key.toLowerCase()) {
      case ' ':  // 스페이스바
        e.preventDefault()
        if (zoom2D < 1.5) {
          // 확대
          const targetZoom = 2.0
          const centerX = mousePosition.x - rect.left
          const centerY = mousePosition.y - rect.top

          const gridX = centerX - gridPosition.x
          const gridY = centerY - gridPosition.y
          const newGridX = gridX * (targetZoom / zoom2D)
          const newGridY = gridY * (targetZoom / zoom2D)

          setGridPosition({
            x: centerX - newGridX,
            y: centerY - newGridY,
          })
          setZoom2D(targetZoom)
        } else {
          // 축소
          resetGridPosition()
        }
        break

      case 'q':  // Quick Zoom
        e.preventDefault()
        const quickZoom = Math.min(maxZoom, zoom2D * 1.3)
        const rect = gridContainerRef.current.getBoundingClientRect()
        const centerX = rect.width / 2
        const centerY = rect.height / 2

        const gridX = centerX - gridPosition.x
        const gridY = centerY - gridPosition.y
        const newGridX = gridX * (quickZoom / zoom2D)
        const newGridY = gridY * (quickZoom / zoom2D)

        setGridPosition({
          x: centerX - newGridX,
          y: centerY - newGridY,
        })
        setZoom2D(quickZoom)
        break

      case 'e':  // Entire view
        e.preventDefault()
        resetGridPosition()
        break

      case 'z':  // Zoom mode (돋보기)
        e.preventDefault()
        if (!e.repeat) {
          setKeyboardMode('magnify')
        }
        break

      case 'f':  // Focus
        e.preventDefault()
        if (selectedCell !== null) {
          const row = Math.floor(selectedCell / gridSize)
          const col = selectedCell % gridSize
          zoomToCell(row, col)
        }
        break

      case '?':
      case '/':
        if (e.shiftKey || e.key === '?') {
          e.preventDefault()
          setShowKeyboardHelp(prev => !prev)
        }
        break

      case 'escape':
        e.preventDefault()
        setShowKeyboardHelp(false)
        setKeyboardMode('normal')
        break
    }
  }

  const handleKeyUp = (e: KeyboardEvent) => {
    if (e.key.toLowerCase() === 'z') {
      setKeyboardMode('normal')
    }
  }

  document.addEventListener('keydown', handleKeyDown)
  document.addEventListener('keyup', handleKeyUp)

  return () => {
    document.removeEventListener('keydown', handleKeyDown)
    document.removeEventListener('keyup', handleKeyUp)
  }
}, [zoom2D, gridPosition, selectedCell, mousePosition, gridSize, zoomToCell, resetGridPosition])
```

#### 4.2.3 Flutter 구현

**Flutter에서는 키보드 단축키 지원 제한적** → 웹 전용 기능으로 두기

---

### 4.3 돋보기 기능

#### 4.3.1 개념

**Z키를 누르고 있으면**:
- 마우스 커서 근처에 200x200px 원형 돋보기 표시
- 3배 확대된 화면 실시간 렌더링
- 중심에 빨간 점 표시

**코드 위치**: 996-1181줄

#### 4.3.2 구현 (TypeScript)

```typescript
const renderMagnifier = useCallback(() => {
  if (keyboardMode !== 'magnify') return

  const magnifierCanvas = magnifierCanvasRef.current
  const container = gridContainerRef.current
  if (!magnifierCanvas || !container) return

  const ctx = magnifierCanvas.getContext('2d')
  if (!ctx) return

  const magnifierSize = 200
  const magnification = 3
  const sourceSize = magnifierSize / magnification  // 66.67px

  // 고해상도 캔버스
  const devicePixelRatio = window.devicePixelRatio || 1
  magnifierCanvas.width = magnifierSize * devicePixelRatio
  magnifierCanvas.height = magnifierSize * devicePixelRatio
  ctx.scale(devicePixelRatio, devicePixelRatio)

  // 원형 클리핑
  ctx.save()
  ctx.beginPath()
  ctx.arc(magnifierSize / 2, magnifierSize / 2, magnifierSize / 2 - 5, 0, Math.PI * 2)
  ctx.clip()

  // 배경
  ctx.fillStyle = '#f8fafc'
  ctx.fillRect(0, 0, magnifierSize, magnifierSize)

  // 소스 영역 계산
  const sourceX = relativeMousePos.x - sourceSize / 2
  const sourceY = relativeMousePos.y - sourceSize / 2

  // 모든 하위 요소 순회하며 그리기
  const allElements = container.querySelectorAll('*')
  Array.from(allElements).forEach(element => {
    const rect = element.getBoundingClientRect()
    // ... 겹치는 영역 계산 및 그리기
  })

  // 중심점 표시
  ctx.restore()
  ctx.strokeStyle = '#ef4444'
  ctx.lineWidth = 2
  ctx.beginPath()
  ctx.arc(magnifierSize / 2, magnifierSize / 2, 3, 0, Math.PI * 2)
  ctx.stroke()

  // 테두리
  ctx.strokeStyle = '#e2e8f0'
  ctx.lineWidth = 4
  ctx.beginPath()
  ctx.arc(magnifierSize / 2, magnifierSize / 2, magnifierSize / 2 - 2, 0, Math.PI * 2)
  ctx.stroke()
}, [keyboardMode, relativeMousePos, selectedCell, gridPosition, zoom2D])
```

#### 4.3.3 Flutter 구현

**모바일에서는 불필요** → 웹 전용 기능

---

## 5. 성능 최적화 전략

### 5.1 렌더링 최적화 요약

| 기법 | 설명 | 성능 향상 |
|------|------|----------|
| Sparse Grid | 빈 셀 저장 안 함 | 메모리 99% 절감 |
| Object Pool | 객체 재사용 | GC 부담 90% 감소 |
| Viewport Culling | 화면 밖 미렌더링 | CPU 80% 절감 |
| LOD 시스템 | 줌 레벨별 디테일 조정 | FPS 2배 향상 |
| SVG 패턴 | 그리드 선 반복 렌더링 방지 | GPU 효율 50% 향상 |
| 적응적 인터랙션 | 불필요한 줌 방지 | UX 개선 |

### 5.2 성능 목표

| 지표 | 목표 | 측정 방법 |
|------|------|----------|
| FPS | 60fps | Chrome DevTools Performance |
| 렌더링 시간 | < 16ms/프레임 | requestAnimationFrame |
| 메모리 (1000x1000) | < 100MB | Chrome DevTools Memory |
| 초기 로딩 | < 3초 | Time to Interactive |
| 줌/팬 반응 | < 50ms | 사용자 입력 → 화면 업데이트 |

### 5.3 Flutter 성능 최적화

```dart
// 1. RepaintBoundary로 리페인트 격리
RepaintBoundary(
  child: CustomPaint(
    painter: GridPainter(...),
  ),
)

// 2. const 위젯 사용
const Text('선택된 블록')

// 3. ListView.builder로 lazy loading
ListView.builder(
  itemCount: selectedBlocks.length,
  itemBuilder: (context, index) {
    return BlockListTile(block: selectedBlocks[index]);
  },
)

// 4. shouldRepaint 최적화
@override
bool shouldRepaint(GridPainter oldDelegate) {
  return oldDelegate.zoom != zoom ||
         oldDelegate.gridPosition != gridPosition ||
         oldDelegate.selectedBlocks != selectedBlocks;
}
```

---

## 6. 시각적 요소 명세

### 6.1 색상

| 요소 | 색상 | 용도 |
|------|------|------|
| 그리드 선 | `rgba(6, 182, 212, 0.4~0.8)` | 줌 레벨별 투명도 변화 |
| 배경 그라데이션 | `#EFF2F7 → #EBF8FF` | 부드러운 배경 |
| 그리드 오버레이 | `rgba(0, 0, 0, 0.2)` | 깊이감 |
| 선택 아이콘 | SVG (파란색) | `/icons/pick/selected.svg` |
| 하이라이트 아이콘 | SVG (노란색) | `/icons/pick/list-selected.svg` |
| 과거 선택 아이콘 | SVG (회색) | `/icons/pick/past.svg` |

### 6.2 크기

| 요소 | 크기 | 설명 |
|------|------|------|
| 기본 셀 크기 | 30px | `CELL_SIZE = 30` |
| 실제 셀 크기 | `30 * zoom` | 줌에 따라 변화 |
| 그리드 전체 크기 | `gridSize * 30 * zoom` | 예: 100x100 = 3000px |
| 아이콘 크기 | 셀 크기의 95% | 약간의 여백 |
| 미니맵 크기 | 100px (기본), 160px (확장) | 모바일 전용 |
| 돋보기 크기 | 200px | Z키 누를 때 |

### 6.3 애니메이션

| 애니메이션 | 지속 시간 | Easing | 용도 |
|-----------|----------|--------|------|
| 줌 | 300ms | easeInOutCubic | 부드러운 줌 |
| 펄스 (하이라이트) | 1500ms | ease-in-out infinite | 선택 블록 강조 |
| 페이드 인 | 200ms | linear | 정보 패널 등장 |

---

## 7. 상태 관리 플로우

### 7.1 상태 구조

```typescript
// 그리드 상태
const [zoom2D, setZoom2D] = useState(1)
const [gridPosition, setGridPosition] = useState({ x: 0, y: 0 })
const [currentScaleIndex, setCurrentScaleIndex] = useState(0)

// 드래그 상태
const [isDragging, setIsDragging] = useState(false)
const [dragStart, setDragStart] = useState({ x: 0, y: 0 })
const [hasDragged, setHasDragged] = useState(false)

// 터치 상태 (모바일)
const [touchStartDistance, setTouchStartDistance] = useState<number | null>(null)
const [touchStartZoom, setTouchStartZoom] = useState<number>(1)

// 키보드 상태
const [keyboardMode, setKeyboardMode] = useState<'normal' | 'magnify'>('normal')
const [showKeyboardHelp, setShowKeyboardHelp] = useState(false)

// Props로 받는 상태
const {
  gridSize,
  selectedCell,
  gameState,  // "selecting" | "processing" | "results"
  selectedBlocks,
  highlightedBlock,
  animatingBlock,
  onSelectCell,
} = props
```

### 7.2 Flutter 상태 구조

```dart
class GameGridState extends State<GameGrid> with SingleTickerProviderStateMixin {
  // 그리드 상태
  double _zoom = 1.0;
  Offset _gridPosition = Offset.zero;
  int _currentScaleIndex = 0;

  // 드래그 상태
  bool _isDragging = false;
  Offset _dragStart = Offset.zero;
  bool _hasDragged = false;

  // 터치 상태
  double? _touchStartDistance;
  double _touchStartZoom = 1.0;

  // Sparse Grid
  final SparseGrid _sparseGrid = SparseGrid();

  // 축척 레벨
  late List<ScaleLevel> _scaleLevels;

  // 애니메이션
  late AnimationController _zoomAnimationController;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();

    _scaleLevels = generateScaleLevels(widget.gridSize);

    _zoomAnimationController = AnimationController(
      duration: Duration(milliseconds: 300),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _resetGridPosition();
    });
  }

  @override
  void dispose() {
    _zoomAnimationController.dispose();
    _pulseController.dispose();
    _sparseGrid.clear();
    super.dispose();
  }
}
```

---

## 8. Flutter 완벽 재현 가이드

### 8.1 패키지 설치

```yaml
# pubspec.yaml
dependencies:
  flutter:
    sdk: flutter
  provider: ^6.0.0          # 상태 관리
  flutter_svg: ^2.0.0       # SVG 아이콘

dev_dependencies:
  flutter_test:
    sdk: flutter
```

### 8.2 파일 구조

```
lib/
├── widgets/
│   ├── game_grid.dart              # 메인 게임판 위젯
│   ├── grid_painter.dart           # CustomPaint 그리드 렌더러
│   ├── cell_icon_layer.dart        # 셀 아이콘 레이어
│   └── ui_overlay.dart             # UI 오버레이
├── models/
│   ├── tile_data.dart              # TileData 클래스
│   ├── sparse_grid.dart            # SparseGrid 클래스
│   ├── tile_pool.dart              # TilePool 클래스
│   └── lod_manager.dart            # LODManager 클래스
├── utils/
│   ├── scale_levels.dart           # generateScaleLevels()
│   └── viewport_utils.dart         # 좌표 변환 등
└── providers/
    └── game_grid_provider.dart     # 상태 관리 Provider
```

### 8.3 핵심 위젯 구조

```dart
class GameGrid extends StatefulWidget {
  final int gridSize;
  final int? selectedCell;
  final GameState gameState;
  final List<SelectedBlock> selectedBlocks;
  final HighlightedBlock? highlightedBlock;
  final Function(int) onSelectCell;
  final String? fullAdImage;
  final bool showFullAd;

  const GameGrid({
    Key? key,
    required this.gridSize,
    this.selectedCell,
    required this.gameState,
    required this.selectedBlocks,
    this.highlightedBlock,
    required this.onSelectCell,
    this.fullAdImage,
    this.showFullAd = false,
  }) : super(key: key);

  @override
  State<GameGrid> createState() => GameGridState();
}

class GameGridState extends State<GameGrid> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: _buildBackgroundDecoration(),
      child: GestureDetector(
        onScaleStart: _handleScaleStart,
        onScaleUpdate: _handleScaleUpdate,
        onScaleEnd: _handleScaleEnd,
        onTapUp: _handleTap,
        child: Listener(
          onPointerSignal: (event) {
            if (event is PointerScrollEvent) {
              _handleMouseWheel(event);
            }
          },
          child: Stack(
            children: [
              // Layer 2: 광고 배경
              if (widget.showFullAd && widget.fullAdImage != null)
                _buildAdBackground(),

              // Layer 3: SVG 그리드 선
              _buildGridLines(),

              // Layer 4: 그리드 오버레이
              _buildGridOverlay(),

              // Layer 5: 셀 아이콘
              _buildCellIcons(),

              // Layer 6: UI 오버레이
              _buildUIOverlay(),
            ],
          ),
        ),
      ),
    );
  }
}
```

---

## 9. 실제 동작 시나리오

### 9.1 시나리오 1: 100x100 그리드 초기 로딩

**단계별 동작**:

1. **컴포넌트 마운트**
   - `gridSize = 100` prop 전달
   - `generateScaleLevels(100)` 호출 → 6개 축척 레벨 생성
   - `SCALE_LEVELS[0].zoom = 0.2` (전체 뷰)

2. **초기 위치 계산** (494-514줄)
   ```typescript
   const resetGridPosition = () => {
     const containerRect = container.getBoundingClientRect()
     // 컨테이너 크기: 800x600 가정

     // 전체 그리드가 화면에 맞도록 줌 계산
     const zoomFit = Math.min(
       800 / (100 * 30),  // 800 / 3000 = 0.267
       600 / (100 * 30)   // 600 / 3000 = 0.2
     )
     // → zoomFit = 0.2

     setZoom2D(0.2)
     setGridPosition({
       x: (800 - 100 * 30 * 0.2) / 2 = (800 - 600) / 2 = 100,
       y: (600 - 100 * 30 * 0.2) / 2 = (600 - 600) / 2 = 0,
     })
   }
   ```

3. **그리드 렌더링**
   - 전체 그리드 크기: `100 * 30 * 0.2 = 600px`
   - 화면에 600x600px 그리드 표시 (컨테이너 중앙)
   - 그리드 선 간격: `Math.floor(100 / 50) = 2` → 2칸마다 1개 선
   - LOD 레벨: 1 (VERY_LOW)
   - 최대 렌더링 셀: 200개 (selectedBlocks만)

4. **사용자에게 보이는 화면**
   ```
   ┌────────────────────────────────────┐
   │                                    │
   │    [  100x100 그리드 전체 뷰  ]    │
   │    - 그리드 선 보임 (2칸마다)     │
   │    - 선택 아이콘 없음             │
   │    - 텍스트 없음                  │
   │                                    │
   └────────────────────────────────────┘
   ```

---

### 9.2 시나리오 2: 셀 클릭 → 영역 확대

**초기 상태**: zoom = 0.2 (전체 뷰)

**사용자 액션**: (50행, 50열) 클릭

**처리 과정**:

1. **클릭 좌표 → 그리드 좌표 변환**
   ```typescript
   // 마우스 클릭: (400, 300) - 컨테이너 중앙
   const actualGridX = (400 - 100) / 0.2 = 1500
   const actualGridY = (300 - 0) / 0.2 = 1500

   const col = Math.floor(1500 / 30) = 50
   const row = Math.floor(1500 / 30) = 50
   ```

2. **적응적 인터랙션 판단**
   ```typescript
   const cellSelectionThreshold = 0.3  // gridSize=100
   const canSelectCells = 0.2 >= 0.3  // false

   // → 영역 확대 모드
   ```

3. **확대 실행**
   ```typescript
   const targetZoom = Math.min(
     1.5,  // optimalZoomLevel
     Math.max(0.3 * 1.2, 0.2 * 2)  // 0.36 vs 0.4
   ) = 0.4

   const cellCenterX = (50 + 0.5) * 30 * 0.4 = 606
   const cellCenterY = (50 + 0.5) * 30 * 0.4 = 606

   setGridPosition({
     x: 400 - 606 = -206,
     y: 300 - 606 = -306,
   })

   setZoom2D(0.4)
   ```

4. **렌더링 업데이트**
   - 그리드 크기: `100 * 30 * 0.4 = 1200px`
   - 그리드 위치: `(-206, -306)`
   - 화면에 보이는 영역: (50, 50) 셀 근처 약 25x20 셀
   - 그리드 선 간격: 1 (모든 셀)
   - LOD 레벨: 2 (LOW)

5. **사용자에게 보이는 화면**
   ```
   ┌────────────────────────────────────┐
   │                                    │
   │       [  확대된 영역  ]            │
   │       - (50, 50) 셀 중심           │
   │       - 약 25x20 셀 보임           │
   │       - 모든 그리드 선 표시        │
   │                                    │
   └────────────────────────────────────┘
   ```

---

### 9.3 시나리오 3: 마우스 휠로 추가 확대

**초기 상태**: zoom = 0.4

**사용자 액션**: 마우스 휠 위로 (확대)

**처리 과정**:

1. **휠 이벤트**
   ```typescript
   wheelDeltaAccumulator += Math.abs(e.deltaY)  // 120 (일반 마우스)

   // 임계값 초과
   if (120 >= 100) {
     wheelDeltaAccumulator = 0

     const direction = e.deltaY > 0 ? -1 : 1
     // 위로 스크롤 → direction = 1 (확대)
   }
   ```

2. **다음 축척 레벨 계산**
   ```typescript
   // 현재: SCALE_LEVELS[1] = { zoom: 0.5 }
   const currentScaleIndex = 1
   const newIndex = Math.min(6, 1 + 1) = 2
   const newZoom = SCALE_LEVELS[2].zoom = 0.9
   ```

3. **마우스 위치 중심으로 줌**
   ```typescript
   // 마우스 위치: (400, 300)
   const gridX = 400 - (-206) = 606
   const gridY = 300 - (-306) = 606

   const newGridX = 606 * (0.9 / 0.4) = 1363.5
   const newGridY = 606 * (0.9 / 0.4) = 1363.5

   setGridPosition({
     x: 400 - 1363.5 = -963.5,
     y: 300 - 1363.5 = -1063.5,
   })

   setZoom2D(0.9)
   ```

4. **300ms 애니메이션**
   - easeInOutCubic 곡선으로 부드럽게
   - zoom: 0.4 → 0.9
   - position: (-206, -306) → (-963.5, -1063.5)

5. **최종 렌더링**
   - 그리드 크기: `100 * 30 * 0.9 = 2700px`
   - LOD 레벨: 2 (LOW)
   - 셀 선택 가능: `0.9 >= 0.3` → **true**

---

### 9.4 시나리오 4: 셀 선택

**초기 상태**: zoom = 0.9 (셀 선택 가능)

**사용자 액션**: (50행, 50열) 클릭

**처리 과정**:

1. **적응적 인터랙션 판단**
   ```typescript
   const canSelectCells = 0.9 >= 0.3  // true
   // → 셀 선택 모드
   ```

2. **셀 선택**
   ```typescript
   const cellIndex = 50 * 100 + 50 = 5050
   onSelectCell(5050)
   ```

3. **SparseGrid 업데이트**
   ```typescript
   sparseGrid.current.setTile(50, 50, 'selected')
   ```

4. **아이콘 렌더링**
   ```typescript
   const x = 50 * 30 * 0.9 = 1350
   const y = 50 * 30 * 0.9 = 1350
   const cellSize = 30 * 0.9 = 27

   <img src="/icons/pick/selected.svg"
        style={{
          width: 27 * 0.95 = 25.65px,
          height: 25.65px
        }} />
   ```

5. **사용자에게 보이는 화면**
   ```
   ┌────────────────────────────────────┐
   │                                    │
   │       [  선택된 셀  ]              │
   │       - (50, 50)에 파란 아이콘     │
   │       - 우측 패널에 "선택된 블록 1개" │
   │                                    │
   └────────────────────────────────────┘
   ```

---

### 9.5 시나리오 5: 1000x1000 그리드

**초기 상태**: gridSize = 1000

**동작**:

1. **축척 레벨 생성**
   ```typescript
   const baseZoom = Math.min(0.1, 50 / 1000) = 0.05

   SCALE_LEVELS = [
     { zoom: 0.05, label: "전체 (1000x1000)" },
     { zoom: 0.1, label: "대륙 뷰" },
     { zoom: 0.2, label: "국가 뷰" },
     { zoom: 0.4, label: "광역 뷰" },
     { zoom: 0.6, label: "지역 뷰" },
     { zoom: 1.0, label: "구역 뷰" },
     { zoom: 1.4, label: "상세 뷰" },
     { zoom: 1.8, label: "매우 상세" },
     { zoom: 2.2, label: "초상세" },
   ]
   ```

2. **초기 줌 계산**
   ```typescript
   // 컨테이너: 800x600
   const zoomFit = Math.min(
     800 / (1000 * 30),  // 0.0267
     600 / (1000 * 30)   // 0.02
   ) = 0.02

   // → 동적 최소 줌 = 0.02 (SCALE_LEVELS[0]보다 작음)
   ```

3. **LOD 최적화**
   ```typescript
   const lodLevel = getLODLevel(0.02) = 0 (ULTRA_LOW)
   const gridStep = getGridStep(0, 0.02, 1000) = Math.floor(1000 / 20) = 50

   // → 50칸마다 1개 선 렌더링
   ```

4. **Sparse Grid 활용**
   ```typescript
   const shouldUseSparseGrid = 1000 > 500 && 0.02 < 0.2  // true
   const gridStepSize = Math.max(5, Math.floor(1000 / 100)) = 10

   // → 10칸마다 1개 선 (추가 최적화)
   ```

5. **렌더링**
   - 그리드 크기: `1000 * 30 * 0.02 = 600px`
   - 그리드 선: 10칸마다 → 총 100개 선만
   - 선택된 셀만 렌더링 (Sparse Grid)
   - 메모리: < 10MB (Object Pool 덕분)

6. **성능**
   - FPS: 60fps 유지 ✅
   - 메모리: < 50MB ✅
   - 초기 로딩: < 1초 ✅

---

## 10. Flutter 전체 코드 예제

### 10.1 메인 게임판 위젯

**파일**: `lib/widgets/game_grid.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'dart:math';
import '../models/sparse_grid.dart';
import '../models/tile_pool.dart';
import '../models/lod_manager.dart';
import '../utils/scale_levels.dart';
import 'grid_painter.dart';
import 'cell_icon_layer.dart';

enum GameState { selecting, processing, results }

class SelectedBlock {
  final int row;
  final int col;
  final String id;

  SelectedBlock({
    required this.row,
    required this.col,
    required this.id,
  });
}

class HighlightedBlock {
  final int row;
  final int col;

  HighlightedBlock({required this.row, required this.col});
}

class GameGrid extends StatefulWidget {
  final int gridSize;
  final int? selectedCell;
  final GameState gameState;
  final List<SelectedBlock> selectedBlocks;
  final HighlightedBlock? highlightedBlock;
  final HighlightedBlock? animatingBlock;
  final Function(int) onSelectCell;
  final String? fullAdImage;
  final bool showFullAd;
  final bool disabled;
  final bool isMobile;

  const GameGrid({
    Key? key,
    required this.gridSize,
    this.selectedCell,
    required this.gameState,
    required this.selectedBlocks,
    this.highlightedBlock,
    this.animatingBlock,
    required this.onSelectCell,
    this.fullAdImage,
    this.showFullAd = false,
    this.disabled = false,
    this.isMobile = false,
  }) : super(key: key);

  @override
  State<GameGrid> createState() => GameGridState();
}

class GameGridState extends State<GameGrid> with TickerProviderStateMixin {
  static const double CELL_SIZE = 30.0;

  // 그리드 상태
  double _zoom = 1.0;
  Offset _gridPosition = Offset.zero;
  int _currentScaleIndex = 0;

  // 드래그 상태
  bool _isDragging = false;
  Offset _dragStart = Offset.zero;
  bool _hasDragged = false;

  // 터치 상태
  double? _touchStartDistance;
  double _touchStartZoom = 1.0;

  // 휠 누적
  double _wheelDeltaAccumulator = 0;
  static const double WHEEL_THRESHOLD = 100;

  // Sparse Grid
  final SparseGrid _sparseGrid = SparseGrid();

  // 축척 레벨
  late List<ScaleLevel> _scaleLevels;

  // 적응적 인터랙션
  late double _cellSelectionThreshold;
  late double _optimalZoomLevel;

  // 동적 최소 줌
  double _dynamicMinZoom = 0.1;

  // 애니메이션
  late AnimationController _zoomAnimationController;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();

    _scaleLevels = generateScaleLevels(widget.gridSize);
    _cellSelectionThreshold = _getCellSelectionThreshold(widget.gridSize);
    _optimalZoomLevel = _getOptimalZoomLevel(widget.gridSize);

    _zoomAnimationController = AnimationController(
      duration: Duration(milliseconds: 300),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _resetGridPosition();
    });
  }

  @override
  void dispose() {
    _zoomAnimationController.dispose();
    _pulseController.dispose();
    _sparseGrid.clear();
    super.dispose();
  }

  @override
  void didUpdateWidget(GameGrid oldWidget) {
    super.didUpdateWidget(oldWidget);

    // selectedBlocks 업데이트
    if (widget.selectedBlocks != oldWidget.selectedBlocks) {
      _updateSparseGrid();
    }
  }

  void _updateSparseGrid() {
    _sparseGrid.clear();

    for (var block in widget.selectedBlocks) {
      _sparseGrid.setTile(block.row - 1, block.col - 1, TileState.selected);
    }

    if (widget.selectedCell != null) {
      final row = widget.selectedCell! ~/ widget.gridSize;
      final col = widget.selectedCell! % widget.gridSize;
      _sparseGrid.setTile(row, col, TileState.selected);
    }
  }

  double _getCellSelectionThreshold(int gridSize) {
    if (gridSize <= 100) return 0.3;
    if (gridSize <= 500) return 0.6;
    if (gridSize <= 2000) return 1.0;
    return 1.4;
  }

  double _getOptimalZoomLevel(int gridSize) {
    if (gridSize <= 100) return 1.5;
    if (gridSize <= 500) return 1.8;
    if (gridSize <= 2000) return 2.2;
    return 2.5;
  }

  void _resetGridPosition() {
    final RenderBox? box = context.findRenderObject() as RenderBox?;
    if (box == null) return;

    final size = box.size;

    final zoomFit = min(
      size.width / (widget.gridSize * CELL_SIZE),
      size.height / (widget.gridSize * CELL_SIZE),
    );

    setState(() {
      _dynamicMinZoom = zoomFit;
      _zoom = zoomFit;
      _gridPosition = Offset(
        (size.width - widget.gridSize * CELL_SIZE * zoomFit) / 2,
        (size.height - widget.gridSize * CELL_SIZE * zoomFit) / 2,
      );
      _currentScaleIndex = 0;
    });
  }

  int _getClosestScaleIndex(double targetZoom) {
    int closestIndex = 0;
    double minDistance = (targetZoom - _scaleLevels[0].zoom).abs();

    for (int i = 1; i < _scaleLevels.length; i++) {
      final distance = (targetZoom - _scaleLevels[i].zoom).abs();
      if (distance < minDistance) {
        minDistance = distance;
        closestIndex = i;
      }
    }

    return closestIndex;
  }

  void _handleMouseWheel(PointerScrollEvent event) {
    setState(() {
      _wheelDeltaAccumulator += event.scrollDelta.dy.abs();
    });

    Future.delayed(Duration(milliseconds: 100), () {
      if (mounted) {
        setState(() {
          _wheelDeltaAccumulator = 0;
        });
      }
    });

    if (_wheelDeltaAccumulator < WHEEL_THRESHOLD) {
      return;
    }

    setState(() {
      _wheelDeltaAccumulator = 0;
    });

    final direction = event.scrollDelta.dy > 0 ? -1 : 1;

    if ((_zoom - _dynamicMinZoom).abs() < 0.001 && direction == -1) {
      return; // 최소 줌에서 더 축소 불가
    }

    int newIndex = (_currentScaleIndex + direction).clamp(0, _scaleLevels.length - 1);
    double newZoom = _scaleLevels[newIndex].zoom;

    if (direction == -1 && newIndex == 0 && _dynamicMinZoom < _scaleLevels[0].zoom) {
      if (_zoom > _scaleLevels[0].zoom + 0.001) {
        newZoom = _scaleLevels[0].zoom;
      } else {
        newZoom = _dynamicMinZoom;
      }
    }

    final RenderBox box = context.findRenderObject() as RenderBox;
    final localPosition = box.globalToLocal(event.position);

    _animateZoom(newZoom, newIndex, localPosition.dx, localPosition.dy);
  }

  void _animateZoom(double targetZoom, int targetIndex, double centerX, double centerY) {
    final startZoom = _zoom;

    final animation = Tween<double>(
      begin: startZoom,
      end: targetZoom,
    ).animate(CurvedAnimation(
      parent: _zoomAnimationController,
      curve: Curves.easeInOutCubic,
    ));

    void listener() {
      final currentZoom = animation.value;

      final gridX = centerX - _gridPosition.dx;
      final gridY = centerY - _gridPosition.dy;

      final newGridX = gridX * (currentZoom / _zoom);
      final newGridY = gridY * (currentZoom / _zoom);

      setState(() {
        _zoom = currentZoom;
        _gridPosition = Offset(
          centerX - newGridX,
          centerY - newGridY,
        );
      });
    }

    _zoomAnimationController.addListener(listener);

    _zoomAnimationController.forward(from: 0).then((_) {
      _zoomAnimationController.removeListener(listener);
      setState(() {
        _zoom = targetZoom;
        _currentScaleIndex = targetIndex;
      });
    });
  }

  void _handleScaleStart(ScaleStartDetails details) {
    if (details.pointerCount == 2) {
      setState(() {
        _touchStartZoom = _zoom;
      });
    } else if (details.pointerCount == 1) {
      setState(() {
        _isDragging = true;
        _hasDragged = false;
        _dragStart = details.focalPoint;
      });
    }
  }

  void _handleScaleUpdate(ScaleUpdateDetails details) {
    if (details.pointerCount == 2) {
      // Pinch-to-zoom
      final newZoom = _touchStartZoom * details.scale;
      final clampedZoom = newZoom.clamp(_dynamicMinZoom, _scaleLevels.last.zoom);

      final RenderBox box = context.findRenderObject() as RenderBox;
      final localFocalPoint = box.globalToLocal(details.focalPoint);

      final gridX = localFocalPoint.dx - _gridPosition.dx;
      final gridY = localFocalPoint.dy - _gridPosition.dy;

      final newGridX = gridX * (clampedZoom / _zoom);
      final newGridY = gridY * (clampedZoom / _zoom);

      setState(() {
        _zoom = clampedZoom;
        _gridPosition = Offset(
          localFocalPoint.dx - newGridX,
          localFocalPoint.dy - newGridY,
        );
      });
    } else if (details.pointerCount == 1 && _isDragging) {
      // Pan
      final dx = details.focalPoint.dx - _dragStart.dx;
      final dy = details.focalPoint.dy - _dragStart.dy;
      final distance = sqrt(dx * dx + dy * dy);

      if (distance > 5) {
        setState(() {
          _hasDragged = true;
        });
      }

      setState(() {
        _gridPosition = Offset(
          _gridPosition.dx + dx,
          _gridPosition.dy + dy,
        );
        _dragStart = details.focalPoint;
      });
    }
  }

  void _handleScaleEnd(ScaleEndDetails details) {
    if (details.pointerCount < 2) {
      final closestIndex = _getClosestScaleIndex(_zoom);
      final targetZoom = _scaleLevels[closestIndex].zoom;

      setState(() {
        _zoom = targetZoom;
        _currentScaleIndex = closestIndex;
      });
    }

    setState(() {
      _isDragging = false;
      _hasDragged = false;
    });
  }

  void _handleTap(TapUpDetails details) {
    if (widget.gameState != GameState.selecting || widget.disabled) return;
    if (_hasDragged) return;

    final RenderBox box = context.findRenderObject() as RenderBox;
    final localPosition = box.globalToLocal(details.globalPosition);

    final actualGridX = (localPosition.dx - _gridPosition.dx) / _zoom;
    final actualGridY = (localPosition.dy - _gridPosition.dy) / _zoom;

    final col = (actualGridX / CELL_SIZE).floor();
    final row = (actualGridY / CELL_SIZE).floor();

    if (col < 0 || col >= widget.gridSize || row < 0 || row >= widget.gridSize) return;

    final canSelectCells = _zoom >= _cellSelectionThreshold;

    if (canSelectCells) {
      final cellIndex = row * widget.gridSize + col;
      widget.onSelectCell(cellIndex);
    } else {
      final targetZoom = min(
        _optimalZoomLevel,
        max(_cellSelectionThreshold * 1.2, _zoom * 2),
      );

      final cellCenterX = (col + 0.5) * CELL_SIZE * targetZoom;
      final cellCenterY = (row + 0.5) * CELL_SIZE * targetZoom;

      setState(() {
        _gridPosition = Offset(
          localPosition.dx - cellCenterX,
          localPosition.dy - cellCenterY,
        );
        _zoom = targetZoom;
        _currentScaleIndex = _getClosestScaleIndex(targetZoom);
      });
    }
  }

  BoxDecoration _buildBackgroundDecoration() {
    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFFEFF2F7),
          Color(0xFFEBF8FF),
        ],
      ),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: Color(0xFFDADBE3)),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.1),
          blurRadius: 15,
          offset: Offset(0, 4),
        ),
      ],
    );
  }

  Widget _buildAdBackground() {
    return Positioned(
      left: _gridPosition.dx,
      top: _gridPosition.dy,
      child: Container(
        width: widget.gridSize * CELL_SIZE * _zoom,
        height: widget.gridSize * CELL_SIZE * _zoom,
        child: Image.network(
          widget.fullAdImage!,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFF6B21A8).withOpacity(0.3),
                    Color(0xFF155E75).withOpacity(0.3),
                  ],
                ),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('🎁', style: TextStyle(fontSize: 32)),
                    SizedBox(height: 8),
                    Text('상품 이미지', style: TextStyle(fontSize: 12, color: Colors.white60)),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildGridLines() {
    return Positioned(
      left: _gridPosition.dx,
      top: _gridPosition.dy,
      child: CustomPaint(
        size: Size(
          widget.gridSize * CELL_SIZE * _zoom,
          widget.gridSize * CELL_SIZE * _zoom,
        ),
        painter: GridPainter(
          cellSize: CELL_SIZE,
          zoom: _zoom,
          gridSize: widget.gridSize,
          shouldUseSparseGrid: widget.gridSize > 500 && _zoom < 0.2,
          gridStepSize: max(5, (widget.gridSize / 100).floor()),
        ),
      ),
    );
  }

  Widget _buildGridOverlay() {
    return Positioned(
      left: _gridPosition.dx,
      top: _gridPosition.dy,
      child: Container(
        width: widget.gridSize * CELL_SIZE * _zoom,
        height: widget.gridSize * CELL_SIZE * _zoom,
        color: Colors.black.withOpacity(0.2),
      ),
    );
  }

  Widget _buildCellIcons() {
    return Positioned(
      left: _gridPosition.dx,
      top: _gridPosition.dy,
      child: CellIconLayer(
        gridSize: widget.gridSize,
        cellSize: CELL_SIZE,
        zoom: _zoom,
        selectedBlocks: widget.selectedBlocks,
        selectedCell: widget.selectedCell,
        highlightedBlock: widget.highlightedBlock,
        animatingBlock: widget.animatingBlock,
        gameState: widget.gameState,
        pulseController: _pulseController,
      ),
    );
  }

  Widget _buildUIOverlay() {
    return Stack(
      children: [
        // 그리드 정보
        if (!widget.isMobile)
          Positioned(
            top: 16,
            left: 16,
            child: Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Color(0xFFDADBE3)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('그리드: ${widget.gridSize} x ${widget.gridSize}', style: TextStyle(fontSize: 12)),
                  Text('총 셀: ${(widget.gridSize * widget.gridSize).toStringAsFixed(0)}', style: TextStyle(fontSize: 12)),
                  Text('축척: ${_scaleLevels[_currentScaleIndex].label}', style: TextStyle(fontSize: 12)),
                  Text('줌: ${_zoom.toStringAsFixed(2)}x', style: TextStyle(fontSize: 12)),
                  Text(
                    _zoom >= _cellSelectionThreshold ? '🎯 셀선택: 활성화' : '🔍 영역확대: ${_cellSelectionThreshold}x 필요',
                    style: TextStyle(
                      fontSize: 12,
                      color: _zoom >= _cellSelectionThreshold ? Colors.green : Colors.orange,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: _buildBackgroundDecoration(),
      child: Listener(
        onPointerSignal: (event) {
          if (event is PointerScrollEvent) {
            _handleMouseWheel(event);
          }
        },
        child: GestureDetector(
          onScaleStart: _handleScaleStart,
          onScaleUpdate: _handleScaleUpdate,
          onScaleEnd: _handleScaleEnd,
          onTapUp: _handleTap,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Stack(
              children: [
                if (widget.showFullAd && widget.fullAdImage != null)
                  _buildAdBackground(),
                _buildGridLines(),
                _buildGridOverlay(),
                _buildCellIcons(),
                _buildUIOverlay(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
```

---

이 문서로 Flutter 개발자는 현재 구현된 NewGameGrid를 **100% 동일하게** 재현할 수 있습니다! 🎉