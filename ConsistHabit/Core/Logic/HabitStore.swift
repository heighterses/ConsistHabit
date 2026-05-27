import SwiftUI
import SwiftData
import Observation
import Foundation

@MainActor
@Observable
final class HabitStore {
    var userSession: UserSession?
    var celebrationAchievement: Achievement?
    var toastMessage: String?

    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        loadUserSession()
    }

    // MARK: - User Session Management

    func loadUserSession() {
        let fetchDescriptor = FetchDescriptor<UserSession>()
        do {
            let sessions = try modelContext.fetch(fetchDescriptor)
            userSession = sessions.first
        } catch {
            showToast("Failed to load session: \(error.localizedDescription)")
        }
    }

    func createSession(username: String, avatarIdentifier: String, avatarImageData: Data?) {
        let session = UserSession(
            username: username,
            avatarIdentifier: avatarIdentifier,
            avatarImageData: avatarImageData
        )

        modelContext.insert(session)
        save()
        userSession = session
    }

    func updateUsername(_ newUsername: String) {
        guard let session = userSession else { return }
        session.username = newUsername
        save()
    }

    func updateAvatar(identifier: String) {
        guard let session = userSession else { return }
        session.avatarIdentifier = identifier
        session.avatarImageData = nil
        save()
    }

    func updateAvatarPhoto(_ imageData: Data) {
        guard let session = userSession else { return }
        session.avatarImageData = imageData
        save()
    }

    func signOut() {
        if let session = userSession {
            modelContext.delete(session)
            save()
            userSession = nil
        }
    }

    // MARK: - Habit Management

    func addHabit(name: String, emoji: String) {
        guard let session = userSession else { return }
        guard session.canAddHabit else {
            showToast("You've reached your habit limit. Upgrade to Premium or complete a streak!")
            return
        }

        let sortOrder = session.activeHabits.count
        let habit = Habit(name: name, emoji: emoji, sortOrder: sortOrder)
        habit.userSession = session
        session.habits.append(habit)

        modelContext.insert(habit)
        save()

        checkAchievementUnlock(.firstHabit)
    }

    func addHabitWithReminder(habit: Habit) {
        guard let session = userSession else { return }
        guard session.canAddHabit else {
            showToast("You've reached your habit limit. Upgrade to Premium or complete a streak!")
            return
        }

        let sortOrder = session.activeHabits.count
        habit.sortOrder = sortOrder
        habit.userSession = session
        session.habits.append(habit)

        modelContext.insert(habit)
        save()

        if habit.reminderEnabled {
            NotificationManager.shared.scheduleHabitReminder(habit: habit)
        }

        checkAchievementUnlock(.firstHabit)
    }

    func updateHabit(_ habit: Habit, name: String, emoji: String, reminderTime: Date?, reminderEnabled: Bool) {
        habit.name = name
        habit.emoji = emoji
        habit.reminderTime = reminderTime
        habit.reminderEnabled = reminderEnabled
        save()
    }

    func archiveHabit(_ habit: Habit) {
        habit.isArchived = true
        habit.archivedAt = Date()
        save()
    }

    func restoreHabit(_ habit: Habit) {
        habit.isArchived = false
        habit.archivedAt = nil
        save()
    }

    // MARK: - Daily Log Management

    func toggleHabitCompletion(_ habit: Habit) {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        if let existingLog = habit.dailyLogs.first(where: { calendar.startOfDay(for: $0.date) == today }) {
            habit.dailyLogs.removeAll { $0.id == existingLog.id }
            modelContext.delete(existingLog)
        } else {
            let newLog = DailyLog(date: today)
            newLog.habit = habit
            habit.dailyLogs.append(newLog)
            modelContext.insert(newLog)
        }

        save()

        if habit.isCompletedToday {
            HapticManager.shared.trigger(.habitComplete)
            checkStreakRewards()
            checkAchievementUnlock(.allHabitsComplete)
        } else {
            HapticManager.shared.trigger(.habitUncomplete)
        }
    }

    func completeHabitForDate(_ habit: Habit, date: Date) {
        let calendar = Calendar.current
        let normalizedDate = calendar.startOfDay(for: date)

        if !habit.dailyLogs.contains(where: { calendar.startOfDay(for: $0.date) == normalizedDate }) {
            let newLog = DailyLog(date: normalizedDate)
            newLog.habit = habit
            habit.dailyLogs.append(newLog)
            modelContext.insert(newLog)
            save()
        }
    }

    // MARK: - Streak & Achievement Logic

    private func checkStreakRewards() {
        guard let session = userSession else { return }

        let currentStreak = session.currentStreak

        if currentStreak == AppTheme.Business.streakFor14DayReward && session.streakRewardSlots < 1 {
            session.streakRewardSlots = 1
            checkAchievementUnlock(.streak14Days)
        } else if currentStreak >= AppTheme.Business.streakFor30DayReward && session.streakRewardSlots < 2 {
            session.streakRewardSlots = 2
            checkAchievementUnlock(.streak30Days)
        }

        save()
    }

    private func checkAchievementUnlock(_ achievementType: AchievementType) {
        guard let session = userSession else { return }

        let existingAchievement = session.achievements.first { $0.type == achievementType }
        guard existingAchievement == nil else { return }

        let shouldUnlock: Bool
        switch achievementType {
        case .firstHabit:
            shouldUnlock = session.activeHabits.count > 0
        case .streak14Days:
            shouldUnlock = session.currentStreak >= AppTheme.Business.streakFor14DayReward
        case .streak30Days:
            shouldUnlock = session.currentStreak >= AppTheme.Business.streakFor30DayReward
        case .allHabitsComplete:
            shouldUnlock = !session.activeHabits.isEmpty && session.activeHabits.allSatisfy { $0.isCompletedToday }
        default:
            shouldUnlock = false
        }

        if shouldUnlock {
            let achievement = Achievement(type: achievementType, isNew: true)
            achievement.userSession = session
            session.achievements.append(achievement)
            modelContext.insert(achievement)
            save()

            HapticManager.shared.trigger(.achievementUnlock)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                self.celebrationAchievement = achievement
            }
        }
    }

    // MARK: - Premium Management

    func updatePremiumStatus(_ isPremium: Bool) {
        guard let session = userSession else { return }
        session.isPremium = isPremium
        save()
    }

    // MARK: - UI Feedback

    func showToast(_ message: String) {
        toastMessage = message
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            if self.toastMessage == message {
                self.toastMessage = nil
            }
        }
    }

    // MARK: - Data Persistence

    private func save() {
        do {
            try modelContext.save()
        } catch {
            let nsError = error as NSError
            showToast("Failed to save: \(nsError.localizedDescription)")
        }
    }
}
