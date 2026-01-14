# Compositor Specifications

## Overview

The compositor is responsible for combining multiple video frames into a single output frame. This document specifies the implementation details for both real-time preview and final export rendering.

---

## Architecture

### Components

```
┌─────────────────────────────────────────────────────────────────┐
│                     CompositorService                            │
│  Coordinates preview and export rendering                        │
└─────────────────────────────────────────────────────────────────┘
                              │
              ┌───────────────┼───────────────┐
              ▼               │               ▼
┌─────────────────────┐       │     ┌─────────────────────┐
│   MetalRenderer     │       │     │  StackCompositor   │
│   (Preview)         │       │     │  (Export)           │
└─────────────────────┘       │     └─────────────────────┘
              │               │               │
              ▼               │               ▼
┌─────────────────────┐       │     ┌─────────────────────┐
│   MTKView           │       │     │  AVAssetExportSession│
│   (Display)         │       │     │  (File Output)      │
└─────────────────────┘       │     └─────────────────────┘
                              │
                     ┌────────┴────────┐
                     │  Shared Shaders │
                     │  (Shaders.metal)│
                     └─────────────────┘
```

---

## Preview Rendering (Metal)

### MetalRenderer

Real-time preview uses Metal for GPU-accelerated compositing.

```swift
// Compositor/MetalRenderer.swift
import Metal
import MetalKit
import AVFoundation
import CoreVideo

final class MetalRenderer {
    private let device: MTLDevice
    private let commandQueue: MTLCommandQueue
    private let pipelineState: MTLRenderPipelineState
    private let textureCache: CVMetalTextureCache
    
    struct LayerRenderData {
        let texture: MTLTexture
        let transform: LayerTransform
    }
    
    struct LayerTransform {
        var position: SIMD2<Float>      // Normalized 0-1
        var size: SIMD2<Float>          // Normalized 0-1
        var zIndex: Float
        var opacity: Float = 1.0
    }
    
    init() throws {
        guard let device = MTLCreateSystemDefaultDevice() else {
            throw CompositorError.metalNotAvailable
        }
        self.device = device
        
        guard let queue = device.makeCommandQueue() else {
            throw CompositorError.commandQueueFailed
        }
        self.commandQueue = queue
        
        // Create texture cache for CVPixelBuffer conversion
        var cache: CVMetalTextureCache?
        CVMetalTextureCacheCreate(nil, nil, device, nil, &cache)
        guard let textureCache = cache else {
            throw CompositorError.textureCacheFailed
        }
        self.textureCache = textureCache
        
        // Load shaders and create pipeline
        self.pipelineState = try Self.createPipeline(device: device)
    }
    
    private static func createPipeline(device: MTLDevice) throws -> MTLRenderPipelineState {
        guard let library = device.makeDefaultLibrary() else {
            throw CompositorError.shaderLibraryFailed
        }
        
        let descriptor = MTLRenderPipelineDescriptor()
        descriptor.vertexFunction = library.makeFunction(name: "layerVertexShader")
        descriptor.fragmentFunction = library.makeFunction(name: "layerFragmentShader")
        descriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
        
        // Enable alpha blending
        descriptor.colorAttachments[0].isBlendingEnabled = true
        descriptor.colorAttachments[0].sourceRGBBlendFactor = .sourceAlpha
        descriptor.colorAttachments[0].destinationRGBBlendFactor = .oneMinusSourceAlpha
        descriptor.colorAttachments[0].sourceAlphaBlendFactor = .one
        descriptor.colorAttachments[0].destinationAlphaBlendFactor = .oneMinusSourceAlpha
        
        return try device.makeRenderPipelineState(descriptor: descriptor)
    }
    
    /// Converts a CVPixelBuffer to MTLTexture
    func texture(from pixelBuffer: CVPixelBuffer) -> MTLTexture? {
        let width = CVPixelBufferGetWidth(pixelBuffer)
        let height = CVPixelBufferGetHeight(pixelBuffer)
        
        var cvTexture: CVMetalTexture?
        let status = CVMetalTextureCacheCreateTextureFromImage(
            nil,
            textureCache,
            pixelBuffer,
            nil,
            .bgra8Unorm,
            width,
            height,
            0,
            &cvTexture
        )
        
        guard status == kCVReturnSuccess, let cvTexture = cvTexture else {
            return nil
        }
        
        return CVMetalTextureGetTexture(cvTexture)
    }
    
    /// Composites all layers into the output texture
    func render(
        layers: [LayerRenderData],
        to outputTexture: MTLTexture,
        canvasSize: CGSize,
        backgroundColor: SIMD4<Float> = SIMD4(0.1, 0.1, 0.1, 1.0)
    ) {
        guard let commandBuffer = commandQueue.makeCommandBuffer() else { return }
        
        let renderPassDescriptor = MTLRenderPassDescriptor()
        renderPassDescriptor.colorAttachments[0].texture = outputTexture
        renderPassDescriptor.colorAttachments[0].loadAction = .clear
        renderPassDescriptor.colorAttachments[0].clearColor = MTLClearColor(
            red: Double(backgroundColor.x),
            green: Double(backgroundColor.y),
            blue: Double(backgroundColor.z),
            alpha: Double(backgroundColor.w)
        )
        renderPassDescriptor.colorAttachments[0].storeAction = .store
        
        guard let encoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor) else {
            return
        }
        
        encoder.setRenderPipelineState(pipelineState)
        
        // Sort layers by z-index and render back to front
        let sortedStack = layers.sorted { $0.transform.zIndex < $1.transform.zIndex }
        
        for layer in sortedStack {
            renderLayer(layer, encoder: encoder)
        }
        
        encoder.endEncoding()
        commandBuffer.commit()
    }
    
    private func renderLayer(_ layer: LayerRenderData, encoder: MTLRenderCommandEncoder) {
        // Calculate vertex positions from normalized coordinates
        let vertices = calculateVertices(for: layer.transform)
        
        encoder.setVertexBytes(vertices, length: vertices.count * MemoryLayout<Vertex>.stride, index: 0)
        encoder.setFragmentTexture(layer.texture, index: 0)
        
        var opacity = layer.transform.opacity
        encoder.setFragmentBytes(&opacity, length: MemoryLayout<Float>.size, index: 0)
        
        encoder.drawPrimitives(type: .triangleStrip, vertexStart: 0, vertexCount: 4)
    }
    
    private func calculateVertices(for transform: LayerTransform) -> [Vertex] {
        // Convert from normalized (0-1) to clip space (-1 to 1)
        let x = transform.position.x * 2 - 1
        let y = -(transform.position.y * 2 - 1)  // Flip Y for Metal coordinates
        let w = transform.size.x
        let h = transform.size.y
        
        let left = x - w
        let right = x + w
        let top = y + h
        let bottom = y - h
        
        return [
            Vertex(position: SIMD4(left, top, 0, 1), texCoord: SIMD2(0, 0)),
            Vertex(position: SIMD4(right, top, 0, 1), texCoord: SIMD2(1, 0)),
            Vertex(position: SIMD4(left, bottom, 0, 1), texCoord: SIMD2(0, 1)),
            Vertex(position: SIMD4(right, bottom, 0, 1), texCoord: SIMD2(1, 1))
        ]
    }
}

struct Vertex {
    var position: SIMD4<Float>
    var texCoord: SIMD2<Float>
}
```

