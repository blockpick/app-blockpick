# BlockPick UI/UX Analysis Summary

## Overview
Comprehensive UI/UX specification document created for BlockPick's migration from Next.js 15 to Flutter.

## Document Location
- **Main Document**: `/BLOCKPICK_UI_UX_SPECIFICATION.md` (1,280 lines)

## Key Findings

### 1. Component Architecture (35+ Components)

**Core Grid Components**:
- `NewGameGrid` (1,914 lines) - High-performance grid rendering
- `PlanningGameGrid` - Alternative grid for planning phases
- Grid rendering: SVG-based, not WebGL

**Layout Components**:
- `NewGameOverlay` - Full-screen game container
- `MainHeader` - Navigation header
- Layout management with z-index layering

**Sidebar Components**:
- `NewProductPanel` (320px width, slide-in from left)
- `NewGameInfoPanel` (384px width, slide-in from right)
- Tabbed interfaces (Products/Info/Stats)

**Mobile-Specific Components**:
- `MobileBottomContainer` - Draggable sheet with 3 states (closed/peek/expanded)
- `MobileSelectedBlocksSheet` - Block selection interface
- `MobileMinimap` - 100x160px canvas minimap
- `MobileGameInfoModal` - Bottom-sheet modals

**Control Components**:
- `NewFloatingControls` - Floating action buttons
- Zoom controls, grid info overlays
- Keyboard help modal

### 2. Color Palette (14+ Colors)

**Primary Colors**:
- Blue: #5C72F5 (CTAs)
- Purple: #6E5AE9 (Accents)
- Pink: #FF58BB (Alerts)
- Red: #FF5D5C (Destructive)
- Green: #10B981 (Success)
- Yellow: #F59E0B (Warnings)

**Background Colors**:
- Bluewhite: #ECF1F9
- Bgwhite: #EFF2F7
- Disable: #DEDEDE

**Text Colors**:
- Darkblue: #081245
- Navy: #2D3661
- Medium: #555555
- Hint: #C5C9DC

**Gradients**:
- gradient-blue
- gradient-pink
- gradient-purple
- gradient-light

### 3. Grid System Specifications

**Rendering Technology**:
- SVG patterns for grid lines (not WebGL)
- Sparse grid data structure
- Object pooling for memory efficiency
- LOD (Level of Detail) system with 6 thresholds

**Supported Grid Sizes**:
- Small: 10x10
- Medium: 20x20, 50x50
- Large: 100x100
- Very Large: 500x500
- Massive: 1000x1000

**Zoom Ranges (Adaptive)**:
- Min: 0.01x (for 1000x1000) to 0.8x (for 10x10)
- Max: 1.6x to 2.2x depending on grid size
- Smooth animation: 300ms easeInOutCubic

**Cell Selection Thresholds**:
- 10-100px grids: 0.3x zoom required
- 500px grid: 0.6x zoom required
- 2000px grid: 1.0x zoom required
- 10000px grid: 1.4x zoom required

### 4. Interaction Patterns

**Desktop**:
- Mouse wheel zoom (accumulated delta over 100ms)
- Mouse drag pan with 5px threshold
- Shift+Click smart zoom
- 9 keyboard shortcuts (Space, Q, E, Z, F, ?)
- Magnifier tool (Z key, 3x magnification)

**Mobile**:
- Single-touch drag pan
- Pinch-to-zoom (2-finger gesture)
- Bottom sheet drag (3 states)
- Minimap click navigation

### 5. Animation System

**Library**: Framer Motion
- Standard easing: easeInOutCubic
- Spring animations: damping 25, stiffness 200
- List animations: staggered with popLayout mode
- Duration: 300ms (zoom), 1s (progress), 16ms (60 FPS)

**Animation Types**:
- Sidebar transitions (spring physics)
- Button hover/tap (scale 1.1 / 0.95)
- Progress bars (animated width)
- Loading spinners (infinite rotation)
- Drag gestures (elastic 0.2)

### 6. Responsive Design

**Breakpoints**:
- Mobile: < 768px (full-width grid)
- Tablet: 768px-1023px (sidebar toggle)
- Desktop: >= 1024px (3-column layout)

**Mobile Features**:
- Bottom sheet for blocks
- Minimap for navigation
- Simplified header
- Touch-first interactions
- Safe area handling

**Desktop Features**:
- Persistent sidebars
- Zoom controls visible
- Keyboard shortcuts enabled
- Grid info overlays
- Search functionality

### 7. State Management

**Framework**: Zustand
- Grid store: zoom, wireframe, autoRotate, centerOnCell
- Local component state in React hooks
- Game state: "selecting" | "processing" | "results"

**Key State Variables**:
- zoom2D (0.01 to 2.5)
- gridPosition { x, y }
- isDragging, hasDragged
- touchStartDistance, touchStartZoom
- keyboardMode (normal | magnify)
- sheetState (closed | peek | expanded)

### 8. Performance Optimizations

**Rendering**:
- Sparse grid (only non-empty tiles stored)
- Object pool (TilePool with acquire/release)
- Memoized grid patterns
- LOD system for large grids
- Canvas vs SVG selection based on context

**Memory Management**:
- Max visible cells: 25,000 at LOD 3
- Tile pool size: 500-1000
- Memory target: < 100MB for 1000x1000

