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

    /// Sorted layers by z-index (back to front)
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