### Metal Shaders

```metal
// Compositor/Shaders.metal
#include <metal_stdlib>
using namespace metal;

struct VertexIn {
    float4 position [[attribute(0)]];
    float2 texCoord [[attribute(1)]];
};

struct VertexOut {
    float4 position [[position]];
    float2 texCoord;
};

vertex VertexOut layerVertexShader(
    uint vertexID [[vertex_id]],
    constant Vertex* vertices [[buffer(0)]]
) {
    VertexOut out;
    out.position = vertices[vertexID].position;
    out.texCoord = vertices[vertexID].texCoord;
    return out;
}

fragment float4 layerFragmentShader(
    VertexOut in [[stage_in]],
    texture2d<float> texture [[texture(0)]],
    constant float& opacity [[buffer(0)]]
) {
    constexpr sampler textureSampler(
        mag_filter::linear,
        min_filter::linear,
        address::clamp_to_edge
    );
    
    float4 color = texture.sample(textureSampler, in.texCoord);
    color.a *= opacity;
    return color;
}

// Future: Blend mode shaders
fragment float4 multiplyBlendShader(
    VertexOut in [[stage_in]],
    texture2d<float> srcTexture [[texture(0)]],
    texture2d<float> dstTexture [[texture(1)]],
    constant float& opacity [[buffer(0)]]
) {
    constexpr sampler s(mag_filter::linear, min_filter::linear);
    float4 src = srcTexture.sample(s, in.texCoord);
    float4 dst = dstTexture.sample(s, in.texCoord);
    
    float4 result = src * dst;
    result.a = src.a * opacity;
    return result;
}
```

---

## Export Rendering (AVFoundation)

### StackCompositor

For export, we use AVFoundation's custom compositor protocol.

