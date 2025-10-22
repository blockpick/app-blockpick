# BlockPick UI/UX Specification Document
## For Flutter Migration

**Document Version:** 1.0  
**Last Updated:** October 22, 2024  
**Platform:** Next.js 15 → Flutter  
**Status:** Comprehensive UI Documentation

---

## Executive Summary

This document provides a detailed UI/UX specification for migrating BlockPick, a blockchain-based lottery/gaming platform, from Next.js to Flutter. It documents the complete visual design, component hierarchy, interaction patterns, animations, and state management flows.

**Key Statistics:**
- 35+ UI Components
- Multiple responsive layouts (desktop, tablet, mobile)
- 14+ color palette variants
- Complex grid rendering system (supports up to 1000x1000 cells)
- Advanced gesture controls and keyboard shortcuts
- State management via Zustand

---

## Table of Contents

1. [Design System](#design-system)
2. [Color Palette](#color-palette)
3. [Typography & Spacing](#typography--spacing)
4. [Component Hierarchy](#component-hierarchy)
5. [Screen Specifications](#screen-specifications)
6. [Interaction Patterns](#interaction-patterns)
7. [Animation Specifications](#animation-specifications)
8. [Mobile vs Desktop Differences](#mobile-vs-desktop-differences)
9. [Grid System & Rendering](#grid-system--rendering)
10. [State Management](#state-management)

---

## Design System

### Overview
BlockPick uses a modern, gradient-based design system with:
- Multi-layered UI with glassmorphism effects (backdrop blur)
- Smooth animations using Framer Motion (easeInOutCubic, spring physics)
- Responsive grid layout
- Clear visual hierarchy using color and shadow

### Design Principles
1. **Clarity**: Clear information hierarchy with distinct color coding
2. **Responsiveness**: Mobile-first approach with desktop enhancements
3. **Performance**: Optimized rendering for large grids (500x500 to 1000x1000 cells)
4. **Accessibility**: Keyboard shortcuts, hover states, visual feedback
5. **Consistency**: Unified component design across platforms

---

## Color Palette

### Primary Colors
| Name | Hex Value | Usage |
|------|-----------|-------|
| Blue | #5C72F5 | Primary CTA, buttons, highlights |
| Purple | #6E5AE9 | Secondary accents, gradients |
| Pink | #FF58BB | Alerts, featured content, gradients |
| Red | #FF5D5C | Destructive actions, errors |
| Green | #10B981 | Success, active states |
| Yellow | #F59E0B | Warnings, time-limited indicators |
| White | #FFFFFF | Backgrounds, text |

### Background Colors
| Name | Hex Value | Usage |
|------|-----------|-------|
| Deep White | #FCFCFC | Base background |
| Bluewhite | #ECF1F9 | Secondary background, hover state |
| Bgwhite | #EFF2F7 | Card backgrounds, borders |
| Whitegray | #FCFCFC | Alternative background |
| Disable | #DEDEDE | Disabled states |

### Text Colors
| Name | Hex Value | Hierarchy |
|------|-----------|-----------|
| Darkblue | #081245 | Primary (H1, Headlines) |
| Navy | #2D3661 | Secondary (body text) |
| Medium | #555555 | Tertiary (labels) |
| Light | #999999 | Quaternary (hints) |
| Hint | #C5C9DC | Disabled text, very light |

### Gradient Definitions
```
gradient-blue: linear-gradient(147deg, #3D81F6 0%, #875DF4 100%)
gradient-pink: linear-gradient(138deg, #FF58BB 6%, #FF5D5C 100%)
gradient-purple: linear-gradient(151deg, #E33FF4 0%, #6E5AE9 100%)
gradient-light: linear-gradient(146deg, #EFF6FF 4%, #F9F5FF 100%)
```

---

## Typography & Spacing

### Font Sizes (Tailwind-based)
- **H1/Display**: 32px (font-bold)
- **H2/Large**: 24px (font-bold)
- **H3/Medium**: 18px (font-semibold)
- **Body Large**: 16px (font-medium)
- **Body**: 14px (font-normal)
- **Body Small**: 12px (font-normal)
- **Caption**: 10px (font-normal)

### Font Weights
- **Bold**: 700
- **Semibold**: 600
- **Medium**: 500
- **Normal**: 400

### Spacing Scale (4px base)
- xs: 0.5rem (8px)
- sm: 0.75rem (12px)
- md: 1rem (16px)
- lg: 1.5rem (24px)
- xl: 2rem (32px)
- 2xl: 2.5rem (40px)
- 3xl: 3rem (48px)
- 4xl: 3.5rem (56px)

### Border Radius
- None: 0
- Small: 4px
- Medium: 8px
- Large: 16px (rounded-2xl default)
- Extra Large: 24px (rounded-3xl)

---

## Component Hierarchy

### Top-Level Layouts

#### 1. Main Layout (`NewGameOverlay`)
**Location**: `components/blockpick/new-round/new-game-overlay.tsx`

**Structure**:
```
NewGameOverlay (Full screen container)
├── Animated Background (gradient blur effects)
├── Main Content Area
│   ├── Game Grid (background)
│   ├── Left Sidebar (product selection - optional)
│   ├── Right Sidebar (game info - optional)
│   ├── Floating Controls (bottom center)
│   └── Settings Panel (overlay modal)
└── Status Indicators
```

**Props**:
- `gameTitle`: string
- `gameStatus`: "active" | "upcoming" | "ended"
- `timeLeft`: string
- `userBalance`: { points: number }
- `backgroundComponent`: React.ReactNode (game grid)
- `showSidebar`: boolean
- `sidebarContent`: React.ReactNode
- `gameContent`: React.ReactNode
- `floatingControls`: React.ReactNode

**Styling**:
- Background: gradient from bgwhite via bluewhite
- Animated pulse effects at corners (blur-3xl, opacity 20%)
- Z-layers: 10 (relative) for main content

---

### Grid Components

#### 2. New Game Grid (`NewGameGrid`)
**Location**: `components/blockpick/new-round/new-game-grid.tsx`

**Purpose**: High-performance grid rendering supporting up to 1000x1000 cells

**Key Features**:
- SVG-based grid rendering (not WebGL for performance)
- Zoom range: 0.05x to 2.5x (adaptive based on grid size)
- Pan/drag functionality with smooth transitions
- Keyboard shortcuts (Space, Q, E, Z, F, ?)
- Touch gestures (pinch-to-zoom, drag)
- Magnifier tool (Z key)

**Structure**:
```
NewGameGrid
├── Loading overlay (animation spinner)
├── Main grid container
│   ├── Ad background image (optional)
│   ├── SVG grid pattern
│   │   └── Dynamic pattern based on zoom level
│   ├── Cell icons overlay
│   │   ├── Selected blocks (selected.svg)
│   │   ├── Highlighted blocks (list-selected.svg)
│   │   ├── Past selections (past.svg)
│   │   ├── Winner indicators
│   │   └── Unique/Duplicate markers
│   ├── Zoom Controls (web only)
│   │   ├── Minus button
│   │   ├── Scale display
│   │   └── Plus button
│   ├── Grid Info Panel (web only)
│   ├── Selected Cell Info (web only)
│   ├── Adaptive Interaction Guide (web only)
│   ├── Magnifier Tool (overlay canvas)
│   └── Keyboard Help Modal (fullscreen)
└── Grid position overlay (visual feedback)
```

**Grid States**:
```typescript
interface GridState {
  zoom: number              // 0.05 - 2.5
  gridPosition: { x, y }    // Pan offset
  isDragging: boolean
  hasDragged: boolean       // Drag distance threshold
  keyboardMode: 'normal' | 'magnify'
  canSelectCells: boolean   // Based on cellSelectionThreshold
}
```

**Scale Levels (Adaptive)**:
The scale system is dynamic based on grid size:

| Grid Size | Scale Levels | Example |
|-----------|--------------|---------|
| 10x10 | 3 levels | 0.8x, 1.2x, 1.6x |
| 20x20 | 4 levels | 0.5x, 0.9x, 1.3x, 1.7x |
| 50x50 | 5 levels | 0.3x, 0.6x, 1.0x, 1.4x, 1.8x |
| 100x100 | 6 levels | 0.2x, 0.5x, 0.9x, 1.3x, 1.7x, 2.1x |
| 500x500 | 9 levels | 0.02x to 2.2x |
| 1000x1000 | 9 levels | 0.01x to 2.2x |

**Cell Selection Threshold**:
```
gridSize <= 100: 0.3x (lower zoom = can still select)
gridSize <= 500: 0.6x
gridSize <= 2000: 1.0x
gridSize > 2000: 1.4x (must zoom more)
```

**Rendering Optimization**:
- Sparse grid for large grids at low zoom (< 0.2x zoom on 500x500+ grids)
- LOD (Level of Detail) system with 6 thresholds
- Tile pooling for memory efficiency
- Dynamic grid step calculation based on viewport

**Cell Icons**:
- SVG paths rendered at cell positions
- Icons scale with zoom level (cellSize * zoom * 0.95)
- Grayscale filter applied to past selections

---

#### 3. Planning Game Grid (`PlanningGameGrid`)
**Location**: `components/blockpick/game/planning-grid.tsx`

**Purpose**: Alternative grid for planning phases

**Key Differences from NewGameGrid**:
- Canvas-based rendering (not SVG)
- Fixed 100x100 grid
- Zone-aware cell selection
- Different interaction model (zones instead of individual cells)
- Uses Zustand grid store for state

---

### Sidebar Components

#### 4. Product Panel (`NewProductPanel`)
**Location**: `components/blockpick/new-round/new-product-panel.tsx`

**Dimensions**:
- Width: 320px (w-80)
- Height: Full height of parent
- Position: Left sidebar (slides in from left, -300px initially)

**Structure**:
```
NewProductPanel
├── Header
│   ├── Title "상품 선택"
│   └── Close button (X)
│   └── Tab Navigation
│       ├── Products tab
│       ├── Info tab
│       └── Stats tab
├── Content Area (flex-1 overflow-y-auto)
│   └── Tab-specific content
│       ├── Products: Grid of product cards
│       ├── Info: Game details & description
│       └── Stats: Participation stats & win probability
└── Footer: (if any)
```

**Product Card**:
```
Product Card (rounded-xl, border-2)
├── Image: 64x64px thumbnail
├── Content
│   ├── Name (text-sm, truncated)
│   ├── Brand (text-xs)
│   ├── Price (text-lg, bold)
│   └── Description (text-xs, 2 lines max)
└── Selection state indicator
    └── Border color: blue/bulegray
    └── Background: bluewhite/white
```

**Tab Styling**:
- Active: bg-white, text-blue, border, shadow
- Inactive: text-navywhite, hover:text-darkblue

**Animation**: Framer Motion
- whileHover: scale 1.02
- whileTap: scale 0.98

---

#### 5. Game Info Panel (`NewGameInfoPanel`)
**Location**: `components/blockpick/new-round/new-game-info-panel.tsx`

**Dimensions**:
- Width: 384px (w-96)
- Height: Full height of parent
- Position: Right sidebar (slides in from right, 400px initially)

**Structure**:
```
NewGameInfoPanel (flex flex-col)
├── Game Info Section
│   ├── Header (p-4, border-b)
│   │   ├── Title & Close button
│   │   └── Tab navigation
│   │       ├── Game Status
│   │       └── Prize Info
│   └── Content (p-4)
│       ├── Game Stats Card
│       │   ├── Participants (Users icon)
│       │   ├── Total Blocks (Grid icon)
│       │   ├── Required Picks (Target icon)
│       │   └── Winners (Award icon)
│       ├── Progress Bar
│       │   ├── Progress indicator (pink, dynamic width)
│       │   └── Time remaining (Play icon)
│       └── Prize Info (conditional)
├── Selected Blocks Section (flex-1)
│   ├── Header (border-b)
│   │   ├── Count display
│   │   └── CLEAR button
│   └── Block List (overflow-y-auto, p-4)
│       ├── Empty state (Target icon + message)
│       └── Block items (clickable, zoom on click)
│           ├── Target icon
│           ├── Coordinates (Row × Column)
│           └── Remove button (X)
└── Confirm Button
    ├── State: Enabled/Disabled
    ├── Style: Gradient blue-purple
    └── Content: Cost info + Select blocks text
```

**Block List Item Animation**:
```typescript
motion.div
  whileHover={{ scale: 1.02 }}
  whileTap={{ scale: 0.98 }}
  className="hover:bg-bluewhite hover:border-blue"
```

---

### Floating Controls

#### 6. Floating Controls (`NewFloatingControls`)
**Location**: `components/blockpick/new-round/new-floating-controls.tsx`

**Structure**:
```
NewFloatingControls (flex gap-3)
├── Individual control buttons
│   ├── Motion wrapper (scale animation, delay)
│   ├── Link or Button
│   ├── Styling:
│   │   ├── Size: w-12 h-12 (mobile: w-11 h-11)
│   │   ├── Background: white/90 with backdrop blur
│   │   ├── Border: bulegray
│   │   ├── Shape: rounded-xl
│   │   └── Shadow: lg, hover:shadow-xl
│   └── Tooltip (hidden on mobile)
```

**Button Animations**:
```
whileHover: scale 1.1
whileTap: scale 0.95
transition: spring physics
```

---

### Mobile-Specific Components

#### 7. Mobile Bottom Container (`MobileBottomContainer`)
**Location**: `components/blockpick/new-round/mobile-bottom-container.tsx`

**Purpose**: Fixed bottom action area for mobile with draggable sheet

**States**:
- `closed`: Only drag handle visible
- `peek`: 3 blocks visible + 200px height
- `expanded`: Full 40vh height

**Structure**:
```
MobileBottomContainer
├── Draggable Bottom Sheet (z-60)
│   ├── Drag Handle (w-12 h-1)
│   ├── Sheet Header (gradient bg)
│   │   ├── Cost Info Card
│   │   │   ├── Hash icon
│   │   │   ├── "선택된 블록" label
│   │   │   ├── Count (bold)
│   │   │   └── Total cost (gradient text)
│   │   ├── Recent Coordinates Card
│   │   │   ├── Grid icon
│   │   │   └── Latest row × col
│   │   └── Control Buttons
│   │       ├── MapPin icon + hint
│   │       ├── Trash (clear) button
│   │       ├── Expand/collapse button
│   │       └── Close (X) button
│   └── Block List
│       ├── Animated list (popLayout mode)
│       ├── Block items
│       │   ├── Index badge (1-9)
│       │   ├── Coordinates
│       │   ├── Block ID
│       │   └── Remove button
│       └── "More" button (if peek mode & overflow)
└── Fixed Bottom Button (z-50, pb-safe)
    ├── State-dependent styling
    │   ├── Disabled: gradient-disable, opacity-50
    │   └── Enabled: gradient blue-purple-pink
    ├── Lock icon (if disabled)
    ├── Zap icon (if enabled)
    └── Text: Block count + "참가하기"
```

**Drag Gestures**:
- Swipe down > 100px: Close
- Swipe down 50-100px: Peek state
- Swipe up > 50px: Expand
- Elastic: 0.2 (20% overdrag)

**Dimensions**:
- Button height: 80px (fixed)
- Peek height: min(blocks.length * 72 + 200, 350px)
- Expanded: 40vh

---

#### 8. Mobile Minimap (`MobileMinimap`)
**Location**: `components/blockpick/new-round/mobile-minimap.tsx`

**Purpose**: Navigation aid for large grids

**Dimensions**:
- Default: 100x100px
- Expanded: 160x160px
- Position: Fixed bottom-right (bottom-48, right-4)
- Z-index: 40

**Rendering**:
- Canvas-based (not SVG)
- Grid background: #f1f5f9
- Grid lines: #e2e8f0 (step-based for large grids)
- Selected blocks: rgba(59, 130, 246, 0.6)
- Viewport rect: rgba(239, 68, 68, 0.8)

**Interaction**:
- Click to navigate to that grid position
- Toggle expand/collapse button
- Drag events are not interactive (view-only)

---

#### 9. Mobile Game Info Modal (`MobileGameInfoModal`)
**Location**: `components/blockpick/new-round/mobile-game-info-modal.tsx`

**Positioning**:
- Fixed bottom-0 inset-x-0
- Max height: 85vh
- Rounded-t-3xl (top corners only)
- Swipe down to close

**Structure**:
```
MobileGameInfoModal (bottom sheet)
├── Drag Handle
├── Header
│   ├── Icon + Title + "게임 정보"
│   └── Close button
│   └── Tab navigation
│       ├── Status tab (TrendingUp icon)
│       └── Prize tab (Package icon)
├── Content (overflow-y-auto)
│   ├── Status tab content
│   │   ├── Progress Card
│   │   │   ├── Label + percentage
│   │   │   ├── Animated progress bar
│   │   │   └── Stat display
│   │   └── Stats Grid (2 cols × 2 rows)
│   │       ├── Participants (Users icon, blue)
│   │       ├── Total Blocks (Grid icon, purple)
│   │       ├── Winners (Award icon, pink)
│   │       └── Time Left (Clock icon, green)
│   └── Prize tab content
│       ├── Product Info Card
│       │   ├── Icon + Title
│       │   └── Details (brand, price, qty, shipping)
│       └── Participation Guide
└── Backdrop blur overlay (black/60, z-60)
```

**Animations**:
- Entry: spring physics (damping: 30, stiffness: 300)
- Stats cards: staggered fade-in with x translation
- Progress bar: animated width over 1s

---

### Header Component

#### 10. Main Header (`MainHeader`)
**Location**: `components/blockpick/layout/header.tsx`

**Sticky positioning**: top-0 z-30

**Two Layout Modes**:

**Mode 1: Game Detail Page**
```
Header (Game page layout)
├── Left: Back button (ArrowLeft icon)
├── Center: Cash + Points display
│   ├── Wallet icon + Cash (blue)
│   └── Points display (purple)
└── Right: User profile button + dropdown
    ├── Avatar circle (gradient blue-purple)
    ├── First letter initial
    ├── Online indicator (green dot)
    └── Dropdown menu (if open)
        ├── User info section
        │   ├── Nickname/email
        │   ├── Role badge
        └── Menu items
            ├── My Profile
            ├── My Wallet
            ├── My Pick
            ├── Logout
```

**Mode 2: Default Pages**
```
Header (Regular page layout)
├── Left section
│   ├── Sidebar toggle (Menu icon)
│   └── Search form
│       └── Input field (w-64)
├── Right section
│   ├── Wallet info (if logged in)
│   │   ├── Cash (blue)
│   │   └── Points (purple)
│   ├── My Pick link
│   ├── Language dropdown (Globe icon)
│   │   └── 4 languages (KO, EN, JA, ZH)
│   └── User profile (same as above)
```

**Styling**:
- Background: white
- Border-bottom: bulegray
- Dropdown: absolute right-0, mt-2, w-56, shadow-lg, z-50

---

## Screen Specifications

### 1. New Round Game Screen

**URL**: `/[locale]/(default)/new-round`

**Full Page Structure**:
```
NewRoundPage
├── Header (MainHeader)
├── Main Content (NewGameOverlay)
│   ├── Game Grid (NewGameGrid)
│   ├── Left Sidebar (NewProductPanel) - slide in
│   ├── Right Sidebar (NewGameInfoPanel) - slide in
│   ├── Floating Controls (NewFloatingControls) - bottom center
│   └── Mobile Container (MobileBottomContainer) - mobile only
└── Mobile Minimap (MobileMinimap) - mobile only
```

**Responsive Behavior**:

**Desktop (≥1024px)**:
- Full header with all options visible
- Product panel: left sidebar (320px wide)
- Game info panel: right sidebar (384px wide)
- Grid: center area
- Floating controls: bottom center, 3 buttons
- Zoom controls: bottom-left corner
- Grid info: top-left
- Keyboard help: enabled

**Tablet (768px-1023px)**:
- Compact header
- Product panel: overlay sidebar or modal
- Game info: overlay sidebar or modal
- Floating controls: centered, 2 buttons
- Grid: fills remaining space
- Zoom controls: visible but smaller

**Mobile (<768px)**:
- Simplified header (back, cash, user profile)
- No sidebars (content in modals/bottom sheets)
- Full-width grid
- Mobile bottom container (draggable sheet)
- Minimap: fixed bottom-right
- Floating controls: hidden or single button
- Simplified grid info (no overlay panels)

---

### 2. Game Results Screen

**Visual State**: After game ends

**Grid Rendering Changes**:
- Selected blocks: show with `past.svg` icon (grayscale)
- Winner cell: highlighted with winner indicator
- Unique cells: marked with `unique` state
- Duplicate cells: marked with `duplicate` state
- All icons: applied grayscale(0.5) filter

**Overlay Elements**:
- Results modal: centered, showing:
  - Winner announcement
  - Prize details
  - Participation stats
  - Option to play again

---

### 3. My Pick Screen

**Purpose**: User's game history and saved picks

**Components Used**:
- My Pick Achievements
- My Pick Game History
- My Pick Participated Games
- My Pick Wishlist
- My Pick Game Cards

---

### 4. Planning Screen

**Alternative Grid Interface**:
- Uses `PlanningGameGrid` instead of `NewGameGrid`
- Canvas rendering
- Zone-based selection
- Participants toggle to show other players

---

## Interaction Patterns

### Desktop Interactions

#### Grid Interactions

**Mouse Wheel Zoom**:
```
1. Accumulate wheelDelta over 100ms
2. If accumulated > WHEEL_THRESHOLD (100):
   a. Calculate target zoom from SCALE_LEVELS
   b. Animate zoom with easeInOutCubic (300ms)
   c. Adjust grid position to maintain mouse position
3. Reset accumulator after 100ms idle
```

**Mouse Drag Pan**:
```
1. On mouseDown: record start position, setIsDragging = true
2. On mouseMove:
   a. Calculate dx, dy
   b. If distance > 5px: setHasDragged = true
   c. Update gridPosition (x += dx, y += dy)
3. On mouseUp: setIsDragging = false
4. On grid click:
   a. If hasDragged: ignore click (was panning)
   b. Else if zoom >= cellSelectionThreshold: select cell
   c. Else: zoom to cell area (2x current zoom)
```

**Shift + Click Smart Zoom**:
```
1. Click with Shift held
2. Toggle between:
   a. Normal zoom: 0.8x
   b. Optimal zoom: calculated per grid size
3. Animate to cell center
```

#### Keyboard Shortcuts

| Key | Action | Mode |
|-----|--------|------|
| Space | Zoom toggle at mouse position | Normal |
| Q | Quick zoom (1.3x current) | Normal |
| E | Fit entire grid to view | Normal |
| Z | Toggle magnifier mode (hold) | Normal |
| F | Focus on selected cell | Normal |
| ? or / | Show keyboard help | Normal |
| ESC | Deactivate modes | Any |

#### Magnifier Tool (Z Key)

**Visual**:
- Circular 200x200px overlay
- 3x magnification
- Position: mouse position + 20px offset
- Red crosshair at center
- Border: 4px white
- Shadow: drop shadow 10px

**Interaction**:
- Shows actual screen content magnified
- Updates in real-time with mouse movement
- Release Z key to deactivate

---

### Mobile Interactions

#### Touch Pan**:
```
1. On touchStart (1 finger):
   a. Record start position
   b. setIsTouching = true
2. On touchMove:
   a. Calculate dx, dy
   b. If distance > 3px: setHasDragged = true
   c. Update gridPosition
3. On touchEnd:
   a. setIsTouching = false
   b. setHasDragged = false
```

#### Pinch-to-Zoom**:
```
1. On touchStart (2 fingers):
   a. Calculate distance between points
   b. Record center point
   c. Record current zoom
2. On touchMove:
   a. New distance = distance(touch1, touch2)
   b. scale = newDistance / oldDistance
   c. newZoom = startZoom * scale
   d. Clamp zoom to [dynamicMinZoom, maxZoom]
   e. Update gridPosition to keep center fixed
3. On touchEnd:
   a. Snap to nearest SCALE_LEVEL
```

#### Bottom Sheet Gestures**:
```
1. Drag handle: drag.y constraint
2. On dragEnd:
   a. offset.y > 100: close sheet
   b. offset.y > 50: peek state
   c. offset.y < -50: expand state
3. Drag elastic: 0.2 (20% overdrag)
```

#### Minimap Click**:
```
1. On canvas click:
   a. Get click position relative to canvas
   b. Convert to grid coordinates
   c. Pan grid to show that area
   d. Animate with spring physics
```

---

## Animation Specifications

### Framework
- **Library**: Framer Motion (v10+)
- **Default Easing**: easeInOutCubic for most transitions
- **Spring Physics**: damping: 25, stiffness: 200 (for overlays)

### Animation Catalog

#### 1. Sidebar Animations
```typescript
// Product Panel Entry
initial={{ x: -300, opacity: 0 }}
animate={{ x: 0, opacity: 1 }}
exit={{ x: -300, opacity: 0 }}
transition={{ type: "spring", damping: 25, stiffness: 200 }}

// Game Info Panel Entry
initial={{ x: 400, opacity: 0 }}
animate={{ x: 0, opacity: 1 }}
exit={{ x: 400, opacity: 0 }}
transition={{ type: "spring", damping: 25, stiffness: 200 }}
```

#### 2. Button Animations
```typescript
// Hover & Tap
whileHover={{ scale: 1.1 }}
whileTap={{ scale: 0.95 }}

// Floating Controls - Staggered
initial={{ scale: 0, opacity: 0 }}
animate={{ scale: 1, opacity: 1 }}
transition={{ delay: index * 0.1 }}
```

#### 3. List Animations
```typescript
// List Item (PopLayout mode for reordering)
layout
initial={{ opacity: 0, x: -20, scale: 0.9 }}
animate={{ opacity: 1, x: 0, scale: 1 }}
exit={{ opacity: 0, x: 20, scale: 0.9 }}
transition={{ delay: index * 0.05 }}

// AnimatePresence with mode="popLayout"
// Allows smooth reordering when items removed
```

#### 4. Modal Animations
```typescript
// Overlay
initial={{ opacity: 0 }}
animate={{ opacity: 1 }}
exit={{ opacity: 0 }}

// Modal Content
initial={{ y: 20, opacity: 0 }}
animate={{ y: 0, opacity: 1 }}
exit={{ y: 20, opacity: 0 }}

// Mobile Bottom Sheet
initial={{ y: '100%', opacity: 0 }}
animate={{ y: 0, opacity: 1 }}
exit={{ y: '100%', opacity: 0 }}
transition={{ type: 'spring', damping: 30, stiffness: 300 }}
```

#### 5. Progress Bar Animation
```typescript
// Animated width
initial={{ width: 0 }}
animate={{ width: `${percentage}%` }}
transition={{ duration: 1, ease: 'easeOut' }}
```

#### 6. Zoom Animation
```typescript
// Smooth zoom with easeInOutCubic
// Duration: 300ms
// Maintains mouse position as pivot point
```

#### 7. Loading State
```typescript
// Spinner
<div className="animate-spin rounded-full h-12 w-12 border-b-2 border-blue" />

// Overlay with blur
className="bg-black/50 backdrop-blur-sm"
```

---

## Mobile vs Desktop Differences

### Navigation

| Aspect | Desktop | Mobile |
|--------|---------|--------|
| Header menu | Full width with search | Simplified (back, cash, user) |
| Sidebars | Persistent overlays | Bottom sheets/modals |
| Controls | Top/bottom fixed | Floating/bottom sheet |
| Zoom info | Visible panels | Hidden/modal |

### Grid Display

| Aspect | Desktop | Mobile |
|--------|---------|--------|
| Cell icons | Always visible | Scale with zoom |
| Zoom controls | Visible buttons | In floating button |
| Grid info overlay | Top-left panel | Modal on demand |
| Keyboard shortcuts | Full (9 shortcuts) | Limited/disabled |

### Touch Handling

| Aspect | Desktop | Mobile |
|--------|---------|--------|
| Zoom method | Mouse wheel | Pinch gesture |
| Pan method | Mouse drag | Touch drag |
| Selection | Click at threshold | Tap at threshold |
| Cursor | grab/grabbing | default |

### Bottom Sheet

| State | Height | Content |
|-------|--------|---------|
| Closed | 0 | Drag handle only |
| Peek | min(blocks*72+200, 350px) | 3 blocks + controls |
| Expanded | 40vh | All blocks |

### Responsive Breakpoints

```
Mobile: < 768px
  - Full-width grid
  - Bottom sheet for blocks
  - Minimap enabled
  - No zoom controls visible
  
Tablet: 768px - 1023px
  - Grid with sidebar toggle
  - Product/info panels as overlay
  - Compact header
  - Zoom controls in toolbar
  
Desktop: ≥ 1024px
  - 3-column layout (sidebar | grid | sidebar)
  - Persistent panels
  - Full header with search
  - All UI elements visible
```

---

## Grid System & Rendering

### Architecture

**Performance Optimization Strategy**:
1. **Sparse Grid Data Structure**: Only stores tiles with state != 'empty'
2. **Object Pool**: Recycles TileData objects
3. **LOD System**: Renders different detail levels based on zoom
4. **SVG Rendering**: Not WebGL (simpler, more compatible)
5. **Pattern Caching**: Memoized grid patterns

### Tile Pool

```typescript
class TilePool {
  acquire(row, col): TileData
  release(tile): void
  clear(): void
}

// Reduces GC pressure, improves performance
```

### Sparse Grid Data Structure

```typescript
class SparseGrid {
  tiles: Map<string, TileData>  // Only non-empty tiles
  getTile(row, col)
  setTile(row, col, state)
  getVisibleTiles(bounds)
}
```

### LOD (Level of Detail) System

```typescript
class LODManager {
  static readonly LOD_THRESHOLDS = [0.05, 0.1, 0.3, 0.6, 1.0, 2.0]
  
  getLODLevel(zoom): 0-5
  shouldRenderTile(lodLevel, tileSize): boolean
  getGridStep(lodLevel, zoom, gridSize): number
}
```

### Grid Pattern Rendering

```typescript
// SVG Pattern for infinite tiling
<pattern id={`grid-${gridSize}-${zoom}`}>
  <path d={`M ${cellSize} 0 L 0 0 0 ${cellSize}`}
    stroke={colorByZoom}
    strokeWidth={widthByZoom}
    vectorEffect="non-scaling-stroke"
  />
</pattern>

// Usage
<rect fill={`url(#grid-...)`} width="100%" height="100%" />
```

### Cell Icon Rendering

```typescript
// Rendered as HTML elements overlaid on grid
// Icons: selected.svg, list-selected.svg, past.svg
// Size: cellSize * zoom * 0.95
// Position: transform(col * cellSize * zoom, row * cellSize * zoom)
// States:
//   - selected: normal
//   - highlighted: list-selected.svg
//   - results: past.svg with grayscale(0.5)
//   - animating: pulse animation
```

### Dynamic Grid Size Support

| Grid Size | Initial Zoom | Min Zoom | Max Zoom | Cell Selection |
|-----------|--------------|----------|----------|-----------------|
| 10×10 | 0.8 | 0.8 | 1.6 | 0.3 |
| 20×20 | 0.5 | 0.5 | 1.7 | 0.3 |
| 100×100 | 0.2 | 0.2 | 2.1 | 0.3 |
| 500×500 | 0.02 | 0.02 | 2.2 | 0.6 |
| 1000×1000 | 0.01 | 0.01 | 2.2 | 1.0 |

---

## State Management

### Zustand Store Architecture

#### Grid Store (`useGridStore`)
```typescript
interface GridState {
  zoom: number
  wireframe: boolean
  autoRotate: boolean
  centerOnCell: number | null
  setZoom: (zoom) => void
  toggleWireframe: () => void
  toggleAutoRotate: () => void
  resetCamera: () => void
  setCenterOnCell: (cell) => void
}

// Usage: useGridStore((state) => state.zoom)
```

#### Component Local State

**NewGameGrid State**:
```typescript
const [zoom2D, setZoom2D] = useState(1)
const [gridPosition, setGridPosition] = useState({ x: 0, y: 0 })
const [isDragging, setIsDragging] = useState(false)
const [dragStart, setDragStart] = useState({ x: 0, y: 0 })
const [hasDragged, setHasDragged] = useState(false)
const [isLoading, setIsLoading] = useState(true)
const [imageError, setImageError] = useState(false)
const [touchStartDistance, setTouchStartDistance] = useState(null)
const [keyboardMode, setKeyboardMode] = useState('normal')
const [mousePosition, setMousePosition] = useState({ x: 0, y: 0 })
const [currentScaleIndex, setCurrentScaleIndex] = useState(0)
```

**Mobile Container State**:
```typescript
const [sheetState, setSheetState] = useState<'closed' | 'peek' | 'expanded'>('peek')
```

**Product Panel State**:
```typescript
const [activeTab, setActiveTab] = useState<'products' | 'info' | 'stats'>('products')
const [imageErrors, setImageErrors] = useState<Record<string, boolean>>({})
```

### Game State Flow

```
Game States: "selecting" | "processing" | "results"

selecting:
  - Can click to select cells
  - Grid interactive
  - Display selected blocks

processing:
  - Grid disabled
  - Loading animation
  - Cannot interact

results:
  - Show winner
  - Show unique/duplicate cells
  - Display game stats
  - Can't select new blocks
  - Option to play again
```

### Data Structure Examples

```typescript
// Selected Block
interface Block {
  row: number         // 1-based
  col: number         // 1-based
  id: string          // unique identifier
}

// Game Results
interface GameResults {
  winnerCell: number | null
  winnerProduct: any
  uniqueCells: number[]
  playerSelections: Record<number, number>  // cell -> count
  wonPrize: boolean
  pointsEarned: number
}

// Grid Tile
interface TileData {
  id: string
  row: number
  col: number
  state: 'empty' | 'selected' | 'winner' | 'unique' | 'duplicate'
  lastUpdated: number
}

// Game Stats
interface GameStats {
  participants: number
  totalBlocks: number
  requiredPicks: number
  maxPicks: number
  winners: number
  timeLeft: string
}
```

---

## Implementation Notes for Flutter Migration

### Key Considerations

1. **Grid Rendering**
   - Use CustomPaint or Skia Canvas (not WebGL)
   - Implement LOD system in Dart
   - Sparse grid data structure translates well
   - SVG patterns → Canvas drawing code

2. **Animations**
   - Use Flutter's AnimationController with Curves
   - Spring animations: use SpringDescription for physics
   - Gesture animations for drag/pan
   - Duration: 300ms for standard, 1s for progress bars

3. **Touch Gestures**
   - GestureDetector for drag detection
   - ScaleGestureRecognizer for pinch-zoom
   - LongPressGestureRecognizer for magnifier activation

4. **State Management**
   - Riverpod or Provider (instead of Zustand)
   - StateNotifier for complex state
   - Consider bloc_pattern for game flow

5. **Responsive Design**
   - Use MediaQuery.of(context) for breakpoints
   - LayoutBuilder for flexible layouts
   - Stack for overlay positioning
   - PageView for bottom sheets

6. **Color System**
   - Create Color constants matching hex values
   - Gradient system: LinearGradient, RadialGradient
   - Use Extensions for color opacity variants

7. **Keyboard Shortcuts**
   - RawKeyboardListener for desktop
   - HardwareKeyboard API
   - Focus management with FocusNode

8. **Mobile Safe Area**
   - SafeArea widget for notch/cutout handling
   - ViewInsets for keyboard detection

---

## Performance Targets

- **Grid Render**: < 60ms (60 FPS)
- **Zoom Animation**: 300ms (smooth)
- **Pan Sensitivity**: Real-time (<16ms latency)
- **Memory Usage**: < 100MB for 1000×1000 grid
- **Tile Pool Size**: 500-1000 tiles
- **Max Visible Cells**: 25,000 at LOD 3

---

## Accessibility Features

- ✅ Keyboard shortcuts (? shows help)
- ✅ High contrast colors
- ✅ Clear visual hierarchy
- ✅ Touch target sizes: min 44×44px
- ✅ Alt text for icons
- ✅ Semantic HTML/Flutter widgets
- ✅ Focus indicators
- ✅ Haptic feedback (consider for mobile)

---

## Browser / Platform Support

**Web**:
- Chrome 90+
- Firefox 88+
- Safari 14+
- Edge 90+

**Mobile (via Flutter)**:
- iOS 12+
- Android 5.0+
- Tablet (iPad, Android tablets)

---

## Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.0 | Oct 22, 2024 | Initial comprehensive specification |

---

## Appendix: File Reference

### Component Files
- NewGameGrid: `components/blockpick/new-round/new-game-grid.tsx` (1914 lines)
- NewGameOverlay: `components/blockpick/new-round/new-game-overlay.tsx`
- NewGameInfoPanel: `components/blockpick/new-round/new-game-info-panel.tsx`
- NewProductPanel: `components/blockpick/new-round/new-product-panel.tsx`
- MobileBottomContainer: `components/blockpick/new-round/mobile-bottom-container.tsx`
- MobileMininimap: `components/blockpick/new-round/mobile-minimap.tsx`
- MobileGameInfoModal: `components/blockpick/new-round/mobile-game-info-modal.tsx`
- MainHeader: `components/blockpick/layout/header.tsx`

### Configuration Files
- Tailwind Config: `tailwind.config.ts`
- Grid Store: `lib/grid-store.ts`

### Styling Files
- Global CSS: `styles/globals.css`

---

**Document ends.**
