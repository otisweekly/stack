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

    // Image-specific default duration
    var imageDuration: TimeInterval = 1.0

    /// Effective duration for playback
    var duration: TimeInterval {
        switch type {
        case .video:
            return videoDuration ?? 0
        case .image:
            return imageDuration
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

// MARK: - Factory Methods

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

    /// Creates a MediaItem from URL (for PHPicker results)
    static func fromURL(_ url: URL, type: MediaType) async throws -> MediaItem {
        if type == .video {
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
                assetIdentifier: url.absoluteString,
                url: url,
                type: .video,
                originalSize: size,
                creationDate: nil,
                videoDuration: duration.seconds
            )
        } else {
            // Image
            var size = CGSize(width: 1080, height: 1920)
            if let imageSource = CGImageSourceCreateWithURL(url as CFURL, nil),
               let properties = CGImageSourceCopyPropertiesAtIndex(imageSource, 0, nil) as? [String: Any] {
                let width = properties[kCGImagePropertyPixelWidth as String] as? CGFloat ?? 1080
                let height = properties[kCGImagePropertyPixelHeight as String] as? CGFloat ?? 1920
                size = CGSize(width: width, height: height)
            }

            return MediaItem(
                id: UUID(),
                assetIdentifier: url.absoluteString,
                url: url,
                type: .image,
                originalSize: size,
                creationDate: nil,
                videoDuration: nil
            )
        }
    }
}
