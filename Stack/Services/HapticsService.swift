import UIKit

@MainActor
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

    private func prepareAll() {
        lightGenerator.prepare()
        mediumGenerator.prepare()
        heavyGenerator.prepare()
        selectionGenerator.prepare()
    }

    func light() {
        lightGenerator.impactOccurred()
    }

    func medium() {
        mediumGenerator.impactOccurred()
    }

    func heavy() {
        heavyGenerator.impactOccurred()
    }

    func selection() {
        selectionGenerator.selectionChanged()
    }

    func success() {
        notificationGenerator.notificationOccurred(.success)
    }

    func warning() {
        notificationGenerator.notificationOccurred(.warning)
    }

    func error() {
        notificationGenerator.notificationOccurred(.error)
    }
}
