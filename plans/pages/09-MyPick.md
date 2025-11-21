# 09-MyPick (참여 내역)

## 📋 페이지 정보

| 항목 | 내용 |
|------|------|
| **페이지 ID** | BP-09 |
| **페이지명** | MyPick (Game Participation History Screen) |
| **경로** | `/my-pick` |
| **파일** | `lib/features/my_pick/my_pick_screen.dart`, `lib/components/cards/my_pick_card.dart` |
| **우선순위** | **MEDIUM** (사용자 경험 향상) |
| **상태** | 🔄 **진행 중** |
| **진행률** | **70%** |
| **Story Points** | **25pt** |

---

## 🎯 페이지 목적

사용자가 **참여한 게임의 이력과 상태**를 확인하고 관리하는 **게임 참가 내역 페이지**입니다.

이 화면은 다음과 같은 주요 목적을 가집니다:
- **참가 이력 확인**: 참여한 모든 게임 목록 표시
- **게임 상태 추적**: Active(진행 중), Drawing(추첨 중), Won(당첨), Lost(미당첨) 상태 확인
- **선택 블록 확인**: 각 게임에서 선택한 블록 좌표 표시
- **게임 재진입**: 게임 상세 화면으로 빠르게 이동하여 그리드 확인

---

## 🖼️ 화면 구성

### 레이아웃

```
┌───────────────────────────────────────┐
│ [탭: ALL DAILY SELECT VIBE]           │ ← 탭 바
├───────────────────────────────────────┤
│                                       │
│ 1. 게임 카드 리스트                    │
│    ┌──────────────────────────────┐   │
│    │ [Active] [Daily]             │   │
│    │ ┌────────────┐               │   │
│    │ │   이미지   │               │   │
│    │ └────────────┘               │   │
│    │ iPhone 16 Pro Max            │   │ ← MyPick Card
│    │ Selected: 3 blocks           │   │
│    │ X5-Y10, X12-Y8, X20-Y15      │   │
│    │                              │   │
│    │ [View on Grid →]             │   │
│    └──────────────────────────────┘   │
│                                       │
│    ┌──────────────────────────────┐   │
│    │ [Drawing] [Select]           │   │
│    │ ┌────────────┐               │   │
│    │ │   이미지   │               │   │
│    │ └────────────┘               │   │
│    │ Gucci Bag                    │   │
│    │ Selected: 5 blocks           │   │
│    │ X3-Y7, X8-Y12, ...           │   │
│    │                              │   │
│    │ [View on Grid →]             │   │
│    └──────────────────────────────┘   │
│                                       │
│    ┌──────────────────────────────┐   │
│    │ [Won] [Vibe]                 │   │
│    │ ┌────────────┐               │   │
│    │ │   이미지   │               │   │
│    │ └────────────┘               │   │
│    │ AirPods Pro                  │   │
│    │ Selected: 2 blocks           │   │
│    │ X15-Y20, X18-Y22             │   │
│    │ 🎉 Congratulations!          │   │
│    │                              │   │
│    │ [View on Grid →]             │   │
│    └──────────────────────────────┘   │
│                                       │
│    (스크롤 가능)                       │
│                                       │
└───────────────────────────────────────┘
```

### UI 컴포넌트

#### 1. 탭 바 (Tab Bar)

