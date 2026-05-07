# BlockPick UI/UX 상세 기획서 (Flutter 마이그레이션용)

> **작성일**: 2025-10-22
> **목적**: Next.js 웹앱을 Flutter 모바일 앱으로 마이그레이션하기 위한 UI/UX 상세 명세
> **버전**: 1.0.0

---

## 목차

1. [개요](#1-개요)
2. [디자인 시스템](#2-디자인-시스템)
3. [화면별 UI 명세](#3-화면별-ui-명세)
4. [컴포넌트 상세 명세](#4-컴포넌트-상세-명세)
5. [인터랙션 및 제스처](#5-인터랙션-및-제스처)
6. [애니메이션 명세](#6-애니메이션-명세)
7. [상태 관리](#7-상태-관리)
8. [반응형 레이아웃](#8-반응형-레이아웃)
9. [성능 최적화](#9-성능-최적화)
10. [Flutter 마이그레이션 가이드](#10-flutter-마이그레이션-가이드)

---

## 1. 개요

### 1.1 BlockPick 게임 시스템 개요

BlockPick은 그리드 기반의 블록 선택 게임으로, 사용자가 대형 그리드(최대 1000x1000)에서 블록을 선택하여 게임에 참여하는 시스템입니다.

**핵심 기능**:
- 대형 그리드 렌더링 (10x10 ~ 1000x1000)
- 실시간 블록 선택/해제
- 줌, 팬, 회전 등 3D 인터랙션
- 선택된 블록 관리 및 결제
- 게임 정보 및 통계 표시
- 미니맵을 통한 네비게이션

### 1.2 주요 화면 구조

```
BlockPick 게임
├── Select Phase (블록 선택 단계)
│   ├── 게임 그리드 (메인 뷰)
│   ├── 게임 정보 패널 (우측 사이드바)
│   ├── 플로팅 컨트롤 (하단 중앙)
│   ├── 모바일 바텀시트 (선택 블록 리스트)
│   ├── 모바일 미니맵 (우하단)
│   └── 헤더 (상단 고정)
├── Stage Phase (게임 진행 단계)
└── Vibe Phase (결과 발표 단계)
```

### 1.3 기술 스택 (현재)

- **프레임워크**: Next.js 15 (React 19)
- **3D 렌더링**: SVG + Canvas (Three.js 대안)
- **애니메이션**: Framer Motion
- **스타일**: Tailwind CSS
- **상태관리**: Zustand (로컬 상태)

---

## 2. 디자인 시스템

### 2.1 컬러 팔레트

#### 2.1.1 메인 컬러
| 컬러명 | Hex | RGB | 용도 |
|--------|-----|-----|------|
| `blue` | `#5C72F5` | `92, 114, 245` | 주요 액션, 선택 표시 |
| `purple` | `#6E5AE9` | `110, 90, 233` | 보조 액션, 그라데이션 |
| `pink` | `#FF58BB` | `255, 88, 187` | 강조, 진행률 |
| `red` | `#FF5D5C` | `255, 93, 92` | 경고, 삭제 |
| `green` | `#10B981` | `16, 185, 129` | 성공, 활성 상태 |
| `yellow` | `#F59E0B` | `245, 158, 11` | 대기, 주의 |
| `white` | `#FFFFFF` | `255, 255, 255` | 배경, 카드 |

#### 2.1.2 배경 컬러
| 컬러명 | Hex | 용도 |
|--------|-----|------|
| `deepwhite` | `#FCFCFC` | 메인 배경 |
| `whitegray` | `#FCFCFC` | 카드 배경 |
| `bluewhite` | `#ECF1F9` | 강조 배경 |
| `disable` | `#DEDEDE` | 비활성 배경 |

#### 2.1.3 텍스트 컬러
| 컬러명 | Hex | 용도 |
|--------|-----|------|
| `darkblue` | `#081245` | 주요 텍스트 (제목) |
| `navy` | `#2D3661` | 본문 텍스트 |
| `navywhite` | `#4B547F` | 보조 텍스트 |
| `grayblue` | `#8A91B0` | 힌트 텍스트 |
| `medium` | `#555555` | 일반 텍스트 |
| `hint` | `#C5C9DC` | 플레이스홀더 |
| `light` | `#999999` | 비활성 텍스트 |

#### 2.1.4 선(Stroke) 컬러
| 컬러명 | Hex | 용도 |
|--------|-----|------|
| `bulegray` | `#DADBE3` | 기본 border |
| `bgwhite` | `#EFF2F7` | 구분선 |
| `navystroke` | `#2A3547` | 강조 border |

#### 2.1.5 그라데이션
```css
/* 블루 그라데이션 */
background: linear-gradient(147deg, #3D81F6 0%, #875DF4 100%);

/* 핑크 그라데이션 */
background: linear-gradient(138deg, #FF58BB 6%, #FF5D5C 100%);

/* 퍼플 그라데이션 */
background: linear-gradient(151deg, #E33FF4 0%, #6E5AE9 100%);

/* 라이트 그라데이션 */
background: linear-gradient(146deg, #EFF6FF 4%, #F9F5FF 100%);
```

### 2.2 타이포그래피

#### 2.2.1 폰트 패밀리
```css
font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto,
             "Helvetica Neue", Arial, sans-serif;
```

#### 2.2.2 폰트 크기 및 용도
| 클래스 | 크기 | 용도 | Flutter 대응 |
|--------|------|------|--------------|
| `text-xs` | 12px | 캡션, 라벨 | `fontSize: 12` |
| `text-sm` | 14px | 본문, 버튼 | `fontSize: 14` |
| `text-base` | 16px | 기본 텍스트 | `fontSize: 16` |
| `text-lg` | 18px | 부제목 | `fontSize: 18` |
| `text-xl` | 20px | 제목 | `fontSize: 20` |
| `text-2xl` | 24px | 큰 제목 | `fontSize: 24` |

#### 2.2.3 폰트 두께
| 클래스 | 값 | 용도 |
|--------|-----|------|
| `font-normal` | 400 | 일반 텍스트 |
| `font-medium` | 500 | 강조 텍스트 |
| `font-semibold` | 600 | 부제목 |
| `font-bold` | 700 | 제목, 버튼 |

### 2.3 간격(Spacing)

Tailwind의 기본 스페이싱 스케일 사용 (4px 단위)

| 클래스 | 크기 | 용도 |
|--------|------|------|
| `p-1` / `m-1` | 4px | 최소 간격 |
| `p-2` / `m-2` | 8px | 작은 간격 |
| `p-3` / `m-3` | 12px | 기본 내부 여백 |
| `p-4` / `m-4` | 16px | 카드 패딩 |
| `p-6` / `m-6` | 24px | 섹션 간격 |
| `p-8` / `m-8` | 32px | 큰 섹션 간격 |

### 2.4 모서리(Border Radius)

| 클래스 | 크기 | 용도 |
|--------|------|------|
| `rounded-md` | 6px | 작은 버튼 |
| `rounded-lg` | 8px | 버튼, 입력 필드 |
| `rounded-xl` | 12px | 카드 |
| `rounded-2xl` | 16px | 큰 카드, 모달 |
| `rounded-full` | 9999px | 원형 아바타, 배지 |

### 2.5 그림자(Shadow)

```css
/* 기본 그림자 */
shadow-sm: 0 1px 2px 0 rgba(0, 0, 0, 0.05);
shadow: 0 1px 3px 0 rgba(0, 0, 0, 0.1);
shadow-md: 0 4px 6px -1px rgba(0, 0, 0, 0.1);
shadow-lg: 0 10px 15px -3px rgba(0, 0, 0, 0.1);
shadow-xl: 0 20px 25px -5px rgba(0, 0, 0, 0.1);

/* 컬러 그림자 (버튼) */
shadow-purple/30: 0 10px 30px -10px rgba(139, 92, 246, 0.3);
shadow-blue/30: 0 10px 30px -10px rgba(59, 130, 246, 0.3);
```

### 2.6 아이콘

**아이콘 라이브러리**: Lucide React (lucide-react)

**주요 사용 아이콘**:
- `Grid3x3`: 그리드 표시
- `Hash`: 블록 카운트
- `MapPin`: 위치 이동
- `Trash2`: 삭제
- `X`: 닫기
- `ChevronUp/Down`: 확장/축소
- `Zap`: 액션 버튼
- `Lock`: 잠금/비활성
- `Target`: 선택 표시
- `Trophy`: 게임 상태
- `Users`: 참가자
- `Award`: 당첨자

**Flutter 대응**: Material Icons 또는 Lucide Flutter 패키지 사용

---

## 3. 화면별 UI 명세

### 3.1 게임 선택 화면 (`/blockpick/select/[roundId]`)

#### 3.1.1 레이아웃 구조

```
┌─────────────────────────────────────────────────────────┐
│ Header (고정, 64px)                                      │
│ ┌─────────┬─────────────────────┬─────────┐            │
│ │  Back   │  Cash + Point       │  User   │            │
│ └─────────┴─────────────────────┴─────────┘            │
├─────────────────────────────────────────────────────────┤
│                                                          │
│  ┌─────────────────────────────────────────┐            │
│  │                                          │ ┌────────┐ │
│  │                                          │ │        │ │
│  │          Game Grid (Full Screen)        │ │ Game   │ │
│  │          (SVG/Canvas 렌더링)             │ │ Info   │ │
│  │                                          │ │ Panel  │ │
│  │                                          │ │        │ │
│  │                                          │ │ 384px  │ │
│  └─────────────────────────────────────────┘ └────────┘ │
│            ▲                                             │
│         Floating Controls                                │
├─────────────────────────────────────────────────────────┤
│ Mobile Bottom Sheet (모바일만)                           │
│ ┌─────────────────────────────────────────────────────┐ │
│ │ Selected Blocks List + Confirm Button               │ │
│ └─────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────┘
```

#### 3.1.2 Desktop Layout (>= 1024px)

**구성 요소**:
1. **Header** (상단 고정)
   - 높이: 64px
   - 배경: `bg-white`
   - Border: `border-b border-bulegray`
   - 레이아웃:
     ```
     [뒤로가기] [                Cash + Point               ] [User Dropdown]
     ```

2. **Game Grid** (메인 영역)
   - 위치: 전체 화면 (헤더 아래)
   - 배경: `bg-gradient-to-br from-bgwhite via-bluewhite to-bluewhite`
   - 렌더링: SVG 기반 (셀 + 선택 표시)

3. **Game Info Panel** (우측 사이드바)
   - 너비: 384px
   - 위치: 우측 고정
   - 배경: 투명 (내부 카드는 `bg-white`)
   - 애니메이션: 슬라이드 인/아웃 (Spring, damping: 25, stiffness: 200)

4. **Floating Controls** (하단 중앙)
   - 위치: `bottom-6 left-1/2 transform -translate-x-1/2`
   - 레이아웃: 가로 배열
   - 버튼 크기: 48x48px
   - 간격: 12px

#### 3.1.3 Mobile Layout (< 768px)

**주요 차이점**:
1. **Game Info Panel 제거** → 모달로 대체
2. **Bottom Sheet 추가**
   - 3가지 상태: `closed`, `peek`, `expanded`
   - 드래그 가능
3. **Minimap 추가**
   - 위치: 우하단 (bottom: 192px, right: 16px)
   - 크기: 100px (기본), 160px (확장)
4. **Floating Controls 크기 조정**
   - 버튼 크기: 44x44px (터치 최적화)

#### 3.1.4 색상 및 스타일

```css
/* 배경 그라데이션 */
background: linear-gradient(to bottom right,
  #FCFCFC 0%,
  #ECF1F9 50%,
  #ECF1F9 100%
);

/* 애니메이션 배경 효과 */
.pulse-bg-1 {
  width: 384px;
  height: 384px;
  background: rgba(236, 241, 249, 0.2);
  border-radius: 9999px;
  filter: blur(80px);
  animation: pulse 2s ease-in-out infinite;
}
```

---

### 3.2 헤더 (MainHeader)

#### 3.2.1 게임 상세 페이지 헤더

**위치**: `components/blockpick/layout/header.tsx:74-187`

**레이아웃**:
```
┌────────────────────────────────────────────────────────┐
│  [←]        [Cash: 10,000원] [Point: 5,000P]      [👤] │
└────────────────────────────────────────────────────────┘
```

**구성 요소**:

1. **뒤로가기 버튼** (좌측)
   ```tsx
   <button className="p-2 rounded-lg hover:bg-bgwhite">
     <ArrowLeft className="h-5 w-5 text-navywhite" />
   </button>
   ```
   - 크기: 40x40px
   - 아이콘: 20x20px
   - Hover: 배경색 `#EFF2F7`

2. **캐시 + 포인트** (중앙 절대 위치)
   ```tsx
   <div className="absolute left-1/2 transform -translate-x-1/2">
     <div className="px-4 py-2 bg-bluewhite rounded-lg">
       <Wallet /> {cash}원
     </div>
     <div className="px-4 py-2 bg-bluewhite rounded-lg">
       {point}P
     </div>
   </div>
   ```
   - 배경: `#ECF1F9`
   - 텍스트: 14px, semibold
   - 캐시: `text-blue`, 포인트: `text-purple`

3. **유저 드롭다운** (우측)
   ```tsx
   <button className="flex items-center space-x-2">
     <div className="w-8 h-8 rounded-full bg-gradient-to-br from-blue to-purple">
       {nickname[0]}
     </div>
     <ChevronDown className="h-4 w-4" />
   </button>
   ```
   - 아바타: 32x32px, 원형
   - 온라인 표시: 12x12px, 녹색 점

**드롭다운 메뉴**:
```
┌──────────────────────────────┐
│ User Name                    │
│ user@email.com               │
│ [일반 회원]                   │
├──────────────────────────────┤
│ 👤 마이페이지                 │
│ 💰 지갑                       │
│ 📌 마이픽                     │
├──────────────────────────────┤
│ 🚪 로그아웃                   │
└──────────────────────────────┘
```

#### 3.2.2 일반 페이지 헤더

**레이아웃**:
```
┌────────────────────────────────────────────────────────┐
│  [☰] [🔍 검색...]  [💰 Cash|Point] [📌] [🌐] [👤]     │
└────────────────────────────────────────────────────────┘
```

**추가 요소**:
- 사이드바 토글 버튼
- 검색창 (256px)
- 마이픽 버튼
- 언어 선택 드롭다운

---

### 3.3 게임 그리드 (NewGameGrid)

#### 3.3.1 컴포넌트 구조

**위치**: `components/blockpick/new-round/new-game-grid.tsx`

**Props**:
```typescript
interface NewGameGridProps {
  gridSize: number                    // 그리드 크기 (10-1000)
  onBlockClick: (row: number, col: number) => void
  selectedBlocks: Array<{
    row: number
    col: number
    id: string
  }>
  isMobile?: boolean
  containerWidth?: number
  containerHeight?: number
}
```

#### 3.3.2 렌더링 전략

**Sparse Grid 데이터 구조**:
```typescript
class SparseGrid {
  private tiles = new Map<string, TileData>()

  interface TileData {
    id: string
    row: number
    col: number
    state: 'empty' | 'selected' | 'winner' | 'unique' | 'duplicate'
    lastUpdated: number
  }
}
```

**메모리 최적화**:
- Object Pool 패턴 사용
- 빈 셀은 렌더링하지 않음
- 뷰포트 내 셀만 렌더링 (Viewport Culling)
- 타일 재사용 (500-1000개 풀)

#### 3.3.3 LOD (Level of Detail) 시스템

줌 레벨에 따라 렌더링 디테일 조정:

```typescript
const LOD_THRESHOLDS = {
  ULTRA_LOW: 0.1,   // 전체 뷰 (1000x1000)
  VERY_LOW: 0.2,    // 광역 뷰
  LOW: 0.5,         // 일반 뷰
  MEDIUM: 1.0,      // 기본 뷰
  HIGH: 2.0,        // 확대 뷰
  ULTRA_HIGH: 5.0   // 최대 확대
}
```

**디테일 레벨별 렌더링**:
| Zoom | LOD | 그리드선 | 텍스트 | 선택 효과 |
|------|-----|----------|--------|-----------|
| 0.1-0.2 | ULTRA_LOW | 10칸마다 | 숨김 | 단순 색상 |
| 0.2-0.5 | VERY_LOW | 5칸마다 | 숨김 | 단순 색상 |
| 0.5-1.0 | LOW | 모두 표시 | 숨김 | 테두리만 |
| 1.0-2.0 | MEDIUM | 모두 표시 | 표시 | 전체 효과 |
| 2.0-5.0 | HIGH | 모두 표시 | 표시 | 전체 효과 + 그림자 |
| >5.0 | ULTRA_HIGH | 모두 표시 | 큰 글씨 | 전체 효과 + 애니메이션 |

#### 3.3.4 셀 렌더링

**빈 셀** (state: 'empty'):
```svg
<rect
  x={col * cellSize}
  y={row * cellSize}
  width={cellSize}
  height={cellSize}
  fill="#FFFFFF"
  stroke="#DADBE3"
  strokeWidth="1"
  opacity="0.8"
/>
```

**선택된 셀** (state: 'selected'):
```svg
<g>
  <rect
    fill="url(#blueGradient)"
    stroke="#5C72F5"
    strokeWidth="2"
    filter="url(#glow)"
  />
  <text
    x={centerX}
    y={centerY}
    fill="#FFFFFF"
    fontSize="12"
    fontWeight="600"
    textAnchor="middle"
  >
    {row},{col}
  </text>
</g>
```

**당첨 셀** (state: 'winner'):
```svg
<rect
  fill="url(#goldGradient)"
  stroke="#F59E0B"
  strokeWidth="3"
/>
```

#### 3.3.5 인터랙션 영역

**클릭 영역 확장**:
```typescript
// 실제 셀 크기보다 큰 클릭 영역 (터치 최적화)
const hitboxSize = Math.max(cellSize, 44) // 최소 44x44px
```

---

### 3.4 게임 정보 패널 (NewGameInfoPanel)

#### 3.4.1 레이아웃

**위치**: `components/blockpick/new-round/new-game-info-panel.tsx`

**크기**: 384px (너비) x 100% (높이)

**구조**:
```
┌──────────────────────────────────────┐
│ Game Title              [i] [x]      │ ← 헤더
├──────────────────────────────────────┤
│ [Game Status] [Prize Info]           │ ← 탭
├──────────────────────────────────────┤
│                                      │
│  ┌────────────────────────────────┐ │
│  │ 📊 게임 통계                    │ │
│  │ Participants: 1,234            │ │
│  │ Blocks: 10,000 (100x100)       │ │
│  │ Required pick: 5/100           │ │
│  │ Winners: 10                    │ │
│  └────────────────────────────────┘ │
│                                      │
│  Progress: [████░░░░░░] 5%          │
│  Ends in: 2d 5h 30m                 │
│                                      │
├──────────────────────────────────────┤
│ Selected Blocks (5)         [CLEAR]  │
├──────────────────────────────────────┤
│                                      │
│  ┌────────────────────────────────┐ │
│  │ ✓ 10 Row, 25 Column      [x]  │ │ ← 스크롤 영역
│  │ ✓ 12 Row, 30 Column      [x]  │ │
│  │ ✓ 15 Row, 45 Column      [x]  │ │
│  └────────────────────────────────┘ │
│                                      │
├──────────────────────────────────────┤
│ [⚡ Select blocks (₩1,000/pick)]     │ ← 확정 버튼
└──────────────────────────────────────┘
```

#### 3.4.2 탭 네비게이션

**탭 스타일**:
```tsx
// 활성 탭
<button className="
  flex-1 px-3 py-2 rounded-lg
  bg-blue text-white shadow-sm
  transition-all duration-200
">
  <Trophy className="h-4 w-4" />
  Game status
</button>

// 비활성 탭
<button className="
  flex-1 px-3 py-2 rounded-lg
  text-medium hover:text-darkblue hover:bg-bgwhite
">
  <Info className="h-4 w-4" />
  Prize info
</button>
```

#### 3.4.3 게임 통계 카드

```tsx
<div className="bg-bluewhite rounded-xl p-4 border border-bulegray">
  <h3 className="text-darkblue font-semibold mb-3">게임 통계</h3>

  {/* 통계 항목 */}
  <div className="flex items-center justify-between">
    <div className="flex items-center gap-2">
      <Users className="h-4 w-4 text-blue" />
      <span className="text-medium">Participants :</span>
    </div>
    <span className="text-darkblue font-medium">1,234</span>
  </div>
</div>
```

**색상**:
- 배경: `#ECF1F9`
- Border: `#DADBE3`
- 아이콘: `#5C72F5`

#### 3.4.4 진행률 바

```tsx
<div className="w-full bg-whitegray rounded-full h-2">
  <div
    className="bg-pink h-2 rounded-full transition-all duration-300"
    style={{ width: `${progressPercentage}%` }}
  />
</div>
```

**애니메이션**: width 변경 시 300ms transition

#### 3.4.5 선택 블록 리스트

**개별 블록 카드**:
```tsx
<motion.div
  whileHover={{ scale: 1.02 }}
  whileTap={{ scale: 0.98 }}
  className="
    flex items-center justify-between p-2
    bg-white rounded-lg border border-bulegray
    hover:bg-bluewhite hover:border-blue
    cursor-pointer group
  "
>
  <div className="flex items-center gap-2">
    <Target className="h-3 w-3 text-green group-hover:text-blue" />
    <span className="text-sm text-navy group-hover:text-blue">
      {row} Row, {col} Column
    </span>
  </div>

  <button onClick={onRemove}>
    <X className="h-3 w-3 text-hint hover:text-red" />
  </button>
</motion.div>
```

**인터랙션**:
- 클릭: 해당 블록 위치로 줌 이동
- X 버튼: 블록 삭제 (이벤트 버블링 방지)

#### 3.4.6 확정 버튼

```tsx
<motion.button
  whileHover={{ scale: 1.02 }}
  whileTap={{ scale: 0.98 }}
  disabled={selectedBlocks.length === 0}
  className="
    w-full py-3 px-6 rounded-xl
    bg-gradient-to-r from-blue to-purple
    text-white font-bold
    flex items-center justify-center gap-2
    shadow-lg
    disabled:from-disable disabled:to-disable
  "
>
  <Zap className="h-5 w-5" />
  Select blocks (₩{costPerPick} / pick)
</motion.button>
```

**비활성 상태**:
- 배경: 회색 그라데이션
- 그림자 제거
- 커서: `not-allowed`

---

### 3.5 플로팅 컨트롤 (NewFloatingControls)

#### 3.5.1 레이아웃

**위치**: `components/blockpick/new-round/new-floating-controls.tsx`

**위치**: 화면 하단 중앙
```css
position: fixed;
bottom: 24px;
left: 50%;
transform: translateX(-50%);
z-index: 20;
```

**구조**:
```
[ 🏠 ] [ 📊 ] [ 🔄 ] [ 🎯 ] [ ⚙️ ]
```

#### 3.5.2 컨트롤 버튼

**버튼 크기**:
- Desktop: 48x48px
- Mobile: 44x44px

**스타일**:
```tsx
<motion.button
  whileHover={{ scale: 1.1 }}
  whileTap={{ scale: 0.95 }}
  className="
    w-12 h-12 rounded-xl
    bg-white/90 backdrop-blur-md
    border border-bulegray shadow-lg
    hover:bg-white hover:border-disable hover:shadow-xl
    transition-all duration-200
  "
>
  <IconComponent className="h-6 w-6" />
</motion.button>
```

**활성 상태**:
```tsx
className="
  bg-bluewhite border-blue-300 text-blue shadow-blue-200
"
```

#### 3.5.3 컨트롤 목록

| 아이콘 | 기능 | 툴팁 | 단축키 |
|--------|------|------|--------|
| 🏠 Home | 홈으로 이동 | "홈으로" | - |
| 📊 Info | 게임 정보 토글 | "게임 정보" | I |
| 🔄 Reset | 뷰 리셋 | "초기화" | Space |
| 🎯 Center | 선택 블록 중심 | "중심으로" | C |
| ⚙️ Settings | 설정 모달 | "설정" | S |

#### 3.5.4 툴팁

```tsx
<div className="
  absolute bottom-full left-1/2 transform -translate-x-1/2
  mb-2 px-3 py-2
  bg-darkblue text-white text-sm rounded-lg
  whitespace-nowrap
  opacity-0 group-hover:opacity-100
  transition-opacity duration-200
  pointer-events-none
  shadow-lg
">
  {tooltip}
  <div className="
    absolute top-full left-1/2 transform -translate-x-1/2
    w-0 h-0
    border-t-4 border-t-gray-900
    border-l-4 border-l-transparent
    border-r-4 border-r-transparent
  " />
</div>
```

**모바일**: 툴팁 숨김 처리

---

### 3.6 모바일 바텀시트 (MobileBottomContainer)

#### 3.6.1 레이아웃

**위치**: `components/blockpick/new-round/mobile-bottom-container.tsx`

**3가지 상태**:
1. **Closed**: 드래그 핸들만 표시
2. **Peek**: 3개 블록 미리보기 + 요약 정보
3. **Expanded**: 전체 블록 리스트

#### 3.6.2 상태별 높이

```typescript
const heights = {
  closed: 0,
  peek: Math.min(selectedBlocks.length * 72 + 200, 350),
  expanded: '40vh'  // 최대 40% 뷰포트
}
```

#### 3.6.3 드래그 핸들

```tsx
<div className="flex justify-center pt-2 pb-1 cursor-grab active:cursor-grabbing">
  <div className="w-12 h-1 bg-bulegray rounded-full" />
</div>
```

**드래그 제스처**:
```typescript
const handleDragEnd = (event, info: PanInfo) => {
  if (info.offset.y > 100) {
    setSheetState('closed')
  } else if (info.offset.y > 50) {
    setSheetState('peek')
  } else if (info.offset.y < -50) {
    setSheetState('expanded')
  }
}
```

#### 3.6.4 헤더 (Peek/Expanded)

```
┌──────────────────────────────────────────┐
│ ┌────────────────────────────────────┐   │
│ │ # 선택된 블록: 5개                  │   │
│ │   ₩1,000 × 5 = ₩5,000             │   │
│ └────────────────────────────────────┘   │
│                                          │
│ ┌────────────────────────────────────┐   │
│ │ 🎯 최근 선택 좌표                   │   │
│ │    10행 × 25열                     │   │
│ └────────────────────────────────────┘   │
│                                          │
│ [📍 탭하여 위치로 이동]  [🗑️] [^] [×]   │
└──────────────────────────────────────────┘
```

**비용 정보 카드**:
```tsx
<div className="p-3 bg-white/90 rounded-xl border border-blue/20 shadow-sm">
  <div className="flex items-center justify-between">
    <div className="flex items-center gap-2.5">
      <div className="w-9 h-9 rounded-lg bg-gradient-to-br from-blue/20 to-purple/20">
        <Hash className="h-5 w-5 text-blue" />
      </div>
      <div>
        <div className="text-xs text-medium">선택된 블록</div>
        <div className="text-sm font-bold text-darkblue">5개</div>
      </div>
    </div>
    <div className="text-right">
      <div className="text-xs text-medium">₩1,000 × 5</div>
      <div className="text-lg font-bold bg-gradient-to-r from-blue to-purple bg-clip-text text-transparent">
        ₩5,000
      </div>
    </div>
  </div>
</div>
```

#### 3.6.5 블록 리스트

**Peek 상태**: 최대 3개만 표시
```tsx
const displayBlocks = sheetState === 'expanded'
  ? selectedBlocks
  : selectedBlocks.slice(0, 3)
```

**개별 블록 카드**:
```tsx
<motion.div
  layout
  initial={{ opacity: 0, x: -20, scale: 0.9 }}
  animate={{ opacity: 1, x: 0, scale: 1 }}
  exit={{ opacity: 0, x: 20, scale: 0.9 }}
  transition={{ delay: index * 0.05 }}
  onClick={() => onZoomToBlock(row, col)}
  className="
    group relative
    bg-white hover:bg-gradient-to-r hover:from-blue/5 hover:to-purple/5
    rounded-2xl border border-bulegray/50 hover:border-blue/30
    transition-all active:scale-98
    overflow-hidden
  "
>
  <div className="p-3.5 flex items-center justify-between">
    <div className="flex items-center gap-3">
      <div className="w-8 h-8 rounded-lg bg-gradient-to-br from-blue/10 to-purple/10 border border-blue/20">
        <span className="text-xs font-bold text-blue">{index + 1}</span>
      </div>
      <div>
        <div className="text-sm font-semibold text-darkblue">
          {row}행 × {col}열
        </div>
        <div className="text-xs text-medium">Block #{id}</div>
      </div>
    </div>

    <button onClick={onRemove} className="p-2 rounded-lg bg-red/10 hover:bg-red/20">
      <X className="h-4 w-4 text-red" />
    </button>
  </div>
</motion.div>
```

**스태거 애니메이션**: 각 블록 50ms 딜레이

#### 3.6.6 더보기 버튼

```tsx
{sheetState === 'peek' && selectedBlocks.length > 3 && (
  <button className="
    w-full py-3 text-center
    text-sm font-medium text-blue
    bg-blue/5 rounded-xl border border-blue/20
    hover:bg-blue/10
  ">
    +{selectedBlocks.length - 3}개 더보기
  </button>
)}
```

#### 3.6.7 확정 버튼 (고정)

**위치**: 화면 최하단 고정
```css
position: fixed;
bottom: 0;
left: 0;
right: 0;
z-index: 50;
padding-bottom: env(safe-area-inset-bottom); /* iOS Safe Area */
```

```tsx
<div className="fixed bottom-0 left-0 right-0 z-50 pb-safe">
  <div className="bg-white/95 backdrop-blur-xl border-t border-bulegray/30 px-4 py-3">
    <motion.button
      whileTap={!isDisabled ? { scale: 0.98 } : {}}
      disabled={isDisabled}
      className={`
        w-full py-4 px-6 rounded-2xl font-bold text-white
        flex items-center justify-center gap-2
        ${isDisabled
          ? 'bg-gradient-to-r from-disable to-disable opacity-50'
          : 'bg-gradient-to-r from-blue via-purple to-pink hover:shadow-xl'
        }
      `}
      style={{
        boxShadow: !isDisabled ? '0 10px 30px -10px rgba(139, 92, 246, 0.5)' : 'none'
      }}
    >
      {isDisabled ? (
        <>
          <Lock className="h-5 w-5" />
          <span>블록을 선택하세요</span>
        </>
      ) : (
        <>
          <Zap className="h-5 w-5" />
          <span>{selectedBlocks.length}개 블록으로 참가하기</span>
        </>
      )}
    </motion.button>
  </div>
</div>
```

**높이**: 약 80px (py-3 + py-4 + safe-area)

---

### 3.7 모바일 미니맵 (MobileMinimap)

#### 3.7.1 레이아웃

**위치**: `components/blockpick/new-round/mobile-minimap.tsx`

**위치**:
```css
position: fixed;
bottom: 192px;  /* 바텀시트 위 */
right: 16px;
z-index: 40;
```

**크기**:
- 기본: 100x100px
- 확장: 160x160px

#### 3.7.2 구조

```
┌─────────────────────┐
│ 미니맵         [+/-] │
├─────────────────────┤
│                     │
│   ┌───────────┐     │
│   │ 현재 뷰포트│     │ ← 빨간 사각형
│   └───────────┘     │
│  •  •  •            │ ← 선택된 블록 (파란 점)
│                     │
└─────────────────────┘
```

#### 3.7.3 Canvas 렌더링

```typescript
const canvasRef = useRef<HTMLCanvasElement>(null)
const ctx = canvas.getContext('2d')

// 1. 배경
ctx.fillStyle = '#f1f5f9'
ctx.fillRect(0, 0, minimapSize, minimapSize)

// 2. 그리드 선 (10칸마다)
ctx.strokeStyle = '#e2e8f0'
ctx.lineWidth = 0.5
for (let i = 0; i <= gridSize; i += step) {
  ctx.moveTo(i * cellSize, 0)
  ctx.lineTo(i * cellSize, minimapSize)
  ctx.stroke()
}

// 3. 선택된 블록
selectedBlocks.forEach(block => {
  const x = (block.col - 1) * cellSize
  const y = (block.row - 1) * cellSize

  ctx.fillStyle = 'rgba(59, 130, 246, 0.6)'  // blue
  ctx.fillRect(x, y, cellSize, cellSize)

  ctx.strokeStyle = 'rgba(37, 99, 235, 0.8)'
  ctx.strokeRect(x, y, cellSize, cellSize)
})

// 4. 뷰포트 사각형
ctx.strokeStyle = 'rgba(239, 68, 68, 0.8)'  // red
ctx.lineWidth = 2
ctx.strokeRect(viewportX, viewportY, viewportWidth, viewportHeight)

// 5. 뷰포트 반투명 오버레이
ctx.fillStyle = 'rgba(239, 68, 68, 0.15)'
ctx.fillRect(viewportX, viewportY, viewportWidth, viewportHeight)
```

#### 3.7.4 뷰포트 계산

```typescript
const CELL_SIZE = 30  // 그리드 셀 크기
const gridPixelSize = gridSize * CELL_SIZE
const minimapScale = minimapSize / gridPixelSize

// 뷰포트 크기 (줌 적용)
const viewportPixelWidth = containerWidth / zoom
const viewportPixelHeight = containerHeight / zoom

// 미니맵에서의 뷰포트 크기
const viewportWidth = viewportPixelWidth * minimapScale
const viewportHeight = viewportPixelHeight * minimapScale

// 뷰포트 시작 위치
const viewportGridX = -panX / zoom
const viewportGridY = -panY / zoom

const viewportX = viewportGridX * minimapScale
const viewportY = viewportGridY * minimapScale
```

#### 3.7.5 클릭 이벤트

```typescript
const handleMinimapClick = (e: React.MouseEvent) => {
  const rect = canvas.getBoundingClientRect()
  const x = e.clientX - rect.left
  const y = e.clientY - rect.top

  // 그리드 좌표로 변환
  const gridX = (x / minimapSize) * gridSize
  const gridY = (y / minimapSize) * gridSize

  onMinimapClick(gridX, gridY)  // 해당 위치로 팬 이동
}
```

#### 3.7.6 확장/축소 버튼

```tsx
<motion.button
  whileTap={{ scale: 0.9 }}
  onClick={() => setIsExpanded(!isExpanded)}
  className="w-5 h-5 rounded-md bg-bluewhite hover:bg-blue/10"
>
  <svg className="w-3 h-3 text-blue">
    {isExpanded ? (
      <path d="M20 12H4" />  // 축소 (-)
    ) : (
      <path d="M12 4v16m8-8H4" />  // 확장 (+)
    )}
  </svg>
</motion.button>
```

---

## 4. 컴포넌트 상세 명세

### 4.1 NewGameOverlay

**위치**: `components/blockpick/new-round/new-game-overlay.tsx`

**역할**: 게임 화면 전체 레이아웃 컨테이너

**Props**:
```typescript
interface NewGameOverlayProps {
  gameTitle: string
  gameStatus: "active" | "upcoming" | "ended"
  timeLeft: string
  userBalance: { points: number }
  backgroundComponent: React.ReactNode        // 그리드
  backUrl: string
  headerActions?: React.ReactNode
  showSidebar?: boolean
  sidebarContent?: React.ReactNode            // 상품 패널
  onToggleSidebar?: () => void
  showSettings?: boolean
  settingsContent?: React.ReactNode
  onToggleSettings?: () => void
  floatingControls?: React.ReactNode
  gameContent?: React.ReactNode               // 게임 정보 패널
  onToggleGameInfo?: () => void
}
```

**배경 효과**:
```tsx
{/* 그라데이션 배경 */}
<div className="absolute inset-0 bg-gradient-to-br from-white/90 via-bluewhite/80 to-bluewhite/90" />

{/* 애니메이션 blob */}
<div className="absolute top-0 left-0 w-96 h-96 bg-bluewhite/20 rounded-full blur-3xl animate-pulse" />
<div className="absolute bottom-0 right-0 w-96 h-96 bg-bluewhite/20 rounded-full blur-3xl animate-pulse delay-1000" />
```

**사이드바 애니메이션**:
```tsx
// 왼쪽 사이드바 (상품 선택)
<motion.div
  initial={{ x: -300, opacity: 0 }}
  animate={{ x: 0, opacity: 1 }}
  exit={{ x: -300, opacity: 0 }}
  transition={{ type: "spring", damping: 25, stiffness: 200 }}
  className="absolute left-0 top-0 h-full z-20"
/>

// 오른쪽 사이드바 (게임 정보)
<motion.div
  initial={{ x: 400, opacity: 0 }}
  animate={{ x: 0, opacity: 1 }}
  exit={{ x: 400, opacity: 0 }}
  transition={{ type: "spring", damping: 25, stiffness: 200 }}
  className="absolute right-0 top-0 h-full z-20"
/>
```

---

### 4.2 게임 상태 표시

**상태별 색상**:
```typescript
const getStatusColor = (status: string) => {
  switch (status) {
    case 'active':
      return 'text-green bg-bluewhite border-bulegray'
    case 'upcoming':
      return 'text-yellow bg-whitegray border-bulegray'
    case 'ended':
      return 'text-red bg-whitegray border-bulegray'
  }
}

const getStatusText = (status: string) => {
  switch (status) {
    case 'active': return '진행중'
    case 'upcoming': return '예정'
    case 'ended': return '종료'
  }
}
```

**렌더링**:
```tsx
<div className={`
  px-3 py-1 rounded-full text-sm font-medium
  ${getStatusColor(gameStatus)}
`}>
  {getStatusText(gameStatus)}
</div>
```

---

## 5. 인터랙션 및 제스처

### 5.1 데스크톱 인터랙션

#### 5.1.1 마우스 휠 (줌)

```typescript
const handleWheel = (e: WheelEvent) => {
  e.preventDefault()

  const delta = e.deltaY
  const zoomSpeed = 0.001
  const newZoom = Math.max(0.1, Math.min(10, zoom - delta * zoomSpeed))

  setZoom(newZoom)
}
```

**줌 범위**: 0.1x ~ 10x

**줌 속도**: 0.001 (부드러운 줌)

#### 5.1.2 드래그 (팬)

```typescript
const handleMouseDown = (e: MouseEvent) => {
  setIsDragging(true)
  setDragStart({ x: e.clientX, y: e.clientY })
}

const handleMouseMove = (e: MouseEvent) => {
  if (!isDragging) return

  const deltaX = e.clientX - dragStart.x
  const deltaY = e.clientY - dragStart.y

  // 5px 임계값 (클릭과 드래그 구분)
  if (Math.abs(deltaX) < 5 && Math.abs(deltaY) < 5) return

  setPan({
    x: panX + deltaX,
    y: panY + deltaY
  })

  setDragStart({ x: e.clientX, y: e.clientY })
}
```

**임계값**: 5px (우발적 드래그 방지)

#### 5.1.3 클릭 (블록 선택)

```typescript
const handleClick = (e: MouseEvent) => {
  // 드래그 중이었으면 클릭 무시
  if (wasDragging) return

  const rect = canvas.getBoundingClientRect()
  const x = (e.clientX - rect.left - panX) / zoom
  const y = (e.clientY - rect.top - panY) / zoom

  const col = Math.floor(x / CELL_SIZE) + 1
  const row = Math.floor(y / CELL_SIZE) + 1

  if (row >= 1 && row <= gridSize && col >= 1 && col <= gridSize) {
    onBlockClick(row, col)
  }
}
```

#### 5.1.4 키보드 단축키

| 키 | 기능 | 설명 |
|----|------|------|
| `Space` | 뷰 리셋 | 줌 1x, 팬 (0, 0) |
| `Q` | 줌 아웃 | zoom *= 0.9 |
| `E` | 줌 인 | zoom *= 1.1 |
| `W` | 위로 팬 | panY += 50 |
| `A` | 왼쪽으로 팬 | panX += 50 |
| `S` | 아래로 팬 | panY -= 50 |
| `D` | 오른쪽으로 팬 | panX -= 50 |
| `F` | 선택 블록 중심 | 마지막 선택 블록으로 이동 |
| `Z` | 와이어프레임 토글 | 그리드 선 표시/숨김 |
| `I` | 정보 패널 토글 | 우측 패널 열기/닫기 |
| `Esc` | 모달 닫기 | 열린 모달/패널 닫기 |

**구현**:
```typescript
useEffect(() => {
  const handleKeyDown = (e: KeyboardEvent) => {
    switch (e.key.toLowerCase()) {
      case ' ':
        e.preventDefault()
        resetView()
        break
      case 'q':
        setZoom(z => Math.max(0.1, z * 0.9))
        break
      case 'e':
        setZoom(z => Math.min(10, z * 1.1))
        break
      // ... 기타
    }
  }

  window.addEventListener('keydown', handleKeyDown)
  return () => window.removeEventListener('keydown', handleKeyDown)
}, [])
```

### 5.2 모바일 제스처

#### 5.2.1 핀치 투 줌

```typescript
const handlePinch = (e: TouchEvent) => {
  if (e.touches.length !== 2) return

  const touch1 = e.touches[0]
  const touch2 = e.touches[1]

  const distance = Math.hypot(
    touch2.clientX - touch1.clientX,
    touch2.clientY - touch1.clientY
  )

  if (lastPinchDistance) {
    const scale = distance / lastPinchDistance
    setZoom(z => Math.max(0.1, Math.min(10, z * scale)))
  }

  setLastPinchDistance(distance)
}
```

#### 5.2.2 터치 팬

```typescript
const handleTouchMove = (e: TouchEvent) => {
  if (e.touches.length !== 1) return

  const touch = e.touches[0]

  if (lastTouchPos) {
    const deltaX = touch.clientX - lastTouchPos.x
    const deltaY = touch.clientY - lastTouchPos.y

    setPan({
      x: panX + deltaX,
      y: panY + deltaY
    })
  }

  setLastTouchPos({ x: touch.clientX, y: touch.clientY })
}
```

#### 5.2.3 더블 탭 (줌 토글)

```typescript
let lastTapTime = 0

const handleTouchEnd = (e: TouchEvent) => {
  const now = Date.now()

  if (now - lastTapTime < 300) {
    // 더블 탭
    const newZoom = zoom === 1 ? 2 : 1
    setZoom(newZoom)
  }

  lastTapTime = now
}
```

#### 5.2.4 바텀시트 드래그

**드래그 방향**:
- ↑ (위로): `closed` → `peek` → `expanded`
- ↓ (아래로): `expanded` → `peek` → `closed`

**임계값**:
```typescript
const DRAG_THRESHOLD = {
  OPEN: -50,   // 50px 위로 드래그 시 열림
  PEEK: 50,    // 50px 아래로 드래그 시 peek
  CLOSE: 100   // 100px 아래로 드래그 시 닫힘
}
```

**Framer Motion 설정**:
```tsx
<motion.div
  drag="y"
  dragConstraints={{ top: 0, bottom: 0 }}
  dragElastic={0.2}
  onDragEnd={(e, info: PanInfo) => {
    const { offset } = info

    if (offset.y > DRAG_THRESHOLD.CLOSE) {
      setSheetState('closed')
    } else if (offset.y > DRAG_THRESHOLD.PEEK) {
      setSheetState('peek')
    } else if (offset.y < DRAG_THRESHOLD.OPEN) {
      setSheetState('expanded')
    }
  }}
/>
```

#### 5.2.5 스와이프 제스처

**좌우 스와이프**: 사이드바 열기/닫기 (미구현, 향후 추가 가능)

---

## 6. 애니메이션 명세

### 6.1 Framer Motion 설정

**기본 transition**:
```typescript
const defaultTransition = {
  type: "spring",
  damping: 25,
  stiffness: 200
}
```

### 6.2 애니메이션 목록

#### 6.2.1 페이드 인

```tsx
<motion.div
  initial={{ opacity: 0 }}
  animate={{ opacity: 1 }}
  exit={{ opacity: 0 }}
  transition={{ duration: 0.2 }}
/>
```

#### 6.2.2 슬라이드 인/아웃

**왼쪽에서**:
```tsx
<motion.div
  initial={{ x: -300, opacity: 0 }}
  animate={{ x: 0, opacity: 1 }}
  exit={{ x: -300, opacity: 0 }}
  transition={{ type: "spring", damping: 25, stiffness: 200 }}
/>
```

**오른쪽에서**:
```tsx
<motion.div
  initial={{ x: 400, opacity: 0 }}
  animate={{ x: 0, opacity: 1 }}
  exit={{ x: 400, opacity: 0 }}
/>
```

**아래에서**:
```tsx
<motion.div
  initial={{ y: 100, opacity: 0 }}
  animate={{ y: 0, opacity: 1 }}
  exit={{ y: 100, opacity: 0 }}
/>
```

#### 6.2.3 스케일 애니메이션

```tsx
<motion.div
  initial={{ scale: 0, opacity: 0 }}
  animate={{ scale: 1, opacity: 1 }}
  exit={{ scale: 0, opacity: 0 }}
  transition={{ delay: index * 0.1 }}  // 스태거
/>
```

#### 6.2.4 호버 효과

```tsx
<motion.button
  whileHover={{ scale: 1.1 }}
  whileTap={{ scale: 0.95 }}
  transition={{ type: "spring", stiffness: 400, damping: 17 }}
/>
```

#### 6.2.5 Layout 애니메이션

```tsx
<motion.div
  layout
  transition={{ type: "spring", damping: 25, stiffness: 200 }}
/>
```

**사용 예**: 블록 리스트 재정렬

#### 6.2.6 Stagger Children

```tsx
<motion.div
  initial="hidden"
  animate="visible"
  variants={{
    hidden: { opacity: 0 },
    visible: {
      opacity: 1,
      transition: {
        staggerChildren: 0.05
      }
    }
  }}
>
  {items.map((item, i) => (
    <motion.div
      key={i}
      variants={{
        hidden: { opacity: 0, x: -20 },
        visible: { opacity: 1, x: 0 }
      }}
    />
  ))}
</motion.div>
```

#### 6.2.7 진행률 바 애니메이션

```tsx
<motion.div
  className="h-2 bg-pink rounded-full"
  initial={{ width: 0 }}
  animate={{ width: `${progressPercentage}%` }}
  transition={{ duration: 1, ease: "easeInOut" }}
/>
```

#### 6.2.8 펄스 애니메이션

```css
@keyframes pulse {
  0%, 100% {
    opacity: 1;
  }
  50% {
    opacity: 0.5;
  }
}

.animate-pulse {
  animation: pulse 2s cubic-bezier(0.4, 0, 0.6, 1) infinite;
}
```

### 6.3 애니메이션 타이밍

| 애니메이션 | 지속 시간 | Easing |
|-----------|----------|--------|
| 페이드 인/아웃 | 200ms | linear |
| 슬라이드 | Spring | damping: 25, stiffness: 200 |
| 호버 | Spring | damping: 17, stiffness: 400 |
| 탭 | 150ms | easeInOut |
| 진행률 바 | 1000ms | easeInOut |
| 모달 등장 | 300ms | easeInOutCubic |
| 스태거 딜레이 | 50ms | - |

---

## 7. 상태 관리

### 7.1 로컬 상태 (useState)

**게임 그리드 컴포넌트**:
```typescript
const [zoom, setZoom] = useState(1)
const [panX, setPanX] = useState(0)
const [panY, setPanY] = useState(0)
const [isDragging, setIsDragging] = useState(false)
const [selectedCells, setSelectedCells] = useState<Set<string>>(new Set())
```

**바텀시트**:
```typescript
const [sheetState, setSheetState] = useState<'closed' | 'peek' | 'expanded'>('peek')
```

**모달/드롭다운**:
```typescript
const [showUserDropdown, setShowUserDropdown] = useState(false)
const [showSettings, setShowSettings] = useState(false)
```

### 7.2 글로벌 상태 (Zustand)

**Grid Store** (`lib/grid-store.ts`):
```typescript
interface GridStore {
  // State
  zoom: number
  wireframeMode: boolean
  autoRotate: boolean
  centerOnCell: { x: number; y: number; z: number } | null

  // Actions
  setZoom: (zoom: number) => void
  toggleWireframe: () => void
  toggleAutoRotate: () => void
  setCenterOnCell: (position: Position | null) => void
}

const useGridStore = create<GridStore>((set) => ({
  zoom: 1,
  wireframeMode: false,
  autoRotate: false,
  centerOnCell: null,

  setZoom: (zoom) => set({ zoom }),
  toggleWireframe: () => set((state) => ({ wireframeMode: !state.wireframeMode })),
  toggleAutoRotate: () => set((state) => ({ autoRotate: !state.autoRotate })),
  setCenterOnCell: (position) => set({ centerOnCell: position })
}))
```

**사용**:
```typescript
const zoom = useGridStore((state) => state.zoom)
const setZoom = useGridStore((state) => state.setZoom)
```

### 7.3 Props Drilling 방지

**Context API 사용** (선택적):
```typescript
const GameContext = createContext<{
  gameId: string
  gridSize: number
  onBlockSelect: (row: number, col: number) => void
} | null>(null)

export const useGameContext = () => {
  const context = useContext(GameContext)
  if (!context) throw new Error('GameContext not found')
  return context
}
```

---

## 8. 반응형 레이아웃

### 8.1 브레이크포인트

| 이름 | 최소 너비 | 설명 |
|------|----------|------|
| Mobile | 0px | 모바일 (기본) |
| Tablet | 768px | 태블릿 |
| Desktop | 1024px | 데스크톱 |
| Large Desktop | 1440px | 큰 데스크톱 |

### 8.2 반응형 클래스

```tsx
<div className="
  w-full                 /* 모바일: 100% */
  md:w-1/2               /* 태블릿: 50% */
  lg:w-1/3               /* 데스크톱: 33% */
  xl:w-1/4               /* 큰 데스크톱: 25% */
">
```

### 8.3 모바일 vs 데스크톱 차이

| 기능 | 모바일 | 데스크톱 |
|------|--------|----------|
| 게임 정보 패널 | 모달 | 고정 사이드바 |
| 선택 블록 리스트 | 바텀시트 | 사이드바 내부 |
| 미니맵 | 우하단 플로팅 | 숨김/옵션 |
| 헤더 검색 | 숨김 | 표시 |
| 플로팅 컨트롤 버튼 | 44x44px | 48x48px |
| 드래그 핸들 | 표시 | 숨김 |
| 터치 타겟 | 최소 44x44px | 제한 없음 |

### 8.4 Safe Area (iOS)

```css
/* iOS Notch/홈 인디케이터 대응 */
.pb-safe {
  padding-bottom: env(safe-area-inset-bottom);
}

.pt-safe {
  padding-top: env(safe-area-inset-top);
}
```

**적용 위치**:
- 고정 버튼 (하단)
- 헤더 (상단)
- 바텀시트

---

## 9. 성능 최적화

### 9.1 렌더링 최적화

#### 9.1.1 Viewport Culling

뷰포트 밖의 셀은 렌더링하지 않음:

```typescript
const getViewportBounds = (): ViewportBounds => {
  const startRow = Math.floor(-panY / zoom / CELL_SIZE)
  const endRow = Math.ceil((containerHeight - panY) / zoom / CELL_SIZE)
  const startCol = Math.floor(-panX / zoom / CELL_SIZE)
  const endCol = Math.ceil((containerWidth - panX) / zoom / CELL_SIZE)

  return {
    minRow: Math.max(1, startRow),
    maxRow: Math.min(gridSize, endRow),
    minCol: Math.max(1, startCol),
    maxCol: Math.min(gridSize, endCol)
  }
}

// 렌더링 시 뷰포트 내 셀만
for (let row = bounds.minRow; row <= bounds.maxRow; row++) {
  for (let col = bounds.minCol; col <= bounds.maxCol; col++) {
    renderCell(row, col)
  }
}
```

#### 9.1.2 Object Pooling

```typescript
class TilePool {
  private pool: TileData[] = []
  private inUse = new Set<TileData>()

  acquire(row: number, col: number): TileData {
    let tile = this.pool.pop()
    if (!tile) {
      tile = { id: `${row}-${col}`, row, col, state: 'empty', lastUpdated: Date.now() }
    } else {
      // 재사용
      tile.id = `${row}-${col}`
      tile.row = row
      tile.col = col
      tile.state = 'empty'
      tile.lastUpdated = Date.now()
    }
    this.inUse.add(tile)
    return tile
  }

  release(tile: TileData): void {
    this.inUse.delete(tile)
    this.pool.push(tile)
  }
}
```

**풀 크기**: 500-1000개 (메모리 vs 성능 균형)

#### 9.1.3 Debounce/Throttle

**Zoom**:
```typescript
import { debounce } from 'lodash'

const debouncedZoom = debounce((newZoom: number) => {
  setZoom(newZoom)
}, 16)  // ~60fps
```

**Pan**:
```typescript
import { throttle } from 'lodash'

const throttledPan = throttle((x: number, y: number) => {
  setPan({ x, y })
}, 16)
```

#### 9.1.4 React.memo

```typescript
const CellComponent = React.memo(({ row, col, state, onClick }: CellProps) => {
  return (
    <rect
      x={col * CELL_SIZE}
      y={row * CELL_SIZE}
      width={CELL_SIZE}
      height={CELL_SIZE}
      fill={getCellColor(state)}
      onClick={() => onClick(row, col)}
    />
  )
}, (prev, next) => {
  // 상태가 변경되지 않으면 리렌더링 방지
  return prev.state === next.state && prev.row === next.row && prev.col === next.col
})
```

### 9.2 메모리 최적화

#### 9.2.1 Sparse Grid

빈 셀은 저장하지 않음:

```typescript
class SparseGrid {
  private tiles = new Map<string, TileData>()

  // 10,000 셀 중 100개만 선택 → 메모리 사용량 99% 감소
}
```

#### 9.2.2 타일 재사용

사용하지 않는 타일은 풀로 반환:

```typescript
// 뷰포트 밖으로 나간 타일 해제
visibleTiles.forEach(tile => {
  if (!isInViewport(tile)) {
    pool.release(tile)
    visibleTiles.delete(tile.id)
  }
})
```

### 9.3 성능 목표

| 지표 | 목표 | 측정 |
|------|------|------|
| FPS | 60fps | 렌더링 < 16ms |
| 초기 로딩 | < 3초 | Time to Interactive |
| 메모리 (1000x1000) | < 100MB | Chrome DevTools |
| 줌/팬 반응 속도 | < 50ms | 사용자 입력 → 화면 업데이트 |
| 블록 선택 반응 | < 100ms | 클릭 → 시각 피드백 |

### 9.4 프로파일링

```typescript
// 개발 모드에서만 활성화
if (process.env.NODE_ENV === 'development') {
  const start = performance.now()

  renderGrid()

  const end = performance.now()
  if (end - start > 16) {
    console.warn(`Slow render: ${end - start}ms`)
  }
}
```

---

## 10. Flutter 마이그레이션 가이드

### 10.1 위젯 매핑

| React 컴포넌트 | Flutter 위젯 |
|---------------|--------------|
| `<div>` | `Container` |
| `<motion.div>` | `AnimatedContainer` / `AnimatedBuilder` |
| `<button>` | `ElevatedButton` / `TextButton` / `IconButton` |
| `<input>` | `TextField` |
| Framer Motion | `AnimationController` + `Tween` |
| Zustand Store | `Provider` / `Riverpod` |
| `useState` | `StatefulWidget` + `setState` |
| `useEffect` | `initState` / `didUpdateWidget` |
| SVG | `CustomPaint` / `Canvas` |
| `overflow-y-auto` | `ListView` / `SingleChildScrollView` |

### 10.2 레이아웃 변환

#### 10.2.1 Flexbox → Row/Column

**React**:
```tsx
<div className="flex items-center justify-between">
  <div>Left</div>
  <div>Right</div>
</div>
```

**Flutter**:
```dart
Row(
  mainAxisAlignment: MainAxisAlignment.spaceBetween,
  crossAxisAlignment: CrossAxisAlignment.center,
  children: [
    Text('Left'),
    Text('Right'),
  ],
)
```

#### 10.2.2 Absolute Positioning → Stack

**React**:
```tsx
<div className="relative">
  <div className="absolute top-0 right-0">
    Floating
  </div>
</div>
```

**Flutter**:
```dart
Stack(
  children: [
    // 메인 컨텐츠
    Container(),

    // 플로팅 요소
    Positioned(
      top: 0,
      right: 0,
      child: Text('Floating'),
    ),
  ],
)
```

#### 10.2.3 Fixed Position → Positioned (Stack)

**React**:
```tsx
<div className="fixed bottom-0 left-0 right-0">
  Fixed Bottom
</div>
```

**Flutter**:
```dart
Stack(
  children: [
    // 메인 컨텐츠

    Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        child: Text('Fixed Bottom'),
      ),
    ),
  ],
)
```

### 10.3 그리드 렌더링

#### 10.3.1 CustomPaint

```dart
class GridPainter extends CustomPainter {
  final int gridSize;
  final double cellSize;
  final Set<String> selectedBlocks;
  final double zoom;
  final Offset pan;

  GridPainter({
    required this.gridSize,
    required this.cellSize,
    required this.selectedBlocks,
    required this.zoom,
    required this.pan,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey[300]!
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    // 뷰포트 계산
    final bounds = getViewportBounds(size);

    // 그리드 선
    for (int i = bounds.minRow; i <= bounds.maxRow; i++) {
      canvas.drawLine(
        Offset(0, i * cellSize * zoom + pan.dy),
        Offset(size.width, i * cellSize * zoom + pan.dy),
        paint,
      );
    }

    // 셀 렌더링
    for (int row = bounds.minRow; row <= bounds.maxRow; row++) {
      for (int col = bounds.minCol; col <= bounds.maxCol; col++) {
        final id = '$row-$col';
        if (selectedBlocks.contains(id)) {
          // 선택된 셀
          final rect = Rect.fromLTWH(
            col * cellSize * zoom + pan.dx,
            row * cellSize * zoom + pan.dy,
            cellSize * zoom,
            cellSize * zoom,
          );

          final selectedPaint = Paint()
            ..shader = LinearGradient(
              colors: [Color(0xFF5C72F5), Color(0xFF6E5AE9)],
            ).createShader(rect);

          canvas.drawRect(rect, selectedPaint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(GridPainter oldDelegate) {
    return oldDelegate.zoom != zoom ||
           oldDelegate.pan != pan ||
           oldDelegate.selectedBlocks != selectedBlocks;
  }
}
```

**사용**:
```dart
CustomPaint(
  painter: GridPainter(
    gridSize: 100,
    cellSize: 30,
    selectedBlocks: selectedBlocks,
    zoom: zoom,
    pan: pan,
  ),
  child: GestureDetector(
    onTapUp: (details) => handleTap(details.localPosition),
    onScaleUpdate: (details) => handleZoomPan(details),
  ),
)
```

### 10.4 제스처 처리

#### 10.4.1 GestureDetector

```dart
GestureDetector(
  // 탭
  onTapUp: (TapUpDetails details) {
    final position = details.localPosition;
    final row = ((position.dy - pan.dy) / zoom / cellSize).floor();
    final col = ((position.dx - pan.dx) / zoom / cellSize).floor();
    onBlockClick(row, col);
  },

  // 드래그 (팬)
  onPanUpdate: (DragUpdateDetails details) {
    setState(() {
      pan += details.delta;
    });
  },

  child: CustomPaint(...),
)
```

#### 10.4.2 InteractiveViewer (줌/팬)

```dart
InteractiveViewer(
  boundaryMargin: EdgeInsets.all(double.infinity),
  minScale: 0.1,
  maxScale: 10.0,
  onInteractionUpdate: (ScaleUpdateDetails details) {
    setState(() {
      zoom = details.scale;
      pan = details.focalPoint;
    });
  },
  child: CustomPaint(...),
)
```

### 10.5 애니메이션

#### 10.5.1 AnimationController

```dart
class _GameGridState extends State<GameGrid> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _zoomAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _zoomAnimation = Tween<double>(begin: 1.0, end: 2.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  void zoomIn() {
    _controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _zoomAnimation,
      builder: (context, child) {
        return CustomPaint(
          painter: GridPainter(zoom: _zoomAnimation.value),
        );
      },
    );
  }
}
```

#### 10.5.2 슬라이드 애니메이션

```dart
SlideTransition(
  position: Tween<Offset>(
    begin: Offset(1.0, 0.0),  // 오른쪽에서
    end: Offset.zero,
  ).animate(CurvedAnimation(
    parent: _controller,
    curve: Curves.easeInOut,
  )),
  child: GameInfoPanel(),
)
```

### 10.6 상태 관리 (Riverpod)

#### 10.6.1 Provider 정의

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

final zoomProvider = StateProvider<double>((ref) => 1.0);
final panProvider = StateProvider<Offset>((ref) => Offset.zero);
final selectedBlocksProvider = StateProvider<Set<String>>((ref) => {});
```

#### 10.6.2 사용

```dart
class GameGrid extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final zoom = ref.watch(zoomProvider);
    final pan = ref.watch(panProvider);
    final selectedBlocks = ref.watch(selectedBlocksProvider);

    return CustomPaint(
      painter: GridPainter(
        zoom: zoom,
        pan: pan,
        selectedBlocks: selectedBlocks,
      ),
    );
  }
}
```

#### 10.6.3 상태 업데이트

```dart
void handleZoom(double newZoom) {
  ref.read(zoomProvider.notifier).state = newZoom;
}
```

### 10.7 바텀시트

```dart
void showBlocksBottomSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => DraggableScrollableSheet(
      initialChildSize: 0.4,
      minChildSize: 0.2,
      maxChildSize: 0.9,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // 드래그 핸들
              Container(
                margin: EdgeInsets.only(top: 8),
                width: 48,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // 컨텐츠
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  itemCount: selectedBlocks.length,
                  itemBuilder: (context, index) {
                    return BlockListTile(block: selectedBlocks[index]);
                  },
                ),
              ),
            ],
          ),
        );
      },
    ),
  );
}
```

### 10.8 그라데이션

```dart
Container(
  decoration: BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Color(0xFF3D81F6),  // blue
        Color(0xFF875DF4),  // purple
      ],
    ),
    borderRadius: BorderRadius.circular(12),
  ),
)
```

### 10.9 Safe Area

```dart
SafeArea(
  child: Scaffold(
    body: ...,
  ),
)
```

### 10.10 패키지 추천

| 기능 | 패키지 |
|------|--------|
| 상태 관리 | `riverpod` / `provider` |
| 애니메이션 | `flutter_animate` |
| 그리드 렌더링 | `CustomPaint` (내장) |
| 제스처 | `GestureDetector` (내장) |
| HTTP | `dio` |
| GraphQL | `graphql_flutter` |
| 로컬 저장소 | `shared_preferences` |
| 캐싱 | `hive` / `isar` |
| 아이콘 | `lucide_icons` |

### 10.11 성능 최적화 (Flutter)

```dart
// 1. const 위젯 사용
const Text('Hello')

