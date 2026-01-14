# UI Specifications

## Design System

### Color Palette

```swift
extension Color {
    // Backgrounds
    static let backgroundPrimary = Color(hex: "#1A1A1A")      // Main background
    static let backgroundSecondary = Color(hex: "#2A2A2A")    // Cards, panels
    static let backgroundTertiary = Color(hex: "#3A3A3A")     // Elevated surfaces
    
    // Surfaces (Frontier cream palette)
    static let surfacePrimary = Color(hex: "#F5F2EB")         // Panel backgrounds
    static let surfaceSecondary = Color(hex: "#E8E4DB")       // Panel hover/pressed
    static let surfaceTertiary = Color(hex: "#D4CFC4")        // Borders, dividers
    
    // Accent
    static let accentPrimary = Color(hex: "#E85D04")          // Equipment orange
    static let accentSecondary = Color(hex: "#F4A261")        // Secondary orange
    
    // Text
    static let textPrimary = Color(hex: "#FFFFFF")            // Primary text on dark
    static let textSecondary = Color(hex: "#A0A0A0")          // Secondary text
    static let textOnSurface = Color(hex: "#1A1A1A")          // Text on cream
    
    // Semantic
    static let success = Color(hex: "#4CAF50")
    static let warning = Color(hex: "#FF9800")
    static let error = Color(hex: "#F44336")
}
```

### Typography

```swift
extension Font {
    // Display
    static let displayLarge = Font.system(size: 32, weight: .bold, design: .default)
    static let displayMedium = Font.system(size: 24, weight: .semibold, design: .default)
    
    // Headlines
    static let headlineLarge = Font.system(size: 20, weight: .semibold, design: .default)
    static let headlineMedium = Font.system(size: 17, weight: .semibold, design: .default)
    
    // Body
    static let bodyLarge = Font.system(size: 17, weight: .regular, design: .default)
    static let bodyMedium = Font.system(size: 15, weight: .regular, design: .default)
    static let bodySmall = Font.system(size: 13, weight: .regular, design: .default)
    
    // Labels
    static let labelLarge = Font.system(size: 15, weight: .medium, design: .default)
    static let labelMedium = Font.system(size: 13, weight: .medium, design: .default)
    static let labelSmall = Font.system(size: 11, weight: .medium, design: .default)
    
    // Monospace (for timecodes)
    static let mono = Font.system(size: 13, weight: .medium, design: .monospaced)
}
```

### Spacing

```swift
enum Spacing {
    static let xxs: CGFloat = 4
    static let xs: CGFloat = 8
    static let sm: CGFloat = 12
    static let md: CGFloat = 16
    static let lg: CGFloat = 24
    static let xl: CGFloat = 32
    static let xxl: CGFloat = 48
}
```

### Corner Radius

```swift
enum CornerRadius {
    static let sm: CGFloat = 4
    static let md: CGFloat = 8
    static let lg: CGFloat = 12
    static let xl: CGFloat = 16
    static let full: CGFloat = 9999  // Pill shape
}
```

---

## Screen Specifications

### 1. Import Screen

**Purpose**: Entry point for creating a new composition

**Layout**:
```
┌─────────────────────────────────────┐
│            Status Bar               │
├─────────────────────────────────────┤
│                                     │
│                                     │
│         [Large Import Icon]         │
│                                     │
│           "Add Videos"              │
│    "Select 2-12 videos to begin"    │
│                                     │
│       ┌─────────────────────┐       │
│       │   Import Videos     │       │
│       └─────────────────────┘       │
│                                     │
│                                     │
│                                     │
├─────────────────────────────────────┤
│          (Empty footer)             │
└─────────────────────────────────────┘
```

**Components**:
- Import icon: SF Symbol `video.badge.plus` at 64pt
- Title: `.displayMedium`, `textPrimary`
- Subtitle: `.bodyMedium`, `textSecondary`
- Button: Primary style, full width with horizontal padding

**Behavior**:
- Tap button → Present PHPicker (video only, limit 12)
- On selection → Navigate to Contact Sheet
- Haptic: Medium impact on button tap

---

### 2. Contact Sheet Screen

**Purpose**: Review and select imported videos for composition

