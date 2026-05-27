import SwiftData
import Foundation

@Model
final class UserSession {
    @Attribute(.unique) var id: UUID
    var username: String
    var avatarIdentifier: String
    var avatarImageData: Data?
    var isPremium: Bool
    var streakRewardSlots: Int
    var totalDaysTracked: Int
    var createdAt: Date
    var lastActiveAt: Date

    @Relationship(deleteRule: .cascade, inverse: \Habit.userSession) var habits: [Habit] = []
    @Relationship(deleteRule: .cascade) var achievements: [Achievement] = []

    init(
        id: UUID = UUID(),
        username: String,
        avatarIdentifier: String,
        avatarImageData: Data? = nil,
        isPremium: Bool = false,
        streakRewardSlots: Int = 0,
        totalDaysTracked: Int = 0,
        createdAt: Date = Date(),
        lastActiveAt: Date = Date()
    ) {
        self.id = id
        self.username = username
        self.avatarIdentifier = avatarIdentifier
        self.avatarImageData = avatarImageData
        self.isPremium = isPremium
        self.streakRewardSlots = streakRewardSlots
        self.totalDaysTracked = totalDaysTracked
        self.createdAt = createdAt
        self.lastActiveAt = lastActiveAt
    }

    // MARK: - Computed Properties

    var hasCustomPhoto: Bool {
        avatarImageData != nil
    }

    var totalFreeSlots: Int {
        AppTheme.Business.baseFreeHabits + streakRewardSlots
    }

    var displayName: String {
        username.trimmingCharacters(in: .whitespaces)
    }

    var activeHabits: [Habit] {
        habits.filter { !$0.isArchived }
    }

    var currentStreak: Int {
        let calendar = Calendar.current
        let sortedLogs = allDailyLogs.sorted { $0.date > $1.date }

        var streak = 0
        var checkDate = calendar.startOfDay(for: Date())

        for log in sortedLogs {
            if log.date == checkDate {
                streak += 1
                checkDate = calendar.date(byAdding: .day, value: -1, to: checkDate) ?? checkDate
            } else if log.date < checkDate {
                break
            }
        }

        return streak
    }

    private var allDailyLogs: [DailyLog] {
        habits.flatMap { $0.dailyLogs }
    }

    var canAddHabit: Bool {
        isPremium || activeHabits.count < totalFreeSlots
    }
}
