import Foundation

final class AchievementEngine {
    static func checkAllAchievements(session: UserSession, habits: [Habit]) {
        let activeHabits = habits.filter { !$0.isArchived }

        checkStreakAchievements(session: session)
        checkHabitAchievements(session: session, activeHabits: activeHabits)
        checkConsistencyAchievements(session: session, activeHabits: activeHabits)
    }

    private static func checkStreakAchievements(session: UserSession) {
        let streak = session.currentStreak

        if streak >= 7 {
            attemptUnlock(.streak7Days, in: session)
        }
        if streak >= 14 {
            attemptUnlock(.streak14Days, in: session)
        }
        if streak >= 30 {
            attemptUnlock(.streak30Days, in: session)
        }
        if streak >= 60 {
            attemptUnlock(.streak60Days, in: session)
        }
        if streak >= 100 {
            attemptUnlock(.streak100Days, in: session)
        }
    }

    private static func checkHabitAchievements(session: UserSession, activeHabits: [Habit]) {
        if activeHabits.count >= 1 {
            attemptUnlock(.firstHabit, in: session)
        }

        if !activeHabits.isEmpty && activeHabits.allSatisfy({ $0.isCompletedToday }) {
            attemptUnlock(.allHabitsComplete, in: session)
        }
    }

    private static func checkConsistencyAchievements(session: UserSession, activeHabits: [Habit]) {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        var perfectWeekDays = 0
        var perfectMonthDays = 0

        for dayOffset in 0..<7 {
            let date = calendar.date(byAdding: .day, value: -dayOffset, to: today) ?? today
            if isPerfectDay(date: date, habits: activeHabits) {
                perfectWeekDays += 1
            } else {
                break
            }
        }

        for dayOffset in 0..<30 {
            let date = calendar.date(byAdding: .day, value: -dayOffset, to: today) ?? today
            if isPerfectDay(date: date, habits: activeHabits) {
                perfectMonthDays += 1
            } else {
                break
            }
        }

        if perfectWeekDays >= 7 {
            attemptUnlock(.perfectWeek, in: session)
        }

        if perfectMonthDays >= 30 {
            attemptUnlock(.perfectMonth, in: session)
        }
    }

    private static func isPerfectDay(date: Date, habits: [Habit]) -> Bool {
        let calendar = Calendar.current
        let normalizedDate = calendar.startOfDay(for: date)

        guard !habits.isEmpty else { return false }

        for habit in habits {
            let isCompleted = habit.dailyLogs.contains { log in
                calendar.startOfDay(for: log.date) == normalizedDate
            }
            if !isCompleted {
                return false
            }
        }

        return true
    }

    private static func attemptUnlock(_ type: AchievementType, in session: UserSession) {
        guard session.achievements.first(where: { $0.type == type }) == nil else {
            return
        }

        let achievement = Achievement(type: type, isNew: true)
        session.achievements.append(achievement)
    }
}
