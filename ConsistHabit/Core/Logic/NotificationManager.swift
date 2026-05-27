import UserNotifications
import Foundation
import UIKit

@MainActor
final class NotificationManager {
    static let shared = NotificationManager()

    private init() {}

    func requestNotificationPermission() async -> Bool {
        do {
            let granted = try await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge])
            return granted
        } catch {
            return false
        }
    }

    func scheduleHabitReminder(habit: Habit) {
        guard habit.reminderEnabled, let reminderTime = habit.reminderTime else {
            cancelHabitReminder(habit: habit)
            return
        }

        let content = UNMutableNotificationContent()
        content.title = "Time to \(habit.emoji) \(habit.name)"
        content.body = "Keep your streak going 🔥"
        content.sound = .default
        content.badge = NSNumber(value: UIApplication.shared.applicationIconBadgeNumber + 1)

        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute], from: reminderTime)

        var triggerComponents = DateComponents()
        triggerComponents.hour = components.hour
        triggerComponents.minute = components.minute

        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerComponents, repeats: true)
        let request = UNNotificationRequest(identifier: habit.id.uuidString, content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Failed to schedule reminder: \(error.localizedDescription)")
            }
        }
    }

    func cancelHabitReminder(habit: Habit) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [habit.id.uuidString])
    }

    func scheduleStreakAtRiskNotification(streakCount: Int) {
        guard streakCount > 3 else { return }

        let content = UNMutableNotificationContent()
        content.title = "Don't break your \(streakCount) day streak!"
        content.body = "Complete a habit now to keep the momentum going."
        content.sound = .default

        var components = DateComponents()
        components.hour = 20
        components.minute = 0

        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        let request = UNNotificationRequest(identifier: "streak-at-risk", content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Failed to schedule streak notification: \(error.localizedDescription)")
            }
        }
    }

    func notifyAchievementUnlock(_ achievement: Achievement) {
        let content = UNMutableNotificationContent()
        content.title = "Achievement Unlocked!"
        content.body = "\(achievement.type.icon) \(achievement.type.title)"
        content.sound = .default
        content.badge = NSNumber(value: (UIApplication.shared.applicationIconBadgeNumber) + 1)

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: achievement.id.uuidString, content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Failed to send achievement notification: \(error.localizedDescription)")
            }
        }
    }

    func cancelAllNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }

    func setNotificationDelegate(_ delegate: UNUserNotificationCenterDelegate) {
        UNUserNotificationCenter.current().delegate = delegate
    }
}
