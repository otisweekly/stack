import AVFoundation
import UIKit

final class ThumbnailService {
    static let shared = ThumbnailService()

    private let thumbnailSize = CGSize(width: 300, height: 533) // 9:16 aspect

    private init() {}

    func generateThumbnail(for item: MediaItem) async throws -> URL {
        switch item.type {
        case .video:
            return try await generateVideoThumbnail(for: item)
        case .image:
            return try await generateImageThumbnail(for: item)
        }
    }

    private func generateVideoThumbnail(for item: MediaItem) async throws -> URL {
        let asset = AVAsset(url: item.url)
        let generator = AVAssetImageGenerator(asset: asset)
        generator.appliesPreferredTrackTransform = true
        generator.maximumSize = thumbnailSize

        let time = CMTime(seconds: 0.5, preferredTimescale: 600)
        let cgImage = try await generator.image(at: time).image

        let image = UIImage(cgImage: cgImage)
        guard let data = image.jpegData(compressionQuality: 0.8) else {
            throw ThumbnailError.encodingFailed
        }

        let url = thumbnailURL(for: item.id)
        try data.write(to: url)

        return url
    }

    private func generateImageThumbnail(for item: MediaItem) async throws -> URL {
        guard let image = UIImage(contentsOfFile: item.url.path) else {
            throw ThumbnailError.loadFailed
        }

        // Resize image to thumbnail size
        let scaledImage = resizeImage(image, to: thumbnailSize)

        guard let data = scaledImage.jpegData(compressionQuality: 0.8) else {
            throw ThumbnailError.encodingFailed
        }

        let url = thumbnailURL(for: item.id)
        try data.write(to: url)

        return url
    }

    private func resizeImage(_ image: UIImage, to size: CGSize) -> UIImage {
        let aspectRatio = image.size.width / image.size.height
        var targetSize = size

        if aspectRatio > size.width / size.height {
            targetSize.height = size.width / aspectRatio
        } else {
            targetSize.width = size.height * aspectRatio
        }

        let renderer = UIGraphicsImageRenderer(size: targetSize)
        return renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: targetSize))
        }
    }

    private func thumbnailURL(for id: UUID) -> URL {
        FileManager.default.temporaryDirectory
            .appendingPathComponent("thumb_\(id.uuidString).jpg")
    }

    func generateThumbnails(for items: [MediaItem]) async throws -> [UUID: URL] {
        var thumbnails: [UUID: URL] = [:]

        for item in items {
            do {
                let url = try await generateThumbnail(for: item)
                thumbnails[item.id] = url
            } catch {
                print("Failed to generate thumbnail for \(item.id): \(error)")
            }
        }

        return thumbnails
    }
}

enum ThumbnailError: LocalizedError {
    case loadFailed
    case encodingFailed

    var errorDescription: String? {
        switch self {
        case .loadFailed:
            return "Failed to load media for thumbnail"
        case .encodingFailed:
            return "Failed to encode thumbnail"
        }
    }
}
