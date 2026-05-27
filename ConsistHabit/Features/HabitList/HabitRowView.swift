import SwiftUI
import SwiftData

struct HabitRowView: View {
    @Environment(HabitStore.self) var store
    let habit: Habit
    @State private var showArchiveConfirmation = false
    @State private var showDetailView = false

    var body: some View {
        NavigationLink(destination: HabitDetailView(habit: habit).environment(store), isActive: $showDetailView) {
            VStack(spacing: 0) {
                HStack(spacing: AppTheme.Spacing.md) {
                Button {
                    withAnimation(AppTheme.Animation.springSnappy) {
                        store.toggleHabitCompletion(habit)
                    }
                } label: {
                    Image(systemName: habit.isCompletedToday ? "checkmark.circle.fill" : "circle")
                        .font(.system(size: 24))
                        .foregroundColor(habit.isCompletedToday ? AppTheme.AccentColor.mint : AppTheme.TextColor.tertiary)
                        .contentTransition(.symbolEffect(.replace))
                }

                VStack(alignment: .leading, spacing: AppTheme.Spacing.xs) {
                    Text("\(habit.emoji) \(habit.name)")
                        .font(AppTheme.Typography.bodyLarge)
                        .foregroundColor(AppTheme.TextColor.primary)
                        .strikethrough(habit.isCompletedToday)

                    let daysAgo = habit.startedDaysAgo
                    let streakText = habit.currentStreak > 0
                        ? "Going for \(habit.currentStreak) day\(habit.currentStreak == 1 ? "" : "s")"
                        : "Started \(daysAgo) day\(daysAgo == 1 ? "" : "s") ago"

                    Text(streakText)
                        .font(AppTheme.Typography.bodySmall)
                        .foregroundColor(AppTheme.TextColor.secondary)
                }

                Spacer()

                if habit.currentStreak > 1 {
                    HStack(spacing: AppTheme.Spacing.xs) {
                        Image(systemName: "flame.fill")
                            .font(.system(size: 14))
                            .foregroundColor(AppTheme.AccentColor.coral)

                        Text("\(habit.currentStreak)")
                            .font(AppTheme.Typography.bodyMedium)
                            .foregroundColor(AppTheme.AccentColor.coral)
                    }
                    .padding(.vertical, AppTheme.Spacing.xs)
                    .padding(.horizontal, AppTheme.Spacing.sm)
                    .background(AppTheme.AccentColor.coral.opacity(0.2))
                    .cornerRadius(AppTheme.Radius.full)
                }
            }
            .padding(AppTheme.Spacing.xl)
            .background(AppTheme.BackgroundColor.elevated)
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 4)
            .swipeActions(edge: .trailing) {
                Button {
                    showArchiveConfirmation = true
                } label: {
                    Image(systemName: "archivebox.fill")
                }
                .tint(AppTheme.AccentColor.coral)
            }
            }
        }
        .alert("Archive Habit?", isPresented: $showArchiveConfirmation) {
            Button("Cancel", role: .cancel) {}
            Button("Archive", role: .destructive) {
                withAnimation(AppTheme.Animation.springSnappy) {
                    store.archiveHabit(habit)
                }
            }
        } message: {
            Text("You can restore this habit later in your profile.")
        }
    }
}

#Preview {
    let habit = Habit(name: "Exercise", emoji: "💪")

    return HabitRowView(habit: habit)
        .padding()
        .background(AppTheme.BackgroundColor.primary)
        .modelContainer(for: Habit.self, inMemory: true)
}
