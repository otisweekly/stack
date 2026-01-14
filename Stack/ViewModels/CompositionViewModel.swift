import SwiftUI
import AVFoundation

@Observable
final class CompositionViewModel {
    var composition: Composition
    var mediaItems: [MediaItem]
    var selectedLayerID: UUID?
    var isPlaying = false
    var currentTime: CMTime = .zero
    var totalDuration: TimeInterval = 0

    init(composition: Composition, mediaItems: [MediaItem]) {
        self.composition = composition
        self.mediaItems = mediaItems
        self.totalDuration = composition.calculateDuration(with: mediaItems)
    }

    func mediaItem(for layer: MediaLayer) -> MediaItem? {
        mediaItems.first { $0.id == layer.mediaID }
    }

    func selectLayer(_ id: UUID?) {
        selectedLayerID = id
        HapticsService.shared.selection()
    }

    func updateLayerPosition(_ id: UUID, position: CGPoint) {
        guard var layer = composition.layers.first(where: { $0.id == id }) else { return }
        layer.position = position
        composition.updateLayer(layer)
    }

    func updateLayerSize(_ id: UUID, size: CGSize) {
        guard var layer = composition.layers.first(where: { $0.id == id }) else { return }
        layer.size = size
        composition.updateLayer(layer)
    }

    func bringToFront(_ id: UUID) {
        composition.bringToFront(layerID: id)
        HapticsService.shared.medium()
    }

    func sendToBack(_ id: UUID) {
        composition.sendToBack(layerID: id)
        HapticsService.shared.medium()
    }

    func deleteLayer(_ id: UUID) {
        composition.removeLayer(id: id)
        if selectedLayerID == id {
            selectedLayerID = nil
        }
        HapticsService.shared.heavy()
    }

    func togglePlay() {
        isPlaying.toggle()
        HapticsService.shared.light()
    }

    func seek(to time: CMTime) {
        currentTime = time
        HapticsService.shared.selection()
    }

    func updateCanvasSize(_ size: CanvasSize) {
        composition.canvasSize = size
        HapticsService.shared.light()
    }
}
