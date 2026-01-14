import Foundation
import CoreGraphics

enum CanvasSize: String, Codable, CaseIterable, Identifiable {
    case portrait9x16 = "9:16"
    case landscape16x9 = "16:9"
    case square1x1 = "1:1"
    case portrait4x5 = "4:5"

    var id: String { rawValue }

    var aspectRatio: CGFloat {
        switch self {
        case .portrait9x16: return 9.0 / 16.0
        case .landscape16x9: return 16.0 / 9.0
        case .square1x1: return 1.0
        case .portrait4x5: return 4.0 / 5.0
        }
    }

    var displayName: String {
        switch self {
        case .portrait9x16: return "9:16"
        case .landscape16x9: return "16:9"
        case .square1x1: return "1:1"
        case .portrait4x5: return "4:5"
        }
    }

    var subtitle: String {
        switch self {
        case .portrait9x16: return "Stories, Reels, TikTok"
        case .landscape16x9: return "YouTube, Landscape"
        case .square1x1: return "Square"
        case .portrait4x5: return "Instagram Portrait"
        }
    }

    func pixelSize(for resolution: ExportResolution) -> CGSize {
        switch resolution {
        case .hd1080:
            switch self {
            case .portrait9x16: return CGSize(width: 1080, height: 1920)
            case .landscape16x9: return CGSize(width: 1920, height: 1080)
            case .square1x1: return CGSize(width: 1080, height: 1080)
            case .portrait4x5: return CGSize(width: 1080, height: 1350)
            }
        case .uhd4k:
            switch self {
            case .portrait9x16: return CGSize(width: 2160, height: 3840)
            case .landscape16x9: return CGSize(width: 3840, height: 2160)
            case .square1x1: return CGSize(width: 2160, height: 2160)
            case .portrait4x5: return CGSize(width: 2160, height: 2700)
            }
        }
    }

    func fittedSize(in container: CGSize) -> CGSize {
        let containerRatio = container.width / container.height
        if aspectRatio > containerRatio {
            return CGSize(width: container.width, height: container.width / aspectRatio)
        } else {
            return CGSize(width: container.height * aspectRatio, height: container.height)
        }
    }
}
