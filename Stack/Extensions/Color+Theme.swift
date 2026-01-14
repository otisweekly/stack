import SwiftUI

extension Color {
    // MARK: - Core Palette (Black & White Only)

    /// Pure black - primary backgrounds, text on light
    static let stackBlack = Color(hex: "#000000")

    /// Pure white - text on dark, surfaces
    static let stackWhite = Color(hex: "#FFFFFF")

    // MARK: - Accent (Use Sparingly)

    /// Teal accent for primary actions only
    static let stackAccent = Color(hex: "#009290")

    // MARK: - Semantic

    /// Primary background
    static let backgroundPrimary = stackBlack

    /// Secondary background for cards/panels
    static let backgroundSecondary = Color(hex: "#1A1A1A")

    /// Tertiary background for elevated surfaces
    static let backgroundTertiary = Color(hex: "#2A2A2A")

    /// Text on dark backgrounds
    static let textPrimary = stackWhite

    /// Secondary text
    static let textSecondary = stackWhite.opacity(0.6)

    /// Text on light backgrounds / glass
    static let textOnGlass = stackBlack

    /// Disabled/inactive state
    static let textDisabled = stackWhite.opacity(0.4)

    /// Borders and dividers
    static let border = stackWhite.opacity(0.15)

    // MARK: - Liquid Glass

    /// Glass material tint (used with .ultraThinMaterial)
    static let glassTint = stackWhite.opacity(0.1)

    // MARK: - Semantic Colors

    static let success = Color(hex: "#4CAF50")
    static let warning = Color(hex: "#FF9800")
    static let error = Color(hex: "#F44336")
}

// MARK: - Hex Initializer

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
