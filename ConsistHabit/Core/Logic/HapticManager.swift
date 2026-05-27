import UIKit

@MainActor
final class HapticManager {
    static let shared = HapticManager()

    private init() {}

    enum HapticEvent {
        case habitComplete
        case habitUncomplete
        case achievementUnlock
        case paywallTrigger
        case buttonTap
        case selectionChange
        case errorOccurred
        case onboardingComplete
    }

    func trigger(_ event: HapticEvent) {
        guard UIDevice.current.hasHaptics else { return }

        switch event {
        case .habitComplete:
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.impactOccurred()

        case .habitUncomplete:
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.impactOccurred()

        case .achievementUnlock:
            let generator = UIImpactFeedbackGenerator(style: .heavy)
            generator.impactOccurred()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                let notificationGenerator = UINotificationFeedbackGenerator()
                notificationGenerator.notificationOccurred(.success)
            }

        case .paywallTrigger:
            let notificationGenerator = UINotificationFeedbackGenerator()
            notificationGenerator.notificationOccurred(.warning)

        case .buttonTap:
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.impactOccurred()

        case .selectionChange:
            let selectionGenerator = UISelectionFeedbackGenerator()
            selectionGenerator.selectionChanged()

        case .errorOccurred:
            let notificationGenerator = UINotificationFeedbackGenerator()
            notificationGenerator.notificationOccurred(.error)

        case .onboardingComplete:
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.impactOccurred()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                let notificationGenerator = UINotificationFeedbackGenerator()
                notificationGenerator.notificationOccurred(.success)
            }
        }
    }

    private func isReduceMotionEnabled() -> Bool {
        UIAccessibility.isReduceMotionEnabled
    }
}

private extension UIDevice {
    var hasHaptics: Bool {
        do {
            let feedbackGenerator = UIImpactFeedbackGenerator(style: .light)
            feedbackGenerator.prepare()
            return true
        } catch {
            return false
        }
    }
}