```swift
// Compositor/StackCompositor.swift
import AVFoundation
import CoreImage

final class StackCompositor: NSObject, AVVideoCompositing {
    
    // MARK: - AVVideoCompositing Properties
    
    var sourcePixelBufferAttributes: [String: Any]? {
        [
            kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA,
            kCVPixelBufferMetalCompatibilityKey as String: true
        ]
    }
    
    var requiredPixelBufferAttributesForRenderContext: [String: Any] {
        [
            kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA,
            kCVPixelBufferMetalCompatibilityKey as String: true
        ]
    }
    
    // MARK: - Properties
    
    private let ciContext: CIContext
    private let colorSpace: CGColorSpace
    
    override init() {
        self.ciContext = CIContext(options: [.useSoftwareRenderer: false])
        self.colorSpace = CGColorSpaceCreateDeviceRGB()
        super.init()
    }
    
    // MARK: - AVVideoCompositing Methods
    
    func renderContextChanged(_ newRenderContext: AVVideoCompositionRenderContext) {
        // Handle render context changes if needed
    }
    
    func startRequest(_ request: AVAsynchronousVideoCompositionRequest) {
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
        
        // Start with background color
        var outputImage = CIImage(color: CIColor(red: 0.1, green: 0.1, blue: 0.1))
            .cropped(to: CGRect(origin: .zero, size: outputSize))
        
        // Composite each layer (sorted by z-index, back to front)
        let sortedStack = instruction.layerTransforms.sorted { $0.zIndex < $1.zIndex }
        
        for layerTransform in sortedStack {
            guard let trackID = layerTransform.trackID,
                  let sourceBuffer = request.sourceFrame(byTrackID: trackID) else {
                continue
            }
            
            let sourceImage = CIImage(cvPixelBuffer: sourceBuffer)
            let transformedImage = transformLayer(
                sourceImage,
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
    
    func cancelAllPendingVideoCompositionRequests() {
        // Cancel any pending work
    }
    
    // MARK: - Private Methods
    
    private func transformLayer(
        _ image: CIImage,
        transform: LayerTransformData,
        outputSize: CGSize
    ) -> CIImage {
        let sourceSize = image.extent.size
        
        // Calculate target frame in pixel coordinates
        let targetFrame = CGRect(
            x: (transform.position.x - transform.size.x / 2) * outputSize.width,
            y: (1 - transform.position.y - transform.size.y / 2) * outputSize.height, // Flip Y
            width: transform.size.x * outputSize.width,
            height: transform.size.y * outputSize.height
        )
        
        // Calculate scale to fit source into target
        let scaleX = targetFrame.width / sourceSize.width
        let scaleY = targetFrame.height / sourceSize.height
        let scale = min(scaleX, scaleY)  // Aspect fit
        
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
        
        // Apply opacity if not fully opaque
        if transform.opacity < 1.0 {
            result = result.applyingFilter("CIColorMatrix", parameters: [
                "inputAVector": CIVector(x: 0, y: 0, z: 0, w: CGFloat(transform.opacity))
            ])
        }
        
        return result
    }
}

// MARK: - Supporting Types

struct LayerTransformData {
    let trackID: CMPersistentTrackID?
    let position: CGPoint       // Normalized 0-1
    let size: CGSize            // Normalized 0-1
    let zIndex: Int
    let opacity: Float
}
```

### StackInstruction

```swift
// Compositor/StackInstruction.swift
import AVFoundation

final class StackInstruction: NSObject, AVVideoCompositionInstructionProtocol {
    
    // MARK: - AVVideoCompositionInstructionProtocol
    
    var timeRange: CMTimeRange
    var enablePostProcessing: Bool = false
    var containsTweening: Bool = false
    var requiredSourceTrackIDs: [NSValue]?
    var passthroughTrackID: CMPersistentTrackID = kCMPersistentTrackID_Invalid
    
    // MARK: - Custom Properties
    
    let layerTransforms: [LayerTransformData]
    
    init(
        timeRange: CMTimeRange,
        layerTransforms: [LayerTransformData]
    ) {
        self.timeRange = timeRange
        self.layerTransforms = layerTransforms
        self.requiredSourceTrackIDs = layerTransforms
            .compactMap { $0.trackID }
            .map { NSValue(bytes: [$0], objCType: "i") }
        
        super.init()
    }
}
```

---

## ExportService

Coordinates the export process using AVFoundation.