**Layout**:
```
┌─────────────────────────────────────┐
│  ← Back        Contact Sheet  Done →│
├─────────────────────────────────────┤
│ ┌─────────┐ ┌─────────┐ ┌─────────┐ │
│ │ ▶︎       │ │ ▶︎       │ │ ▶︎       │ │
│ │         │ │         │ │         │ │
│ │   0:12  │ │   0:08  │ │   0:15  │ │
│ └─────────┘ └─────────┘ └─────────┘ │
│ ┌─────────┐ ┌─────────┐ ┌─────────┐ │
│ │ ▶︎       │ │ ▶︎       │ │ ▶︎       │ │
│ │         │ │         │ │         │ │
│ │   0:22  │ │   0:05  │ │   0:18  │ │
│ └─────────┘ └─────────┘ └─────────┘ │
│ ┌─────────┐ ┌─────────┐ ┌─────────┐ │
│ │ ▶︎       │ │ ▶︎       │ │ ▶︎       │ │
│ │         │ │         │ │         │ │
│ │   0:30  │ │   0:11  │ │   0:09  │ │
│ └─────────┘ └─────────┘ └─────────┘ │
│                                     │
├─────────────────────────────────────┤
│       "9 videos selected"           │
│  ┌──────────────────────────────┐   │
│  │      Continue to Canvas      │   │
│  └──────────────────────────────┘   │
└─────────────────────────────────────┘
```

**Components**:
- Navigation bar with back and done buttons
- 3-column grid with `Spacing.xs` gap
- Thumbnail cells with:
  - Video thumbnail (aspect fill)
  - Play indicator (SF Symbol `play.fill`, small, top-left)
  - Duration badge (bottom-right, pill shape)
  - Selection overlay (accent color border when selected)
  - Checkmark badge (top-right when selected)
- Footer with selection count and continue button

**Behavior**:
- Tap thumbnail → Toggle selection
- Long press → Show video preview modal
- Drag → Reorder (with haptic feedback)
- Done → Navigate to Canvas with selected videos
- Haptic: Light impact on selection, medium on reorder

**Animations**:
- Thumbnails appear with staggered fade-in (0.05s delay each)
- Selection border animates in (0.2s spring)
- Checkmark scales in (0.15s spring)

---

### 3. Canvas Screen

**Purpose**: Main composition workspace

**Layout**:
```
┌─────────────────────────────────────┐
│  ← Back                     Export →│
├─────────────────────────────────────┤
│                                     │
│  ┌───────────────────────────────┐  │
│  │                               │  │
│  │    ┌─────────┐  ┌────────┐    │  │
│  │    │ Video 1 │  │Video 2 │    │  │
│  │    └─────────┘  └────────┘    │  │
│  │         ┌──────────────┐      │  │
│  │         │   Video 3    │      │  │
│  │         └──────────────┘      │  │
│  │    ┌────┐    ┌────────────┐   │  │
│  │    │ V4 │    │  Video 5   │   │  │
│  │    └────┘    └────────────┘   │  │
│  │                               │  │
│  └───────────────────────────────┘  │
│                                     │
├─────────────────────────────────────┤
│   ◀︎◀︎  │  ▶︎  │  ▶︎▶︎    0:00 / 0:30  │
│   ━━━━━━━━●━━━━━━━━━━━━━━━━━━━━━━━   │
├─────────────────────────────────────┤
│  ┌─────────────────────────────┐    │
│  │      ☰  Settings Panel      │    │
│  │                             │    │
│  │  Canvas Size: [9:16 ▼]      │    │
│  │  Snap to Grid: [  ○───]     │    │
│  │  Loop Videos:  [───●  ]     │    │
│  │                             │    │
│  └─────────────────────────────┘    │
└─────────────────────────────────────┘
```

**Components**:

**Canvas Area**:
- Background: `backgroundSecondary` 
- Canvas frame: White border (1pt), represents output frame
- Canvas interior: Letterboxed to match selected ratio
- Video layers: Positioned within canvas bounds

**Video Layer** (when not selected):
- Video content with corner radius (`CornerRadius.sm`)
- Thin border (0.5pt, white @ 30% opacity)

**Video Layer** (when selected):
- Accent color border (2pt)
- Resize handles at corners and edges
- Delete button (top-right, outside frame)

