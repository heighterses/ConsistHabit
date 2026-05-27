import SwiftUI
import SwiftData

struct HabitListView: View {
    @Environment(HabitStore.self) var store
    let habits: [Habit]

    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
            headerWithProgress

            if habits.isEmpty {
                emptyState
            } else {
                LazyVStack(spacing: AppTheme.Spacing.sm) {
                    ForEach(habits, id: \.id) { habit in
                        HabitRowView(habit: habit)
                            .environment(store)
                            .transition(.asymmetric(insertion: .move(edge: .leading), removal: .move(edge: .leading)))
                    }
                }
            }
        }
        .padding(AppTheme.Spacing.lg)
    }

    private var headerWithProgress: some View {
        let completedCount = habits.filter { $0.isCompletedToday }.count
        let progressRatio = habits.isEmpty ? 0.0 : Double(completedCount) / Double(habits.count)

        return VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
            HStack {
                VStack(alignment: .leading, spacing: AppTheme.Spacing.xs) {
                    Text("Today")
                        .font(AppTheme.Typography.headingMedium)
                        .foregroundColor(AppTheme.TextColor.primary)

                    Text(Date().formattedFullDate())
                        .font(AppTheme.Typography.bodySmall)
                        .foregroundColor(AppTheme.TextColor.secondary)
                }

                Spacer()

                ZStack {
                    Circle()
                        .stroke(AppTheme.BackgroundColor.card, lineWidth: 3)

                    Circle()
                        .trim(from: 0, to: progressRatio)
                        .stroke(AppTheme.AccentColor.gold, style: StrokeStyle(lineWidth: 3, lineCap: .round))
                        .rotationEffect(.degrees(-90))

                    VStack(spacing: 0) {
                        Text("\(completedCount)")
                            .font(AppTheme.Typography.numeric)
                            .foregroundColor(AppTheme.AccentColor.gold)

                        Text("of \(habits.count)")
                            .font(AppTheme.Typography.bodySmall)
                            .foregroundColor(AppTheme.TextColor.secondary)
                    }
                }
                .frame(width: 70, height: 70)
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: AppTheme.Spacing.lg) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 48))
                .foregroundColor(AppTheme.AccentColor.mint)

            VStack(spacing: AppTheme.Spacing.sm) {
                Text("No Habits Yet")
                    .font(AppTheme.Typography.headingMedium)
                    .foregroundColor(AppTheme.TextColor.primary)

                Text("Create your first habit to get started with building consistency.")
                    .font(AppTheme.Typography.bodyMedium)
                    .foregroundColor(AppTheme.TextColor.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .fillMaxWidth()
        .padding(.vertical, AppTheme.Spacing.xxxl)
        .padding(.horizontal, AppTheme.Spacing.lg)
    }
}

#Preview {
    let habit1 = Habit(name: "Exercise", emoji: "💪")
    let habit2 = Habit(name: "Read", emoji: "📚")

    return HabitListView(habits: [habit1, habit2])
        .background(AppTheme.BackgroundColor.primary)
        .modelContainer(for: Habit.self, inMemory: true)
}
