import SwiftUI

// MARK: - Liquid Glass Styles

extension View {
    /// Standard liquid glass panel
    func liquidGlass() -> some View {
        self
            .background(.ultraThinMaterial)
            .background(Color.glassTint)
    }

    /// Glass with subtle border
    func liquidGlassBordered(cornerRadius: CGFloat = CornerRadius.xl) -> some View {
        self
            .background(.ultraThinMaterial)
            .background(Color.glassTint)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(Color.white.opacity(0.2), lineWidth: 0.5)
            )
    }

    /// Bottom navigation glass (uses bar material)
    func liquidGlassNav() -> some View {
        self.background(.bar)
    }
}

// MARK: - Glass Panel Component

struct GlassPanel<Content: View>: View {
    let cornerRadius: CGFloat
    let content: () -> Content

    init(cornerRadius: CGFloat = CornerRadius.xl, @ViewBuilder content: @escaping () -> Content) {
        self.cornerRadius = cornerRadius
        self.content = content
    }

    var body: some View {
        content()
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(Color.white.opacity(0.15), lineWidth: 0.5)
            )
    }
}

// MARK: - Glass Card Component

struct GlassCard<Content: View>: View {
    let content: () -> Content

    init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content
    }

    var body: some View {
        content()
            .padding(Spacing.md)
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: CornerRadius.lg))
    }
}
