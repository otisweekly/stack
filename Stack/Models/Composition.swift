import Foundation

/// Represents the full canvas composition with all layers
struct Composition: Equatable {
    var id: UUID
    var layers: [VideoLayer]
    var canvasSize: CanvasSize
    var loopEnabled: Bool
    var snapToGridEnabled: Bool

    init(
        id: UUID = UUID(),
        layers: [VideoLayer] = [],
        canvasSize: CanvasSize = .portrait9x16,
        loopEnabled: Bool = true,
        snapToGridEnabled: Bool = false
    ) {
        self.id = id
        self.layers = layers
        self.canvasSize = canvasSize
        self.loopEnabled = loopEnabled
        self.snapToGridEnabled = snapToGridEnabled
    }

    /// Create an empty composition with default settings
    static func empty() -> Composition {
        Composition()
    }

    /// Layers sorted by z-index (lowest first for rendering order)
    var sortedStack: [VideoLayer] {
        layers.sorted { $0.zIndex < $1.zIndex }
    }

    /// Duration based on the longest layer (requires clips to calculate)
    func duration(clips: [VideoClip]) -> TimeInterval {
        layers.compactMap { layer in
            clips.first { $0.id == layer.clipID }?.duration
        }.max() ?? 0
    }

    /// Add a new layer to the composition
    mutating func addLayer(_ layer: VideoLayer) {
        layers.append(layer)
    }

    /// Update an existing layer
    mutating func updateLayer(_ layer: VideoLayer) {
        if let index = layers.firstIndex(where: { $0.id == layer.id }) {
            layers[index] = layer
        }
    }

    /// Remove a layer by ID
    mutating func removeLayer(id: UUID) {
        layers.removeAll { $0.id == id }
    }

    /// Bring a layer to the front (highest z-index)
    mutating func bringToFront(layerID: UUID) {
        guard let maxZ = layers.map(\.zIndex).max(),
              let index = layers.firstIndex(where: { $0.id == layerID }) else { return }
        layers[index].zIndex = maxZ + 1
    }

    /// Send a layer to the back (lowest z-index)
    mutating func sendToBack(layerID: UUID) {
        guard let minZ = layers.map(\.zIndex).min(),
              let index = layers.firstIndex(where: { $0.id == layerID }) else { return }
        layers[index].zIndex = minZ - 1
    }
}
