# Data Models (Updated)

## Overview

This document defines all data models for Layers. Key update: **Images are now supported alongside videos.** Images display for a configurable duration (default 1 second), while videos play their full duration.

---

## Core Models

### MediaItem

Base type for both videos and images.

```swift
import Foundation
import AVFoundation
import Photos

/// Represents any media item (video or image) imported from the user's library
struct MediaItem: Identifiable, Hashable {
    let id: UUID
    let assetIdentifier: String          // PHAsset local identifier
    let url: URL                          // Local file URL
    let type: MediaType
    let originalSize: CGSize              // Native dimensions
    let creationDate: Date?
    var thumbnailURL: URL?                // Generated thumbnail location
    
    // Video-specific (nil for images)
    let videoDuration: TimeInterval?
    
    // Image-specific
    let defaultImageDuration: TimeInterval = 1.0  // Images show for 1 second
    
    /// Effective duration for playback
    var duration: TimeInterval {
        switch type {
        case .video:
            return videoDuration ?? 0
        case .image:
            return defaultImageDuration
        }
    }
    
    var aspectRatio: CGFloat {
        guard originalSize.height > 0 else { return 1 }
        return originalSize.width / originalSize.height
    }
    
    var formattedDuration: String {
        switch type {
        case .video:
            let minutes = Int(duration) / 60
            let seconds = Int(duration) % 60
            return String(format: "%d:%02d", minutes, seconds)
        case .image:
            return "IMG"
        }
    }
    
    var isVideo: Bool { type == .video }
    var isImage: Bool { type == .image }
    
    // Hashable
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: MediaItem, rhs: MediaItem) -> Bool {
        lhs.id == rhs.id
    }
}

enum MediaType: String, Codable {
    case video
    case image
}
```

### MediaItem Factory

```swift
extension MediaItem {
    /// Creates a MediaItem from a PHAsset (video)
    static func fromVideo(asset: PHAsset, url: URL) async throws -> MediaItem {
        let avAsset = AVAsset(url: url)
        let duration = try await avAsset.load(.duration)
        let tracks = try await avAsset.load(.tracks)
        
        var size = CGSize(width: 1920, height: 1080)
        if let videoTrack = tracks.first(where: { $0.mediaType == .video }) {
            size = try await videoTrack.load(.naturalSize)
            let transform = try await videoTrack.load(.preferredTransform)
            if transform.a == 0 && transform.d == 0 {
                size = CGSize(width: size.height, height: size.width)
            }
        }
        
        return MediaItem(
            id: UUID(),
            assetIdentifier: asset.localIdentifier,
            url: url,
            type: .video,
            originalSize: size,
            creationDate: asset.creationDate,
            videoDuration: duration.seconds
        )
    }
    
    /// Creates a MediaItem from a PHAsset (image)
    static func fromImage(asset: PHAsset, url: URL) -> MediaItem {
        let size = CGSize(width: asset.pixelWidth, height: asset.pixelHeight)
        
        return MediaItem(
            id: UUID(),
            assetIdentifier: asset.localIdentifier,
            url: url,
            type: .image,
            originalSize: size,
            creationDate: asset.creationDate,
            videoDuration: nil
        )
    }
}
```

---

### MediaLayer

Represents a single media layer within the composition canvas.