**Interaction**:
- Debounced scale index updates
- Accumulated wheel delta (threshold 100)
- 5px drag threshold
- Elastic touch gestures (20% overdrag)

### 9. Mobile vs Desktop Key Differences

| Aspect | Desktop | Mobile |
|--------|---------|--------|
| Grid interactive | Always | Touch-based |
| Sidebars | Persistent | Bottom sheets |
| Zoom control | Visible buttons | Pinch gesture |
| Pan method | Mouse drag | Touch drag |
| Keyboard | Full shortcuts | Limited |
| Touch target | 44px minimum | 48-56px |
| Header | Full navigation | Simplified |

### 10. Flutter Migration Considerations

**Rendering**:
- Use CustomPaint/Canvas (not Skia WebGL)
- Implement sparse grid in Dart
- Convert SVG patterns to Canvas drawing
- LOD system translates well

**Animations**:
- AnimationController + Curves
- SpringDescription for physics
- GestureDetector for pan
- ScaleGestureRecognizer for zoom

**State**:
- Riverpod or Provider (not Zustand)
- StateNotifier for complex state
- Consider bloc_pattern for game flow

**UI Widgets**:
- Stack for layering
- GestureDetector for touch
- CustomPaint for grid
- PageView for bottom sheets
- SafeArea for notches

---

## Document Structure

### Sections Included

1. **Design System** - Principles and approach
2. **Color Palette** - 14+ colors with usage
3. **Typography & Spacing** - Font sizes, weights, spacing scale
4. **Component Hierarchy** - Detailed component tree
5. **Screen Specifications** - Full page layouts
6. **Interaction Patterns** - Desktop and mobile interactions
7. **Animation Specifications** - Framer Motion catalog
8. **Mobile vs Desktop** - Comparison table
9. **Grid System & Rendering** - Architecture details
10. **State Management** - Data structures and flows
11. **Implementation Notes** - Flutter migration guide
12. **Performance Targets** - Benchmarks and goals
13. **Accessibility Features** - A11y compliance
14. **Browser/Platform Support** - Compatibility matrix

### Total Coverage

- **35+ UI Components** documented
- **14+ Color variants** specified
- **9 Keyboard shortcuts** listed
- **3 Grid types** analyzed
- **6 LOD levels** defined
- **Multiple animation patterns** cataloged
- **3 responsive breakpoints** detailed
- **2 rendering engines** compared (SVG vs WebGL)

---

## Key Metrics

| Metric | Value |
|--------|-------|
| Document lines | 1,280 |
| Components analyzed | 35+ |
| Color variants | 14+ |
| Keyboard shortcuts | 9 |
| LOD levels | 6 |
| Responsive breakpoints | 3 |
| Animation types | 7+ |
| Grid sizes supported | 6 |

---

## Critical Implementation Details for Flutter

### Grid Rendering
- Canvas-based (not WebGL)
- Sparse grid pattern optimization
- Tile pooling essential for large grids
- LOD system critical for 500x500+ grids

### Touch Interactions
- Pinch-to-zoom: GestureDetector with scale factor
- Pan: OnPanUpdate with accumulated deltas
- Drag threshold: 3-5px minimum movement
- Elastic overdrag: 0.2 (20%)

### Animation Timing
- Standard transitions: 300ms easeInOutCubic
- Spring animations: damping 25, stiffness 200
- Progress animations: 1s easeOut
- Frame rate target: 60 FPS

### State Management
- Separate stores for grid and game state
- Local state for UI interactions
- Reactive updates on state changes
- Memoization for expensive calculations

---

## Files Referenced

**Component Files**:
- `/components/blockpick/new-round/new-game-grid.tsx`
- `/components/blockpick/new-round/new-game-overlay.tsx`
- `/components/blockpick/new-round/new-game-info-panel.tsx`
- `/components/blockpick/new-round/new-product-panel.tsx`
- `/components/blockpick/new-round/mobile-bottom-container.tsx`
- `/components/blockpick/new-round/mobile-minimap.tsx`
- `/components/blockpick/new-round/mobile-game-info-modal.tsx`
- `/components/blockpick/layout/header.tsx`

**Configuration**:
- `/tailwind.config.ts`
- `/lib/grid-store.ts`
- `/styles/globals.css`

---

## Next Steps for Flutter Development

1. **Design System Setup**
   - Create Color constants matching hex values
   - Set up Gradient system
   - Define Typography extensions

2. **Grid Component**
   - Implement Canvas-based grid
   - Create sparse grid data structure
   - Implement LOD system
   - Add gesture handlers

3. **Component Migration**
   - Convert layout components (NewGameOverlay → Stack)
   - Migrate sidebars (to Column/SlideTransition)
   - Create mobile sheets (PageView/BottomSheet)
   - Implement controls (FloatingActionButton alternatives)

4. **State & Animations**
   - Set up state management (Riverpod/Provider)
   - Implement AnimationController setup
   - Create gesture handlers
   - Add scroll physics

5. **Testing & Performance**
   - Profile grid rendering
   - Test large grids (500x500+)
   - Validate touch performance
   - Benchmark memory usage

---

**Document prepared**: October 22, 2024  
**Analysis coverage**: Very Thorough - All major components documented  
**Ready for**: Flutter migration team
