import UIKit

/// Centralized haptic feedback service
final class HapticsService {
    static let shared = HapticsService()

    private let lightGenerator = UIImpactFeedbackGenerator(style: .light)
    private let mediumGenerator = UIImpactFeedbackGenerator(style: .medium)
    private let heavyGenerator = UIImpactFeedbackGenerator(style: .heavy)
    private let selectionGenerator = UISelectionFeedbackGenerator()
    private let notificationGenerator = UINotificationFeedbackGenerator()

    private init() {
        prepareAll()
    }

    func prepareAll() {
        lightGenerator.prepare()
        mediumGenerator.prepare()
        heavyGenerator.prepare()
        selectionGenerator.prepare()
    }

    /// Light impact - selections, toggles
    func light() {
        lightGenerator.impactOccurred()
    }

    /// Medium impact - button presses, confirmations
    func medium() {
        mediumGenerator.impactOccurred()
    }

    /// Heavy impact - destructive actions, significant events
    func heavy() {
        heavyGenerator.impactOccurred()
    }

    /// Selection feedback - scrubbing, picker changes
    func selection() {
        selectionGenerator.selectionChanged()
    }

    /// Success notification
    func success() {
        notificationGenerator.notificationOccurred(.success)
    }

    /// Warning notification
    func warning() {
        notificationGenerator.notificationOccurred(.warning)
    }

    /// Error notification
    func error() {
        notificationGenerator.notificationOccurred(.error)
    }
}
