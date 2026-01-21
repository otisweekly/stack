import Foundation

/// Represents a media layer positioned on the canvas
struct VideoLayer: Identifiable, Equatable {
    let id: UUID
    let clipID: UUID
    var position: CGPoint      // Normalized (0-1) relative to canvas
    var size: CGSize           // Normalized (0-1) relative to canvas
    var zIndex: Int
    var audioVolume: Float     // 0.0 to 1.0

    init(
        id: UUID = UUID(),
        clipID: UUID,
        position: CGPoint = CGPoint(x: 0.5, y: 0.5),
        size: CGSize = CGSize(width: 0.5, height: 0.5),
        zIndex: Int = 0,
        audioVolume: Float = 1.0
    ) {
        self.id = id
        self.clipID = clipID
        self.position = position
        self.size = size
        self.zIndex = zIndex
        self.audioVolume = audioVolume
    }

    /// Create a layer from a clip with default positioning
    static func from(clip: VideoClip, zIndex: Int) -> VideoLayer {
        VideoLayer(
            clipID: clip.id,
            position: CGPoint(x: 0.5, y: 0.5),
            size: CGSize(width: 0.4, height: 0.4),
            zIndex: zIndex,
            audioVolume: clip.isVideo ? 1.0 : 0.0
        )
    }

    /// Calculate pixel frame from normalized coordinates
    func pixelFrame(in canvasSize: CGSize) -> CGRect {
        let width = size.width * canvasSize.width
        let height = size.height * canvasSize.height
        let x = position.x * canvasSize.width - width / 2
        let y = position.y * canvasSize.height - height / 2
        return CGRect(x: x, y: y, width: width, height: height)
    }
}