```swift
import Foundation
import CoreGraphics
import AVFoundation

struct MediaLayer: Identifiable, Hashable, Codable {
    let id: UUID
    let mediaID: UUID                     // Reference to source MediaItem
    let mediaType: MediaType
    
    // Transform (in canvas coordinate space, 0-1 normalized)
    var position: CGPoint                 // Center point
    var size: CGSize                      // Width and height (normalized)
    var zIndex: Int                       // Layer ordering (higher = front)
    
    // Visibility and timing
    var isVisible: Bool = true
    
    // For images: how long to display (default 1 second)
    var imageDuration: TimeInterval = 1.0
    
    // For videos: offset into source video
    var videoStartTime: CMTime = .zero
    var playbackRate: Float = 1.0
    
    // Audio control (videos only)
    var audioVolume: Float = 1.0          // 0.0 (muted) to 1.0 (full)
    var isMuted: Bool { audioVolume == 0 }
    
    /// Effective duration for this layer
    var duration: TimeInterval {
        switch mediaType {
        case .image:
            return imageDuration
        case .video:
            return 0  // Calculated from source at runtime
        }
    }
    
    // Computed
    var frame: CGRect {
        CGRect(
            x: position.x - size.width / 2,
            y: position.y - size.height / 2,
            width: size.width,
            height: size.height
        )
    }
    
    // Hashable
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: MediaLayer, rhs: MediaLayer) -> Bool {
        lhs.id == rhs.id
    }
}

extension MediaLayer {
    /// Creates a new layer from a media item with default positioning
    static func from(media: MediaItem, zIndex: Int) -> MediaLayer {
        // Default size: fit to 40% of canvas width, maintain aspect ratio
        let width: CGFloat = 0.4
        let height = width / media.aspectRatio
        
        // Default position: slightly randomized center
        let offsetX = CGFloat.random(in: -0.1...0.1)
        let offsetY = CGFloat.random(in: -0.1...0.1)
        
        return MediaLayer(
            id: UUID(),
            mediaID: media.id,
            mediaType: media.type,
            position: CGPoint(x: 0.5 + offsetX, y: 0.5 + offsetY),
            size: CGSize(width: width, height: height),
            zIndex: zIndex
        )
    }
    
    /// Returns the frame in pixel coordinates for a given canvas size
    func pixelFrame(in canvasSize: CGSize) -> CGRect {
        CGRect(
            x: frame.origin.x * canvasSize.width,
            y: frame.origin.y * canvasSize.height,
            width: frame.size.width * canvasSize.width,
            height: frame.size.height * canvasSize.height
        )
    }
}
```

---

### Composition

Represents the entire project/composition state.

```swift
import Foundation
import CoreGraphics
import AVFoundation

struct Composition: Identifiable, Codable {
    let id: UUID
    var name: String
    var canvasSize: CanvasSize
    var layers: [MediaLayer]
    var createdAt: Date
    var modifiedAt: Date
    
    // Playback settings
    var loopMedia: Bool = true
    var snapToGrid: Bool = false
    
    // Max duration cap
    static let maxDuration: TimeInterval = 90.0
    
    /// Computed duration (longest media in composition)
    /// For images, uses their imageDuration
    /// For videos, must be calculated with actual MediaItem data
    var sortedLayers: [MediaLayer] {
        layers.sorted { $0.zIndex < $1.zIndex }
    }
    
    // MARK: - Layer Management
    
    mutating func addLayer(_ layer: MediaLayer) {
        layers.append(layer)
        modifiedAt = Date()
    }
    
    mutating func removeLayer(id: UUID) {
        layers.removeAll { $0.id == id }
        reindexLayers()
        modifiedAt = Date()
    }
    
    mutating func updateLayer(_ layer: MediaLayer) {
        if let index = layers.firstIndex(where: { $0.id == layer.id }) {
            layers[index] = layer
            modifiedAt = Date()
        }
    }
    
    mutating func bringToFront(layerID: UUID) {
        guard let layer = layers.first(where: { $0.id == layerID }) else { return }
        let maxZ = layers.map(\.zIndex).max() ?? 0
        var updatedLayer = layer
        updatedLayer.zIndex = maxZ + 1
        updateLayer(updatedLayer)
    }
    
    mutating func sendToBack(layerID: UUID) {
        guard let layer = layers.first(where: { $0.id == layerID }) else { return }
        let minZ = layers.map(\.zIndex).min() ?? 0
        var updatedLayer = layer
        updatedLayer.zIndex = minZ - 1
        updateLayer(updatedLayer)
        reindexLayers()
    }
    
    mutating func updateImageDuration(_ layerID: UUID, duration: TimeInterval) {
        guard var layer = layers.first(where: { $0.id == layerID }),
              layer.mediaType == .image else { return }
        layer.imageDuration = duration
        updateLayer(layer)
    }
    
    mutating func updateAudioVolume(_ layerID: UUID, volume: Float) {
        guard var layer = layers.first(where: { $0.id == layerID }),
              layer.mediaType == .video else { return }
        layer.audioVolume = max(0, min(1, volume))
        updateLayer(layer)
    }
    
    mutating func toggleMute(_ layerID: UUID) {
        guard var layer = layers.first(where: { $0.id == layerID }),
              layer.mediaType == .video else { return }
        layer.audioVolume = layer.audioVolume > 0 ? 0 : 1.0
        updateLayer(layer)
    }
    
    private mutating func reindexLayers() {
        let sorted = layers.sorted { $0.zIndex < $1.zIndex }
        for (index, layer) in sorted.enumerated() {
            if let layerIndex = layers.firstIndex(where: { $0.id == layer.id }) {
                layers[layerIndex].zIndex = index
            }
        }
    }
}

extension Composition {
    static func empty(name: String = "Untitled") -> Composition {
        Composition(
            id: UUID(),
            name: name,
            canvasSize: .portrait9x16,
            layers: [],
            createdAt: Date(),
            modifiedAt: Date()
        )
    }
    
    /// Calculate total duration given the media items (capped at 90 seconds)
    func calculateDuration(with mediaItems: [MediaItem]) -> TimeInterval {
        var maxDuration: TimeInterval = 0
        
        for layer in layers {
            let layerDuration: TimeInterval
            
            switch layer.mediaType {
            case .image:
                layerDuration = layer.imageDuration
            case .video:
                if let media = mediaItems.first(where: { $0.id == layer.mediaID }) {
                    layerDuration = media.duration
                } else {
                    layerDuration = 0
                }
            }
            
            maxDuration = max(maxDuration, layerDuration)
        }
        
        // Cap at maximum allowed duration
        return min(maxDuration, Self.maxDuration)
    }
}
```

