import SwiftData
import Foundation

enum AchievementType: String, Codable, CaseIterable {
    case streak7Days = "streak7Days"
    case streak14Days = "streak14Days"
    case streak30Days = "streak30Days"
    case streak60Days = "streak60Days"
    case streak100Days = "streak100Days"
    case firstHabit = "firstHabit"
    case allHabitsComplete = "allHabitsComplete"
    case perfectWeek = "perfectWeek"
    case perfectMonth = "perfectMonth"

    var title: String {
        switch self {
        case .streak7Days:
            return "First Week"
        case .streak14Days:
            return "Two Weeks Strong"
        case .streak30Days:
            return "One Month Champion"
        case .streak60Days:
            return "Two Month Legend"
        case .streak100Days:
            return "Century Streak"
        case .firstHabit:
            return "Getting Started"
        case .allHabitsComplete:
            return "Perfect Day"
        case .perfectWeek:
            return "Perfect Week"
        case .perfectMonth:
            return "Perfect Month"
        }
    }

    var description: String {
        switch self {
        case .streak7Days:
            return "Keep a 7-day streak on any habit"
        case .streak14Days:
            return "Maintain a 14-day global streak"
        case .streak30Days:
            return "Reach a 30-day global streak"
        case .streak60Days:
            return "Achieve a 60-day global streak"
        case .streak100Days:
            return "Hit 100 consecutive days"
        case .firstHabit:
            return "Create your first habit"
        case .allHabitsComplete:
            return "Complete all habits in one day"
        case .perfectWeek:
            return "100% completion for 7 days"
        case .perfectMonth:
            return "100% completion for 30 days"
        }
    }

    var icon: String {
        switch self {
        case .streak7Days:
            return "🔥"
        case .streak14Days:
            return "⭐"
        case .streak30Days:
            return "👑"
        case .streak60Days:
            return "💎"
        case .streak100Days:
            return "🚀"
        case .firstHabit:
            return "🎯"
        case .allHabitsComplete:
            return "✨"
        case .perfectWeek:
            return "🏆"
        case .perfectMonth:
            return "🌟"
        }
    }

    var rewardMessage: String? {
        switch self {
        case .streak14Days:
            return "You earned 1 free habit slot! You can now track 4 habits."
        case .streak30Days:
            return "You earned 2 free habit slots! You can now track 6 habits."
        default:
            return nil
        }
    }
}

@Model
final class Achievement {
    @Attribute(.unique) var id: UUID
    var type: AchievementType
    var unlockedAt: Date
    var isNew: Bool

    @Relationship(deleteRule: .cascade) var userSession: UserSession?

    init(
        id: UUID = UUID(),
        type: AchievementType,
        unlockedAt: Date = Date(),
        isNew: Bool = true
    ) {
        self.id = id
        self.type = type
        self.unlockedAt = unlockedAt
        self.isNew = isNew
    }
}