**Playback Controls**:
- Transport: Previous, Play/Pause, Next
- Timecode: Current time / Total duration (monospace)
- Scrubber: Custom slider with accent color

**Utility Panel** (slides up from bottom):
- Drag handle at top
- Settings organized in sections
- Canvas size picker (segmented or dropdown)
- Toggle switches for snap-to-grid and loop

**Behavior**:
- Drag layer → Reposition within canvas
- Pinch layer → Resize proportionally
- Double-tap layer → Fit to canvas width
- Long-press layer → Show context menu (bring to front, send to back, delete)
- Tap canvas background → Deselect all
- Swipe up on panel → Expand utility panel
- Swipe down on panel → Collapse utility panel
- Play button → Start/stop all video playback
- Scrubber drag → Seek all videos to position

**Haptics**:
- Light impact on layer selection
- Medium impact on layer reposition (when snapping)
- Heavy impact on delete
- Soft continuous during scrubbing

---

### 4. Export Screen

**Purpose**: Configure and execute export

**Layout**:
```
┌─────────────────────────────────────┐
│  ← Back           Export Settings   │
├─────────────────────────────────────┤
│                                     │
│  ┌───────────────────────────────┐  │
│  │                               │  │
│  │      [Composition Preview]    │  │
│  │                               │  │
│  └───────────────────────────────┘  │
│                                     │
│  Resolution                         │
│  ┌─────────────────────────────────┐│
│  │  ○ 1080p (1920×1080)            ││
│  │  ● 4K (3840×2160)               ││
│  └─────────────────────────────────┘│
│                                     │
│  Estimated Size: ~128 MB            │
│  Duration: 0:30                     │
│                                     │
│                                     │
├─────────────────────────────────────┤
│  ┌──────────────────────────────┐   │
│  │        Export Video          │   │
│  └──────────────────────────────┘   │
└─────────────────────────────────────┘
```

**Export Progress Modal**:
```
┌─────────────────────────────────────┐
│                                     │
│          Exporting Video            │
│                                     │
│         ━━━━━━━━━━━●━━━━━━          │
│              67%                    │
│                                     │
│           [Cancel]                  │
│                                     │
└─────────────────────────────────────┘
```

**Behavior**:
- Resolution selection → Update estimated file size
- Export button → Show progress modal, begin export
- Cancel → Abort export, return to canvas
- Completion → Success haptic, show share sheet or return to canvas

---

## Component Library

### Primary Button

```swift
struct PrimaryButton: View {
    let title: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.labelLarge)
                .foregroundColor(.textOnSurface)
                .frame(maxWidth: .infinity)
                .padding(.vertical, Spacing.md)
                .background(Color.surfacePrimary)
                .cornerRadius(CornerRadius.md)
        }
    }
}
```

### Secondary Button

```swift
struct SecondaryButton: View {
    let title: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.labelLarge)
                .foregroundColor(.textPrimary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, Spacing.md)
                .background(Color.backgroundTertiary)
                .cornerRadius(CornerRadius.md)
                .overlay(
                    RoundedRectangle(cornerRadius: CornerRadius.md)
                        .stroke(Color.textSecondary.opacity(0.3), lineWidth: 1)
                )
        }
    }
}
```

### Duration Badge

```swift
struct DurationBadge: View {
    let duration: TimeInterval
    
    var body: some View {
        Text(duration.formatted)
            .font(.mono)
            .foregroundColor(.textPrimary)
            .padding(.horizontal, Spacing.xs)
            .padding(.vertical, Spacing.xxs)
            .background(Color.black.opacity(0.6))
            .cornerRadius(CornerRadius.sm)
    }
}
```

### Thumbnail Cell

```swift
struct ThumbnailCell: View {
    let clip: VideoClip
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            ZStack(alignment: .topTrailing) {
                // Thumbnail image
                AsyncImage(url: clip.thumbnailURL) { image in
                    image.resizable().aspectRatio(contentMode: .fill)
                } placeholder: {
                    Color.backgroundTertiary
                }
                .frame(aspectRatio: 9/16, contentMode: .fit)
                .clipped()
                .cornerRadius(CornerRadius.sm)
                
                // Selection overlay
                if isSelected {
                    RoundedRectangle(cornerRadius: CornerRadius.sm)
                        .stroke(Color.accentPrimary, lineWidth: 2)
                    
                    // Checkmark
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.accentPrimary)
                        .padding(Spacing.xxs)
                }
                
                // Duration badge
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        DurationBadge(duration: clip.duration)
                            .padding(Spacing.xxs)
                    }
                }
            }
        }
        .buttonStyle(.plain)
    }
}
```

