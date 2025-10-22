# BlockPick UI/UX Specification - Complete Index

## Overview
This is a comprehensive UI/UX specification package for migrating BlockPick from Next.js 15 to Flutter. The documentation has been thoroughly analyzed from the current codebase and organized for development teams.

## Documents Included

### 1. BLOCKPICK_UI_UX_SPECIFICATION.md (34 KB, 1,280 lines)
**Main comprehensive reference document**

This is the primary specification document containing:
- Complete design system
- Detailed color palette with 14+ variants
- Typography and spacing specifications
- Component hierarchy (35+ components)
- Screen-by-screen layouts
- Interaction patterns for desktop and mobile
- Animation specifications with Framer Motion details
- Mobile vs Desktop comparison
- Grid system architecture
- State management flows
- Performance targets
- Implementation notes for Flutter

**Sections**:
1. Design System
2. Color Palette
3. Typography & Spacing
4. Component Hierarchy
5. Screen Specifications
6. Interaction Patterns
7. Animation Specifications
8. Mobile vs Desktop Differences
9. Grid System & Rendering
10. State Management
11. Implementation Notes for Flutter
12. Performance Targets
13. Accessibility Features
14. Browser/Platform Support
15. File Reference

### 2. UI_ANALYSIS_SUMMARY.md (9 KB, ~250 lines)
**Quick reference and findings summary**

High-level overview containing:
- Key findings from code analysis
- Component architecture summary
- Color palette overview
- Grid system specifications
- Interaction patterns summary
- Animation system overview
- Responsive design breakpoints
- State management approach
- Performance optimizations
- Mobile vs Desktop comparison
- Flutter migration considerations
- Critical implementation details
- Next steps for Flutter development

## Analysis Coverage

### Components Analyzed
- 35+ UI components documented
- All major screens covered
- Mobile and desktop variants
- State management flows

### Technical Details
- 14+ color variants specified
- 9 keyboard shortcuts documented
- 6 LOD (Level of Detail) levels
- 3 responsive breakpoints
- Multiple animation patterns
- Touch gesture specifications

### Grid System Details
- SVG-based rendering
- Sparse grid optimization
- Object pooling strategy
- Support for grids up to 1000x1000 cells
- Adaptive zoom ranges
- Cell selection thresholds

## Key Statistics

| Aspect | Details |
|--------|---------|
| Total Pages | 2 main documents |
| Total Lines | 1,530+ lines |
| Components | 35+ |
| Colors | 14+ variants |
| Breakpoints | 3 (mobile, tablet, desktop) |
| Grid Sizes | 6 (10x10 to 1000x1000) |
| Keyboard Shortcuts | 9 |
| Animation Types | 7+ |
| Performance Target | 60 FPS, <100MB RAM |

## How to Use This Documentation

### For Product Managers
- Read: UI_ANALYSIS_SUMMARY.md (sections 1-6)
- Reference: BLOCKPICK_UI_UX_SPECIFICATION.md (Screen Specifications section)

### For UI/UX Designers
- Read: Both documents completely
- Focus on: Design System, Color Palette, Component Hierarchy, Animations
- Reference: Mobile vs Desktop section for responsive decisions

### For Frontend Engineers (Flutter)
- Read: Both documents
- Focus on: Implementation Notes, Grid System & Rendering, State Management
- Reference: Interaction Patterns, Animation Specifications

### For QA/Testing
- Read: Interaction Patterns, Mobile vs Desktop
- Reference: Performance Targets, Accessibility Features

## Component Files Referenced

### Core Grid
- `components/blockpick/new-round/new-game-grid.tsx` (1,914 lines)
- `components/blockpick/game/planning-grid.tsx`

### Layout
- `components/blockpick/new-round/new-game-overlay.tsx`
- `components/blockpick/layout/header.tsx`

### Sidebars
- `components/blockpick/new-round/new-game-info-panel.tsx`
- `components/blockpick/new-round/new-product-panel.tsx`

