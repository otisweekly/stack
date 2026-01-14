import AVFoundation
import Photos
import Combine

enum ExportError: LocalizedError {
    case compositionFailed
    case exportFailed(String)
    case saveFailed(String)
    case cancelled

    var errorDescription: String? {
        switch self {
        case .compositionFailed:
            return "Failed to create video composition"
        case .exportFailed(let reason):
            return "Export failed: \(reason)"
        case .saveFailed(let reason):
            return "Failed to save video: \(reason)"
        case .cancelled:
            return "Export was cancelled"
        }
    }
}

final class ExportService {
    static let shared = ExportService()

    private var exportSession: AVAssetExportSession?
    private var progressTimer: Timer?

    private init() {}

    func export(
        composition: Composition,
        mediaItems: [MediaItem],
        settings: ExportSettings,
        progress: @escaping (Double) -> Void
    ) async throws -> URL {

        // 1. Build AVMutableComposition with all video tracks
        let avComposition = AVMutableComposition()
        var trackMapping: [UUID: CMPersistentTrackID] = [:]
        var layerTransforms: [LayerTransformData] = []

        // Calculate max duration
        let maxDuration = min(
            composition.calculateDuration(with: mediaItems),
            Composition.maxDuration
        )
        let maxDurationCMTime = CMTime(seconds: maxDuration, preferredTimescale: 600)

        var trackIndex: CMPersistentTrackID = 1

        // Add each media item as a separate track
        for layer in composition.layers {
            guard let item = mediaItems.first(where: { $0.id == layer.mediaID }) else { continue }

            if item.isVideo {
                // Video layer
                let asset = AVAsset(url: item.url)
                guard let sourceTrack = try await asset.loadTracks(withMediaType: .video).first else {
                    continue
                }

                let compositionTrack = avComposition.addMutableTrack(
                    withMediaType: .video,
                    preferredTrackID: trackIndex
                )

                let sourceDuration = try await asset.load(.duration)
                let timeRange = CMTimeRange(start: .zero, duration: min(sourceDuration, maxDurationCMTime))

                try compositionTrack?.insertTimeRange(timeRange, of: sourceTrack, at: .zero)

                // Add audio track if available
                if let audioTrack = try await asset.loadTracks(withMediaType: .audio).first {
                    let audioCompositionTrack = avComposition.addMutableTrack(
                        withMediaType: .audio,
                        preferredTrackID: trackIndex + 100
                    )
                    try audioCompositionTrack?.insertTimeRange(timeRange, of: audioTrack, at: .zero)

                    // Set audio volume
                    let audioMix = AVMutableAudioMix()
                    let params = AVMutableAudioMixInputParameters(track: audioCompositionTrack)
                    params.setVolume(layer.audioVolume, at: .zero)
                    audioMix.inputParameters = [params]
                }

                if let trackID = compositionTrack?.trackID {
                    trackMapping[layer.id] = trackID
                    layerTransforms.append(LayerTransformData(
                        trackID: trackID,
                        position: layer.position,
                        size: layer.size,
                        zIndex: layer.zIndex,
                        mediaType: .video
                    ))
                }

                trackIndex += 1
            } else {
                // Image layer - no video track needed, just add transform data
                layerTransforms.append(LayerTransformData(
                    trackID: nil,
                    position: layer.position,
                    size: layer.size,
                    zIndex: layer.zIndex,
                    mediaType: .image,
                    imageURL: item.url
                ))
            }
        }

        // 2. Create video composition with custom compositor
        let outputSize = composition.canvasSize.pixelSize(for: settings.resolution)

        let videoComposition = AVMutableVideoComposition()
        videoComposition.customVideoCompositorClass = StackCompositor.self
        videoComposition.frameDuration = CMTime(value: 1, timescale: 30)
        videoComposition.renderSize = outputSize

        // 3. Create instruction for the entire duration
        let instruction = StackInstruction(
            timeRange: CMTimeRange(start: .zero, duration: maxDurationCMTime),
            layerTransforms: layerTransforms
        )

        videoComposition.instructions = [instruction]

        // 4. Setup export session
        let outputURL = FileManager.default.temporaryDirectory
            .appendingPathComponent("Stack_\(Date().timeIntervalSince1970).mov")

        // Remove existing file if present
        try? FileManager.default.removeItem(at: outputURL)

        let presetName = settings.resolution == .uhd4k
            ? AVAssetExportPreset3840x2160
            : AVAssetExportPresetHighestQuality

        guard let session = AVAssetExportSession(
            asset: avComposition,
            presetName: presetName
        ) else {
            throw ExportError.compositionFailed
        }

        session.outputURL = outputURL
        session.outputFileType = .mov
        session.videoComposition = videoComposition

        exportSession = session

        // 5. Export with progress tracking
        let progressTask = Task { @MainActor in
            while !Task.isCancelled {
                progress(Double(session.progress))
                try await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds
            }
        }

        await session.export()
        progressTask.cancel()

        exportSession = nil

        guard session.status == .completed else {
            if session.status == .cancelled {
                throw ExportError.cancelled
            }
            throw ExportError.exportFailed(session.error?.localizedDescription ?? "Unknown error")
        }

        // 6. Save to Photos library
        try await saveToPhotosLibrary(url: outputURL)

        return outputURL
    }

    func cancel() {
        exportSession?.cancelExport()
    }

    private func saveToPhotosLibrary(url: URL) async throws {
        try await PHPhotoLibrary.shared().performChanges {
            PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: url)
        }
    }
}