// 2. ListView.builder (lazy loading)
ListView.builder(
  itemCount: 1000,
  itemBuilder: (context, index) => ListTile(),
)

// 3. RepaintBoundary (리페인트 격리)
RepaintBoundary(
  child: CustomPaint(...),
)

// 4. Viewport Culling (자동)
// Flutter는 자동으로 뷰포트 밖 위젯 렌더링 생략
```

---

## 부록

### A. 색상 참조표 (Hex + Dart)

```dart
class AppColors {
  // Main Colors
  static const blue = Color(0xFF5C72F5);
  static const white = Color(0xFFFFFFFF);
  static const red = Color(0xFFFF5D5C);
  static const pink = Color(0xFFFF58BB);
  static const purple = Color(0xFF6E5AE9);
  static const green = Color(0xFF10B981);
  static const yellow = Color(0xFFF59E0B);

  // Background Colors
  static const deepwhite = Color(0xFFFCFCFC);
  static const whitegray = Color(0xFFFCFCFC);
  static const bluewhite = Color(0xFFECF1F9);
  static const disable = Color(0xFFDEDEDE);
  static const grayblue = Color(0xFF8A91B0);
  static const navywhite = Color(0xFF4B547F);
  static const navy = Color(0xFF2D3661);
  static const darkblue = Color(0xFF081245);

