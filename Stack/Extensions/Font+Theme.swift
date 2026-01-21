import SwiftUI

extension Font {
    // MARK: - PP Fuji Font Family

    /// Display - Large titles, hero text (34pt Bold)
    static let fujiDisplay = Font.custom("PPFuji-Bold", size: 34)

    /// Display Medium - Section headers (28pt Bold)
    static let fujiDisplayMedium = Font.custom("PPFuji-Bold", size: 28)

    /// Headline - Card titles (22pt Bold)
    static let fujiHeadline = Font.custom("PPFuji-Bold", size: 22)

    /// Headline Small - Subsection headers (18pt Regular)
    static let fujiHeadlineSmall = Font.custom("PPFuji-Regular", size: 18)

    /// Body - Primary content (16pt Regular)
    static let fujiBody = Font.custom("PPFuji-Regular", size: 16)

    /// Body Small - Secondary content (14pt Regular)
    static let fujiBodySmall = Font.custom("PPFuji-Regular", size: 14)

    /// Label - Button text, labels (14pt Bold)
    static let fujiLabel = Font.custom("PPFuji-Bold", size: 14)

    /// Label Small - Tags, badges (12pt Bold)
    static let fujiLabelSmall = Font.custom("PPFuji-Bold", size: 12)

    /// Caption - Timestamps, metadata (12pt Light)
    static let fujiCaption = Font.custom("PPFuji-Light", size: 12)

    /// Caption Small - Fine print (10pt Light)
    static let fujiCaptionSmall = Font.custom("PPFuji-Light", size: 10)

    /// Monospace - Timecodes (13pt Medium)
    static let mono = Font.system(size: 13, weight: .medium, design: .monospaced)

    /// Monospace Small (11pt Medium)
    static let monoSmall = Font.system(size: 11, weight: .medium, design: .monospaced)

    // MARK: - Dynamic Type Support

    static func fuji(_ style: FujiStyle, size: CGFloat) -> Font {
        let fontName: String
        switch style {
        case .light: fontName = "PPFuji-Light"
        case .regular: fontName = "PPFuji-Regular"
        case .bold: fontName = "PPFuji-Bold"
        }
        return Font.custom(fontName, size: size, relativeTo: .body)
    }

    enum FujiStyle {
        case light, regular, bold
    }
}

// MARK: - Fallback System Fonts
// Use these if PP Fuji fonts are not available

extension Font {
    /// Display Large (system fallback)
    static let displayLarge = Font.system(size: 32, weight: .bold, design: .default)

    /// Display Medium (system fallback)
    static let displayMedium = Font.system(size: 24, weight: .semibold, design: .default)

    /// Headline Large (system fallback)
    static let headlineLarge = Font.system(size: 20, weight: .semibold, design: .default)

    /// Headline Medium (system fallback)
    static let headlineMedium = Font.system(size: 17, weight: .semibold, design: .default)

    /// Body Large (system fallback)
    static let bodyLarge = Font.system(size: 17, weight: .regular, design: .default)

    /// Body Medium (system fallback)
    static let bodyMedium = Font.system(size: 15, weight: .regular, design: .default)

    /// Body Small (system fallback)
    static let bodySmall = Font.system(size: 13, weight: .regular, design: .default)

    /// Label Large (system fallback)
    static let labelLarge = Font.system(size: 15, weight: .medium, design: .default)

    /// Label Medium (system fallback)
    static let labelMedium = Font.system(size: 13, weight: .medium, design: .default)

    /// Label Small (system fallback)
    static let labelSmall = Font.system(size: 11, weight: .medium, design: .default)
}