### Mobile Components
- `components/blockpick/new-round/mobile-bottom-container.tsx`
- `components/blockpick/new-round/mobile-minimap.tsx`
- `components/blockpick/new-round/mobile-game-info-modal.tsx`
- `components/blockpick/new-round/mobile-selected-blocks-sheet.tsx`

### Controls
- `components/blockpick/new-round/new-floating-controls.tsx`

### Configuration
- `tailwind.config.ts` (Color definitions)
- `lib/grid-store.ts` (State management)

## Flutter Migration Checklist

### Phase 1: Setup & Design System
- [ ] Create Color constants from palette
- [ ] Set up Gradient system
- [ ] Define Typography extensions
- [ ] Set up state management (Riverpod/Provider)

### Phase 2: Core Grid Component
- [ ] Implement Canvas-based grid rendering
- [ ] Create sparse grid data structure
- [ ] Implement LOD system
- [ ] Add gesture handlers (pan, pinch-zoom)

### Phase 3: UI Components
- [ ] Convert layout components
- [ ] Create sidebar components (SlideTransition)
- [ ] Implement bottom sheets
- [ ] Create floating controls

### Phase 4: Interactions & Animations
- [ ] Implement zoom animations
- [ ] Add drag/pan gestures
- [ ] Create spring animations
- [ ] Add keyboard shortcuts (desktop)

### Phase 5: Mobile Features
- [ ] Bottom sheet with 3 states
- [ ] Minimap component
- [ ] Mobile-specific gestures
- [ ] Safe area handling

### Phase 6: Testing & Optimization
- [ ] Profile grid rendering
- [ ] Test large grids (500x500+)
- [ ] Validate touch performance
- [ ] Benchmark memory usage

## Performance Targets

- Grid render: < 60ms (60 FPS)
- Zoom animation: 300ms
- Pan sensitivity: < 16ms latency
- Memory: < 100MB for 1000x1000 grid
- Tile pool: 500-1000 tiles
- Max visible cells: 25,000

## Browser/Platform Support

### Web
- Chrome 90+
- Firefox 88+
- Safari 14+
- Edge 90+

### Mobile (Flutter)
- iOS 12+
- Android 5.0+
- Tablets (iPad, Android tablets)

## Key Design Principles

1. **Clarity**: Clear information hierarchy
2. **Responsiveness**: Mobile-first approach
3. **Performance**: Optimized rendering for large grids
4. **Accessibility**: Keyboard shortcuts, hover states
5. **Consistency**: Unified component design

## Color Palette Quick Reference

### Primary Colors
- Blue: #5C72F5
- Purple: #6E5AE9
- Pink: #FF58BB
- Red: #FF5D5C
- Green: #10B981
- Yellow: #F59E0B

### Background Colors
- Bluewhite: #ECF1F9
- Bgwhite: #EFF2F7
- Disable: #DEDEDE

### Text Colors
- Darkblue: #081245
- Navy: #2D3661
- Medium: #555555
- Hint: #C5C9DC

## Interaction Patterns Quick Reference

### Desktop
- Wheel zoom (accumulated delta)
- Mouse drag pan
- Shift+Click smart zoom
- 9 keyboard shortcuts
- Z key magnifier (3x)

### Mobile
- Single-touch pan
- Pinch-to-zoom
- Bottom sheet drag (3 states)
- Minimap click navigation

## Animation Quick Reference

- Standard: 300ms easeInOutCubic
- Spring: damping 25, stiffness 200
- Hover: scale 1.1
- Tap: scale 0.95
- Progress: 1s easeOut
- List: staggered, popLayout mode

## Contact & Support

**Document Prepared**: October 22, 2024
**Analysis Level**: Very Thorough
**Target Audience**: Flutter migration team
**Status**: Complete and ready for implementation

## Document Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.0 | Oct 22, 2024 | Initial comprehensive specification |

---

**For complete details, refer to BLOCKPICK_UI_UX_SPECIFICATION.md**