---

### CanvasSize

```swift
import Foundation
import CoreGraphics

enum CanvasSize: String, Codable, CaseIterable, Identifiable {
    case portrait9x16 = "9:16"
    case landscape16x9 = "16:9"
    case square1x1 = "1:1"
    case portrait4x5 = "4:5"
    
    var id: String { rawValue }
    
    var aspectRatio: CGFloat {
        switch self {
        case .portrait9x16: return 9.0 / 16.0
        case .landscape16x9: return 16.0 / 9.0
        case .square1x1: return 1.0
        case .portrait4x5: return 4.0 / 5.0
        }
    }
    
    var displayName: String {
        switch self {
        case .portrait9x16: return "9:16"
        case .landscape16x9: return "16:9"
        case .square1x1: return "1:1"
        case .portrait4x5: return "4:5"
        }
    }
    
    var subtitle: String {
        switch self {
        case .portrait9x16: return "Stories, Reels, TikTok"
        case .landscape16x9: return "YouTube, Landscape"
        case .square1x1: return "Square"
        case .portrait4x5: return "Instagram Portrait"
        }
    }
    
    func pixelSize(for resolution: ExportResolution) -> CGSize {
        switch resolution {
        case .hd1080:
            switch self {
            case .portrait9x16: return CGSize(width: 1080, height: 1920)
            case .landscape16x9: return CGSize(width: 1920, height: 1080)
            case .square1x1: return CGSize(width: 1080, height: 1080)
            case .portrait4x5: return CGSize(width: 1080, height: 1350)
            }
        case .uhd4k:
            switch self {
            case .portrait9x16: return CGSize(width: 2160, height: 3840)
            case .landscape16x9: return CGSize(width: 3840, height: 2160)
            case .square1x1: return CGSize(width: 2160, height: 2160)
            case .portrait4x5: return CGSize(width: 2160, height: 2700)
            }
        }
    }
    
    func fittedSize(in container: CGSize) -> CGSize {
        let containerRatio = container.width / container.height
        if aspectRatio > containerRatio {
            return CGSize(width: container.width, height: container.width / aspectRatio)
        } else {
            return CGSize(width: container.height * aspectRatio, height: container.height)
        }
    }
}
```

---

### ExportResolution & Settings

```swift
enum ExportResolution: String, Codable, CaseIterable, Identifiable {
    case hd1080 = "1080p"
    case uhd4k = "4K"
    
    var id: String { rawValue }
    
    var displayName: String {
        switch self {
        case .hd1080: return "1080p"
        case .uhd4k: return "4K"
        }
    }
    
    var bitrate: Int {
        switch self {
        case .hd1080: return 10_000_000
        case .uhd4k: return 35_000_000
        }
    }
}

struct ExportSettings: Codable {
    var resolution: ExportResolution = .hd1080
    
    func estimatedFileSize(duration: TimeInterval) -> Int64 {
        Int64(Double(resolution.bitrate) * duration / 8)
    }
    
    func formattedEstimatedSize(duration: TimeInterval) -> String {
        let bytes = estimatedFileSize(duration: duration)
        let formatter = ByteCountFormatter()
        formatter.countStyle = .file
        return formatter.string(fromByteCount: bytes)
    }
}
```

---

## View State Models

### AppSettings

Persisted user preferences.

