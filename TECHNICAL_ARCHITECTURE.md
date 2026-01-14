# Technical Architecture

## Overview

Stack is built using a layered architecture that separates concerns between UI, business logic, and media processing. The app leverages SwiftUI for the interface, Combine for reactive data flow, and AVFoundation + Metal for video compositing.

---

## Architecture Pattern

**MVVM + Coordinator**

```
┌─────────────────────────────────────────────────────────────┐
│                         Views (SwiftUI)                      │
│  ImportView | ContactSheetView | CanvasView | ExportView    │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                      ViewModels                              │
│  ImportVM | CompositionVM | ExportVM                        │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                       Services                               │
│  MediaImportService | CompositorService | ExportService     │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                    Core Frameworks                           │
│  AVFoundation | Metal | Photos | CoreImage                  │
└─────────────────────────────────────────────────────────────┘
```

---

## Project Structure

```
Stack/
├── App/
│   ├── StackApp.swift              # App entry point
│   └── AppCoordinator.swift         # Navigation coordination
│
├── Models/
│   ├── VideoClip.swift              # Video asset model
│   ├── Composition.swift            # Canvas state model
│   ├── VideoLayer.swift             # Individual layer in composition
│   └── CanvasConfiguration.swift    # Canvas size/ratio settings
│
├── ViewModels/
│   ├── ImportViewModel.swift        # Handles media import flow
│   ├── CompositionViewModel.swift   # Manages canvas state
│   └── ExportViewModel.swift        # Manages export process
│
├── Views/
│   ├── Import/
│   │   ├── ImportView.swift         # Initial import screen
│   │   └── ContactSheetView.swift   # Grid of imported videos
│   │
│   ├── Canvas/
│   │   ├── CanvasView.swift         # Main composition canvas
│   │   ├── VideoLayerView.swift     # Individual video layer
│   │   ├── CanvasControlsView.swift # Playback controls
│   │   └── LayerHandleView.swift    # Resize/move handles
│   │
│   ├── Export/
│   │   ├── ExportView.swift         # Export options screen
│   │   └── ExportProgressView.swift # Progress indicator
│   │
│   ├── Utility/
│   │   ├── UtilityPanelView.swift   # Sliding drawer panel
│   │   └── CanvasSettingsView.swift # Canvas configuration
│   │
│   └── Components/
│       ├── ThumbnailView.swift      # Video thumbnail component
│       ├── DurationBadge.swift      # Time duration badge
│       └── HapticButton.swift       # Button with haptic feedback
│
├── Services/
│   ├── MediaImportService.swift     # PHPicker + asset loading
│   ├── ThumbnailService.swift       # Video thumbnail generation
│   ├── CompositorService.swift      # Real-time video compositing
│   ├── ExportService.swift          # Final video rendering
│   └── HapticsService.swift         # Haptic feedback manager
│
├── Compositor/
│   ├── StackCompositor.swift       # AVVideoCompositing impl
│   ├── StackInstruction.swift      # AVVideoCompositionInstruction
│   ├── MetalRenderer.swift          # Metal-based frame rendering
│   └── Shaders.metal                # Metal shader functions
│
├── Extensions/
│   ├── AVAsset+Extensions.swift     # Asset helpers
│   ├── CGSize+AspectRatio.swift     # Size calculations
│   ├── Color+Theme.swift            # App color palette
│   └── View+Haptics.swift           # Haptic view modifiers
│
├── Resources/
│   ├── Assets.xcassets/             # Images and colors
│   └── Localizable.strings          # Localized strings
│
└── Preview Content/
    └── PreviewAssets.xcassets/      # Preview assets
```

---

## Core Frameworks

### AVFoundation

Used for:
- Loading video assets (`AVAsset`, `AVURLAsset`)
- Video composition (`AVMutableComposition`, `AVMutableVideoComposition`)
- Playback (`AVPlayer`, `AVPlayerLayer`)
- Export (`AVAssetExportSession`)

### Metal

Used for:
- Real-time video frame compositing
- GPU-accelerated rendering of multiple video layers
- Custom blend modes (future)

### Photos Framework

Used for:
- PHPicker for video selection
- Saving exports to camera roll
- Accessing video metadata

### CoreImage

Used for:
- Frame transformations (scale, position)
- Optional image processing (future filters)

---

## Data Flow

### Import Flow

```
PHPicker Selection
       │
       ▼
MediaImportService.loadAssets()
       │
       ├──▶ Create VideoClip models
       │
       ├──▶ ThumbnailService.generateThumbnails()
       │
       ▼
ImportViewModel updates @Published clips
       │
       ▼
ContactSheetView renders grid
```

### Composition Flow