```swift
// Services/ExportService.swift
import AVFoundation
import Photos

enum ExportError: LocalizedError {
    case compositionFailed
    case exportFailed(String)
    case saveFailed(String)
    
    var errorDescription: String? {
        switch self {
        case .compositionFailed:
            return "Failed to create video composition"
        case .exportFailed(let reason):
            return "Export failed: \(reason)"
        case .saveFailed(let reason):
            return "Failed to save video: \(reason)"
        }
    }
}

final class ExportService {
    
    func export(
        composition: Composition,
        clips: [VideoClip],
        settings: ExportSettings,
        progress: @escaping (Double) -> Void
    ) async throws -> URL {
        
        // 1. Build AVMutableComposition with all video tracks
        let avComposition = AVMutableComposition()
        var trackMapping: [UUID: CMPersistentTrackID] = [:]
        
        // Find the longest video duration
        let maxDuration = clips.map { CMTime(seconds: $0.duration, preferredTimescale: 600) }
            .max() ?? CMTime(seconds: 10, preferredTimescale: 600)
        
        // Add each video as a separate track
        for (index, layer) in composition.layers.enumerated() {
            guard let clip = clips.first(where: { $0.id == layer.clipID }) else { continue }
            
            let asset = AVAsset(url: clip.url)
            guard let sourceTrack = try await asset.loadTracks(withMediaType: .video).first else {
                continue
            }
            
            let compositionTrack = avComposition.addMutableTrack(
                withMediaType: .video,
                preferredTrackID: CMPersistentTrackID(index + 1)
            )
            
            let sourceDuration = try await asset.load(.duration)
            let insertTime = CMTime.zero
            let timeRange = CMTimeRange(start: .zero, duration: min(sourceDuration, maxDuration))
            
            try compositionTrack?.insertTimeRange(timeRange, of: sourceTrack, at: insertTime)
            
            if let trackID = compositionTrack?.trackID {
                trackMapping[layer.id] = trackID
            }
        }
        
        // 2. Create video composition with custom compositor
        let outputSize = composition.canvasSize.pixelSize(for: settings.resolution)
        
        let videoComposition = AVMutableVideoComposition()
        videoComposition.customVideoCompositorClass = StackCompositor.self
        videoComposition.frameDuration = CMTime(value: 1, timescale: 30)
        videoComposition.renderSize = outputSize
        
        // 3. Create instruction for the entire duration
        let layerTransforms = composition.layers.map { layer -> LayerTransformData in
            LayerTransformData(
                trackID: trackMapping[layer.id],
                position: layer.position,
                size: layer.size,
                zIndex: layer.zIndex,
                opacity: 1.0  // Future: layer.opacity
            )
        }
        
        let instruction = StackInstruction(
            timeRange: CMTimeRange(start: .zero, duration: maxDuration),
            layerTransforms: layerTransforms
        )
        
        videoComposition.instructions = [instruction]
        
        // 4. Setup export session
        let outputURL = FileManager.default.temporaryDirectory
            .appendingPathComponent("Stack_\(Date().timeIntervalSince1970).mov")
        
        guard let exportSession = AVAssetExportSession(
            asset: avComposition,
            presetName: settings.resolution == .uhd4k
                ? AVAssetExportPreset3840x2160
                : AVAssetExportPresetHighestQuality
        ) else {
            throw ExportError.compositionFailed
        }
        
        exportSession.outputURL = outputURL
        exportSession.outputFileType = .mov
        exportSession.videoComposition = videoComposition
        
        // 5. Export with progress tracking
        let progressTimer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()
        let cancellable = progressTimer.sink { _ in
            progress(Double(exportSession.progress))
        }
        
        await exportSession.export()
        cancellable.cancel()
        
        guard exportSession.status == .completed else {
            throw ExportError.exportFailed(exportSession.error?.localizedDescription ?? "Unknown error")
        }
        
        // 6. Save to Photos library
        try await saveToPhotosLibrary(url: outputURL)
        
        return outputURL
    }
    
    private func saveToPhotosLibrary(url: URL) async throws {
        try await PHPhotoLibrary.shared().performChanges {
            PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: url)
        }
    }
}
```

---

## Performance Considerations

### Memory Management

1. **Texture Pooling**: Reuse MTLTextures for intermediate results
2. **CVPixelBuffer Pooling**: Use `CVPixelBufferPool` for export
3. **Lazy Loading**: Only load video frames when needed
4. **Cache Eviction**: Clear texture cache on memory warning

### Threading

1. **Preview Rendering**: Runs on dedicated Metal thread
2. **Export Rendering**: AVFoundation handles threading internally
3. **UI Updates**: Always dispatch to main thread

### Optimization Tips

1. Use `MTLHeap` for related textures to reduce allocation overhead
2. Batch draw calls where possible
3. Use triple buffering for smooth preview playback
4. Consider lower resolution for preview (render at display size, not export size)

---

## Error Handling

```swift
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
```
