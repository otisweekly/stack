import SwiftUI

extension Animation {
    /// Quick response (buttons, selections) - 0.15s ease out
    static let quick = Animation.easeOut(duration: 0.15)

    /// Standard transitions - 0.25s ease in-out
    static let standard = Animation.easeInOut(duration: 0.25)

    /// Smooth movements (panels, sheets) - spring with 0.4s response
    static let smooth = Animation.spring(response: 0.4, dampingFraction: 0.8)

    /// Bouncy feedback (success states) - spring with less damping
    static let bouncy = Animation.spring(response: 0.35, dampingFraction: 0.6)

    /// Snappy interactions - spring with quick response
    static let snappy = Animation.spring(response: 0.3, dampingFraction: 0.7)
}

// MARK: - Transitions

extension AnyTransition {
    /// Slide up (for bottom sheets, panels)
    static var slideUp: AnyTransition {
        .move(edge: .bottom).combined(with: .opacity)
    }

    /// Slide down (for top sheets)
    static var slideDown: AnyTransition {
        .move(edge: .top).combined(with: .opacity)
    }

    /// Scale in (for selections, badges)
    static var pop: AnyTransition {
        .scale(scale: 0.8).combined(with: .opacity)
    }

    /// Scale in with larger effect
    static var scaleIn: AnyTransition {
        .scale(scale: 0.9).combined(with: .opacity)
    }

    /// Fade (general purpose)
    static var fade: AnyTransition {
        .opacity
    }

    /// Asymmetric slide (for navigation)
    static var fadeSlide: AnyTransition {
        .asymmetric(
            insertion: .move(edge: .trailing).combined(with: .opacity),
            removal: .move(edge: .leading).combined(with: .opacity)
        )
    }
}