```
User Gesture (drag/pinch)
       │
       ▼
CanvasView gesture handlers
       │
       ▼
CompositionViewModel.updateLayer()
       │
       ├──▶ Update VideoLayer position/size
       │
       ▼
CompositorService.updateComposition()
       │
       ▼
MetalRenderer re-renders frame
       │
       ▼
CanvasView displays updated preview
```

### Export Flow

```
User taps Export
       │
       ▼
ExportViewModel.startExport()
       │
       ▼
ExportService.renderComposition()
       │
       ├──▶ Create AVMutableComposition
       │
       ├──▶ Apply StackCompositor
       │
       ├──▶ AVAssetExportSession.exportAsynchronously()
       │
       ▼
Save to Photos library
```

---

## Video Compositing Architecture

### Real-Time Preview

For preview playback, we use a Metal-based approach:

1. **AVPlayerLooper** for each video layer (looping playback)
2. **CADisplayLink** to sync frame updates
3. **MetalRenderer** composites all visible frames
4. **MTKView** displays the final composited frame

```swift
// Pseudocode for render loop
func displayLinkFired() {
    let currentTime = CACurrentMediaTime()
    
    // Get current frame from each layer's player
    var frames: [(texture: MTLTexture, transform: LayerTransform)] = []
    for layer in composition.layers {
        if let texture = layer.player.currentFrameTexture {
            frames.append((texture, layer.transform))
        }
    }
    
    // Composite all frames
    metalRenderer.composite(frames: frames, to: outputTexture)
    
    // Display
    metalView.currentDrawable?.present()
}
```

### Export Rendering

For export, we use AVFoundation's compositor protocol:

1. **AVMutableComposition** holds all video tracks
2. **AVMutableVideoComposition** with custom compositor
3. **StackCompositor** implements `AVVideoCompositing`
4. **StackInstruction** implements `AVVideoCompositionInstructionProtocol`

```swift
class StackCompositor: NSObject, AVVideoCompositing {
    func renderContext(for request: AVAsynchronousVideoCompositionRequest) {
        // Get source frames for all layers
        // Composite using Metal or CoreImage
        // Return final frame
    }
}
```

---

## Memory Management

### Video Assets

- Load assets lazily (only when needed for playback)
- Use `AVAssetImageGenerator` for thumbnails (don't decode full video)
- Release players when layers are removed

### Thumbnails

- Generate at 1x scale, display at appropriate size
- Cache in memory with `NSCache` (auto-eviction)
- Don't persist to disk

### Metal Resources

- Reuse textures where possible
- Use texture pools for intermediate buffers
- Release resources on memory warning

---

## Threading Model

| Operation | Thread |
|-----------|--------|
| UI updates | Main |
| Asset loading | Background (async) |
| Thumbnail generation | Background (async) |
| Metal rendering | Render thread |
| Export encoding | Background (async) |

### Concurrency

```swift
// Asset loading
Task {
    let asset = AVAsset(url: url)
    let duration = try await asset.load(.duration)
    
    await MainActor.run {
        viewModel.updateClip(duration: duration)
    }
}

// Export with progress
exportSession.exportAsynchronously {
    // Completion on arbitrary thread
    Task { @MainActor in
        viewModel.exportCompleted()
    }
}
```

---

## State Management

### AppState (Global)

```swift
@Observable
class AppState {
    var currentScreen: Screen = .import
    var composition: Composition?
    var isExporting: Bool = false
}
```

### CompositionViewModel (Canvas)

```swift
@Observable
class CompositionViewModel {
    var layers: [VideoLayer] = []
    var selectedLayerID: UUID?
    var canvasSize: CanvasSize = .portrait9x16
    var isPlaying: Bool = false
    var currentTime: CMTime = .zero
}
```

---

## Error Handling

### Error Types

```swift
enum StackError: LocalizedError {
    case importFailed(underlying: Error)
    case assetLoadFailed(url: URL)
    case exportFailed(reason: String)
    case compositorError(reason: String)
    case insufficientMemory
    
    var errorDescription: String? {
        switch self {
        case .importFailed(let error):
            return "Failed to import videos: \(error.localizedDescription)"
        // ... etc
        }
    }
}
```

### Error Presentation

- Use SwiftUI `.alert()` for user-facing errors
- Log technical details to console for debugging
- Graceful degradation where possible

---

## Performance Targets

| Metric | Target |
|--------|--------|
| Import 12 videos | < 3 seconds |
| Thumbnail generation (12) | < 2 seconds |
| Preview frame rate | 60 fps |
| Export 30s composition | < 30 seconds |
| Memory (12 layers) | < 500 MB |
| App launch | < 1 second |
