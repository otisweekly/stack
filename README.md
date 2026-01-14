# Stack App Documentation

## For Claude Code

This documentation package contains everything needed to build **Stack**, an iOS video collage compositor app. 

---

## 🚨 START HERE — EVERY TIME 🚨

```
┌─────────────────────────────────────────────────────────┐
│                                                         │
│   1. Read START_HERE.md first                           │
│   2. Read PROGRESS.md second                            │
│   3. Then proceed with work                             │
│                                                         │
│   ALWAYS update PROGRESS.md before conversation ends!   │
│                                                         │
└─────────────────────────────────────────────────────────┘
```

---

## Quick Start

### 1. Read the Documents in This Order

| Priority | Document | Purpose |
|----------|----------|---------|
| 🔴 **1** | `START_HERE.md` | Agent orientation - read this FIRST every session |
| 🔴 **2** | `PROGRESS.md` | Current project status - read SECOND every session |
| 🔴 **3** | `CLAUDE_CODE_INSTRUCTIONS.md` | Mandatory workflow rules |
| 🟡 **4** | `PROJECT_BRIEF.md` | Product vision, features, and constraints |
| 🟡 **5** | `DESIGN_LANGUAGE.md` | Visual design system, colors, typography, liquid glass |
| 🟡 **6** | `ACCEPTANCE_CRITERIA.md` | **Definition of done for every feature** |
| 🟡 **7** | `TECHNICAL_ARCHITECTURE.md` | System design and project structure |
| 🟡 **8** | `DATA_MODELS.md` | All data structures (includes image support) |
| 🟡 **9** | `UI_SPECIFICATIONS.md` | Screen layouts and interaction patterns |
| 🟢 **10** | `COMPOSITOR_SPECIFICATIONS.md` | Deep dive on video rendering (for Phase 5-6) |
| 🟢 **11** | `IMPLEMENTATION_GUIDE.md` | Step-by-step build phases |

**Note**: `FRONTIER_PATTERNS.md` is deprecated - we're no longer matching Frontier's aesthetic.

### 2. Create the Xcode Project

```bash
# Create project directory
mkdir -p ~/Developer/Stack

# Create Xcode project with these settings:
# - Product Name: Stack
# - Bundle ID: com.anthropic.stack
# - Interface: SwiftUI
# - Language: Swift
# - Minimum Deployment: iOS 16.0
# - Devices: iPhone
```

### 3. Follow Implementation Phases

The `IMPLEMENTATION_GUIDE.md` contains 8 phases. Complete each phase fully before moving to the next:

1. **Phase 1**: Project Setup & Core Infrastructure
2. **Phase 2**: Data Models & Services Foundation  
3. **Phase 3**: Media Import Flow
4. **Phase 4**: Canvas Core - Layout & Gestures
5. **Phase 5**: Video Playback
6. **Phase 6**: Video Compositing & Export
7. **Phase 7**: Polish & Refinement
8. **Phase 8**: App Store Preparation

---

## Key Technical Decisions

### Frameworks

| Framework | Usage |
|-----------|-------|
| SwiftUI | All UI (with liquid glass materials) |
| AVFoundation | Video/image playback, composition, export |
| Metal | Real-time preview rendering |
| Photos | Media import and export |
| CoreImage | Frame transformations |

### Architecture

- **MVVM** with `@Observable` for state management
- **Protocol-based** services for testability
- **Tab-based navigation** with liquid glass bottom bar

### Design System