```swift
import Foundation

struct AppSettings: Codable {
    var defaultImageDuration: TimeInterval = 1.0     // 0.5 - 5.0 seconds
    var defaultCanvasSize: CanvasSize = .portrait9x16
    var loopMediaByDefault: Bool = true
    
    // Persist to UserDefaults
    static let key = "StackAppSettings"
    
    static func load() -> AppSettings {
        guard let data = UserDefaults.standard.data(forKey: key),
              let settings = try? JSONDecoder().decode(AppSettings.self, from: data) else {
            return AppSettings()
        }
        return settings
    }
    
    func save() {
        if let data = try? JSONEncoder().encode(self) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }
}
```

### AppState

```swift
import SwiftUI

@Observable
final class AppState {
    var currentTab: Tab = .create
    var mediaItems: [MediaItem] = []
    var composition: Composition?
    var selectedLayerID: UUID?
    var isExporting = false
    var settings: AppSettings = AppSettings.load()
    
    enum Tab {
        case create
        case library
        case settings
    }
    
    func reset() {
        mediaItems = []
        composition = nil
        selectedLayerID = nil
        isExporting = false
    }
    
    func mediaItem(for layer: MediaLayer) -> MediaItem? {
        mediaItems.first { $0.id == layer.mediaID }
    }
    
    func saveSettings() {
        settings.save()
    }
    
    // Audio helpers for Settings tab
    func videoLayers() -> [MediaLayer] {
        composition?.layers.filter { $0.mediaType == .video } ?? []
    }
    
    func setVolume(_ volume: Float, for layerID: UUID) {
        composition?.updateAudioVolume(layerID, volume: volume)
    }
}
```

### ImportState

```swift
enum ImportState: Equatable {
    case idle
    case selecting
    case loading(progress: Double, loaded: Int, total: Int)
    case loaded(items: [MediaItem])
    case error(message: String)
    
    var isLoading: Bool {
        if case .loading = self { return true }
        return false
    }
}
```

### SelectionState

```swift
struct SelectionState: Equatable {
    var selectedIDs: Set<UUID> = []
    
    var count: Int { selectedIDs.count }
    var isEmpty: Bool { selectedIDs.isEmpty }
    
    mutating func toggle(_ id: UUID) {
        if selectedIDs.contains(id) {
            selectedIDs.remove(id)
        } else {
            selectedIDs.insert(id)
        }
    }
    
    mutating func selectAll(_ ids: [UUID]) {
        selectedIDs = Set(ids)
    }
    
    mutating func deselectAll() {
        selectedIDs.removeAll()
    }
    
    func isSelected(_ id: UUID) -> Bool {
        selectedIDs.contains(id)
    }
}
```

---

## Image Duration Settings

Users can adjust how long an image displays:

```swift
struct ImageDurationPicker: View {
    @Binding var duration: TimeInterval
    
    let presets: [TimeInterval] = [0.5, 1.0, 2.0, 3.0, 5.0]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Display Duration")
                .font(.fujiLabel)
                .foregroundColor(.textPrimary)
            
            HStack(spacing: 8) {
                ForEach(presets, id: \.self) { preset in
                    Button {
                        duration = preset
                        HapticsService.shared.light()
                    } label: {
                        Text(formatDuration(preset))
                            .font(.fujiLabelSmall)
                            .foregroundColor(duration == preset ? .stackBlack : .stackWhite)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(duration == preset ? Color.stackAccent : Color.clear)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.stackWhite.opacity(0.3), lineWidth: 1)
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                }
            }
        }
    }
    
    private func formatDuration(_ seconds: TimeInterval) -> String {
        if seconds < 1 {
            return "\(Int(seconds * 1000))ms"
        } else {
            return "\(Int(seconds))s"
        }
    }
}
```

---

## Persistence

### Project File Format

```swift
struct ProjectFile: Codable {
    static let currentVersion = 2  // Updated for image support
    
    let version: Int
    let composition: Composition
    let mediaManifest: [MediaManifest]
    
    struct MediaManifest: Codable {
        let mediaID: UUID
        let assetIdentifier: String
        let type: MediaType
        let originalFilename: String
    }
}
```

---

## Extensions

### CMTime Extensions

```swift
import AVFoundation

extension CMTime {
    var displayString: String {
        guard isValid && !isIndefinite else { return "--:--" }
        let totalSeconds = Int(seconds)
        let minutes = totalSeconds / 60
        let secs = totalSeconds % 60
        return String(format: "%d:%02d", minutes, secs)
    }
}
```

### TimeInterval Extensions

```swift
extension TimeInterval {
    var displayString: String {
        let totalSeconds = Int(self)
        let minutes = totalSeconds / 60
        let secs = totalSeconds % 60
        return String(format: "%d:%02d", minutes, secs)
    }
}
```