  // Stroke Colors
  static const bgwhite = Color(0xFFEFF2F7);
  static const bulegray = Color(0xFFDADBE3);
  static const navystroke = Color(0xFF2A3547);

  // Text Colors
  static const hint = Color(0xFFC5C9DC);
  static const black = Color(0xFF111111);
  static const dark = Color(0xFF333333);
  static const medium = Color(0xFF555555);
  static const light = Color(0xFF999999);
}
```

### B. 주요 컴포넌트 파일 경로

```
components/blockpick/
├── new-round/
│   ├── new-game-grid.tsx              (1,914 lines)
│   ├── new-game-overlay.tsx           (175 lines)
│   ├── new-game-info-panel.tsx        (268 lines)
│   ├── new-floating-controls.tsx      (74 lines)
│   ├── mobile-bottom-container.tsx    (296 lines)
│   ├── mobile-minimap.tsx             (182 lines)
│   ├── mobile-game-info-modal.tsx
│   ├── new-product-panel.tsx
│   └── new-zoom-panel.tsx
├── layout/
│   ├── header.tsx                     (361 lines)
│   ├── sidebar.tsx
│   └── footer.tsx
└── game/
    ├── planning-grid.tsx
    └── overlay/
        ├── game-overlay-layout.tsx
        ├── game-floating-controls.tsx
        ├── game-results-overlay.tsx
        ├── game-selection-info.tsx
        ├── game-sidebar-panel.tsx
        └── product-selection-panel.tsx
```

### C. 참고 자료

- [Framer Motion 문서](https://www.framer.com/motion/)
- [Tailwind CSS 문서](https://tailwindcss.com/)
- [Lucide Icons](https://lucide.dev/)
- [Flutter 공식 문서](https://flutter.dev/docs)
- [Riverpod 문서](https://riverpod.dev/)
- [CustomPaint Tutorial](https://api.flutter.dev/flutter/widgets/CustomPaint-class.html)

---

**문서 끝**

이 문서는 BlockPick 웹앱의 UI/UX를 Flutter 모바일 앱으로 마이그레이션하기 위한 완전한 명세를 제공합니다. 각 컴포넌트의 시각적 디자인, 인터랙션, 애니메이션, 그리고 Flutter 구현 방법이 상세히 기술되어 있습니다.
