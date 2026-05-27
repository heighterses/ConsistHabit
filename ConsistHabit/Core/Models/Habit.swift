import SwiftData
import Foundation

@Model
final class Habit {
    @Attribute(.unique) var id: UUID
    var name: String
    var emoji: String
    var colorHex: String
    var sortOrder: Int
    var reminderTime: Date?
    var reminderEnabled: Bool
    var createdAt: Date
    var archivedAt: Date?
    var isArchived: Bool

    @Relationship(deleteRule: .cascade) var userSession: UserSession?
    @Relationship(deleteRule: .cascade, inverse: \DailyLog.habit) var dailyLogs: [DailyLog] = []

    init(
        id: UUID = UUID(),
        name: String,
        emoji: String,
        colorHex: String = "20D7D0",
        sortOrder: Int = 0,
        reminderTime: Date? = nil,
        reminderEnabled: Bool = false,
        createdAt: Date = Date(),
        archivedAt: Date? = nil,
        isArchived: Bool = false
    ) {
        self.id = id
        self.name = name
        self.emoji = emoji
        self.colorHex = colorHex
        self.sortOrder = sortOrder
        self.reminderTime = reminderTime
        self.reminderEnabled = reminderEnabled
        self.createdAt = createdAt
        self.archivedAt = archivedAt
        self.isArchived = isArchived
    }

    // MARK: - Computed Properties

    var currentStreak: Int {
        let calendar = Calendar.current
        let sortedLogs = dailyLogs.sorted { $0.date > $1.date }

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

    var longestStreak: Int {
        let calendar = Calendar.current
        let sortedLogs = dailyLogs.sorted { $0.date < $1.date }

        var longestLength = 0
        var currentLength = 0
        var lastDate: Date?

        for log in sortedLogs {
            if let last = lastDate {
                let expectedDate = calendar.date(byAdding: .day, value: 1, to: last) ?? last
                if log.date == expectedDate {
                    currentLength += 1
                } else {
                    longestLength = max(longestLength, currentLength)
                    currentLength = 1
                }
            } else {
                currentLength = 1
            }
            lastDate = log.date
        }

        longestLength = max(longestLength, currentLength)
        return longestLength
    }

    var totalCompletions: Int {
        dailyLogs.count
    }

    var completionRate: Double {
        let calendar = Calendar.current
        let thirtyDaysAgo = calendar.date(byAdding: .day, value: -30, to: Date()) ?? Date()
        let recentLogs = dailyLogs.filter { $0.date >= thirtyDaysAgo }

        guard !recentLogs.isEmpty else { return 0 }
        return Double(recentLogs.count) / 30.0
    }

    var isCompletedToday: Bool {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        return dailyLogs.contains { calendar.startOfDay(for: $0.date) == today }
    }

    var startedDaysAgo: Int {
        let calendar = Calendar.current
        let daysElapsed = calendar.dateComponents([.day], from: createdAt, to: Date()).day ?? 0
        return max(0, daysElapsed)
    }
}
