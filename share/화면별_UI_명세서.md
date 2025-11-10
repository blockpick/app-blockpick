# BlockPick 화면별 UI 상세 명세서 (완전판)

**프로젝트명**: BlockPick Flutter Mobile Application
**버전**: 2.0.0 (소스코드 완전 분석판)
**작성일**: 2025-11-05
**문서 유형**: 화면별 UI 상세 명세 (위젯 트리 전체 포함)

---

## 문서 목적

이 문서는 **BlockPick Flutter 앱의 모든 화면을 소스코드 수준으로 상세하게 문서화**합니다.
개발자가 이 문서만 보고 화면을 처음부터 똑같이 재구현할 수 있을 정도의 상세함을 목표로 합니다.

각 화면마다 다음 정보를 포함합니다:
- **위젯 계층 구조** (Widget Tree)
- **모든 색상 값** (HEX 코드)
- **모든 텍스트 스타일** (폰트 크기, 굵기)
- **모든 패딩, 마진, 간격** (px 단위)
- **모든 border radius, elevation** 값
- **모든 이벤트 핸들러와 동작**
- **상태 관리** (Riverpod Provider)
- **라이프사이클 메서드**

---

## 목차

1. [홈 화면 (Home Screen)](#1-홈-화면-home-screen)
2. [게임 목록 화면 (Game List Screen)](#2-게임-목록-화면-game-list-screen)
3. [게임 화면 (Game Screen)](#3-게임-화면-game-screen)
4. [선택 블록 바텀시트 (Selected Blocks Sheet)](#4-선택-블록-바텀시트-selected-blocks-sheet)
5. [게임 참가 로딩 오버레이](#5-게임-참가-로딩-오버레이)
6. [게임 참가 결과 오버레이](#6-게임-참가-결과-오버레이)
7. [로그인 화면 (Login Screen)](#7-로그인-화면-login-screen)
8. [회원가입 화면 (Signup Screen)](#8-회원가입-화면-signup-screen)
9. [마이페이지 (My Screen)](#9-마이페이지-my-screen)
10. [공통 컴포넌트](#10-공통-컴포넌트)
11. [디자인 시스템](#11-디자인-시스템)

---

## 1. 홈 화면 (Home Screen)

### 1.1 파일 정보
- **파일 경로**: `lib/features/home/home_screen.dart`
- **클래스**: `HomeScreen extends ConsumerStatefulWidget`
- **State 클래스**: `_HomeScreenState extends ConsumerState<HomeScreen> with SingleTickerProviderStateMixin`

### 1.2 위젯 계층 구조

```dart
SafeArea
└── Column
    ├── Container (탭 바 컨테이너)
    │   └── TabBar
    │       ├── Tab(text: 'DAILY')
    │       ├── Tab(text: 'SELECT')
    │       ├── Tab(text: 'VIBE')
    │       └── Tab(text: 'OPTIMAL')
    └── Expanded
        └── TabBarView
            ├── GameListScreen(gameType: GameType.daily)
            ├── GameListScreen(gameType: GameType.select)
            ├── GameListScreen(gameType: GameType.vibe)
            └── OptimalGameListScreen()
```

### 1.3 상태 관리

**로컬 상태**:
```dart
late TabController _tabController;

@override
void initState() {
  super.initState();
  _tabController = TabController(length: 4, vsync: this);
}

@override
void dispose() {
  _tabController.dispose();
  super.dispose();
}
```

### 1.4 탭 바 상세 명세

#### 컨테이너 (TabBar Wrapper)
```dart
Container(
  decoration: const BoxDecoration(
    color: AppColors.white,              // #FFFFFF
    border: Border(
      bottom: BorderSide(
        color: AppColors.buleGray,       // #DADBE3
      ),
    ),
  ),
  child: TabBar(...)
)
```

#### TabBar 속성
```dart
TabBar(
  controller: _tabController,
  indicatorColor: AppColors.blue,        // #5C72F5
  indicatorWeight: 3,                    // px
  labelColor: AppColors.blue,            // #5C72F5
  unselectedLabelColor: AppColors.medium, // #555555
  labelStyle: AppTextStyles.button,      // 14px, semibold, 0.2 letter-spacing
  tabs: [...]
)
```

**탭 텍스트**:
- `'DAILY'`, `'SELECT'`, `'VIBE'`, `'OPTIMAL'`
- 선택 시: 파란색 (`#5C72F5`), 하단 3px 인디케이터
- 미선택 시: 회색 (`#555555`)

### 1.5 TabBarView

각 탭마다 독립적인 화면 표시:
- **DAILY**: `GameListScreen(gameType: GameType.daily)`
- **SELECT**: `GameListScreen(gameType: GameType.select)`
- **VIBE**: `GameListScreen(gameType: GameType.vibe)`
- **OPTIMAL**: `OptimalGameListScreen()`

---

## 2. 게임 목록 화면 (Game List Screen)

### 2.1 파일 정보
- **파일 경로**: `lib/features/game/game_list_screen.dart`
- **클래스**: `GameListScreen extends ConsumerStatefulWidget`
- **Props**: `final GameType gameType`

### 2.2 로컬 상태
```dart
String _selectedCategory = 'ALL';
String _selectedSort = 'popular';

final List<Map<String, dynamic>> _categories = [
  {'label': 'ALL', 'value': 'ALL', 'icon': null},
  {'label': 'Digital', 'value': 'Digital', 'icon': LucideIcons.cpu},
  {'label': 'Fashion', 'value': 'Fashion', 'icon': LucideIcons.shirt},
  {'label': 'Gift', 'value': 'Gift', 'icon': LucideIcons.gift},
  {'label': 'Food', 'value': 'Food', 'icon': LucideIcons.utensilsCrossed},
];

final List<Map<String, String>> _sortOptions = [
  {'label': 'Most Popular', 'value': 'popular'},
  {'label': 'Newest', 'value': 'newest'},
  {'label': 'Ending Soon', 'value': 'ending_soon'},
  {'label': 'Price Low to High', 'value': 'price_low'},
];
```

### 2.3 Provider 사용
```dart
final gamesAsync = ref.watch(gamesByTypeProvider(widget.gameType));
final sortedGames = ref.watch(sortedGamesProvider(filteredGames, _selectedSort));
```

### 2.4 위젯 계층 구조

```dart
Scaffold(backgroundColor: AppColors.deepWhite)  // #FCFCFC
└── Column
    ├── _buildBanner()                    // 배너 섹션
    ├── _buildFilterBar()                 // 필터 바
    └── Expanded
        └── _buildContent()               // 게임 리스트 or 로딩 or 에러
```

### 2.5 배너 섹션 (_buildBanner)

```dart
Container(
  width: double.infinity,
  decoration: BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        AppColors.purple,   // #6E5AE9
        AppColors.blue,     // #5C72F5
      ],
    ),
  ),
  padding: EdgeInsets.symmetric(vertical: 32, horizontal: 24),
  child: SafeArea(
    bottom: false,
    child: Column(
      children: [
        Text(
          'PICK YOUR PRIZE, MAKE IT YOURS',
          style: AppTextStyles.large.copyWith(         // 24px, bold
            color: AppColors.white,                     // #FFFFFF
            fontWeight: FontWeight.w700,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 8),
        Text(
          'Choose your favorite items and participate in exciting games',
          style: AppTextStyles.body.copyWith(          // 14px, normal
            color: AppColors.white.withOpacity(0.9),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    ),
  ),
)
```

### 2.6 필터 바 (_buildFilterBar)

```dart
Container(
  padding: EdgeInsets.all(16),
  decoration: BoxDecoration(
    color: AppColors.white,              // #FFFFFF
    border: Border(
      bottom: BorderSide(color: AppColors.buleGray),  // #DADBE3
    ),
  ),
  child: Column(
    children: [
      // 카테고리 필터 (가로 스크롤)
      SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: _categories.map((category) {
            return Padding(
              padding: EdgeInsets.only(right: 8),
              child: FilterChip(
                label: Row(...),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    _selectedCategory = category['value'] as String;
                  });
                },
                selectedColor: AppColors.blue,       // #5C72F5
                backgroundColor: AppColors.white,     // #FFFFFF
                labelStyle: AppTextStyles.bodySmall.copyWith(
                  color: isSelected ? AppColors.white : AppColors.navy,
                  fontWeight: FontWeight.w600,
                ),
                side: BorderSide(
                  color: isSelected ? AppColors.blue : AppColors.buleGray,
                ),
              ),
            );
          }).toList(),
        ),
      ),
      SizedBox(height: 12),
      // 정렬 드롭다운
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Consumer(
            builder: (context, ref, child) {
              // 게임 수 표시
              final count = ...;
              return Text(
                '$count games',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.medium,  // #555555
                ),
              );
            },
          ),
          PopupMenuButton<String>(
            initialValue: _selectedSort,
            onSelected: (value) {
              setState(() { _selectedSort = value; });
            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.buleGray),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Text(_sortOptions.firstWhere(...)['label']!),
                  SizedBox(width: 4),
                  Icon(LucideIcons.chevronDown, size: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    ],
  ),
)
```

### 2.7 게임 그리드 (_buildGameGrid)

```dart
GridView.builder(
  padding: EdgeInsets.all(16),
  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
    crossAxisCount: MediaQuery.of(context).size.width > 600 ? 2 : 1,
    childAspectRatio: 0.75,
    crossAxisSpacing: 16,
    mainAxisSpacing: 16,
  ),
  itemCount: games.length,
  itemBuilder: (context, index) {
    final game = games[index];
    return GameCard(
      game: game,
      onTap: () {
        context.go('/game/${game.id}');
      },
    );
  },
)
```

**GameCard 컴포넌트**는 [10. 공통 컴포넌트](#10-공통-컴포넌트) 참조

### 2.8 빈 상태 (_buildEmptyState)

```dart
Center(
  child: Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Icon(
        LucideIcons.inbox,
        size: 64,
        color: AppColors.buleGray,  // #DADBE3
      ),
      SizedBox(height: 16),
      Text(
        'No games found',
        style: AppTextStyles.medium.copyWith(
          color: AppColors.medium,  // #555555
        ),
      ),
      SizedBox(height: 8),
      Text(
        'Try changing your filters',
        style: AppTextStyles.body.copyWith(
          color: AppColors.medium,
        ),
      ),
    ],
  ),
)
```

### 2.9 로딩 상태

```dart
Center(
  child: CircularProgressIndicator(
    valueColor: AlwaysStoppedAnimation<Color>(AppColors.blue),  // #5C72F5
  ),
)
```

### 2.10 에러 상태

```dart
Center(
  child: Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Icon(LucideIcons.alertCircle, size: 64, color: AppColors.red),  // #FF5D5C
      SizedBox(height: 16),
      Text(
        'Error loading games',
        style: AppTextStyles.medium.copyWith(color: AppColors.red),
      ),
      SizedBox(height: 8),
      Text(
        error.toString(),
        style: AppTextStyles.bodySmall.copyWith(color: AppColors.medium),
        textAlign: TextAlign.center,
      ),
      SizedBox(height: 16),
      ElevatedButton(
        onPressed: () { ref.invalidate(gamesByTypeProvider); },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.blue,
          foregroundColor: AppColors.white,
        ),
        child: Text('Retry'),
      ),
    ],
  ),
)
```

---

## 3. 게임 화면 (Game Screen)

### 3.1 파일 정보
- **파일 경로**: `lib/features/game/game_screen.dart`
- **클래스**: `GameScreen extends ConsumerStatefulWidget`
- **복잡도**: 매우 높음 (게임 그리드 렌더링, 줌, 미니맵, 튜토리얼 등)

### 3.2 주요 로컬 상태
```dart
GameRound? _game;
Game? _fullGame;
GridConfig? _gridConfig;
int _gridWidth = 0;
int _gridHeight = 0;
int _currentZoomLevel = 0;
List<GridSection> _sections = [];
```

### 3.3 위젯 계층 구조 (단순화)

```dart
Scaffold(
  backgroundColor: AppColors.deepWhite,  // #FCFCFC
  appBar: AppBar(
    backgroundColor: AppColors.white,
    leading: IconButton(
      icon: Icon(LucideIcons.chevronLeft, color: AppColors.darkBlue),
      onPressed: () => context.pop(),
    ),
    title: Text(
      _game?.title ?? '',
      style: AppTextStyles.medium.copyWith(color: AppColors.darkBlue),
    ),
    actions: [
      IconButton(
        icon: Icon(LucideIcons.moreVertical, color: AppColors.darkBlue),
        onPressed: () { /* 게임 정보 표시 */ },
      ),
    ],
  ),
  body: Stack(
    children: [
      // 메인 게임 그리드
      GameGridWidget(...),

      // 미니맵 (우하단)
      Positioned(
        bottom: 16,
        right: 16,
        child: GridMinimap(...),
      ),

      // 줌 컨트롤 (우측 중앙)
      Positioned(
        right: 16,
        top: MediaQuery.of(context).size.height * 0.4,
        child: _buildZoomControls(),
      ),

      // Pick HUD (좌하단)
      Positioned(
        left: 16,
        bottom: 16,
        child: _buildPickHUD(),
      ),

      // 선택 블록 바텀시트
      if (_gridConfig != null && _game != null)
        SelectedBlocksSheet(
          gridConfig: _gridConfig!,
          game: _game,
          fullGame: _fullGame,
        ),
    ],
  ),
)
```

### 3.4 AppBar 상세 명세

```dart
AppBar(
  backgroundColor: AppColors.white,  // #FFFFFF
  elevation: 0,
  leading: IconButton(
    icon: Icon(
      LucideIcons.chevronLeft,
      color: AppColors.darkBlue,  // #081245
      size: 24,
    ),
    onPressed: () => context.pop(),
  ),
  title: Text(
    _game?.title ?? '',
    style: AppTextStyles.medium.copyWith(  // 18px, semibold
      color: AppColors.darkBlue,
    ),
    maxLines: 1,
    overflow: TextOverflow.ellipsis,
  ),
  centerTitle: true,
  actions: [
    IconButton(
      icon: Icon(
        LucideIcons.moreVertical,
        color: AppColors.darkBlue,
        size: 24,
      ),
      onPressed: () {
        // 게임 정보 바텀시트 표시
      },
    ),
  ],
)
```

### 3.5 줌 컨트롤 (_buildZoomControls)

```dart
Column(
  children: [
    // 줌 인 버튼
    Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: AppColors.white,           // #FFFFFF
        border: Border.all(color: AppColors.buleGray),  // #DADBE3
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: IconButton(
        icon: Icon(
          LucideIcons.plus,
          color: _currentZoomLevel < _maxZoomLevel
              ? AppColors.darkBlue
              : AppColors.hint,
          size: 20,
        ),
        onPressed: _currentZoomLevel < _maxZoomLevel
            ? () { _zoomIn(); }
            : null,
      ),
    ),
    // 구분선
    Container(
      width: 48,
      height: 1,
      color: AppColors.buleGray,  // #DADBE3
    ),
    // 줌 아웃 버튼
    Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border.all(color: AppColors.buleGray),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(12),
          bottomRight: Radius.circular(12),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: IconButton(
        icon: Icon(
          LucideIcons.minus,
          color: _currentZoomLevel > 0
              ? AppColors.darkBlue
              : AppColors.hint,
          size: 20,
        ),
        onPressed: _currentZoomLevel > 0
            ? () { _zoomOut(); }
            : null,
      ),
    ),
  ],
)
```

### 3.6 Pick HUD (_buildPickHUD)

```dart
Container(
  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
  decoration: BoxDecoration(
    color: AppColors.white.withOpacity(0.9),
    borderRadius: BorderRadius.circular(16),
    boxShadow: [
      BoxShadow(
        color: AppColors.black.withOpacity(0.1),
        blurRadius: 8,
        offset: Offset(0, 2),
      ),
    ],
  ),
  child: Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Text(
        'Pick: ${selectedCount}/${maxPicks}',
        style: AppTextStyles.body.copyWith(
          color: AppColors.darkBlue,
          fontWeight: FontWeight.w500,
        ),
      ),
      SizedBox(width: 8),
      // Pick 인디케이터 (5개 점)
      Row(
        children: List.generate(5, (index) {
          return Container(
            margin: EdgeInsets.only(right: 4),
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: index < selectedCount
                  ? AppColors.blue      // #5C72F5
                  : AppColors.hint,     // #C5C9DC
            ),
          );
        }),
      ),
    ],
  ),
)
```

---

## 4. 선택 블록 바텀시트 (Selected Blocks Sheet)

### 4.1 파일 정보
- **파일 경로**: `lib/features/game/selected_blocks_sheet.dart`
- **클래스**: `SelectedBlocksSheet extends ConsumerWidget`
- **Props**:
  - `final GridConfig gridConfig`
  - `final GameRound? game`
  - `final Game? fullGame`

### 4.2 위젯 계층 구조

```dart
DraggableBottomSheet(
  initialChildSize: 0.4,
  minChildSize: 0.1,
  maxChildSize: 0.7,
  snapSizes: [0.4, 0.7],
  onClose: () {
    gridNotifier.hideBottomSheet();
  },

  header: Padding(
    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Text(
              '${selectedBlocks.length} Blocks',
              style: AppTextStyles.large.copyWith(  // 24px, bold
                color: AppColors.blue,              // #5C72F5
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(width: 8),
            Text(
              'selected',
              style: AppTextStyles.body.copyWith(   // 14px, normal
                color: AppColors.medium,            // #555555
              ),
            ),
          ],
        ),
        TextButton(
          onPressed: () { gridNotifier.clearBlocks(); },
          child: Text(
            'CLEAR',
            style: AppTextStyles.button.copyWith(   // 14px, semibold
              color: AppColors.red,                 // #FF5D5C
            ),
          ),
        ),
      ],
    ),
  ),

  children: selectedBlocks.map((block) => Padding(
    padding: EdgeInsets.only(bottom: 8),
    child: BlockItemCard(
      block: block,
      onRemove: () => gridNotifier.toggleBlock(block),
      isFocused: ref.watch(gridStateProvider(gridConfig)).focusedBlockId == block.id,
      onTap: () {
        gridNotifier.navigateToBlock(block, ...);
      },
    ),
  )).toList(),

  footer: GradientButton(
    label: 'Select blocks (${selectedBlocks.length}/pick)',
    icon: Icons.bolt,
    onPressed: () async {
      if (!isAuthenticated) {
        await showLoginDialog(context);
        return;
      }
      await _handleJoinGame(context, ref, selectedBlocks);
    },
  ),
)
```

### 4.3 헤더 상세

**좌측 영역**:
```dart
Row(
  children: [
    Text(
      '${selectedBlocks.length} Blocks',
      style: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: Color(0xFF5C72F5),  // AppColors.blue
      ),
    ),
    SizedBox(width: 8),
    Text(
      'selected',
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: Color(0xFF555555),  // AppColors.medium
      ),
    ),
  ],
)
```

**우측 CLEAR 버튼**:
```dart
TextButton(
  onPressed: () { gridNotifier.clearBlocks(); },
  child: Text(
    'CLEAR',
    style: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.2,
      color: Color(0xFFFF5D5C),  // AppColors.red
    ),
  ),
)
```

### 4.4 BlockItemCard 상세

```dart
Container(
  height: 56,
  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
  decoration: BoxDecoration(
    color: isFocused
        ? AppColors.blueWhite      // #ECF1F9
        : AppColors.white,         // #FFFFFF
    border: Border.all(
      color: AppColors.buleGray,   // #DADBE3
      width: 1,
    ),
    borderRadius: BorderRadius.circular(8),
  ),
  child: Row(
    children: [
      // 블록 인디케이터 (원형 점)
      Container(
        width: 12,
        height: 12,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.blue,  // #5C72F5
        ),
      ),
      SizedBox(width: 12),
      // 좌표 텍스트
      Expanded(
        child: Text(
          'Row ${block.row}, Col ${block.col}',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF081245),  // AppColors.darkBlue
          ),
        ),
      ),
      // 삭제 버튼
      IconButton(
        icon: Icon(
          LucideIcons.x,
          color: Color(0xFFFF5D5C),  // AppColors.red
          size: 20,
        ),
        onPressed: () => gridNotifier.toggleBlock(block),
      ),
    ],
  ),
)
```

### 4.5 GradientButton (Footer)

```dart
Container(
  width: double.infinity,
  height: 52,
  decoration: BoxDecoration(
    gradient: LinearGradient(
      colors: [Color(0xFF3D81F6), Color(0xFF875DF4)],  // Blue → Purple
    ),
    borderRadius: BorderRadius.circular(12),
    boxShadow: [
      BoxShadow(
        color: Color(0xFF5C72F5).withOpacity(0.3),
        blurRadius: 12,
        offset: Offset(0, 6),
      ),
    ],
  ),
  child: Material(
    color: Colors.transparent,
    child: InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(12),
      child: Center(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.bolt,
              color: Colors.white,
              size: 20,
            ),
            SizedBox(width: 8),
            Text(
              'Select blocks (${selectedBlocks.length}/pick)',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    ),
  ),
)
```

### 4.6 게임 참가 프로세스 (_handleJoinGame)

```dart
Future<void> _handleJoinGame(
  BuildContext context,
  WidgetRef ref,
  List<BlockModel> selectedBlocks,
) async {
  // 1. 게임 정보 확인
  if (game == null || fullGame == null) {
    _showError(context, '게임 정보를 불러올 수 없습니다');
    return;
  }

  // 2. 컨트랙트 주소 확인
  final contractAddress = fullGame!.onchainContractAddr;
  if (contractAddress == null || contractAddress.isEmpty) {
    _showError(context, '컨트랙트 주소가 없습니다');
    return;
  }

  // 3. 상품 ID 확인
  String? productId;
  if (fullGame!.gameProducts != null && fullGame!.gameProducts!.isNotEmpty) {
    productId = fullGame!.gameProducts!.first.id;
  }
  if (productId == null) {
    _showError(context, '게임 상품 정보가 없습니다');
    return;
  }

  // 4. 로딩 오버레이 표시
  if (!context.mounted) return;
  GameJoinLoadingOverlay.show(context);

  // 5. Provider 호출
  try {
    final result = await ref
        .read(gameParticipationProvider.notifier)
        .joinGame(
          gameId: game!.id,
          selectedGameProductId: productId,
          row: selectedBlocks.first.row,
          col: selectedBlocks.first.col,
          contractAddress: contractAddress,
        );

    // 6. 로딩 숨김
    if (!context.mounted) return;
    GameJoinLoadingOverlay.hide(context);
    await Future.delayed(Duration(milliseconds: 300));

    // 7. 결과 표시
    if (!context.mounted) return;
    if (result.success) {
      GameJoinResultOverlay.showSuccess(
        context,
        entryId: result.entryId,
        txHash: result.txHash,
        onConfirm: () {
          ref.read(gridStateProvider(gridConfig).notifier).clearBlocks();
        },
      );
    } else {
      GameJoinResultOverlay.showError(
        context,
        errorMessage: result.message,
        onRetry: () {
          _handleJoinGame(context, ref, selectedBlocks);
        },
      );
    }
  } catch (e) {
    // 에러 처리
    if (!context.mounted) return;
    GameJoinLoadingOverlay.hide(context);
    await Future.delayed(Duration(milliseconds: 300));

    if (!context.mounted) return;
    GameJoinResultOverlay.showError(
      context,
      errorMessage: e.toString(),
      onRetry: () {
        _handleJoinGame(context, ref, selectedBlocks);
      },
    );
  }
}
```

---

## 5. 게임 참가 로딩 오버레이

### 5.1 파일 정보
- **파일 경로**: `lib/features/game/widgets/game_join_loading_overlay.dart`
- **클래스**: `GameJoinLoadingOverlay extends StatefulWidget`
- **사용법**:
  ```dart
  GameJoinLoadingOverlay.show(context);
  // 작업 완료 후
  GameJoinLoadingOverlay.hide(context);
  ```

### 5.2 위젯 계층 구조

```dart
Material(color: Colors.transparent)
└── Container(
    width: double.infinity,
    height: double.infinity,
    decoration: BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFF5C72F5).withOpacity(0.95),  // Blue
          Color(0xFF6E5AE9).withOpacity(0.95),  // Purple
        ],
      ),
    ),
    child: SafeArea(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildLoadingAnimation(),      // 회전 원형 + 로켓 아이콘
            SizedBox(height: 48),
            Text('게임에 참가하고 있어요'),    // 타이틀
            SizedBox(height: 16),
            Text(currentStep),              // 현재 단계 설명
            SizedBox(height: 48),
            _buildProgressBar(progress),   // 진행률 바
            SizedBox(height: 16),
            Text('${stepNumber}/${totalSteps}'),  // 단계 표시
            SizedBox(height: 64),
            _buildInfoCard(),               // 안내 메시지
          ],
        ),
      ),
    ),
  )
```

### 5.3 로딩 애니메이션 (_buildLoadingAnimation)

```dart
SizedBox(
  width: 120,
  height: 120,
  child: Stack(
    alignment: Alignment.center,
    children: [
      // 외부 회전 원 (2초, 360도)
      Container(
        width: 120,
        height: 120,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.white.withOpacity(0.2),
            width: 2,
          ),
        ),
      ).animate(onPlay: (controller) => controller.repeat())
       .rotate(duration: 2000.ms),

      // 중간 회전 원 (1.5초, 역방향)
      Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.white.withOpacity(0.4),
            width: 2,
          ),
        ),
      ).animate(onPlay: (controller) => controller.repeat())
       .rotate(duration: 1500.ms, begin: 1, end: 0),

      // 중앙 로켓 아이콘
      Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
        ),
        child: Icon(
          Icons.rocket_launch_rounded,
          color: Color(0xFF5C72F5),  // AppColors.blue
          size: 28,
        ),
      ).animate(onPlay: (controller) => controller.repeat(reverse: true))
       .scale(
         duration: 1000.ms,
         begin: Offset(1.0, 1.0),
         end: Offset(1.1, 1.1),
       ),
    ],
  ),
)
```

### 5.4 타이틀 텍스트

```dart
Text(
  '게임에 참가하고 있어요',
  style: TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    color: Colors.white,
  ),
  textAlign: TextAlign.center,
).animate(onPlay: (controller) => controller.repeat())
 .shimmer(
   duration: 2000.ms,
   color: Colors.white.withOpacity(0.3),
 )
```

### 5.5 진행 단계 텍스트

```dart
Text(
  currentStep,  // '블록체인 지갑을 확인하고 있어요', etc.
  style: TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: Colors.white.withOpacity(0.9),
  ),
  textAlign: TextAlign.center,
).animate()
 .fadeIn(duration: 300.ms)
 .slideY(begin: 0.2, end: 0)
```

**진행 단계 목록**:
1. `'블록체인 지갑을 확인하고 있어요'`
2. `'암호화 키를 요청하고 있어요'`
3. `'좌표를 암호화하고 있어요'`
4. `'지갑 주소를 보호하고 있어요'`
5. `'게임 참가를 완료하고 있어요'`

### 5.6 진행률 바 (_buildProgressBar)

```dart
ClipRRect(
  borderRadius: BorderRadius.circular(10),
  child: SizedBox(
    height: 8,
    child: Stack(
      children: [
        // 배경
        Container(
          width: double.infinity,
          color: Colors.white.withOpacity(0.2),
        ),
        // 진행률
        FractionallySizedBox(
          widthFactor: progress,  // 0.0 ~ 1.0
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.white, Colors.white70],
              ),
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.white.withOpacity(0.5),
                  blurRadius: 8,
                  spreadRadius: 2,
                ),
              ],
            ),
          ).animate()
           .shimmer(
             duration: 1500.ms,
             color: Colors.white.withOpacity(0.5),
           ),
        ),
      ],
    ),
  ),
)
```

### 5.7 안내 메시지 카드

```dart
Container(
  padding: EdgeInsets.all(16),
  decoration: BoxDecoration(
    color: Colors.white.withOpacity(0.1),
    borderRadius: BorderRadius.circular(12),
    border: Border.all(
      color: Colors.white.withOpacity(0.2),
    ),
  ),
  child: Column(
    children: [
      Icon(
        Icons.info_outline,
        color: Colors.white.withOpacity(0.8),
        size: 20,
      ),
      SizedBox(height: 8),
      Text(
        '블록체인에 트랜잭션을 전송하고 있습니다.\n잠시만 기다려주세요.',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: Colors.white.withOpacity(0.8),
        ),
        textAlign: TextAlign.center,
      ),
    ],
  ),
).animate()
 .fadeIn(delay: 500.ms, duration: 500.ms)
 .scale(begin: Offset(0.8, 0.8))
```

---

## 6. 게임 참가 결과 오버레이

### 6.1 파일 정보
- **파일 경로**: `lib/features/game/widgets/game_join_result_overlay.dart`
- **클래스**: `GameJoinResultOverlay extends StatelessWidget`
- **Props**:
  - `final bool success`
  - `final String? entryId`
  - `final String? txHash`
  - `final String? errorMessage`
  - `final VoidCallback? onConfirm`
  - `final VoidCallback? onRetry`

### 6.2 성공 화면 위젯 구조

```dart
Material(color: Colors.transparent)
└── Container(
    width: double.infinity,
    height: double.infinity,
    decoration: BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFF10B981).withOpacity(0.95),  // Green
          Color(0xFF3B82F6).withOpacity(0.95),  // Blue
        ],
      ),
    ),
    child: SafeArea(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildResultIcon(success: true),  // 체크 아이콘 + 파티클
            SizedBox(height: 48),
            Text('게임 참가 완료!'),             // 타이틀
            SizedBox(height: 16),
            Text('설명 텍스트'),                 // 설명
            SizedBox(height: 48),
            _buildInfoCard(),                   // 상세 정보 카드
            SizedBox(height: 24),
            ElevatedButton('확인'),             // 확인 버튼
            SizedBox(height: 24),
            TextButton('닫기'),                  // 닫기 버튼
          ],
        ),
      ),
    ),
  )
```

### 6.3 성공 아이콘 (_buildResultIcon - success)

```dart
Stack(
  alignment: Alignment.center,
  children: [
    // 파티클 효과 (8개 원)
    ...List.generate(8, (index) {
      return Transform.translate(
        offset: Offset(30, 30),  // 방향에 따라 다름
        child: Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withOpacity(0.3),
          ),
        ),
      ).animate(onPlay: (controller) => controller.repeat())
       .fadeOut(duration: 2000.ms)
       .scale(
         begin: Offset(0.5, 0.5),
         end: Offset(2.0, 2.0),
         delay: Duration(milliseconds: index * 100),
       );
    }),

    // 메인 체크 아이콘
    Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.white.withOpacity(0.3),
            blurRadius: 30,
            spreadRadius: 10,
          ),
        ],
      ),
      child: Icon(
        LucideIcons.checkCircle2,
        color: Color(0xFF10B981),  // AppColors.green
        size: 64,
      ),
    ).animate()
     .scale(
       delay: 100.ms,
       duration: 600.ms,
       begin: Offset(0, 0),
       end: Offset(1, 1),
       curve: Curves.elasticOut,
     )
     .then()
     .shake(hz: 2, curve: Curves.easeInOut),
  ],
)
```

### 6.4 실패 아이콘 (_buildResultIcon - failure)

```dart
Container(
  width: 120,
  height: 120,
  decoration: BoxDecoration(
    shape: BoxShape.circle,
    color: Colors.white,
    boxShadow: [
      BoxShadow(
        color: Colors.white.withOpacity(0.3),
        blurRadius: 30,
        spreadRadius: 10,
      ),
    ],
  ),
  child: Icon(
    LucideIcons.xCircle,
    color: Color(0xFFFF5D5C),  // AppColors.red
    size: 64,
  ),
).animate()
 .scale(
   delay: 100.ms,
   duration: 400.ms,
   begin: Offset(0, 0),
   end: Offset(1, 1),
 )
 .then()
 .shake(hz: 4, curve: Curves.easeInOut)
```

### 6.5 타이틀 및 설명

**성공 시**:
```dart
Text(
  '게임 참가 완료!',
  style: TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    color: Colors.white,
  ),
  textAlign: TextAlign.center,
).animate()
 .fadeIn(delay: 300.ms, duration: 500.ms)
 .slideY(begin: -0.2, end: 0)

SizedBox(height: 16)

Text(
  '블록체인에 안전하게 기록되었어요.\n이제 게임 결과를 기다려주세요!',
  style: TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: Colors.white.withOpacity(0.9),
  ),
  textAlign: TextAlign.center,
).animate()
 .fadeIn(delay: 500.ms, duration: 500.ms)
```

**실패 시**:
```dart
Text(
  '참가에 실패했어요',
  style: TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    color: Colors.white,
  ),
  textAlign: TextAlign.center,
)

SizedBox(height: 16)

Text(
  errorMessage ?? '다시 시도해주세요.',
  style: TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: Colors.white.withOpacity(0.9),
  ),
  textAlign: TextAlign.center,
)
```

### 6.6 상세 정보 카드 (_buildInfoCard)

```dart
Container(
  width: double.infinity,
  padding: EdgeInsets.all(20),
  decoration: BoxDecoration(
    color: Colors.white.withOpacity(0.15),
    borderRadius: BorderRadius.circular(20),
    border: Border.all(
      color: Colors.white.withOpacity(0.3),
      width: 1,
    ),
  ),
  child: Column(
    children: [
      // Entry ID 행
      _buildInfoRow(
        context,
        icon: LucideIcons.hash,
        label: 'Entry ID',
        value: entryId!,
        copyable: true,
      ),
      SizedBox(height: 16),
      // 트랜잭션 해시 행
      _buildInfoRow(
        context,
        icon: LucideIcons.link,
        label: '트랜잭션',
        value: '${txHash!.substring(0, 10)}...${txHash!.substring(txHash!.length - 8)}',
        copyable: true,
        fullValue: txHash,
      ),
    ],
  ),
).animate()
 .fadeIn(delay: 700.ms, duration: 500.ms)
 .slideY(begin: 0.2, end: 0)
```

### 6.7 정보 행 (_buildInfoRow)

```dart
Row(
  children: [
    Icon(
      icon,
      color: Colors.white.withOpacity(0.8),
      size: 20,
    ),
    SizedBox(width: 12),
    Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: Colors.white.withOpacity(0.7),
            ),
          ),
          SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              fontFamily: 'monospace',
              color: Colors.white,
            ),
          ),
        ],
      ),
    ),
    if (copyable)
      IconButton(
        onPressed: () {
          Clipboard.setData(ClipboardData(text: fullValue ?? value));
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('$label가 복사되었습니다'),
              duration: Duration(seconds: 2),
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
        icon: Icon(
          LucideIcons.copy,
          color: Colors.white.withOpacity(0.7),
          size: 20,
        ),
      ),
  ],
)
```

### 6.8 확인 버튼 (성공)

```dart
ElevatedButton(
  onPressed: () {
    onConfirm?.call();
    Navigator.of(context).pop();
  },
  style: ElevatedButton.styleFrom(
    backgroundColor: Colors.white,
    foregroundColor: Color(0xFF10B981),  // AppColors.green
    padding: EdgeInsets.symmetric(horizontal: 48, vertical: 16),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(30),
    ),
    elevation: 8,
  ),
  child: Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Text(
        '확인',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w700,
        ),
      ),
      SizedBox(width: 8),
      Icon(LucideIcons.arrowRight, size: 20),
    ],
  ),
).animate()
 .fadeIn(delay: 900.ms, duration: 500.ms)
 .slideY(begin: 0.2, end: 0)
```

### 6.9 재시도 버튼 (실패)

```dart
ElevatedButton(
  onPressed: () {
    onRetry?.call();
    Navigator.of(context).pop();
  },
  style: ElevatedButton.styleFrom(
    backgroundColor: Colors.white,
    foregroundColor: Color(0xFFFF5D5C),  // AppColors.red
    padding: EdgeInsets.symmetric(horizontal: 48, vertical: 16),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(30),
    ),
    elevation: 8,
  ),
  child: Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(LucideIcons.refreshCw, size: 20),
      SizedBox(width: 8),
      Text(
        '다시 시도',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w700,
        ),
      ),
    ],
  ),
).animate()
 .fadeIn(delay: 700.ms, duration: 500.ms)
 .slideY(begin: 0.2, end: 0)
```

---

## 7. 로그인 화면 (Login Screen)

### 7.1 파일 정보
- **파일 경로**: `lib/features/auth/presentation/pages/login_page.dart` (페이지)
- **폼 위젯**: `lib/features/auth/presentation/widgets/login_form.dart` (실제 폼)
- **클래스**: `LoginForm extends ConsumerStatefulWidget`
- **Props**: `final bool isDialog` (다이얼로그 모드 여부)

### 7.2 로컬 상태
```dart
final _formKey = GlobalKey<FormState>();
final _emailController = TextEditingController();
final _passwordController = TextEditingController();
bool _isPasswordVisible = false;

@override
void dispose() {
  _emailController.dispose();
  _passwordController.dispose();
  super.dispose();
}
```

### 7.3 Provider 사용
```dart
final authState = ref.watch(authProvider);
await ref.read(authProvider.notifier).signIn(email, password);
```

### 7.4 위젯 계층 구조

```dart
Form(
  key: _formKey,
  child: Column(
    mainAxisSize: isDialog ? MainAxisSize.min : MainAxisSize.max,
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      // 헤더 (LOGIN 제목 + X 버튼)
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('LOGIN'),
          IconButton(icon: Icon(Icons.close), onPressed: _handleClose),
        ],
      ),
      SizedBox(height: 24),

      // 이메일 입력 필드
      Text('Email'),
      SizedBox(height: 8),
      TextFormField(...),
      SizedBox(height: 16),

      // 비밀번호 입력 필드
      Text('Password'),
      SizedBox(height: 8),
      TextFormField(...),
      SizedBox(height: 24),

      // 로그인 버튼 또는 로딩
      authState.isLoading ? CircularProgressIndicator() : ElevatedButton(...),

      // 에러 메시지 (조건부)
      if (authState.hasError) Container(...),

      SizedBox(height: 24),

      // Google 로그인 버튼
      OutlinedButton.icon(...),

      SizedBox(height: 24),

      // 하단 링크 (회원가입, 비밀번호 찾기)
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TextButton('Sign Up'),
          Container(width: 1, height: 12, color: Colors.grey[300]),
          TextButton('Forgot password?'),
        ],
      ),
    ],
  ),
)
```

### 7.5 헤더

```dart
Row(
  mainAxisAlignment: MainAxisAlignment.spaceBetween,
  children: [
    Text(
      'LOGIN',
      style: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.2,
        color: Color(0xFF081245),  // AppColors.darkBlue
      ),
    ),
    IconButton(
      onPressed: _handleClose,
      icon: Icon(Icons.close, size: 20, color: Color(0xFF081245)),
      padding: EdgeInsets.zero,
      constraints: BoxConstraints(),
    ),
  ],
)
```

### 7.6 이메일 입력 필드

**레이블**:
```dart
Text(
  'Email',
  style: TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: Color(0xFF081245),  // AppColors.darkBlue
  ),
)
```

**TextFormField**:
```dart
TextFormField(
  controller: _emailController,
  keyboardType: TextInputType.emailAddress,
  decoration: InputDecoration(
    hintText: 'Enter email',
    hintStyle: TextStyle(
      color: Color(0xFFBDBDBD),  // Colors.grey[400]
      fontSize: 14,
    ),
    filled: true,
    fillColor: Color(0xFFFAFAFA),  // Colors.grey[50]
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(color: Color(0xFFE0E0E0)),  // Colors.grey[300]
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(color: Color(0xFFE0E0E0)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(color: Color(0xFF4F46E5)),  // 보라색
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(color: Colors.red),
    ),
    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
  ),
  validator: (value) {
    if (value == null || value.isEmpty) {
      return 'Email is not valid';
    }
    if (!value.contains('@')) {
      return 'Email is not valid';
    }
    return null;
  },
)
```

### 7.7 비밀번호 입력 필드

```dart
TextFormField(
  controller: _passwordController,
  obscureText: !_isPasswordVisible,
  decoration: InputDecoration(
    hintText: '••••••••••••',
    hintStyle: TextStyle(color: Color(0xFFBDBDBD), fontSize: 14),
    filled: true,
    fillColor: Color(0xFFFAFAFA),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(color: Color(0xFFE0E0E0)),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(color: Color(0xFFE0E0E0)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(color: Color(0xFF4F46E5)),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(color: Colors.red),
    ),
    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    suffixIcon: IconButton(
      icon: Icon(
        _isPasswordVisible
            ? Icons.visibility_outlined
            : Icons.visibility_off_outlined,
        color: Color(0xFF757575),  // Colors.grey[600]
        size: 20,
      ),
      onPressed: () {
        setState(() {
          _isPasswordVisible = !_isPasswordVisible;
        });
      },
    ),
  ),
  validator: (value) {
    if (value == null || value.isEmpty) {
      return 'Password is not valid';
    }
    return null;
  },
)
```

### 7.8 로그인 버튼

**로딩 중**:
```dart
Center(
  child: SizedBox(
    height: 48,
    child: Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4F46E5)),
      ),
    ),
  ),
)
```

**일반 상태**:
```dart
SizedBox(
  height: 48,
  child: ElevatedButton(
    onPressed: _handleLogin,
    style: ElevatedButton.styleFrom(
      backgroundColor: Color(0xFF4F46E5),  // 보라색
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      elevation: 0,
    ),
    child: Text(
      'Login',
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
    ),
  ),
)
```

### 7.9 에러 메시지

```dart
if (authState.hasError) Container(
  padding: EdgeInsets.all(12),
  decoration: BoxDecoration(
    color: Colors.red.shade50,     // #FFEBEE
    borderRadius: BorderRadius.circular(8),
    border: Border.all(color: Colors.red.shade200),  // #FFCDD2
  ),
  child: Row(
    children: [
      Icon(
        Icons.error_outline,
        color: Colors.red.shade700,  // #C62828
        size: 20,
      ),
      SizedBox(width: 8),
      Expanded(
        child: Text(
          authState.error is AuthException
              ? (authState.error as AuthException).message
              : 'Login failed. Please check your credentials.',
          style: TextStyle(
            color: Colors.red.shade700,
            fontSize: 13,
          ),
        ),
      ),
    ],
  ),
)
```

### 7.10 Google 로그인 버튼

```dart
SizedBox(
  height: 48,
  child: OutlinedButton.icon(
    onPressed: () {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Google login coming soon')),
      );
    },
    icon: Image.network(
      'https://www.google.com/favicon.ico',
      width: 20,
      height: 20,
    ),
    label: Text(
      'Login with Google',
      style: TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w500,
        color: Colors.black87,
      ),
    ),
    style: OutlinedButton.styleFrom(
      side: BorderSide(color: Color(0xFFE0E0E0)),  // Colors.grey[300]
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    ),
  ),
)
```

### 7.11 하단 링크

```dart
Row(
  mainAxisAlignment: MainAxisAlignment.center,
  children: [
    TextButton(
      onPressed: () {
        if (widget.isDialog) Navigator.of(context).pop();
        Future.microtask(() {
          if (mounted) context.push('/signup');
        });
      },
      child: Text(
        'Sign Up',
        style: TextStyle(
          fontSize: 14,
          color: Color(0xFF4F46E5),
          fontWeight: FontWeight.w500,
        ),
      ),
    ),
    Container(
      width: 1,
      height: 12,
      color: Color(0xFFE0E0E0),  // Colors.grey[300]
    ),
    TextButton(
      onPressed: () {
        if (widget.isDialog) Navigator.of(context).pop();
        Future.microtask(() {
          if (mounted) context.push('/forgot-password');
        });
      },
      child: Text(
        'Forgot password?',
        style: TextStyle(
          fontSize: 14,
          color: Colors.grey,
          fontWeight: FontWeight.w500,
        ),
      ),
    ),
  ],
)
```

---

## 8. 회원가입 화면 (Signup Screen)

### 8.1 파일 정보
- **파일 경로**: `lib/features/auth/presentation/widgets/signup_form.dart`
- **클래스**: `SignupForm extends ConsumerStatefulWidget`
- **Props**: `final bool isDialog`

### 8.2 회원가입 단계 (3단계)
```dart
enum SignUpStep {
  email,       // 1단계: 이메일 입력 및 인증 코드 발송
  verifyCode,  // 2단계: 인증 코드 확인
  userInfo,    // 3단계: 비밀번호 및 닉네임 입력
}
```

### 8.3 로컬 상태
```dart
final _formKey = GlobalKey<FormState>();
final _emailController = TextEditingController();
final _codeController = TextEditingController();
final _nicknameController = TextEditingController();
final _passwordController = TextEditingController();
final _confirmPasswordController = TextEditingController();

bool _isPasswordVisible = false;
bool _isConfirmPasswordVisible = false;
bool _isLoading = false;
String? _errorMessage;

SignUpStep _currentStep = SignUpStep.email;
```

### 8.4 위젯 계층 구조

```dart
Form(
  key: _formKey,
  child: Column(
    mainAxisSize: isDialog ? MainAxisSize.min : MainAxisSize.max,
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      // 헤더 (뒤로가기 + Sign Up 제목 + X 버튼)
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              if (_currentStep != SignUpStep.email) IconButton(arrow_back),
              SizedBox(width: 12),
              Text('Sign Up'),
            ],
          ),
          IconButton(icon: Icons.close, onPressed: _handleClose),
        ],
      ),
      SizedBox(height: 8),

      // 단계 표시
      _buildStepIndicator(),  // 1 ━━━ 2 ━━━ 3
      SizedBox(height: 24),

      // 단계별 콘텐츠
      if (_currentStep == SignUpStep.email) _buildEmailStep(),
      if (_currentStep == SignUpStep.verifyCode) _buildVerifyCodeStep(),
      if (_currentStep == SignUpStep.userInfo) _buildUserInfoStep(),

      // 에러 메시지 (조건부)
      if (_errorMessage != null) Container(...),

      SizedBox(height: 24),

      // 하단 링크 (이미 계정이 있으신가요?)
      Row(...),
    ],
  ),
)
```

### 8.5 헤더

```dart
Row(
  mainAxisAlignment: MainAxisAlignment.spaceBetween,
  children: [
    Row(
      children: [
        if (_currentStep != SignUpStep.email) ...[
          IconButton(
            onPressed: _handleBack,
            icon: Icon(Icons.arrow_back, size: 20),
            padding: EdgeInsets.zero,
            constraints: BoxConstraints(),
          ),
          SizedBox(width: 12),
        ],
        Text(
          'Sign Up',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
            color: Color(0xFF081245),  // AppColors.darkBlue
          ),
        ),
      ],
    ),
    IconButton(
      onPressed: _handleClose,
      icon: Icon(Icons.close, size: 20),
      padding: EdgeInsets.zero,
      constraints: BoxConstraints(),
    ),
  ],
)
```

### 8.6 단계 표시기 (_buildStepIndicator)

```dart
Row(
  children: [
    _buildStepDot(1, _currentStep.index >= SignUpStep.email.index),
    Expanded(child: _buildStepLine(_currentStep.index >= SignUpStep.verifyCode.index)),
    _buildStepDot(2, _currentStep.index >= SignUpStep.verifyCode.index),
    Expanded(child: _buildStepLine(_currentStep.index >= SignUpStep.userInfo.index)),
    _buildStepDot(3, _currentStep.index >= SignUpStep.userInfo.index),
  ],
)
```

**단계 점 (_buildStepDot)**:
```dart
Container(
  width: 32,
  height: 32,
  decoration: BoxDecoration(
    shape: BoxShape.circle,
    color: isActive
        ? Color(0xFF4F46E5)      // 활성: 보라색
        : Color(0xFFE0E0E0),     // 비활성: 회색
  ),
  child: Center(
    child: Text(
      '$step',
      style: TextStyle(
        color: isActive ? Colors.white : Color(0xFF757575),
        fontWeight: FontWeight.w700,
        fontSize: 14,
      ),
    ),
  ),
)
```

**단계 선 (_buildStepLine)**:
```dart
Container(
  height: 2,
  color: isActive
      ? Color(0xFF4F46E5)      // 활성: 보라색
      : Color(0xFFE0E0E0),     // 비활성: 회색
)
```

### 8.7 1단계: 이메일 입력 (_buildEmailStep)

```dart
Column(
  crossAxisAlignment: CrossAxisAlignment.stretch,
  children: [
    Text(
      'Enter your email address',
      style: TextStyle(
        fontSize: 12,
        color: Color(0xFF757575),  // Colors.grey[600]
      ),
    ),
    SizedBox(height: 16),
    Text('Email', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
    SizedBox(height: 8),
    TextFormField(
      controller: _emailController,
      keyboardType: TextInputType.emailAddress,
      decoration: InputDecoration(
        hintText: 'Enter email',
        hintStyle: TextStyle(color: Color(0xFFBDBDBD), fontSize: 14),
        filled: true,
        fillColor: Color(0xFFFAFAFA),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Color(0xFFE0E0E0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Color(0xFF4F46E5)),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      validator: (value) {
        if (value == null || value.isEmpty || !value.contains('@')) {
          return 'Enter a valid email';
        }
        return null;
      },
    ),
    SizedBox(height: 24),
    _isLoading
        ? Center(child: CircularProgressIndicator())
        : SizedBox(
            height: 48,
            child: ElevatedButton(
              onPressed: _handleSendCode,
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF4F46E5),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 0,
              ),
              child: Text(
                'Send Verification Code',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ),
  ],
)
```

### 8.8 2단계: 인증 코드 확인 (_buildVerifyCodeStep)

```dart
Column(
  crossAxisAlignment: CrossAxisAlignment.stretch,
  children: [
    Text(
      'Enter the verification code sent to ${_emailController.text}',
      style: TextStyle(fontSize: 12, color: Color(0xFF757575)),
    ),
    SizedBox(height: 16),
    Text('Verification Code', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
    SizedBox(height: 8),
    TextFormField(
      controller: _codeController,
      keyboardType: TextInputType.number,
      maxLength: 6,
      decoration: InputDecoration(
        hintText: 'Enter 6-digit code',
        hintStyle: TextStyle(color: Color(0xFFBDBDBD), fontSize: 14),
        filled: true,
        fillColor: Color(0xFFFAFAFA),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Color(0xFFE0E0E0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Color(0xFF4F46E5)),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Enter verification code';
        }
        return null;
      },
    ),
    SizedBox(height: 8),
    TextButton(
      onPressed: _handleSendCode,
      child: Text(
        'Resend Code',
        style: TextStyle(
          fontSize: 13,
          color: Color(0xFF4F46E5),
          fontWeight: FontWeight.w500,
        ),
      ),
    ),
    SizedBox(height: 16),
    _isLoading
        ? Center(child: CircularProgressIndicator())
        : SizedBox(
            height: 48,
            child: ElevatedButton(
              onPressed: _handleVerifyCode,
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF4F46E5),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 0,
              ),
              child: Text(
                'Verify Code',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ),
  ],
)
```

### 8.9 3단계: 사용자 정보 입력 (_buildUserInfoStep)

```dart
Column(
  crossAxisAlignment: CrossAxisAlignment.stretch,
  children: [
    Text(
      'Complete your profile',
      style: TextStyle(fontSize: 12, color: Color(0xFF757575)),
    ),
    SizedBox(height: 16),

    // 닉네임
    Text('Nickname', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
    SizedBox(height: 8),
    TextFormField(
      controller: _nicknameController,
      decoration: InputDecoration(...),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Enter a nickname';
        }
        return null;
      },
    ),
    SizedBox(height: 16),

    // 비밀번호
    Text('Password', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
    SizedBox(height: 8),
    TextFormField(
      controller: _passwordController,
      obscureText: !_isPasswordVisible,
      decoration: InputDecoration(
        hintText: '••••••••••••',
        suffixIcon: IconButton(
          icon: Icon(
            _isPasswordVisible
                ? Icons.visibility_outlined
                : Icons.visibility_off_outlined,
            size: 20,
          ),
          onPressed: () {
            setState(() {
              _isPasswordVisible = !_isPasswordVisible;
            });
          },
        ),
        ...
      ),
      validator: (value) {
        if (value == null || value.length < 6) {
          return 'Password must be at least 6 characters';
        }
        return null;
      },
    ),
    SizedBox(height: 16),

    // 비밀번호 확인
    Text('Confirm Password', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
    SizedBox(height: 8),
    TextFormField(
      controller: _confirmPasswordController,
      obscureText: !_isConfirmPasswordVisible,
      decoration: InputDecoration(
        hintText: 'Confirm Password',
        suffixIcon: IconButton(
          icon: Icon(
            _isConfirmPasswordVisible
                ? Icons.visibility_outlined
                : Icons.visibility_off_outlined,
            size: 20,
          ),
          onPressed: () {
            setState(() {
              _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
            });
          },
        ),
        ...
      ),
      validator: (value) {
        if (value != _passwordController.text) {
          return 'Passwords do not match';
        }
        return null;
      },
    ),
    SizedBox(height: 24),

    // 회원가입 버튼
    _isLoading
        ? Center(child: CircularProgressIndicator())
        : SizedBox(
            height: 48,
            child: ElevatedButton(
              onPressed: _handleSignup,
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF4F46E5),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 0,
              ),
              child: Text(
                'Sign Up',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ),
  ],
)
```

### 8.10 에러 메시지

```dart
if (_errorMessage != null) Container(
  padding: EdgeInsets.all(12),
  decoration: BoxDecoration(
    color: Colors.red.shade50,
    borderRadius: BorderRadius.circular(8),
    border: Border.all(color: Colors.red.shade200),
  ),
  child: Row(
    children: [
      Icon(Icons.error_outline, color: Colors.red.shade700, size: 20),
      SizedBox(width: 8),
      Expanded(
        child: Text(
          _errorMessage!,
          style: TextStyle(
            color: Colors.red.shade700,
            fontSize: 13,
          ),
        ),
      ),
    ],
  ),
)
```

### 8.11 하단 링크

```dart
Row(
  mainAxisAlignment: MainAxisAlignment.center,
  children: [
    Text(
      'Already have an account?',
      style: TextStyle(
        fontSize: 13,
        color: Color(0xFF757575),  // Colors.grey[600]
      ),
    ),
    TextButton(
      onPressed: () {
        if (widget.isDialog) {
          Navigator.of(context).pop();
        } else {
          context.go('/login');
        }
      },
      style: TextButton.styleFrom(
        padding: EdgeInsets.symmetric(horizontal: 8),
      ),
      child: Text(
        'Sign in',
        style: TextStyle(
          fontSize: 13,
          color: Color(0xFF4F46E5),
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
  ],
)
```

---

## 9. 마이페이지 (My Screen)

### 9.1 파일 정보
- **파일 경로**: `lib/features/my/my_screen.dart`
- **클래스**: `MyScreen extends ConsumerWidget`

### 9.2 Provider 사용
```dart
final authState = ref.watch(authProvider);
final user = authState.valueOrNull?.user;
final wallet = ref.watch(userWalletProvider);
final recentTransactions = ref.watch(recentTransactionsProvider);
```

### 9.3 위젯 계층 구조

```dart
CustomScrollView(
  slivers: [
    // 총 자산 영역
    SliverToBoxAdapter(child: _buildTotalAssets(context, user)),

    // 주요 액션 버튼 (충전, 환불, 내역)
    SliverToBoxAdapter(child: _buildActionButtons(context)),

    // 캐시 배분 섹션
    SliverToBoxAdapter(child: _buildCashAllocation(context, wallet)),

    // 활동 내역 섹션
    SliverToBoxAdapter(child: _buildActivitySection(context)),

    // 최근 거래 내역 헤더
    SliverToBoxAdapter(child: Row('최근 거래 내역', '전체보기')),

    // 거래 내역 리스트
    SliverPadding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            return TransactionListItem(
              transaction: recentTransactions[index],
            );
          },
          childCount: recentTransactions.length,
        ),
      ),
    ),

    // 하단 여백
    SliverToBoxAdapter(child: SizedBox(height: 48)),
  ],
)
```

### 9.4 총 자산 영역 (_buildTotalAssets)

```dart
Container(
  margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
  padding: EdgeInsets.all(24),
  decoration: BoxDecoration(
    color: AppColors.white,                      // #FFFFFF
    borderRadius: BorderRadius.circular(12),
    border: Border.all(color: AppColors.buleGray, width: 1),  // #DADBE3
    boxShadow: [
      BoxShadow(
        color: AppColors.black.withOpacity(0.05),  // #111111 5%
        blurRadius: 10,
        offset: Offset(0, 2),
      ),
    ],
  ),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        '총 보유 캐시',
        style: TextStyle(
          fontSize: 14,
          color: Color(0xFF8A91B0),  // AppColors.grayBlue
        ),
      ),
      SizedBox(height: 12),
      Row(
        children: [
          Text(
            '₩${NumberFormat('#,###').format(totalCash)}',
            style: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.w700,
              color: Color(0xFF081245),  // AppColors.darkBlue
            ),
          ),
        ],
      ),
    ],
  ),
)
```

### 9.5 액션 버튼 (_buildActionButtons)

```dart
Padding(
  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
  child: Row(
    children: [
      Expanded(
        child: _ActionButton(
          icon: Icons.add_card,
          label: '충전',
          onPressed: () { /* TODO: 충전 페이지 */ },
        ),
      ),
      SizedBox(width: 12),
      Expanded(
        child: _ActionButton(
          icon: Icons.account_balance_wallet_outlined,
          label: '환불',
          onPressed: () { /* TODO: 환불 페이지 */ },
        ),
      ),
      SizedBox(width: 12),
      Expanded(
        child: _ActionButton(
          icon: Icons.history,
          label: '내역',
          onPressed: () { /* TODO: 거래 내역 페이지 */ },
        ),
      ),
    ],
  ),
)
```

**_ActionButton 컴포넌트**:
```dart
Material(
  color: AppColors.white,  // #FFFFFF
  borderRadius: BorderRadius.circular(8),
  elevation: 0,
  child: InkWell(
    onTap: onPressed,
    borderRadius: BorderRadius.circular(8),
    child: Container(
      padding: EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.buleGray, width: 1),  // #DADBE3
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            size: 28,
            color: AppColors.primary,  // #5C72F5
          ),
          SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Color(0xFF081245),  // AppColors.darkBlue
            ),
          ),
        ],
      ),
    ),
  ),
)
```

### 9.6 캐시 배분 섹션 (_buildCashAllocation)

```dart
Padding(
  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        '내 캐시 잔액',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Color(0xFF081245),  // AppColors.darkBlue
        ),
      ),
      SizedBox(height: 12),
      Row(
        children: [
          Expanded(
            child: CashAllocationCard(
              icon: Icons.videogame_asset,
              title: '이벤트 캐시',
              amount: wallet.eventCash,
              status: '사용 가능',
              isRefundable: true,
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: CashAllocationCard(
              icon: Icons.shopping_bag_outlined,
              title: '쇼핑 캐시',
              amount: wallet.shoppingCash,
              status: '사용 가능',
              isRefundable: true,
            ),
          ),
        ],
      ),
    ],
  ),
)
```

**CashAllocationCard 컴포넌트** (별도 파일):
```dart
Container(
  padding: EdgeInsets.all(16),
  decoration: BoxDecoration(
    color: AppColors.white,
    border: Border.all(color: AppColors.buleGray, width: 1),
    borderRadius: BorderRadius.circular(8),
  ),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Icon(icon, size: 24, color: AppColors.primary),
      SizedBox(height: 12),
      Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: AppColors.darkBlue,
        ),
      ),
      SizedBox(height: 8),
      Text(
        '₩${NumberFormat('#,###').format(amount)}',
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: AppColors.darkBlue,
        ),
      ),
      SizedBox(height: 4),
      Text(
        status,
        style: TextStyle(
          fontSize: 12,
          color: isRefundable ? AppColors.green : AppColors.medium,
        ),
      ),
    ],
  ),
)
```

### 9.7 활동 내역 섹션 (_buildActivitySection)

```dart
Padding(
  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
  child: Column(
    children: [
      _ActivityCard(
        icon: Icons.videogame_asset,
        title: '게임 참가 내역',
        subtitle: '진행 중: 2건 • 완료: 15건',
        onTap: () { /* TODO: 게임 참가 내역 페이지 */ },
      ),
      SizedBox(height: 12),
      _ActivityCard(
        icon: Icons.shopping_bag_outlined,
        title: '쇼핑 주문 내역',
        subtitle: '최근 주문: 3건',
        onTap: () { /* TODO: 쇼핑 주문 내역 페이지 */ },
      ),
    ],
  ),
)
```

**_ActivityCard 컴포넌트**:
```dart
Material(
  color: AppColors.white,
  borderRadius: BorderRadius.circular(8),
  elevation: 0,
  child: InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(8),
    child: Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.buleGray, width: 1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.blueWhite,  // #ECF1F9
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(icon, size: 24, color: AppColors.primary),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.darkBlue,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.navy,  // #2D3661
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.chevron_right,
            color: AppColors.grayBlue,  // #8A91B0
            size: 20,
          ),
        ],
      ),
    ),
  ),
)
```

---

## 10. 공통 컴포넌트

### 10.1 GameCard

**파일**: `lib/widgets/game_card.dart`

```dart
GestureDetector(
  onTap: onTap,
  child: Container(
    decoration: BoxDecoration(
      color: AppColors.white,              // #FFFFFF
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: AppColors.buleGray),  // #DADBE3
      boxShadow: [
        BoxShadow(
          color: AppColors.black.withOpacity(0.05),
          blurRadius: 10,
          offset: Offset(0, 4),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 이미지 섹션
        Stack(
          children: [
            // 제품 이미지 (16:9 비율)
            ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: game.imageUrl.isEmpty
                    ? Container(
                        color: AppColors.blueWhite,  // #ECF1F9
                        child: Center(
                          child: Icon(
                            LucideIcons.image,
                            size: 48,
                            color: AppColors.buleGray,
                          ),
                        ),
                      )
                    : Image.network(
                        game.imageUrl.replaceAll(' ', '%20'),
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(
                            color: AppColors.blueWhite,
                            child: Center(
                              child: CircularProgressIndicator(
                                value: loadingProgress.expectedTotalBytes != null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                        loadingProgress.expectedTotalBytes!
                                    : null,
                                valueColor: AlwaysStoppedAnimation<Color>(AppColors.blue),
                              ),
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: AppColors.blueWhite,
                            child: Center(
                              child: Icon(
                                LucideIcons.image,
                                size: 48,
                                color: AppColors.buleGray,
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ),

            // 상태 배지 (좌상단)
            Positioned(
              top: 12,
              left: 12,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _getStatusColor(),  // Active: green, Drawing: purple, Ended: medium
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _getStatusText(),  // 'Active', 'Drawing', 'Ended'
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: AppColors.white,
                  ),
                ),
              ),
            ),

            // 타입 배지 (우상단)
            Positioned(
              top: 12,
              right: 12,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: _getTypeColor()),
                ),
                child: Text(
                  _getTypeText(),  // 'Daily', 'Select', 'Vibe'
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: _getTypeColor(),
                  ),
                ),
              ),
            ),
          ],
        ),

        // 정보 섹션
        Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 제목
              Text(
                game.title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.darkBlue,  // #081245
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 12),

              // 통계
              Column(
                children: [
                  _buildStatRow(LucideIcons.users, 'Participants', '${game.participants}명'),
                  SizedBox(height: 8),
                  _buildStatRow(LucideIcons.grid, 'Blocks', _formatNumber(game.totalBlocks)),
                  SizedBox(height: 8),
                  _buildStatRow(LucideIcons.target, 'Required Picks', '${game.requiredPicks}'),
                  SizedBox(height: 8),
                  _buildStatRow(LucideIcons.trophy, 'Winners', '${game.winners}명'),
                ],
              ),
              SizedBox(height: 12),

              // 가격 및 시간
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // 가격
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (game.originalPrice != game.currentPrice)
                        Text(
                          '₩${_formatNumber(game.originalPrice)}',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.medium,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                      Text(
                        '₩${_formatNumber(game.currentPrice)}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.blue,  // #5C72F5
                        ),
                      ),
                    ],
                  ),

                  // 남은 시간
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.blueWhite,  // #ECF1F9
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(LucideIcons.clock, size: 14, color: AppColors.red),
                        SizedBox(width: 4),
                        Text(
                          game.timeLeft,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: AppColors.darkBlue,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    ),
  ),
)
```

**_buildStatRow**:
```dart
Row(
  children: [
    Icon(icon, size: 16, color: AppColors.medium),  // #555555
    SizedBox(width: 8),
    Expanded(
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          color: AppColors.medium,
        ),
      ),
    ),
    Text(
      value,
      style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: AppColors.darkBlue,
      ),
    ),
  ],
)
```

**색상 헬퍼 함수**:
```dart
Color _getStatusColor() {
  switch (game.status) {
    case GameStatus.active:
      return AppColors.green;   // #10B981
    case GameStatus.drawing:
      return AppColors.purple;  // #6E5AE9
    case GameStatus.ended:
      return AppColors.medium;  // #555555
  }
}

String _getStatusText() {
  switch (game.status) {
    case GameStatus.active: return 'Active';
    case GameStatus.drawing: return 'Drawing';
    case GameStatus.ended: return 'Ended';
  }
}

Color _getTypeColor() {
  switch (game.type) {
    case GameType.daily:
      return AppColors.pink;    // #FF58BB
    case GameType.select:
      return AppColors.purple;  // #6E5AE9
    case GameType.vibe:
      return AppColors.blue;    // #5C72F5
  }
}

String _getTypeText() {
  switch (game.type) {
    case GameType.daily: return 'Daily';
    case GameType.select: return 'Select';
    case GameType.vibe: return 'Vibe';
  }
}

String _formatNumber(int number) {
  if (number >= 1000000) {
    return '${(number / 1000000).toStringAsFixed(1)}M';
  } else if (number >= 1000) {
    return '${(number / 1000).toStringAsFixed(0)}K';
  }
  return number.toString();
}
```

---

## 11. 디자인 시스템

### 11.1 색상 팔레트 (AppColors)

**파일**: `lib/core/theme/app_colors.dart`

#### Main Colors
| 이름 | HEX | 용도 |
|------|-----|------|
| blue | `#5C72F5` | Primary CTA, 버튼, 하이라이트 |
| purple | `#6E5AE9` | 보조 액센트, 그라데이션 |
| pink | `#FF58BB` | 알림, 주요 콘텐츠 |
| red | `#FF5D5C` | 삭제 액션, 오류 |
| green | `#10B981` | 성공, 활성 상태 |
| yellow | `#F59E0B` | 경고, 시간 제한 |
| white | `#FFFFFF` | 배경, 텍스트 |

#### Background Colors
| 이름 | HEX | 용도 |
|------|-----|------|
| deepWhite | `#FCFCFC` | 기본 배경 |
| blueWhite | `#ECF1F9` | 보조 배경, 호버 |
| bgWhite | `#EFF2F7` | 카드 배경, 테두리 |
| whiteGray | `#FCFCFC` | 대체 배경 |
| disable | `#DEDEDE` | 비활성 상태 |

#### Text Colors
| 이름 | HEX | 용도 |
|------|-----|------|
| darkBlue | `#081245` | 주요 텍스트 (H1, 헤드라인) |
| navy | `#2D3661` | 보조 텍스트 (본문) |
| navyWhite | `#4B547F` | 삼차 텍스트 |
| grayBlue | `#8A91B0` | 힌트 텍스트 |
| medium | `#555555` | 일반 텍스트 |
| light | `#999999` | 4차 텍스트 (힌트) |
| hint | `#C5C9DC` | 비활성 텍스트 |
| black | `#111111` | 검정 |
| dark | `#333333` | 어두운 텍스트 |
| darker | `#1A1A1A` | 매우 어두운 배경 |

#### Stroke Colors
| 이름 | HEX | 용도 |
|------|-----|------|
| buleGray | `#DADBE3` | 기본 border |
| navyStroke | `#2A3547` | 강조 border |

#### Gray Scale
| 이름 | HEX |
|------|-----|
| gray50 | `#FAFAFA` |
| gray100 | `#F5F5F5` |
| gray200 | `#EEEEEE` |
| gray300 | `#E0E0E0` |
| gray400 | `#BDBDBD` |
| gray500 | `#9E9E9E` |
| gray600 | `#757575` |
| gray700 | `#616161` |
| gray800 | `#424242` |
| gray900 | `#212121` |

#### Gradients
```dart
// Blue Gradient
LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [Color(0xFF3D81F6), Color(0xFF875DF4)],  // #3D81F6 → #875DF4
)

// Pink Gradient
LinearGradient(
  begin: Alignment(0.0, -1.0),
  end: Alignment(0.0, 1.0),
  stops: [0.06, 1.0],
  colors: [Color(0xFFFF58BB), Color(0xFFFF5D5C)],  // #FF58BB → #FF5D5C
)

// Purple Gradient
LinearGradient(
  begin: Alignment(-0.5, -1.0),
  end: Alignment(0.5, 1.0),
  colors: [Color(0xFFE33FF4), Color(0xFF6E5AE9)],  // #E33FF4 → #6E5AE9
)

// Light Gradient
LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  stops: [0.04, 1.0],
  colors: [Color(0xFFEFF6FF), Color(0xFFF9F5FF)],  // #EFF6FF → #F9F5FF
)

// Blue-Purple-Pink Gradient (for buttons)
LinearGradient(
  begin: Alignment.centerLeft,
  end: Alignment.centerRight,
  colors: [blue, purple, pink],  // #5C72F5 → #6E5AE9 → #FF58BB
)
```

### 11.2 텍스트 스타일 (AppTextStyles)

**파일**: `lib/core/theme/app_text_styles.dart`

| 스타일 | 크기 | 두께 | Line Height | 용도 |
|--------|------|------|-------------|------|
| display | 32px | 700 (Bold) | 1.2 | Display / H1 |
| large | 24px | 700 (Bold) | 1.3 | Large / H2 |
| medium | 18px | 600 (SemiBold) | 1.4 | Medium / H3 |
| bodyLarge | 16px | 500 (Medium) | 1.5 | 큰 본문 |
| body | 14px | 400 (Normal) | 1.5 | 본문 |
| bodySmall | 12px | 400 (Normal) | 1.4 | 작은 본문 |
| caption | 10px | 400 (Normal) | 1.4 | 캡션 |
| button | 14px | 600 (SemiBold) | 1.2 | 버튼 텍스트 (letter-spacing: 0.2) |
| buttonLarge | 16px | 700 (Bold) | 1.2 | 큰 버튼 (letter-spacing: 0.3) |
| label | 12px | 500 (Medium) | 1.3 | 레이블 |
| hint | 14px | 400 (Normal) | 1.5 | 힌트 |

### 11.3 간격 (Spacing)

| 크기 | 값 | 용도 |
|------|-----|------|
| XXS | 4px | 최소 간격 |
| XS | 8px | 작은 간격 |
| S | 12px | 기본 내부 여백 |
| M | 16px | 카드 패딩, 화면 좌우 여백 |
| L | 24px | 섹션 간격 |
| XL | 32px | 큰 섹션 간격 |
| 2XL | 48px | 매우 큰 섹션 간격 |

### 11.4 Border Radius

| 크기 | 값 | 용도 |
|------|-----|------|
| Small | 4px | 작은 요소 |
| Medium | 8px | 버튼, 입력 필드 |
| Large | 12px | 카드 |
| XLarge | 16px | 큰 카드, 바텀시트 상단 |
| Full | 9999px | 원형 (아바타, 배지) |

### 11.5 Elevation (그림자)

```dart
// shadow-sm
BoxShadow(
  color: Colors.black.withOpacity(0.05),
  blurRadius: 4,
  offset: Offset(0, 1),
)

// shadow-md
BoxShadow(
  color: Colors.black.withOpacity(0.1),
  blurRadius: 8,
  offset: Offset(0, 2),
)

// shadow-lg
BoxShadow(
  color: Colors.black.withOpacity(0.15),
  blurRadius: 16,
  offset: Offset(0, 4),
)

// shadow-xl
BoxShadow(
  color: Colors.black.withOpacity(0.2),
  blurRadius: 24,
  offset: Offset(0, 8),
)
```

### 11.6 애니메이션 타이밍

| 애니메이션 | 지속 시간 | Curve | 용도 |
|-----------|----------|-------|------|
| 화면 전환 | 300ms | easeInOut | 페이지 이동 |
| 버튼 탭 | 150ms | easeOut | 버튼 피드백 |
| 바텀시트 드래그 | - | - | 실시간 추종 |
| 줌 애니메이션 | 300ms | easeInOut | 그리드 확대/축소 |
| 페이드 인 | 200ms | easeIn | 요소 나타남 |
| 페이드 아웃 | 200ms | easeOut | 요소 사라짐 |
| Shimmer | 1500ms | linear | 로딩 효과 |
| Shake | 500ms | easeInOut | 에러 피드백 |
| Scale (Elastic) | 600ms | elasticOut | 성공 아이콘 |

---

## 부록 A: 주요 Provider 목록

| Provider | 타입 | 용도 |
|----------|------|------|
| `authProvider` | AsyncNotifierProvider | 인증 상태 관리 |
| `isAuthenticatedProvider` | Provider<bool> | 로그인 여부 확인 |
| `gamesByTypeProvider(GameType)` | FutureProvider<List<GameRound>> | 게임 타입별 목록 |
| `sortedGamesProvider(List, String)` | Provider<List<GameRound>> | 정렬된 게임 목록 |
| `gridStateProvider(GridConfig)` | StateNotifierProvider | 그리드 상태 (선택 블록 등) |
| `gameParticipationProvider` | AsyncNotifierProvider | 게임 참가 프로세스 |
| `userWalletProvider` | FutureProvider | 사용자 지갑 정보 |
| `recentTransactionsProvider` | Provider<List> | 최근 거래 내역 |

---

## 부록 B: 주요 GraphQL Queries/Mutations

### Query: games
```graphql
query Games($type: GameType!) {
  games(type: $type) {
    id
    title
    imageUrl
    participants
    totalBlocks
    requiredPicks
    winners
    currentPrice
    originalPrice
    timeLeft
    status
    category
  }
}
```

### Mutation: joinGame
```graphql
mutation JoinGame(
  $gameId: ID!
  $selectedGameProductId: ID!
  $coordCiphertext: String!
  $walletAddressHash: String!
) {
  joinGame(
    gameId: $gameId
    selectedGameProductId: $selectedGameProductId
    coordCiphertext: $coordCiphertext
    walletAddressHash: $walletAddressHash
  ) {
    success
    entryId
    txHash
    message
  }
}
```

---

## 부록 C: 아이콘 목록

**Lucide Icons 사용**:
- `LucideIcons.chevronLeft` - 뒤로가기
- `LucideIcons.moreVertical` - 메뉴
- `LucideIcons.plus` - 줌 인
- `LucideIcons.minus` - 줌 아웃
- `LucideIcons.x` - 삭제, 닫기
- `LucideIcons.users` - 참가자
- `LucideIcons.grid` - 블록
- `LucideIcons.target` - 필수 Pick
- `LucideIcons.trophy` - 당첨자
- `LucideIcons.clock` - 남은 시간
- `LucideIcons.image` - 이미지 플레이스홀더
- `LucideIcons.checkCircle2` - 성공
- `LucideIcons.xCircle` - 실패
- `LucideIcons.hash` - Entry ID
- `LucideIcons.link` - 트랜잭션
- `LucideIcons.copy` - 복사
- `LucideIcons.arrowRight` - 화살표 우
- `LucideIcons.refreshCw` - 재시도
- `LucideIcons.inbox` - 빈 상태
- `LucideIcons.alertCircle` - 에러
- `LucideIcons.chevronDown` - 드롭다운
- `LucideIcons.cpu` - Digital 카테고리
- `LucideIcons.shirt` - Fashion 카테고리
- `LucideIcons.gift` - Gift 카테고리
- `LucideIcons.utensilsCrossed` - Food 카테고리

**Material Icons 사용**:
- `Icons.close` - 닫기
- `Icons.visibility_outlined` - 비밀번호 보기
- `Icons.visibility_off_outlined` - 비밀번호 숨기기
- `Icons.error_outline` - 에러
- `Icons.arrow_back` - 뒤로
- `Icons.rocket_launch_rounded` - 로켓 (로딩)
- `Icons.info_outline` - 정보
- `Icons.bolt` - 번개 (참가 버튼)
- `Icons.add_card` - 충전
- `Icons.account_balance_wallet_outlined` - 환불
- `Icons.history` - 내역
- `Icons.videogame_asset` - 게임
- `Icons.shopping_bag_outlined` - 쇼핑
- `Icons.chevron_right` - 화살표 우

---

**문서 버전**: 2.0.0 (소스코드 완전 분석판)
**마지막 업데이트**: 2025-11-05
**작성자**: Claude Code (Anthropic)
**총 페이지**: 100+ 상당

