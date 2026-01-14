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

    // Codable - handle CMTime manually
    enum CodingKeys: String, CodingKey {
        case id, mediaID, mediaType, position, size, zIndex, isVisible
        case imageDuration, videoStartTimeSeconds, playbackRate, audioVolume
    }

    init(id: UUID = UUID(), mediaID: UUID, mediaType: MediaType, position: CGPoint,
         size: CGSize, zIndex: Int, isVisible: Bool = true, imageDuration: TimeInterval = 1.0,
         videoStartTime: CMTime = .zero, playbackRate: Float = 1.0, audioVolume: Float = 1.0) {
        self.id = id
        self.mediaID = mediaID
        self.mediaType = mediaType
        self.position = position
        self.size = size
        self.zIndex = zIndex
        self.isVisible = isVisible
        self.imageDuration = imageDuration
        self.videoStartTime = videoStartTime
        self.playbackRate = playbackRate
        self.audioVolume = audioVolume
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        mediaID = try container.decode(UUID.self, forKey: .mediaID)
        mediaType = try container.decode(MediaType.self, forKey: .mediaType)
        position = try container.decode(CGPoint.self, forKey: .position)
        size = try container.decode(CGSize.self, forKey: .size)
        zIndex = try container.decode(Int.self, forKey: .zIndex)
        isVisible = try container.decode(Bool.self, forKey: .isVisible)
        imageDuration = try container.decode(TimeInterval.self, forKey: .imageDuration)
        let seconds = try container.decode(Double.self, forKey: .videoStartTimeSeconds)
        videoStartTime = CMTime(seconds: seconds, preferredTimescale: 600)
        playbackRate = try container.decode(Float.self, forKey: .playbackRate)
        audioVolume = try container.decode(Float.self, forKey: .audioVolume)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(mediaID, forKey: .mediaID)
        try container.encode(mediaType, forKey: .mediaType)
        try container.encode(position, forKey: .position)
        try container.encode(size, forKey: .size)
        try container.encode(zIndex, forKey: .zIndex)
        try container.encode(isVisible, forKey: .isVisible)
        try container.encode(imageDuration, forKey: .imageDuration)
        try container.encode(videoStartTime.seconds, forKey: .videoStartTimeSeconds)
        try container.encode(playbackRate, forKey: .playbackRate)
        try container.encode(audioVolume, forKey: .audioVolume)
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
            mediaID: media.id,
            mediaType: media.type,
            position: CGPoint(x: 0.5 + offsetX, y: 0.5 + offsetY),
            size: CGSize(width: width, height: height),
            zIndex: zIndex,
            imageDuration: media.imageDuration
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
