import SwiftUI

// MARK: - Glass Styles

extension View {
    /// Standard liquid glass panel
    func liquidGlass() -> some View {
        self
            .background(.ultraThinMaterial)
            .background(Color.glassTint)
    }

    /// Glass with subtle border
    func liquidGlassBordered(cornerRadius: CGFloat = 20) -> some View {
        self
            .background(.ultraThinMaterial)
            .background(Color.glassTint)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(Color.white.opacity(0.2), lineWidth: 0.5)
            )
    }

    /// Bottom navigation glass
    func liquidGlassNav() -> some View {
        self
            .background(.bar)
    }

    /// Standard content padding respecting safe areas
    func contentPadding() -> some View {
        self.padding(.horizontal, Spacing.md)
    }

    /// Bottom padding for content above tab bar
    func tabBarPadding() -> some View {
        self.padding(.bottom, 100)
    }

    /// Corner radius for specific corners
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

// MARK: - RoundedCorner Shape

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

// MARK: - Animation Extensions

extension Animation {
    /// Quick response (buttons, selections)
    static let quick = Animation.easeOut(duration: 0.15)

    /// Standard transitions
    static let standard = Animation.easeInOut(duration: 0.25)

    /// Smooth movements (panels, sheets)
    static let smooth = Animation.spring(response: 0.4, dampingFraction: 0.8)

    /// Bouncy feedback (success states)
    static let bouncy = Animation.spring(response: 0.35, dampingFraction: 0.6)
}

// MARK: - Transition Extensions

extension AnyTransition {
    /// Slide up (for bottom sheets, panels)
    static var slideUp: AnyTransition {
        .move(edge: .bottom).combined(with: .opacity)
    }

    /// Scale in (for selections, badges)
    static var pop: AnyTransition {
        .scale(scale: 0.8).combined(with: .opacity)
    }

    /// Fade (general purpose)
    static var fade: AnyTransition {
        .opacity
    }
}
