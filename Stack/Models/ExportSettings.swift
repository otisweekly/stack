import Foundation

/// Export resolution options
enum ExportResolution: String, CaseIterable, Identifiable {
    case hd1080p = "1080p"
    case uhd4K = "4K"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .hd1080p: return "1080p (HD)"
        case .uhd4K: return "4K (Ultra HD)"
        }
    }

    var multiplier: CGFloat {
        switch self {
        case .hd1080p: return 1.0
        case .uhd4K: return 2.0
        }
    }
}

/// Export quality options
enum ExportQuality: String, CaseIterable, Identifiable {
    case standard = "standard"
    case high = "high"
    case maximum = "maximum"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .standard: return "Standard"
        case .high: return "High"
        case .maximum: return "Maximum"
        }
    }

    /// Approximate bitrate multiplier
    var bitrateMultiplier: Double {
        switch self {
        case .standard: return 1.0
        case .high: return 1.5
        case .maximum: return 2.0
        }
    }
}

/// Configuration for video export
struct ExportSettings: Equatable {
    var resolution: ExportResolution
    var quality: ExportQuality
    var audioEnabled: Bool

    init(
        resolution: ExportResolution = .hd1080p,
        quality: ExportQuality = .high,
        audioEnabled: Bool = true
    ) {
        self.resolution = resolution
        self.quality = quality
        self.audioEnabled = audioEnabled
    }

    /// Estimate file size in MB based on duration
    func estimatedFileSizeMB(duration: TimeInterval, canvasSize: CanvasSize) -> Double {
        // Base bitrate: ~8 Mbps for 1080p standard quality
        let baseBitrateMbps: Double = 8.0
        let resolutionMultiplier = resolution == .uhd4K ? 4.0 : 1.0
        let qualityMultiplier = quality.bitrateMultiplier

        let bitrateMbps = baseBitrateMbps * resolutionMultiplier * qualityMultiplier
        let fileSizeMB = (bitrateMbps * duration) / 8.0

        return fileSizeMB
    }
}
