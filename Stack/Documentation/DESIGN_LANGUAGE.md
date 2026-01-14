# Design Language

## Overview

Stack uses a minimal, editorial aesthetic built on iOS 26's liquid glass design system. The interface is strictly black and white, letting user content be the only source of color. One accent color punctuates critical actions.

---

## Design Principles

### 1. Content First
The user's videos and images are the stars. The UI recedes into the background - literally transparent with liquid glass.

### 2. Monochrome Chrome
All interface elements are black, white, or translucent. No grays, no colors. This creates maximum contrast and a bold, graphic feel.

### 3. One Accent Rule
A single accent color is used sparingly for primary actions only. Nothing else gets color.

### 4. Liquid Glass Everywhere
Embrace iOS 26's liquid glass for navigation, panels, and overlays. The interface should feel like it floats over content.

---

## Color System

```swift
import SwiftUI

extension Color {
    // MARK: - Core Palette (Black & White Only)
    
    /// Pure black - primary backgrounds, text on light
    static let stackBlack = Color(hex: "#000000")
    
    /// Pure white - text on dark, surfaces
    static let stackWhite = Color(hex: "#FFFFFF")
    
    // MARK: - Accent (Use Sparingly)
    
    /// Teal accent for primary actions only
    static let stackAccent = Color(hex: "#009290")
    
    // MARK: - Semantic
    
    /// Primary background
    static let backgroundPrimary = stackBlack
    
    /// Text on dark backgrounds
    static let textPrimary = stackWhite
    
    /// Text on light backgrounds / glass
    static let textOnGlass = stackBlack
    
    /// Disabled/inactive state
    static let textDisabled = stackWhite.opacity(0.4)
    
    /// Borders and dividers
    static let border = stackWhite.opacity(0.15)
    
    // MARK: - Liquid Glass
    
    /// Glass material tint (used with .ultraThinMaterial)
    static let glassTint = stackWhite.opacity(0.1)
}

// MARK: - Hex Initializer

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
```

### Color Usage Rules

| Element | Color | Notes |
|---------|-------|-------|
| App background | `stackBlack` | Always pure black |
| Primary text | `stackWhite` | High contrast |
| Secondary text | `stackWhite` @ 60% | Subdued |
| Disabled text | `stackWhite` @ 40% | Inactive states |
| Primary buttons | `stackAccent` | Import, Export, Continue |
| Secondary buttons | `stackWhite` border | Cancel, Back |
| Icons (active) | `stackWhite` | Navigation, actions |
| Icons (inactive) | `stackWhite` @ 50% | Tab bar unselected |
| Selection indicator | `stackAccent` | Checkmarks, borders |
| Glass surfaces | `.ultraThinMaterial` | Bottom nav, panels |
| Volume sliders | `stackAccent` | Audio controls |

### Accent Color