### Utility Panel

```swift
struct UtilityPanel<Content: View>: View {
    @Binding var isExpanded: Bool
    let content: () -> Content
    
    var body: some View {
        VStack(spacing: 0) {
            // Drag handle
            Capsule()
                .fill(Color.surfaceTertiary)
                .frame(width: 36, height: 4)
                .padding(.top, Spacing.sm)
                .padding(.bottom, Spacing.md)
            
            // Content
            content()
                .padding(.horizontal, Spacing.md)
                .padding(.bottom, Spacing.lg)
        }
        .frame(maxWidth: .infinity)
        .background(Color.surfacePrimary)
        .cornerRadius(CornerRadius.xl, corners: [.topLeft, .topRight])
        .gesture(
            DragGesture()
                .onEnded { value in
                    if value.translation.height > 50 {
                        isExpanded = false
                    } else if value.translation.height < -50 {
                        isExpanded = true
                    }
                }
        )
    }
}
```

---

## Gestures

### Video Layer Gestures

```swift
struct VideoLayerGestures: ViewModifier {
    @Binding var position: CGPoint
    @Binding var scale: CGFloat
    @Binding var isSelected: Bool
    
    @State private var dragOffset: CGSize = .zero
    @State private var lastScale: CGFloat = 1.0
    
    func body(content: Content) -> some View {
        content
            .offset(x: position.x + dragOffset.width,
                    y: position.y + dragOffset.height)
            .scaleEffect(scale)
            .gesture(dragGesture)
            .gesture(pinchGesture)
            .onTapGesture { isSelected = true }
    }
    
    var dragGesture: some Gesture {
        DragGesture()
            .onChanged { value in
                dragOffset = value.translation
                HapticsService.shared.light()
            }
            .onEnded { value in
                position.x += value.translation.width
                position.y += value.translation.height
                dragOffset = .zero
                HapticsService.shared.medium()
            }
    }
    
    var pinchGesture: some Gesture {
        MagnificationGesture()
            .onChanged { value in
                scale = lastScale * value
            }
            .onEnded { value in
                lastScale = scale
                HapticsService.shared.light()
            }
    }
}
```

---

## Animations

### Timing Curves

```swift
enum AnimationCurves {
    static let snappy = Animation.spring(response: 0.3, dampingFraction: 0.7)
    static let smooth = Animation.easeInOut(duration: 0.25)
    static let quick = Animation.easeOut(duration: 0.15)
    static let bounce = Animation.spring(response: 0.4, dampingFraction: 0.6)
}
```

### Common Transitions

```swift
extension AnyTransition {
    static var slideUp: AnyTransition {
        .move(edge: .bottom).combined(with: .opacity)
    }
    
    static var scaleIn: AnyTransition {
        .scale(scale: 0.8).combined(with: .opacity)
    }
    
    static var fadeSlide: AnyTransition {
        .asymmetric(
            insertion: .move(edge: .trailing).combined(with: .opacity),
            removal: .move(edge: .leading).combined(with: .opacity)
        )
    }
}
```

---

## Accessibility

### VoiceOver Labels

- Import button: "Import videos. Double tap to select videos from your library."
- Thumbnail: "Video [index], duration [time]. [Selected/Not selected]. Double tap to toggle selection."
- Canvas layer: "Video layer [index]. Position [x, y]. Size [width by height]. Double tap to select."
- Play button: "[Playing/Paused]. Double tap to [pause/play] all videos."
- Export button: "Export video. Double tap to open export options."

### Dynamic Type

- Support Dynamic Type for all text
- Minimum touch target: 44×44 points
- Ensure contrast ratios meet WCAG AA (4.5:1 for text)

### Reduce Motion

- Respect `UIAccessibility.isReduceMotionEnabled`
- Replace springs with simple fades when enabled
- Disable parallax effects
