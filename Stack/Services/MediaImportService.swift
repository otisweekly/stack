import Photos
import PhotosUI
import SwiftUI
import AVFoundation

enum MediaImportError: LocalizedError {
    case authorizationDenied
    case loadFailed(String)
    case noVideoTrack
    case invalidMedia

    var errorDescription: String? {
        switch self {
        case .authorizationDenied:
            return "Photo library access denied"
        case .loadFailed(let reason):
            return "Failed to load media: \(reason)"
        case .noVideoTrack:
            return "Video has no playable track"
        case .invalidMedia:
            return "Invalid media format"
        }
    }
}

final class MediaImportService {
    static let shared = MediaImportService()

    private init() {}

    func requestAuthorization() async -> Bool {
        let status = await PHPhotoLibrary.requestAuthorization(for: .readWrite)
        return status == .authorized || status == .limited
    }

    func loadMediaItem(from result: PHPickerResult) async throws -> MediaItem {
        let itemProvider = result.itemProvider

        // Check if it's a video
        if itemProvider.hasItemConformingToTypeIdentifier(UTType.movie.identifier) {
            return try await loadVideo(from: itemProvider)
        }
        // Check if it's an image
        else if itemProvider.hasItemConformingToTypeIdentifier(UTType.image.identifier) {
            return try await loadImage(from: itemProvider)
        }

        throw MediaImportError.invalidMedia
    }

    private func loadVideo(from itemProvider: NSItemProvider) async throws -> MediaItem {
        return try await withCheckedThrowingContinuation { continuation in
            itemProvider.loadFileRepresentation(forTypeIdentifier: UTType.movie.identifier) { url, error in
                if let error = error {
                    continuation.resume(throwing: MediaImportError.loadFailed(error.localizedDescription))
                    return
                }

                guard let url = url else {
                    continuation.resume(throwing: MediaImportError.loadFailed("No URL provided"))
                    return
                }

                // Copy to temp directory since the provided URL is temporary
                let tempDir = FileManager.default.temporaryDirectory
                let destURL = tempDir.appendingPathComponent(UUID().uuidString + ".mov")

                do {
                    try FileManager.default.copyItem(at: url, to: destURL)

                    Task {
                        do {
                            let item = try await MediaItem.fromURL(destURL, type: .video)
                            continuation.resume(returning: item)
                        } catch {
                            continuation.resume(throwing: error)
                        }
                    }
                } catch {
                    continuation.resume(throwing: MediaImportError.loadFailed(error.localizedDescription))
                }
            }
        }
    }

    private func loadImage(from itemProvider: NSItemProvider) async throws -> MediaItem {
        return try await withCheckedThrowingContinuation { continuation in
            itemProvider.loadFileRepresentation(forTypeIdentifier: UTType.image.identifier) { url, error in
                if let error = error {
                    continuation.resume(throwing: MediaImportError.loadFailed(error.localizedDescription))
                    return
                }

                guard let url = url else {
                    continuation.resume(throwing: MediaImportError.loadFailed("No URL provided"))
                    return
                }

                // Copy to temp directory since the provided URL is temporary
                let tempDir = FileManager.default.temporaryDirectory
                let ext = url.pathExtension.isEmpty ? "jpg" : url.pathExtension
                let destURL = tempDir.appendingPathComponent(UUID().uuidString + ".\(ext)")

                do {
                    try FileManager.default.copyItem(at: url, to: destURL)

                    Task {
                        do {
                            let item = try await MediaItem.fromURL(destURL, type: .image)
                            continuation.resume(returning: item)
                        } catch {
                            continuation.resume(throwing: error)
                        }
                    }
                } catch {
                    continuation.resume(throwing: MediaImportError.loadFailed(error.localizedDescription))
                }
            }
        }
    }
}