**Teal (#009290)** - A distinctive, calming accent that provides excellent contrast on black backgrounds while feeling premium and editorial.

---

## Typography

### Font: Pangram Pangram "PP Fuji"

PP Fuji is a geometric sans-serif with a modern, clean aesthetic. It has excellent legibility and a distinctive character that sets Stack apart from system fonts.

**Font Files Required (included in project):**
```
PPFuji-Light.otf
PPFuji-Regular.otf
PPFuji-Bold.otf
```

### Setup

1. Add font files to Xcode project (drag into project navigator)
2. Add to Info.plist under "Fonts provided by application":
   - PPFuji-Light.otf
   - PPFuji-Regular.otf
   - PPFuji-Bold.otf
3. Create Font extension:

```swift
import SwiftUI

extension Font {
    // MARK: - PP Fuji Font Family
    
    /// Display - Large titles, hero text
    static let fujiDisplay = Font.custom("PPFuji-Bold", size: 34)
    static let fujiDisplayMedium = Font.custom("PPFuji-Bold", size: 28)
    
    /// Headlines
    static let fujiHeadline = Font.custom("PPFuji-Bold", size: 22)
    static let fujiHeadlineSmall = Font.custom("PPFuji-Regular", size: 18)
    
    /// Body
    static let fujiBody = Font.custom("PPFuji-Regular", size: 16)
    static let fujiBodySmall = Font.custom("PPFuji-Regular", size: 14)
    
    /// Labels
    static let fujiLabel = Font.custom("PPFuji-Bold", size: 14)
    static let fujiLabelSmall = Font.custom("PPFuji-Bold", size: 12)
    
    /// Captions
    static let fujiCaption = Font.custom("PPFuji-Light", size: 12)
    static let fujiCaptionSmall = Font.custom("PPFuji-Light", size: 10)
    
    /// Monospace (for timecodes - use system mono)
    static let mono = Font.system(size: 13, weight: .medium, design: .monospaced)
    static let monoSmall = Font.system(size: 11, weight: .medium, design: .monospaced)
    
    // MARK: - Dynamic Type Support
    
    static func fuji(_ style: FujiStyle, size: CGFloat) -> Font {
        let weight: String
        switch style {
        case .light: weight = "PPFuji-Light"
        case .regular: weight = "PPFuji-Regular"
        case .bold: weight = "PPFuji-Bold"
        }
        return Font.custom(weight, size: size, relativeTo: .body)
    }
    
    enum FujiStyle {
        case light, regular, bold
    }
}
```

### Typography Scale

| Style | Font | Size | Weight | Usage |
|-------|------|------|--------|-------|
| Display | PP Fuji | 34 | Bold | Screen titles |
| Display Medium | PP Fuji | 28 | Bold | Section headers |
| Headline | PP Fuji | 22 | Bold | Card titles |
| Headline Small | PP Fuji | 18 | Regular | Subsection headers |
| Body | PP Fuji | 16 | Regular | Primary content |
| Body Small | PP Fuji | 14 | Regular | Secondary content |
| Label | PP Fuji | 14 | Bold | Button text, labels |
| Label Small | PP Fuji | 12 | Bold | Tags, badges |
| Caption | PP Fuji | 12 | Light | Timestamps, metadata |
| Caption Small | PP Fuji | 10 | Light | Fine print |
| Mono | SF Mono | 13 | Medium | Timecodes |

---

## Liquid Glass

### iOS 26 Glass Materials

```swift
import SwiftUI

// MARK: - Glass Styles

extension View {
    /// Standard liquid glass panel
    func liquidGlass() -> some View {
        self
            .background(.ultraThinMaterial)
            .background(Color.glassTint)
    }
    
    /// Glass with subtle border
    func liquidGlassBordered() -> some View {
        self
            .background(.ultraThinMaterial)
            .background(Color.glassTint)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color.white.opacity(0.2), lineWidth: 0.5)
            )
    }
    
    /// Bottom navigation glass
    func liquidGlassNav() -> some View {
        self
            .background(.bar)  // iOS tab bar material
    }
}

// MARK: - Glass Components

struct GlassPanel<Content: View>: View {
    let cornerRadius: CGFloat
    let content: () -> Content
    
    init(cornerRadius: CGFloat = 20, @ViewBuilder content: @escaping () -> Content) {
        self.cornerRadius = cornerRadius
        self.content = content
    }
    
    var body: some View {
        content()
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(Color.white.opacity(0.15), lineWidth: 0.5)
            )
    }
}

struct GlassCard<Content: View>: View {
    let content: () -> Content
    
    var body: some View {
        content()
            .padding(16)
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}
```

### Bottom Tab Bar (App Store Style)

```swift
struct StackTabBar: View {
    @Binding var selectedTab: Tab
    
    enum Tab: String, CaseIterable {
        case create = "plus.square"
        case library = "square.stack"
        case settings = "slider.horizontal.3"
        
        var label: String {
            switch self {
            case .create: return "Create"
            case .library: return "Library"
            case .settings: return "Settings"
            }
        }
    }
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(Tab.allCases, id: \.self) { tab in
                TabBarButton(
                    icon: tab.rawValue,
                    label: tab.label,
                    isSelected: selectedTab == tab
                ) {
                    selectedTab = tab
                }
            }
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 12)
        .background(.bar)  // Liquid glass material
        .clipShape(Capsule())
        .padding(.horizontal, 40)
        .padding(.bottom, 8)
    }
}

struct TabBarButton: View {
    let icon: String
    let label: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: isSelected ? "\(icon).fill" : icon)
                    .font(.system(size: 20))
                Text(label)
                    .font(.fujiCaptionSmall)
            }
            .foregroundColor(isSelected ? .stackAccent : .white.opacity(0.5))
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
        }
    }
}
```

### Floating Action Button

```swift
struct FloatingActionButton: View {
    let icon: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 24, weight: .medium))
                .foregroundColor(.stackBlack)
                .frame(width: 56, height: 56)
                .background(Color.stackAccent)
                .clipShape(Circle())
                .shadow(color: .stackAccent.opacity(0.4), radius: 12, y: 4)
        }
    }
}
```

---

## Components

### Primary Button (Accent)

```swift
struct PrimaryButton: View {
    let title: String
    let icon: String?
    let action: () -> Void
    var isEnabled: Bool = true
    
    init(_ title: String, icon: String? = nil, isEnabled: Bool = true, action: @escaping () -> Void) {
        self.title = title
        self.icon = icon
        self.isEnabled = isEnabled
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                if let icon = icon {
                    Image(systemName: icon)
                }
                Text(title)
                    .font(.fujiLabel)
            }
            .foregroundColor(isEnabled ? .stackBlack : .stackBlack.opacity(0.5))
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(isEnabled ? Color.stackAccent : Color.stackAccent.opacity(0.3))
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .disabled(!isEnabled)
    }
}
```

### Secondary Button (White Border)

```swift
struct SecondaryButton: View {
    let title: String
    let icon: String?
    let action: () -> Void
    
    init(_ title: String, icon: String? = nil, action: @escaping () -> Void) {
        self.title = title
        self.icon = icon
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                if let icon = icon {
                    Image(systemName: icon)
                }
                Text(title)
                    .font(.fujiLabel)
            }
            .foregroundColor(.stackWhite)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(Color.clear)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.stackWhite, lineWidth: 1)
            )
        }
    }
}
```

### Duration Badge

```swift
struct DurationBadge: View {
    let duration: TimeInterval
    
    private var formattedDuration: String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
    
    var body: some View {
        Text(formattedDuration)
            .font(.mono)
            .foregroundColor(.stackWhite)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 6))
    }
}
```

### Media Type Badge

```swift
struct MediaTypeBadge: View {
    let isVideo: Bool
    
    var body: some View {
        Image(systemName: isVideo ? "video.fill" : "photo.fill")
            .font(.system(size: 10, weight: .semibold))
            .foregroundColor(.stackWhite)
            .padding(6)
            .background(.ultraThinMaterial)
            .clipShape(Circle())
    }
}
```

### Selection Checkbox

```swift
struct SelectionCheckbox: View {
    let isSelected: Bool
    
    var body: some View {
        ZStack {
            Circle()
                .fill(isSelected ? Color.stackAccent : Color.clear)
                .frame(width: 24, height: 24)
            
            Circle()
                .stroke(isSelected ? Color.stackAccent : Color.white, lineWidth: 2)
                .frame(width: 24, height: 24)
            
            if isSelected {
                Image(systemName: "checkmark")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.stackBlack)
            }
        }
    }
}
```

### Volume Slider (for Audio Mixer)

```swift
struct VolumeSlider: View {
    @Binding var volume: Float  // 0.0 to 1.0
    let thumbnail: Image
    
    var body: some View {
        VStack(spacing: 8) {
            // Thumbnail
            thumbnail
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 80, height: 80)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .overlay(
                    // Mute indicator
                    Group {
                        if volume == 0 {
                            Image(systemName: "speaker.slash.fill")
                                .foregroundColor(.stackWhite)
                                .padding(4)
                                .background(.ultraThinMaterial)
                                .clipShape(Circle())
                        }
                    }
                )
            
            // Volume slider (vertical)
            Slider(value: $volume, in: 0...1)
                .tint(.stackAccent)
                .frame(width: 80)
            
            // Percentage
            Text("\(Int(volume * 100))%")
                .font(.fujiCaptionSmall)
                .foregroundColor(.stackWhite.opacity(0.6))
        }
    }
}
```

---

## Layout

### Spacing Scale

```swift
enum Spacing {
    static let xxs: CGFloat = 4
    static let xs: CGFloat = 8
    static let sm: CGFloat = 12
    static let md: CGFloat = 16
    static let lg: CGFloat = 24
    static let xl: CGFloat = 32
    static let xxl: CGFloat = 48
    static let xxxl: CGFloat = 64
}
```

### Corner Radius Scale

```swift
enum CornerRadius {
    static let xs: CGFloat = 4
    static let sm: CGFloat = 8
    static let md: CGFloat = 12
    static let lg: CGFloat = 16
    static let xl: CGFloat = 20
    static let xxl: CGFloat = 24
    static let full: CGFloat = 9999
}
```

### Safe Area Handling

```swift
extension View {
    /// Standard content padding respecting safe areas
    func contentPadding() -> some View {
        self.padding(.horizontal, Spacing.md)
    }
    
    /// Bottom padding for content above tab bar
    func tabBarPadding() -> some View {
        self.padding(.bottom, 100)  // Tab bar height + spacing
    }
}
```

---

## Icons

Use SF Symbols exclusively. Prefer filled variants for selected/active states.

### Core Icons

| Action | Symbol | Filled Variant |
|--------|--------|----------------|
| Import | `plus.square` | `plus.square.fill` |
| Library | `square.stack` | `square.stack.fill` |
| Settings | `gearshape` | `gearshape.fill` |
| Play | `play` | `play.fill` |
| Pause | `pause` | `pause.fill` |
| Export | `square.and.arrow.up` | `square.and.arrow.up.fill` |
| Delete | `trash` | `trash.fill` |
| Close | `xmark` | - |
| Back | `chevron.left` | - |
| Check | `checkmark` | - |
| Video | `video` | `video.fill` |
| Photo | `photo` | `photo.fill` |
| Layers | `square.3.layers.3d` | `square.3.layers.3d.fill` |

---

## Animation

### Timing

```swift
extension Animation {
    /// Quick response (buttons, selections)
    static let quick = Animation.easeOut(duration: 0.15)
    
    /// Standard transitions
    static let standard = Animation.easeInOut(duration: 0.25)
    
    /// Smooth movements (panels, sheets)
    static let smooth = Animation.spring(response: 0.4, dampingFraction: 0.8)
    
    /// Bouncy feedback (success states)
    static let bouncy = Animation.spring(response: 0.35, dampingFraction: 0.6)
}
```

### Transitions

```swift
extension AnyTransition {
    /// Slide up (for bottom sheets, panels)
    static var slideUp: AnyTransition {
        .move(edge: .bottom).combined(with: .opacity)
    }
    
    /// Scale in (for selections, badges)
    static var pop: AnyTransition {
        .scale(scale: 0.8).combined(with: .opacity)
    }
    
    /// Fade (general purpose)
    static var fade: AnyTransition {
        .opacity
    }
}
```

---

## Haptics

Same haptic system, but used more sparingly to match the minimal aesthetic.

| Interaction | Haptic | Notes |
|-------------|--------|-------|
| Selection | `.light` | Tap on media item |
| Toggle | `.light` | Checkboxes, switches |
| Button press | `.medium` | Primary/secondary buttons |
| Delete | `.heavy` | Destructive actions |
| Success | `.success` | Export complete |
| Error | `.error` | Operation failed |
| Scrubbing | `.selection` | Timeline scrub |

---

## Dark Mode Only

Stack is **dark mode only**. Do not support light mode.

```swift
// In App entry point
@main
struct StackApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(.dark)  // Force dark mode
        }
    }
}
```

---

## Sample Screen Compositions

### Import Screen

```
┌─────────────────────────────────────┐
│           [Status Bar]              │  ← White text
├─────────────────────────────────────┤
│                                     │
│                                     │
│                                     │
│         ┌─────────────┐             │
│         │  ▶︎ + □     │             │  ← White icon, 48pt
│         └─────────────┘             │
│                                     │
│             Stack                   │  ← PP Fuji Bold 34pt
│                                     │
│    Create video collages that       │  ← PP Fuji Regular 16pt
│    move together                    │    White @ 60%
│                                     │
│                                     │
│   ┌─────────────────────────────┐   │
│   │     ███ Import Media ███    │   │  ← Teal (#009290) background
│   └─────────────────────────────┘   │    Black text
│                                     │
│                                     │
│                                     │
│                                     │
├─────────────────────────────────────┤
│     ┌─────────────────────────┐     │
│     │   ⊕      ▤      ≡     │     │  ← Glass tab bar
│     │ Create Library Settings │     │
│     └─────────────────────────┘     │
└─────────────────────────────────────┘
          Pure black background
```

### Contact Sheet

```
┌─────────────────────────────────────┐
│  ←  Select Media            Done →  │  ← White text, teal "Done"
├─────────────────────────────────────┤
│ ┌─────────┐ ┌─────────┐ ┌─────────┐ │
│ │ ◉    ▶︎ │ │ ○    □ │ │ ◉    ▶︎ │ │  ← Teal checkmark when selected
│ │ content │ │ content │ │ content │ │    Media type badge (glass)
│ │   0:12  │ │   IMG   │ │   0:08  │ │  ← Duration badge (glass)
│ └─────────┘ └─────────┘ └─────────┘ │
│ ┌─────────┐ ┌─────────┐ ┌─────────┐ │
│ │ ○    □ │ │ ◉    ▶︎ │ │ ○    □ │ │
│ │ content │ │ content │ │ content │ │
│ │   IMG   │ │   0:22  │ │   IMG   │ │
│ └─────────┘ └─────────┘ └─────────┘ │
│                                     │
│                                     │
├─────────────────────────────────────┤
│     ┌─────────────────────────┐     │
│     │  6 selected  │ Continue │     │  ← Glass panel
│     └─────────────────────────┘     │    Teal continue button
├─────────────────────────────────────┤
│     ┌─────────────────────────┐     │
│     │   ⊕      ▤      ≡     │     │
│     └─────────────────────────┘     │
└─────────────────────────────────────┘
```

### Canvas

```
┌─────────────────────────────────────┐
│  ←                         Export → │  ← Teal "Export"
├─────────────────────────────────────┤
│ ┌───────────────────────────────┐   │
│ │                               │   │
│ │    ┌─────────┐  ┌────────┐    │   │  ← User content (colorful)
│ │    │ Video 1 │  │ Image  │    │   │
│ │    └─────────┘  └────────┘    │   │    Layers CAN overflow edges
│ │         ┌──────────────┐      │   │
│ │         │   Video 2    │      │   │
│ │         └──────────────┘      │   │
│ │    ┌────┐    ┌────────────┐   │   │
│ │    │Img │    │  Video 3   │   │   │
│ │    └────┘    └────────────┘   │   │
│ │                               │   │
│ └───────────────────────────────┘   │
│                                     │
├─────────────────────────────────────┤
│ ┌─────────────────────────────────┐ │
│ │  ◀◀   ▶︎   ▶▶    0:00 / 0:30  │ │  ← Glass controls
│ │  ━━━━━━━━●━━━━━━━━━━━━━━━━━━━  │ │    Teal scrubber
│ └─────────────────────────────────┘ │
├─────────────────────────────────────┤
│     ┌─────────────────────────┐     │
│     │   ⊕      ▤      ≡     │     │
│     └─────────────────────────┘     │
└─────────────────────────────────────┘
```

### Settings Tab - Audio Mixer

The Settings tab shows a contact sheet grid of all media in the current composition with per-clip audio controls.

```
┌─────────────────────────────────────┐
│             Settings                │
├─────────────────────────────────────┤
│                                     │
│  Audio Mixer                        │  ← Section header
│  ┌─────────────────────────────────┐│
│  │                                 ││
│  │ ┌──────┐ ┌──────┐ ┌──────┐     ││  ← Contact sheet grid
│  │ │thumb │ │thumb │ │thumb │     ││    of all media
│  │ │  🔊  │ │  🔇  │ │  🔊  │     ││
│  │ │──●── │ │──○── │ │──●── │     ││  ← Volume sliders
│  │ │ 80%  │ │  0%  │ │ 100% │     ││
│  │ └──────┘ └──────┘ └──────┘     ││
│  │ ┌──────┐ ┌──────┐              ││
│  │ │thumb │ │thumb │  [IMG]       ││  ← Images show no slider
│  │ │  🔊  │ │  🔊  │              ││
│  │ │──●── │ │──●── │              ││
│  │ │ 50%  │ │ 100% │              ││
│  │ └──────┘ └──────┘              ││
│  │                                 ││
│  └─────────────────────────────────┘│
│                                     │
│  Defaults                           │  ← Section header
│  ┌─────────────────────────────────┐│
│  │ Image Duration      [ 1.0s ▼ ] ││  ← Dropdown/picker
│  │ Default Canvas      [ 9:16 ▼ ] ││
│  │ Loop Media          [───●    ] ││  ← Toggle
│  └─────────────────────────────────┘│
│                                     │
├─────────────────────────────────────┤
│     ┌─────────────────────────┐     │
│     │   ⊕      ▤      ≡     │     │
│     └─────────────────────────┘     │
└─────────────────────────────────────┘
```

### Export Screen

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
│  │  ● 4K (3840×2160)               ││  ← Teal selection dot
│  └─────────────────────────────────┘│
│                                     │
│  Estimated Size: ~128 MB            │
│  Duration: 0:30                     │
│                                     │
│                                     │
├─────────────────────────────────────┤
│  ┌──────────────────────────────┐   │
│  │     ███ Export Video ███     │   │  ← Teal button
│  └──────────────────────────────┘   │
└─────────────────────────────────────┘
```
