import SwiftUI

extension Font {
    // MARK: - PP Fuji Font Family

    /// Display - Large titles, hero text
    static let fujiDisplay = Font.custom("PPFuji-Bold", size: 34)
    static let fujiDisplayMedium = Font.custom("PPFuji-Bold", size: 28)

    /// Headlines
    static let fujiHeadline = Font.custom("PPFuji-Bold", size: 22)
    static let fujiHeadlineSmall = Font.custom("PPFuji-Regular", size: 18)

    /// Body
    static let fujiBody = Font.custom("PPFuji-Regular", size: 16)
    static let fujiBodySmall = Font.custom("PPFuji-Regular", size: 14)

    /// Labels
    static let fujiLabel = Font.custom("PPFuji-Bold", size: 14)
    static let fujiLabelSmall = Font.custom("PPFuji-Bold", size: 12)

    /// Captions
    static let fujiCaption = Font.custom("PPFuji-Light", size: 12)
    static let fujiCaptionSmall = Font.custom("PPFuji-Light", size: 10)

    /// Monospace (for timecodes - use system mono)
    static let mono = Font.system(size: 13, weight: .medium, design: .monospaced)
    static let monoSmall = Font.system(size: 11, weight: .medium, design: .monospaced)

    // MARK: - Dynamic Type Support

    static func fuji(_ style: FujiStyle, size: CGFloat) -> Font {
        let weight: String
        switch style {
        case .light: weight = "PPFuji-Light"
        case .regular: weight = "PPFuji-Regular"
        case .bold: weight = "PPFuji-Bold"
        }
        return Font.custom(weight, size: size, relativeTo: .body)
    }

    enum FujiStyle {
        case light, regular, bold
    }
}