- **위치**: 화면 최상단 (SafeArea 아래)
- **탭 목록**: ALL, DAILY, SELECT, VIBE
- **디자인**:
  - 흰색 배경 (#FFFFFF)
  - 선택된 탭: 파란색 텍스트 (#5C72F5) + 하단 파란색 인디케이터 (두께 3px)
  - 미선택 탭: 회색 텍스트 (#757575)
  - isScrollable: false (4개 탭 고정)
- **폰트**: Button (16px, Bold when selected)
- **인터랙션**: 탭 전환 시 부드러운 애니메이션

**탭별 필터링**:
| 탭 | 필터 | 설명 |
|----|------|------|
| ALL | null | 모든 게임 표시 |
| DAILY | GameType.daily | DAILY 게임만 표시 |
| SELECT | GameType.select | SELECT 게임만 표시 |
| VIBE | GameType.vibe | VIBE 게임만 표시 |

---

#### 2. MyPick 카드 (MyPickCard)

- **위치**: 탭 바 아래, 스크롤 가능 리스트
- **레이아웃**: ListView.builder
- **패딩**: 전체 16dp
- **카드 간격**: 12dp

**카드 디자인**:
- **배경**: 흰색 (#FFFFFF)
- **테두리**: 연한 회색 (#E0E0E0), 1px
- **모서리**: 둥근 모서리 (radius 16)
- **그림자**: 0 2px 8px rgba(0,0,0,0.05)
- **패딩**: 16dp
- **마진 하단**: 12dp

**카드 구성 요소**:

1. **헤더 (상단 배지)**:
   - 좌측: 상태 배지 (Active/Drawing/Won/Lost)
   - 우측: 타입 배지 (Daily/Select/Vibe)
   - 간격: 8dp

   **상태 배지**:
   - Active: 초록색 배경 (#10B981), 흰색 텍스트
   - Drawing: 보라색 배경 (#8B5CF6), 흰색 텍스트
   - Won: 골드 배경 (#F59E0B), 흰색 텍스트
   - Lost: 회색 배경 (#6B7280), 흰색 텍스트
   - 패딩: 좌우 12dp, 상하 6dp
   - 모서리: radius 20

   **타입 배지**:
   - Daily: 핑크색 (#EC4899)
   - Select: 보라색 (#8B5CF6)
   - Vibe: 파란색 (#5C72F5)
   - 배경: 반투명 흰색 (Opacity 0.9)
   - 테두리: 타입 색상
   - 패딩: 좌우 12dp, 상하 6dp
   - 모서리: radius 20

2. **게임 정보 섹션**:
   - **이미지**: AspectRatio 16:9
     - 둥근 모서리 (radius 12)
     - Image.asset (Mock 데이터)
     - 로딩/에러 처리
   - **제목**: 게임 이름 (16px, Bold, 네이비)
     - 최대 2줄, 말줄임표
   - **설명**: 게임 설명 (13px, 회색)
     - 최대 2줄, 말줄임표

3. **선택 블록 정보**:
   - **라벨**: "My Picks (X)" (14px, Bold, 네이비)
     - X = 선택한 블록 수
   - **블록 리스트**: Wrap 레이아웃
     - 각 블록: "X5-Y10" 형태
     - 배경: 연한 파란색 (#EBF5FF)
     - 테두리: 파란색 (#5C72F5), Opacity 0.3
     - 패딩: 좌우 12dp, 상하 6dp
     - 모서리: radius 8
     - 간격: 8dp (가로/세로)
     - 폰트: Body Small (12px, SemiBold, 파란색)

4. **당첨 메시지** (당첨 시만):
   - **텍스트**: "🎉 Congratulations! You won!"
   - **배경**: 연한 골드 (#FEF3C7)
   - **패딩**: 12dp
   - **모서리**: radius 8
   - **폰트**: Body (14px, Bold, 골드 #F59E0B)

5. **액션 버튼**:
   - **버튼**: "View on Grid →"
   - **배경**: 파란색 (#5C72F5)
   - **텍스트**: 흰색
   - **패딩**: 상하 12dp
   - **모서리**: radius 8
   - **폰트**: Button (14px, Bold)
   - **액션**: 게임 상세 화면으로 이동

---

#### 3. 빈 상태 (Empty State)

- **위치**: 화면 중앙
- **표시 조건**: 참가한 게임이 없을 때

**구성 요소**:
- **아이콘**: Icons.inbox_outlined
  - 크기: 80px
  - 색상: 회색 (#9CA3AF), Opacity 0.5
- **제목**: "No picks yet"
  - 폰트: Large (18px, SemiBold, 회색)
- **부제목**: "Start playing to see your picks here"
  - 폰트: Body (14px, 회색)

---

#### 4. 게임 상세 바텀시트 (Game Detail Bottom Sheet)

- **표시 조건**: 카드 터치 시
- **높이**: 화면의 70%
- **배경**: 흰색
- **모서리**: 상단 둥근 모서리 (radius 24)
- **애니메이션**: 하단에서 슬라이드 업

**구성 요소**:

1. **핸들 바**:
   - 너비: 40dp
   - 높이: 4dp
   - 색상: 회색 (#D1D5DB), Opacity 0.3
   - 모서리: radius 2
   - 여백: 상단 12dp, 하단 8dp

2. **상품 이미지**:
   - 비율: Expanded (flex 2)
   - 여백: 16dp
   - 모서리: radius 16
   - BoxFit: cover

3. **게임 정보 섹션** (Expanded flex 3):
   - **제목**: 게임 이름 (20px, Bold, 네이비)
   - **설명**: 게임 설명 (14px, 회색)
   - **간격**: 8dp

4. **내 픽 리스트**:
   - **헤더**: "My Picks (X)" (18px, Bold, 네이비)
   - **블록 Wrap**:
     - 각 블록: "X5-Y10"
     - 배경: 연한 파란색
     - 테두리: 파란색
     - 패딩: 좌우 12dp, 상하 6dp
     - 간격: 8dp

5. **액션 버튼**:
   - **버튼**: "View on Grid"
   - **배경**: 파란색 (#5C72F5)
   - **텍스트**: 흰색
   - **패딩**: 상하 16dp
   - **모서리**: radius 12
   - **폰트**: Button (16px, Bold)
   - **액션**:
     1. 바텀시트 닫기
     2. 게임 화면으로 네비게이션
     3. SnackBar 표시 (현재 Mock)

---

## ⚙️ 기능 요구사항

### 기능 1: 탭 기반 게임 타입 필터링

**설명**: 사용자가 ALL, DAILY, SELECT, VIBE 탭을 선택하여 게임 타입별로 참가 내역을 필터링합니다.

**기술 상세**:
- **TabController**: 4개 탭 관리
- **TabBarView**: 각 탭에 _buildGameList(GameType?) 호출
- **SingleTickerProviderStateMixin**: AnimationController 제공

**탭별 데이터**:
```dart
// ALL 탭
_buildGameList(null) → 모든 게임 표시

// DAILY 탭
_buildGameList(GameType.daily) → DAILY 게임만 필터링

// SELECT 탭
_buildGameList(GameType.select) → SELECT 게임만 필터링

// VIBE 탭
_buildGameList(GameType.vibe) → VIBE 게임만 필터링
```

**필터링 로직**:
```dart
final filteredGames = filter == null
    ? allGames
    : allGames.where((game) => game.type == filter).toList();
```

**완료 조건**:
- ✅ 탭 전환 시 부드러운 애니메이션
- ✅ 각 탭에 해당하는 게임만 표시
- ✅ 탭 인디케이터 색상 변경

---

### 기능 2: 참가 게임 목록 조회

**설명**: 사용자가 참가한 모든 게임을 조회하여 표시합니다.

**기술 상세**:
- **데이터 소스**: Mock 데이터 (현재)
  - MockGameData.dailyGames
  - MockGameData.selectGames
  - MockGameData.vibeGames
- **향후**: GraphQL Query
  ```graphql
  query GetMyParticipations {
    getMyParticipations {
      success
      participations {
        id
        game {
          id
          title
          description
          gameType
          status
          imageUrl
        }
        selectedBlocks {
          row
          col
        }
        status
        createdAt
      }
    }
  }
  ```

**현재 구현**:
- 모든 Mock 게임을 allGames 배열에 병합
- 탭 필터에 따라 필터링
- ListView.builder로 표시

**향후 구현**:
- myParticipationsProvider 생성
- GraphQL 쿼리 실행
- Participation 모델로 파싱
- 에러 처리

**완료 조건**:
- ✅ Mock 데이터로 게임 목록 표시
- ⏳ GraphQL API 통합 (향후)
- ⏳ 실시간 업데이트 (향후)

---

### 기능 3: 선택 블록 좌표 표시

**설명**: 각 게임에서 사용자가 선택한 블록의 좌표를 표시합니다.

**기술 상세**:
- **데이터 생성**: `_getMockPicks(GameRound game)` 함수
- **블록 모델**: `BlockModel.fromPosition(row, col, state: BlockState.selected)`
- **표시 형식**: "X{col}-Y{row}" (예: "X5-Y10")

**Mock 데이터 생성 로직**:
```dart
final pickCount = game.requiredPicks + (game.id.hashCode % 10);
return List.generate(
  pickCount,
  (index) => BlockModel.fromPosition(
    (index * 123 % game.actualGridHeight) + 1,
    (index * 456 % game.actualGridWidth) + 1,
    state: BlockState.selected,
  ),
);
```

**UI 표시**:
- Wrap 위젯으로 블록 배치
- 각 블록: 연한 파란색 배경 + 파란색 테두리 컨테이너
- 가로/세로 간격: 8dp

**향후 구현**:
- GraphQL에서 실제 selectedBlocks 조회
- 서버에서 저장된 블록 좌표 파싱

**완료 조건**:
- ✅ Mock 블록 좌표 생성
- ✅ 블록 좌표 Wrap 레이아웃
- ✅ 블록 UI 디자인
- ⏳ 실제 블록 데이터 연동 (향후)

---

### 기능 4: 게임 상태별 배지 표시

**설명**: 각 게임의 현재 상태를 배지로 시각화합니다.

**4가지 상태**:

1. **Active (진행 중)**:
   - 배경: 초록색 (#10B981)
   - 텍스트: "Active" (흰색)
   - 의미: 게임이 아직 진행 중, 추가 참가 가능

2. **Drawing (추첨 중)**:
   - 배경: 보라색 (#8B5CF6)
   - 텍스트: "Drawing" (흰색)
   - 의미: 게임 종료, 추첨 진행 중

3. **Won (당첨)**:
   - 배경: 골드 (#F59E0B)
   - 텍스트: "Won" (흰색)
   - 의미: 사용자가 당첨됨
   - 추가: "🎉 Congratulations!" 메시지 표시

4. **Lost (미당첨)**:
   - 배경: 회색 (#6B7280)
   - 텍스트: "Lost" (흰색)
   - 의미: 게임 종료, 당첨되지 않음

**배지 위치**:
- 카드 상단 좌측 (상태 배지)
- 카드 상단 우측 (타입 배지)

**완료 조건**:
- ✅ 4가지 상태 배지 디자인
- ✅ 상태별 색상 구분
- ✅ 당첨 시 축하 메시지
- ⏳ 실제 게임 상태 연동 (향후)

---

### 기능 5: 게임 상세 바텀시트

**설명**: 게임 카드를 터치하면 게임 상세 정보를 보여주는 바텀시트를 표시합니다.

**기술 구현**:
- **showModalBottomSheet**: Flutter 내장 바텀시트
- **isScrollControlled**: true (높이 커스터마이징)
- **backgroundColor**: Colors.transparent (커스텀 배경)
- **높이**: 화면의 70%

**바텀시트 구성**:
1. 핸들 바 (드래그 인디케이터)
2. 상품 이미지 (flex 2)
3. 게임 정보 + 내 픽 리스트 (flex 3, 스크롤 가능)
4. "View on Grid" 버튼

**액션**:
- 버튼 터치 시:
  1. `Navigator.pop(context)` - 바텀시트 닫기
  2. 게임 화면으로 네비게이션 (향후)
  3. SnackBar 표시 (현재 Mock)

**완료 조건**:
- ✅ 바텀시트 UI 구현
- ✅ 핸들 바 표시
- ✅ 상품 이미지 표시
- ✅ 내 픽 리스트 표시
- ✅ 버튼 액션 (SnackBar)
- ⏳ 게임 화면 네비게이션 (향후)

---

### 기능 6: "View on Grid" 게임 진입

**설명**: 게임 카드 또는 바텀시트에서 "View on Grid" 버튼을 터치하여 게임 화면으로 이동합니다.

**현재 구현**:
- SnackBar로 게임 제목 표시
- 실제 네비게이션 없음

**향후 구현**:
- **GoRouter 네비게이션**:
  ```dart
  context.push('/game/${game.id}');
  ```
- **GameScreen 진입**:
  - gameProvider(gameId) 호출
  - 게임 상세 정보 조회
  - 그리드 렌더링
  - 선택한 블록 하이라이트 표시

**선택 블록 하이라이트**:
- 사용자가 이전에 선택한 블록을 그리드에서 강조 표시
- 색상: 파란색 (#5C72F5)
- 테두리: 두꺼운 테두리 또는 다른 색상

**완료 조건**:
- ⏳ GoRouter 네비게이션 구현 (향후)
- ⏳ GameScreen에 선택 블록 전달 (향후)
- ⏳ 그리드에서 블록 하이라이트 (향후)

---

### 기능 7: 빈 상태 처리

**설명**: 참가한 게임이 없을 때 빈 상태 메시지를 표시합니다.

**표시 조건**:
- `filteredGames.isEmpty == true`

**UI 구성**:
- 화면 중앙 배치 (Center)
- Icons.inbox_outlined (80px, 회색)
- "No picks yet" (제목)
- "Start playing to see your picks here" (부제목)

**완료 조건**:
- ✅ 빈 상태 UI 구현
- ✅ 아이콘 및 텍스트 표시
- ✅ 중앙 정렬

---

## 📱 사용자 시나리오

### 시나리오 1: MyPick 페이지 진입

**사용자 행동**: My 페이지에서 "게임 참가 내역" 카드 터치 (향후) 또는 직접 `/my-pick` 진입

**화면 반응**:

1. **SafeArea 적용**
   - 상단 노치 영역 고려

2. **탭 바 표시**
   - ALL, DAILY, SELECT, VIBE 탭
   - 기본값: ALL 탭 선택

3. **게임 목록 로드**
   - Mock 데이터에서 모든 게임 가져오기
   - allGames = dailyGames + selectGames + vibeGames

4. **게임 카드 표시**
   - ListView로 스크롤 가능
   - 각 게임: MyPickCard 위젯
   - 상태 배지, 타입 배지, 이미지, 제목, 설명, 블록 리스트, 버튼

**예상 시간**: 즉시 (Mock 데이터)

---

### 시나리오 2: 탭 전환 (ALL → DAILY)

**사용자 행동**: DAILY 탭 터치

**화면 반응**:

1. **탭 인디케이터 이동**
   - 파란색 인디케이터가 ALL → DAILY로 이동
   - 애니메이션: 300ms

2. **TabBarView 전환**
   - 화면이 부드럽게 슬라이드
   - _buildGameList(GameType.daily) 호출

3. **DAILY 게임 필터링**
   - allGames에서 gameType이 GameType.daily인 게임만 필터
   - filteredGames에 저장

4. **게임 카드 재렌더링**
   - DAILY 게임만 표시
   - 다른 타입 게임 숨김

**예상 시간**: 즉시 (< 100ms)

---

### 시나리오 3: 게임 카드 터치 (바텀시트 표시)

**사용자 행동**: "iPhone 16 Pro Max" 게임 카드 터치

**화면 반응**:

1. **onTap 콜백 실행**
   - `_showGameDetails(context, game, myPicks)` 호출

2. **바텀시트 애니메이션**
   - 하단에서 슬라이드 업
   - 애니메이션: 300ms
   - 높이: 화면의 70%

3. **바텀시트 내용 표시**:
   - 핸들 바 (드래그 가능)
   - 상품 이미지 (상단 40%)
   - 게임 정보:
     - 제목: "iPhone 16 Pro Max"
     - 설명: "Latest iPhone with..."
   - 내 픽 리스트:
     - "My Picks (3)"
     - X5-Y10, X12-Y8, X20-Y15
   - "View on Grid" 버튼

4. **스크롤 가능**
   - 게임 정보 + 내 픽 섹션 스크롤 가능

**예상 시간**: 300ms (애니메이션)

---

### 시나리오 4: "View on Grid" 버튼 터치 (카드)

**사용자 행동**: 게임 카드의 "View on Grid →" 버튼 터치

**화면 반응**:

1. **현재 동작** (Mock):
   - SnackBar 표시
   - "Opening game: iPhone 16 Pro Max"
   - 배경: 파란색

2. **향후 동작**:
   - GoRouter 네비게이션
   - `/game/daily-001` 경로로 이동
   - GameScreen 로드:
     - 게임 상세 정보 조회
     - 그리드 렌더링
     - 선택한 블록 하이라이트 (X5-Y10, X12-Y8, X20-Y15)

**예상 시간**: 즉시 (현재), 300ms (향후 네비게이션)

---

### 시나리오 5: "View on Grid" 버튼 터치 (바텀시트)

**사용자 행동**: 바텀시트의 "View on Grid" 버튼 터치

**화면 반응**:

1. **바텀시트 닫기**
   - `Navigator.pop(context)` 호출
   - 하단으로 슬라이드 다운
   - 애니메이션: 300ms

2. **현재 동작** (Mock):
   - SnackBar 표시
   - "Opening game: iPhone 16 Pro Max"

3. **향후 동작**:
   - 시나리오 4와 동일
   - GameScreen으로 네비게이션

**예상 시간**: 300ms (바텀시트 닫기) + 300ms (네비게이션)

---

### 시나리오 6: 빈 상태 표시

**사용자 행동**: VIBE 탭 선택 (VIBE 게임 참가 내역 없음)

**화면 반응**:

1. **탭 전환**
   - VIBE 탭으로 이동

2. **게임 필터링**
   - gameType이 GameType.vibe인 게임 필터
   - 결과: 빈 리스트 (isEmpty == true)

3. **빈 상태 표시**:
   - 화면 중앙에:
     - 빈 상자 아이콘 (Inbox, 80px, 회색)
     - "No picks yet"
     - "Start playing to see your picks here"

**예상 시간**: 즉시

---

### 시나리오 7: 당첨 게임 확인

**사용자 행동**: 스크롤하여 당첨된 게임 카드 확인

**화면 반응**:

1. **당첨 게임 카드 표시**:
   - 상태 배지: "Won" (골드 배경)
   - 타입 배지: "Vibe" (파란색)
   - 이미지: AirPods Pro
   - 제목: "AirPods Pro"
   - 선택 블록: X15-Y20, X18-Y22
   - 당첨 메시지:
     - "🎉 Congratulations! You won!"
     - 연한 골드 배경 (#FEF3C7)
   - "View on Grid →" 버튼

2. **시각적 강조**:
   - 골드 색상으로 당첨 강조
   - 축하 메시지로 사용자 만족도 향상

**예상 시간**: 즉시 (스크롤)

---

## 🔧 개발 작업 (Issues)

### Issue BP-09-01: 탭 바 및 탭 필터링 구현

```yaml
title: "[Feature] MyPick 탭 바 및 게임 타입 필터링 (ALL/DAILY/SELECT/VIBE)"
description: |
  ## 개요
  MyPick 페이지에 탭 바를 구현하고, 각 탭에서 해당 게임 타입만 표시합니다.

  ## 작업 내용
  - [x] MyPickScreen StatefulWidget 생성
  - [x] TabController 설정 (4개 탭)
  - [x] TabBar 디자인 구현:
    - ALL, DAILY, SELECT, VIBE 탭
    - 선택된 탭: 파란색 인디케이터
    - 미선택 탭: 회색 텍스트
  - [x] TabBarView 구성:
    - _buildGameList(null) - ALL
    - _buildGameList(GameType.daily) - DAILY
    - _buildGameList(GameType.select) - SELECT
    - _buildGameList(GameType.vibe) - VIBE
  - [x] 탭 전환 애니메이션
  - [x] SingleTickerProviderStateMixin

  ## 완료 조건 (DoD)
  - [x] 탭 전환 시 부드러운 애니메이션
  - [x] 각 탭에 해당하는 게임만 표시
  - [x] 탭 스타일 정확히 적용
  - [x] SafeArea 처리

  ## 기술 스택
  - Flutter TabController
  - TabBar, TabBarView
  - SingleTickerProviderStateMixin

  ## 참조
  - lib/features/my_pick/my_pick_screen.dart

assignees: ["@mobile-dev-1"]
labels: ["frontend", "mobile", "feature", "ui"]
priority: "high"
estimate_point: 3
state: "Done"
module: "MyPick"
cycle: "Cycle 1"
```

---

### Issue BP-09-02: MyPickCard 위젯 구현

```yaml
title: "[Feature] MyPickCard 위젯 구현"
description: |
  ## 개요
  참가한 게임을 표시하는 MyPickCard 위젯을 구현합니다.

  ## 작업 내용
  - [x] MyPickCard 위젯 생성 (StatelessWidget)
  - [x] 카드 레이아웃:
    - 흰색 배경, 테두리, 그림자
    - 둥근 모서리 (radius 16)
  - [x] 헤더 (배지):
    - 상태 배지 (Active/Drawing/Won/Lost)
    - 타입 배지 (Daily/Select/Vibe)
  - [x] 게임 정보:
    - 이미지 (AspectRatio 16:9)
    - 제목 (최대 2줄)
    - 설명 (최대 2줄)
  - [x] 선택 블록 정보:
    - "My Picks (X)" 라벨
    - 블록 Wrap 레이아웃 (X-Y 좌표)
  - [x] 당첨 메시지 (당첨 시):
    - "🎉 Congratulations!" 배너
  - [x] "View on Grid →" 버튼
  - [x] onTap 콜백

  ## 완료 조건 (DoD)
  - [x] 카드 디자인 정확히 구현
  - [x] 상태별 배지 색상 구분
  - [x] 블록 좌표 표시
  - [x] 당첨 시 축하 메시지
  - [x] 버튼 액션 동작

  ## 기술 스택
  - Flutter Container, Column, Row, Wrap
  - Image.asset
  - GestureDetector

  ## 참조
  - lib/components/cards/my_pick_card.dart

assignees: ["@mobile-dev-2"]
labels: ["frontend", "mobile", "feature", "ui", "component"]
priority: "high"
estimate_point: 8
state: "Done"
module: "MyPick"
cycle: "Cycle 1"
```

---

### Issue BP-09-03: Mock 데이터 및 블록 생성

```yaml
title: "[Feature] Mock 게임 데이터 및 블록 좌표 생성"
description: |
  ## 개요
  MyPick 페이지에서 사용할 Mock 게임 데이터와 선택 블록 좌표를 생성합니다.

  ## 작업 내용
  - [x] Mock 게임 데이터 조회:
    - MockGameData.dailyGames
    - MockGameData.selectGames
    - MockGameData.vibeGames
  - [x] allGames 배열 생성 (병합)
  - [x] _getMockPicks 함수 구현:
    - 게임별 다른 수의 블록 생성
    - BlockModel.fromPosition 사용
    - 랜덤 좌표 생성 (hashCode 활용)
  - [x] 게임 필터링 로직:
    - filter가 null이면 모든 게임
    - filter가 있으면 해당 타입만

  ## 완료 조건 (DoD)
  - [x] Mock 게임 데이터 정상 조회
  - [x] 블록 좌표 생성 로직
  - [x] 필터링 정상 동작
  - [x] 게임별 다른 블록 수

  ## 기술 스택
  - Dart List, where
  - BlockModel
  - MockGameData

  ## 참조
  - lib/features/my_pick/my_pick_screen.dart
  - lib/data/mock_game_data.dart

assignees: ["@mobile-dev-1"]
labels: ["frontend", "mobile", "feature", "data"]
priority: "medium"
estimate_point: 3
state: "Done"
module: "MyPick"
cycle: "Cycle 1"
```

---

### Issue BP-09-04: 게임 상세 바텀시트 구현

```yaml
title: "[Feature] 게임 상세 바텀시트 구현"
description: |
  ## 개요
  게임 카드를 터치하면 상세 정보를 보여주는 바텀시트를 구현합니다.

  ## 작업 내용
  - [x] _showGameDetails 함수 구현
  - [x] showModalBottomSheet 사용:
    - isScrollControlled: true
    - backgroundColor: transparent
    - 높이: 화면의 70%
  - [x] 바텀시트 UI:
    - 핸들 바 (드래그 인디케이터)
    - 상품 이미지 (Expanded flex 2)
    - 게임 정보 (Expanded flex 3, 스크롤)
      - 제목, 설명
      - My Picks (X)
      - 블록 Wrap
    - "View on Grid" 버튼
  - [x] 버튼 액션:
    - Navigator.pop (바텀시트 닫기)
    - SnackBar 표시 (Mock)

  ## 완료 조건 (DoD)
  - [x] 바텀시트 정상 표시
  - [x] 핸들 바 표시
  - [x] 상품 이미지 표시
  - [x] 내 픽 리스트 표시
  - [x] 버튼 액션 동작

  ## 기술 스택
  - Flutter showModalBottomSheet
  - Column, Expanded
  - SingleChildScrollView

  ## 참조
  - lib/features/my_pick/my_pick_screen.dart

assignees: ["@mobile-dev-2"]
labels: ["frontend", "mobile", "feature", "ui"]
priority: "medium"
estimate_point: 5
state: "Done"
module: "MyPick"
cycle: "Cycle 1"
```

---

### Issue BP-09-05: 빈 상태 UI 구현

```yaml
title: "[Feature] MyPick 빈 상태 UI 구현"
description: |
  ## 개요
  참가한 게임이 없을 때 빈 상태 메시지를 표시합니다.

  ## 작업 내용
  - [x] _buildEmptyState 함수 구현
  - [x] 빈 상태 UI:
    - Icons.inbox_outlined (80px, 회색)
    - "No picks yet" (제목)
    - "Start playing to see your picks here" (부제목)
  - [x] 중앙 정렬 (Center)
  - [x] 표시 조건: filteredGames.isEmpty

  ## 완료 조건 (DoD)
  - [x] 빈 상태 UI 정상 표시
  - [x] 아이콘 및 텍스트 표시
  - [x] 중앙 정렬

  ## 기술 스택
  - Flutter Center, Column
  - Icons

  ## 참조
  - lib/features/my_pick/my_pick_screen.dart

assignees: ["@mobile-dev-1"]
labels: ["frontend", "mobile", "feature", "ui"]
priority: "low"
estimate_point: 2
state: "Done"
module: "MyPick"
cycle: "Cycle 1"
```

---

### Issue BP-09-06: GraphQL getMyParticipations 통합

```yaml
title: "[API] GraphQL getMyParticipations 쿼리 통합"
description: |
  ## 개요
  사용자의 게임 참가 내역을 GraphQL API를 통해 조회합니다.

  ## 작업 내용
  - [ ] GraphQL Query 정의 (getMyParticipations):
    - participation id
    - game (id, title, description, gameType, status, imageUrl)
    - selectedBlocks (row, col)
    - status (Active/Drawing/Won/Lost)
    - createdAt
  - [ ] myParticipationsProvider 구현:
    - authenticatedGraphqlClientProvider 사용
    - getMyParticipations 쿼리 실행
    - Participation 모델로 파싱
    - 에러 처리
  - [ ] Participation 모델 생성 (freezed):
    - id, game, selectedBlocks, status, createdAt
  - [ ] Mock 데이터 제거
  - [ ] 로딩/에러 상태 UI 업데이트

  ## 완료 조건 (DoD)
  - [ ] getMyParticipations 쿼리 정상 실행
  - [ ] myParticipationsProvider 데이터 반환
  - [ ] Participation 모델 파싱 성공
  - [ ] 에러 처리 구현
  - [ ] 단위 테스트 작성

  ## 기술 스택
  - GraphQL Flutter
  - Riverpod (riverpod_annotation)
  - freezed (Participation 모델)

  ## 참조
  - lib/providers/participation_provider.dart
  - lib/models/participation_model.dart

assignees: ["@mobile-dev-1", "@backend-dev-1"]
labels: ["frontend", "backend", "api", "graphql", "integration"]
priority: "high"
estimate_point: 8
state: "Todo"
module: "MyPick"
cycle: "Cycle 2"
```

---

### Issue BP-09-07: 게임 화면 네비게이션 구현

```yaml
title: "[Feature] MyPick에서 게임 화면으로 네비게이션 구현"
description: |
  ## 개요
  "View on Grid" 버튼을 터치하면 게임 화면으로 이동하고, 선택한 블록을 하이라이트 표시합니다.

  ## 작업 내용
  - [ ] GoRouter 경로 추가:
    - /game/:gameId
  - [ ] 네비게이션 구현:
    - context.push('/game/${game.id}')
  - [ ] GameScreen에 선택 블록 전달:
    - 경로 파라미터 또는 Provider 사용
  - [ ] GameScreen에서 블록 하이라이트:
    - selectedBlocks 리스트 받기
    - GridPainter에서 하이라이트 렌더링
    - 색상: 파란색 (#5C72F5)
    - 테두리: 두꺼운 테두리
  - [ ] SnackBar 제거

  ## 완료 조건 (DoD)
  - [ ] GoRouter 네비게이션 정상 동작
  - [ ] GameScreen 진입 확인
  - [ ] 선택 블록 하이라이트 표시
  - [ ] 애니메이션 부드러움

  ## 기술 스택
  - GoRouter
  - GameScreen
  - GridPainter

  ## 참조
  - lib/features/my_pick/my_pick_screen.dart
  - lib/features/game/game_screen.dart
  - lib/core/router/app_router.dart

assignees: ["@mobile-dev-2"]
labels: ["frontend", "mobile", "feature", "navigation"]
priority: "medium"
estimate_point: 5
state: "Todo"
module: "MyPick"
cycle: "Cycle 2"
```

---

## 📊 Story Points 요약

| Issue | 제목 | Points | 우선순위 | 상태 |
|-------|------|--------|----------|------|
| BP-09-01 | 탭 바 및 탭 필터링 구현 | 3pt | High | ✅ Done |
| BP-09-02 | MyPickCard 위젯 구현 | 8pt | High | ✅ Done |
| BP-09-03 | Mock 데이터 및 블록 생성 | 3pt | Medium | ✅ Done |
| BP-09-04 | 게임 상세 바텀시트 구현 | 5pt | Medium | ✅ Done |
| BP-09-05 | 빈 상태 UI 구현 | 2pt | Low | ✅ Done |
| BP-09-06 | GraphQL getMyParticipations 통합 | 8pt | High | 📋 Todo |
| BP-09-07 | 게임 화면 네비게이션 구현 | 5pt | Medium | 📋 Todo |
| **합계** | | **34pt** | | **62% 완료** |

---

## 🔗 관련 문서

- [전체 프로젝트 기획서](../blockpick-mobile-app.md)
- [00-INDEX](./00-INDEX.md)
- [03-게임플레이화면](./03-게임플레이화면.md)
- [08-My페이지](./08-My페이지.md)
- [10-설정](./10-설정.md)

---

**Last Updated**: 2025-11-20
**Version**: 1.0
**Author**: BlockPick Development Team
