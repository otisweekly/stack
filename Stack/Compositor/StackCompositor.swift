import AVFoundation
import CoreImage

// MARK: - Layer Transform Data

struct LayerTransformData: Sendable {
    let trackID: CMPersistentTrackID?
    let position: CGPoint       // Normalized 0-1
    let size: CGSize            // Normalized 0-1
    let zIndex: Int
    let opacity: Float
    let mediaType: MediaType
    let imageURL: URL?          // For image layers

    init(trackID: CMPersistentTrackID? = nil, position: CGPoint, size: CGSize,
         zIndex: Int, opacity: Float = 1.0, mediaType: MediaType = .video, imageURL: URL? = nil) {
        self.trackID = trackID
        self.position = position
        self.size = size
        self.zIndex = zIndex
        self.opacity = opacity
        self.mediaType = mediaType
        self.imageURL = imageURL
    }
}

// MARK: - Stack Compositor

final class StackCompositor: NSObject, AVVideoCompositing {

    // MARK: - AVVideoCompositing Properties (nonisolated as required by protocol)

    nonisolated var sourcePixelBufferAttributes: [String: any Sendable]? {
        [
            kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA,
            kCVPixelBufferMetalCompatibilityKey as String: true
        ]
    }

    nonisolated var requiredPixelBufferAttributesForRenderContext: [String: any Sendable] {
        [
            kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA,
            kCVPixelBufferMetalCompatibilityKey as String: true
        ]
    }

    nonisolated var supportsWideColorSourceFrames: Bool { false }
    nonisolated var supportsHDRSourceFrames: Bool { false }

    // MARK: - Properties

    private let ciContext: CIContext
    private let colorSpace: CGColorSpace

    override init() {
        self.ciContext = CIContext(options: [.useSoftwareRenderer: false])
        self.colorSpace = CGColorSpaceCreateDeviceRGB()
        super.init()
    }

    // MARK: - AVVideoCompositing Methods

    nonisolated func renderContextChanged(_ newRenderContext: AVVideoCompositionRenderContext) {
        // Context changes don't require cache clearing in this simple implementation
    }

    nonisolated func startRequest(_ request: AVAsynchronousVideoCompositionRequest) {
        guard let instruction = request.videoCompositionInstruction as? StackInstruction else {
            request.finish(with: CompositorError.invalidInstruction)
            return
        }

        // Create output pixel buffer
        guard let outputBuffer = request.renderContext.newPixelBuffer() else {
            request.finish(with: CompositorError.pixelBufferCreationFailed)
            return
        }

        // Get output dimensions
        let outputSize = request.renderContext.size

        // Start with background color (dark gray)
        var outputImage = CIImage(color: CIColor(red: 0.1, green: 0.1, blue: 0.1))
            .cropped(to: CGRect(origin: .zero, size: outputSize))

        // Composite each layer (sorted by z-index, back to front)
        let sortedStack = instruction.layerTransforms.sorted { $0.zIndex < $1.zIndex }

        for layerTransform in sortedStack {
            var sourceImage: CIImage?

            if layerTransform.mediaType == .video, let trackID = layerTransform.trackID {
                // Video layer
                if let sourceBuffer = request.sourceFrame(byTrackID: trackID) {
                    sourceImage = CIImage(cvPixelBuffer: sourceBuffer)
                }
            } else if layerTransform.mediaType == .image, let imageURL = layerTransform.imageURL {
                // Image layer - load directly without caching for thread safety
                sourceImage = CIImage(contentsOf: imageURL)
            }

            guard let source = sourceImage else { continue }

            let transformedImage = Self.transformLayer(
                source,
                transform: layerTransform,
                outputSize: outputSize
            )

            outputImage = transformedImage.composited(over: outputImage)
        }

        // Render to output buffer
        ciContext.render(
            outputImage,
            to: outputBuffer,
            bounds: CGRect(origin: .zero, size: outputSize),
            colorSpace: colorSpace
        )

        request.finish(withComposedVideoFrame: outputBuffer)
    }

    nonisolated func cancelAllPendingVideoCompositionRequests() {
        // Cancel any pending work
    }

    // MARK: - Private Methods (static for thread safety)

    private static func transformLayer(
        _ image: CIImage,
        transform: LayerTransformData,
        outputSize: CGSize
    ) -> CIImage {
        let sourceSize = image.extent.size

        // Calculate target frame in pixel coordinates
        let targetFrame = CGRect(
            x: (transform.position.x - transform.size.width / 2) * outputSize.width,
            y: (1 - transform.position.y - transform.size.height / 2) * outputSize.height,
            width: transform.size.width * outputSize.width,
            height: transform.size.height * outputSize.height
        )

        // Calculate scale to fill target frame
        let scaleX = targetFrame.width / sourceSize.width
        let scaleY = targetFrame.height / sourceSize.height
        let scale = max(scaleX, scaleY)  // Aspect fill

        // Build transform
        var t = CGAffineTransform.identity

        // Scale
        t = t.scaledBy(x: scale, y: scale)

        // Center within target frame
        let scaledSize = CGSize(width: sourceSize.width * scale, height: sourceSize.height * scale)
        let offsetX = targetFrame.origin.x + (targetFrame.width - scaledSize.width) / 2
        let offsetY = targetFrame.origin.y + (targetFrame.height - scaledSize.height) / 2
        t = t.translatedBy(x: offsetX / scale, y: offsetY / scale)

        var result = image.transformed(by: t)

        // Crop to target frame
        result = result.cropped(to: targetFrame)

        // Apply opacity if not fully opaque
        if transform.opacity < 1.0 {
            result = result.applyingFilter("CIColorMatrix", parameters: [
                "inputAVector": CIVector(x: 0, y: 0, z: 0, w: CGFloat(transform.opacity))
            ])
        }

        return result
    }
}

// MARK: - Compositor Error

enum CompositorError: LocalizedError {
    case metalNotAvailable
    case commandQueueFailed
    case textureCacheFailed
    case shaderLibraryFailed
    case invalidInstruction
    case pixelBufferCreationFailed
    case renderFailed

    var errorDescription: String? {
        switch self {
        case .metalNotAvailable:
            return "Metal is not available on this device"
        case .commandQueueFailed:
            return "Failed to create Metal command queue"
        case .textureCacheFailed:
            return "Failed to create texture cache"
        case .shaderLibraryFailed:
            return "Failed to load shader library"
        case .invalidInstruction:
            return "Invalid composition instruction"
        case .pixelBufferCreationFailed:
            return "Failed to create output pixel buffer"
        case .renderFailed:
            return "Render operation failed"
        }
    }
}