- **Colors**: Black (#000000), White (#FFFFFF), Teal Accent (#009290)
- **Typography**: Pangram Pangram "PP Fuji" font family (Light, Regular, Bold)
- **Surfaces**: iOS 26 liquid glass (`.ultraThinMaterial`)
- **Dark mode only**

### No External Dependencies

This app uses only system frameworks. Do not add any SPM packages, CocoaPods, or other dependencies. The only non-system asset is the PP Fuji font family (included in Fonts folder).

---

## Critical Requirements

### Must Have (MVP)

- [ ] Import 2-12 videos OR images from Photos library
- [ ] Display media in contact sheet grid with type badges
- [ ] Position media freely on canvas via drag
- [ ] Resize media via pinch gesture
- [ ] Play all videos simultaneously, images for 1 second default
- [ ] Export composition to camera roll
- [ ] Support 9:16, 16:9, 1:1, 4:5 canvas sizes
- [ ] Liquid glass bottom tab bar (App Store style)
- [ ] Pure black/white UI with orange (#009290) accent
- [ ] Fuji font throughout

### Performance Targets

- Import 12 media items: < 3 seconds
- Preview playback: 60 fps
- Export 30s video: < 30 seconds
- Memory with 12 layers: < 500 MB

### Design Requirements

- Black background, white text/icons only
- Single accent color for primary actions
- Liquid glass surfaces for navigation and panels
- Haptic feedback on all interactions
- Dark mode only (no light mode support)

---

## File Locations Reference

After creating the project, your structure should match:

```
Stack/
├── App/
├── Models/
├── ViewModels/
├── Views/
│   ├── Import/
│   ├── Canvas/
│   ├── Export/
│   ├── Utility/
│   └── Components/
├── Services/
├── Compositor/
├── Extensions/
└── Resources/
```

Refer to `TECHNICAL_ARCHITECTURE.md` for the complete file structure.

---

## Common Gotchas

### PHPicker

- Always request `.readWrite` authorization
- Use `.current` for `preferredAssetRepresentationMode` to avoid transcoding
- Handle the case where user grants limited access

### AVFoundation

- Load asset properties asynchronously with `asset.load(.duration)`
- Video tracks may be rotated - check `preferredTransform`
- `AVPlayerLooper` requires `AVQueuePlayer`, not `AVPlayer`

### Metal

- Create texture cache once, reuse it
- CVPixelBuffers from video must have `kCVPixelBufferMetalCompatibilityKey`
- Remember to flip Y coordinate (Metal's origin is bottom-left)

### SwiftUI

- Use `@Observable` (iOS 17+) instead of `@ObservableObject`
- Wrap `AVPlayerLayer` in `UIViewRepresentable` for video display
- Gestures on overlapping views need `.simultaneousGesture()`

---

## Testing Checkpoints

After each phase, verify:

### Phase 1
- [ ] App launches to import screen
- [ ] Theme colors display correctly

### Phase 2  
- [ ] Can create model instances in playground
- [ ] Haptics trigger on device

### Phase 3
- [ ] PHPicker presents and allows selection
- [ ] Thumbnails appear in contact sheet
- [ ] Selection state toggles correctly

### Phase 4
- [ ] Canvas displays with correct aspect ratio
- [ ] Stack can be dragged and resized
- [ ] Selection highlights active layer

### Phase 5
- [ ] All videos play simultaneously
- [ ] Play/pause controls work
- [ ] Videos loop correctly

### Phase 6
- [ ] Export completes without error
- [ ] Output video appears in Photos
- [ ] All layers visible in exported video

### Phase 7
- [ ] No crashes during normal use
- [ ] VoiceOver announces correctly
- [ ] Animations are smooth

---

## Questions?

If anything is unclear:

1. Re-read the relevant documentation section
2. Check `FRONTIER_PATTERNS.md` for established patterns
3. Refer to Apple's documentation for framework specifics
4. Make reasonable assumptions that align with the project vision

---

## Document Versions

| Document | Version | Last Updated |
|----------|---------|--------------|
| START_HERE.md | 1.0 | January 2026 |
| PROGRESS.md | 1.1 | January 2026 |
| CLAUDE_CODE_INSTRUCTIONS.md | 1.0 | January 2026 |
| PROJECT_BRIEF.md | 2.0 | January 2026 |
| DESIGN_LANGUAGE.md | 1.0 | January 2026 |
| ACCEPTANCE_CRITERIA.md | 1.0 | January 2026 |
| TECHNICAL_ARCHITECTURE.md | 1.0 | January 2026 |
| DATA_MODELS.md | 2.0 | January 2026 |
| UI_SPECIFICATIONS.md | 1.0 | January 2026 |
| COMPOSITOR_SPECIFICATIONS.md | 1.0 | January 2026 |
| IMPLEMENTATION_GUIDE.md | 1.0 | January 2026 |
| README.md | 1.3 | January 2026 |

### Deprecated
- FRONTIER_PATTERNS.md - No longer using Frontier's aesthetic
