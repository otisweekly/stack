import Foundation

enum ExportResolution: String, Codable, CaseIterable, Identifiable {
    case hd1080 = "1080p"
    case uhd4k = "4K"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .hd1080: return "1080p"
        case .uhd4k: return "4K"
        }
    }

    var bitrate: Int {
        switch self {
        case .hd1080: return 10_000_000
        case .uhd4k: return 35_000_000
        }
    }
}

struct ExportSettings: Codable {
    var resolution: ExportResolution = .hd1080

    func estimatedFileSize(duration: TimeInterval) -> Int64 {
        Int64(Double(resolution.bitrate) * duration / 8)
    }

    func formattedEstimatedSize(duration: TimeInterval) -> String {
        let bytes = estimatedFileSize(duration: duration)
        let formatter = ByteCountFormatter()
        formatter.countStyle = .file
        return formatter.string(fromByteCount: bytes)
    }
}
