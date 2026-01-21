import Foundation

/// Canvas aspect ratio options
enum CanvasSize: String, CaseIterable, Identifiable {
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
        case .portrait9x16: return "Stories (9:16)"
        case .landscape16x9: return "Landscape (16:9)"
        case .square1x1: return "Square (1:1)"
        case .portrait4x5: return "Portrait (4:5)"
        }
    }

    /// Calculate the largest size that fits within the container
    func fittedSize(in containerSize: CGSize) -> CGSize {
        let containerRatio = containerSize.width / containerSize.height

        if aspectRatio > containerRatio {
            // Width constrained
            let width = containerSize.width
            let height = width / aspectRatio
            return CGSize(width: width, height: height)
        } else {
            // Height constrained
            let height = containerSize.height
            let width = height * aspectRatio
            return CGSize(width: width, height: height)
        }
    }

    /// Export resolution at 1080p base
    var resolution1080p: CGSize {
        switch self {
        case .portrait9x16: return CGSize(width: 1080, height: 1920)
        case .landscape16x9: return CGSize(width: 1920, height: 1080)
        case .square1x1: return CGSize(width: 1080, height: 1080)
        case .portrait4x5: return CGSize(width: 1080, height: 1350)
        }
    }

    /// Export resolution at 4K base
    var resolution4K: CGSize {
        switch self {
        case .portrait9x16: return CGSize(width: 2160, height: 3840)
        case .landscape16x9: return CGSize(width: 3840, height: 2160)
        case .square1x1: return CGSize(width: 2160, height: 2160)
        case .portrait4x5: return CGSize(width: 2160, height: 2700)
        }
    }
}
