import AVFoundation

final class StackInstruction: NSObject, AVVideoCompositionInstructionProtocol, @unchecked Sendable {

    // MARK: - AVVideoCompositionInstructionProtocol

    let timeRange: CMTimeRange
    let enablePostProcessing: Bool = false
    let containsTweening: Bool = false
    let requiredSourceTrackIDs: [NSValue]?
    let passthroughTrackID: CMPersistentTrackID = kCMPersistentTrackID_Invalid

    // MARK: - Custom Properties

    let layerTransforms: [LayerTransformData]

    init(
        timeRange: CMTimeRange,
        layerTransforms: [LayerTransformData]
    ) {
        self.timeRange = timeRange
        self.layerTransforms = layerTransforms

        // Only require source frames for video layers with valid track IDs
        self.requiredSourceTrackIDs = layerTransforms
            .filter { $0.mediaType == .video }
            .compactMap { $0.trackID }
            .map { NSNumber(value: $0) }

        super.init()
    }
}
