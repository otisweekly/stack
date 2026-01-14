import UIKit

final class HapticsService: @unchecked Sendable {
    nonisolated(unsafe) static let shared = HapticsService()

    private let lightGenerator = UIImpactFeedbackGenerator(style: .light)
    private let mediumGenerator = UIImpactFeedbackGenerator(style: .medium)
    private let heavyGenerator = UIImpactFeedbackGenerator(style: .heavy)
    private let selectionGenerator = UISelectionFeedbackGenerator()
    private let notificationGenerator = UINotificationFeedbackGenerator()

    private init() {
        // Prepare generators on main thread
        Task { @MainActor in
            self.prepareAll()
        }
    }

    @MainActor
    private func prepareAll() {
        lightGenerator.prepare()
        mediumGenerator.prepare()
        heavyGenerator.prepare()
        selectionGenerator.prepare()
    }

    func light() {
        Task { @MainActor in
            self.lightGenerator.impactOccurred()
        }
    }

    func medium() {
        Task { @MainActor in
            self.mediumGenerator.impactOccurred()
        }
    }

    func heavy() {
        Task { @MainActor in
            self.heavyGenerator.impactOccurred()
        }
    }

    func selection() {
        Task { @MainActor in
            self.selectionGenerator.selectionChanged()
        }
    }

    func success() {
        Task { @MainActor in
            self.notificationGenerator.notificationOccurred(.success)
        }
    }

    func warning() {
        Task { @MainActor in
            self.notificationGenerator.notificationOccurred(.warning)
        }
    }

    func error() {
        Task { @MainActor in
            self.notificationGenerator.notificationOccurred(.error)
        }
    }
}
