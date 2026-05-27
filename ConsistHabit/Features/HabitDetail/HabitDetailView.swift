import SwiftUI
import SwiftData

struct HabitDetailView: View {
    @Environment(HabitStore.self) var store
    @Environment(\.dismiss) var dismiss
    @State private var showEditSheet = false
    @State private var showArchiveConfirmation = false

    let habit: Habit

    var body: some View {
        ZStack {
            AppTheme.BackgroundColor.primary.ignoresSafeArea()

            ScrollView {
                VStack(spacing: AppTheme.Spacing.lg) {
                    headerSection

                    miniMatrixSection

                    statsSection

                    completionLogSection

                    archiveButton
                }
                .padding(AppTheme.Spacing.lg)
            }
        }
        .navigationTitle("\(habit.emoji) \(habit.name)")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    showEditSheet = true
                } label: {
                    Image(systemName: "pencil")
                        .foregroundColor(AppTheme.AccentColor.mint)
                }
            }
        }
        .sheet(isPresented: $showEditSheet) {
            EditHabitSheet(habit: habit, isPresented: $showEditSheet)
                .environment(store)
        }
        .alert("Archive Habit?", isPresented: $showArchiveConfirmation) {
            Button("Cancel", role: .cancel) {}
            Button("Archive", role: .destructive) {
                store.archiveHabit(habit)
                dismiss()
            }
        } message: {
            Text("You can restore this habit later in your profile.")
        }
    }

    private var headerSection: some View {
        VStack(spacing: AppTheme.Spacing.md) {
            HStack {
                VStack(alignment: .leading, spacing: AppTheme.Spacing.xs) {
                    Text("Current Streak")
                        .font(AppTheme.Typography.bodyMedium)
                        .foregroundColor(AppTheme.TextColor.secondary)

                    HStack(spacing: AppTheme.Spacing.sm) {
                        Image(systemName: "flame.fill")
                            .foregroundColor(AppTheme.AccentColor.coral)
                        Text("\(habit.currentStreak)")
                            .font(AppTheme.Typography.numeric)
                            .foregroundColor(AppTheme.AccentColor.coral)
                    }
                }

                Spacer()

                VStack(alignment: .trailing, spacing: AppTheme.Spacing.xs) {
                    Text("Longest Streak")
                        .font(AppTheme.Typography.bodyMedium)
                        .foregroundColor(AppTheme.TextColor.secondary)

                    HStack(spacing: AppTheme.Spacing.sm) {
                        Text("\(habit.longestStreak)")
                            .font(AppTheme.Typography.numeric)
                            .foregroundColor(AppTheme.AccentColor.gold)
                        Image(systemName: "crown.fill")
                            .foregroundColor(AppTheme.AccentColor.gold)
                    }
                }
            }
            .padding(AppTheme.Spacing.md)
            .background(AppTheme.BackgroundColor.elevated)
            .cornerRadius(AppTheme.Radius.lg)
        }
    }

    private var miniMatrixSection: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
            Text("Last 12 Weeks")
                .font(AppTheme.Typography.headingMedium)
                .foregroundColor(AppTheme.TextColor.primary)

            let weeks = MatrixCalculator.calculateMatrix(habits: [habit], weekCount: 12)

            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 2), count: 12), spacing: 2) {
                ForEach(weeks.flatMap { $0.days }, id: \.date) { day in
                    RoundedRectangle(cornerRadius: AppTheme.Matrix.cornerRadius)
                        .fill(
                            day.completionRatio == 0 && !day.isFuture
                                ? AppTheme.Matrix.emptyTileColor
                                : AppTheme.AccentColor.mint.opacity(
                                    day.isFuture ? 0.45 : AppTheme.Matrix.opacityForRatio(day.completionRatio)
                                )
                        )
                        .frame(height: 20)
                        .overlay(
                            RoundedRectangle(cornerRadius: AppTheme.Matrix.cornerRadius)
                                .stroke(day.isToday ? AppTheme.AccentColor.gold : .clear, lineWidth: 1.5)
                        )
                }
            }
        }
        .padding(AppTheme.Spacing.md)
        .background(AppTheme.BackgroundColor.elevated)
        .cornerRadius(AppTheme.Radius.lg)
    }

    private var statsSection: some View {
        VStack(spacing: AppTheme.Spacing.md) {
            statsRow(label: "Total Completions", value: "\(habit.totalCompletions)", icon: "✓")
            Divider()
            statsRow(label: "30-Day Rate", value: "\(Int(habit.completionRate * 100))%", icon: "📊")
            Divider()
            statsRow(label: "Started", value: "\(habit.startedDaysAgo) days ago", icon: "🚀")
        }
        .padding(AppTheme.Spacing.md)
        .background(AppTheme.BackgroundColor.elevated)
        .cornerRadius(AppTheme.Radius.lg)
    }

    private func statsRow(label: String, value: String, icon: String) -> some View {
        HStack {
            HStack(spacing: AppTheme.Spacing.sm) {
                Text(icon)
                    .font(.system(size: 18))
                Text(label)
                    .font(AppTheme.Typography.bodyMedium)
                    .foregroundColor(AppTheme.TextColor.primary)
            }

            Spacer()

            Text(value)
                .font(AppTheme.Typography.bodyLarge)
                .foregroundColor(AppTheme.AccentColor.mint)
        }
    }

    private var completionLogSection: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
            Text("Completion Log")
                .font(AppTheme.Typography.headingMedium)
                .foregroundColor(AppTheme.TextColor.primary)

            let sortedLogs = habit.dailyLogs.sorted { $0.date > $1.date }

            if sortedLogs.isEmpty {
                VStack(spacing: AppTheme.Spacing.sm) {
                    Image(systemName: "calendar.badge.exclamationmark")
                        .font(.system(size: 32))
                        .foregroundColor(AppTheme.TextColor.tertiary)
                    Text("No completions yet")
                        .font(AppTheme.Typography.bodyMedium)
                        .foregroundColor(AppTheme.TextColor.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, AppTheme.Spacing.lg)
            } else {
                LazyVStack(spacing: AppTheme.Spacing.sm) {
                    ForEach(sortedLogs.prefix(20), id: \.id) { log in
                        HStack {
                            VStack(alignment: .leading, spacing: AppTheme.Spacing.xs) {
                                Text(log.date.formattedFullDate())
                                    .font(AppTheme.Typography.bodyMedium)
                                    .foregroundColor(AppTheme.TextColor.primary)

                                Text(log.completedAt.formattedTime())
                                    .font(AppTheme.Typography.bodySmall)
                                    .foregroundColor(AppTheme.TextColor.secondary)
                            }

                            Spacer()

                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(AppTheme.AccentColor.mint)
                        }
                        .padding(AppTheme.Spacing.md)
                        .background(AppTheme.BackgroundColor.card)
                        .cornerRadius(AppTheme.Radius.lg)
                    }

                    if sortedLogs.count > 20 {
                        Text("\(sortedLogs.count - 20) more completions")
                            .font(AppTheme.Typography.bodySmall)
                            .foregroundColor(AppTheme.TextColor.secondary)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding(AppTheme.Spacing.md)
                    }
                }
            }
        }
        .padding(AppTheme.Spacing.md)
        .background(AppTheme.BackgroundColor.elevated)
        .cornerRadius(AppTheme.Radius.lg)
    }

    private var archiveButton: some View {
        Button {
            showArchiveConfirmation = true
        } label: {
            Text("Archive Habit")
                .font(AppTheme.Typography.bodyLarge)
                .foregroundColor(AppTheme.AccentColor.coral)
                .fillMaxWidth()
                .frame(height: 48)
                .background(AppTheme.AccentColor.coral.opacity(0.1))
                .cornerRadius(AppTheme.Radius.lg)
        }
    }
}

extension View {
    func tooltip(_ text: String, side: TooltipSide = .top) -> some View {
        self.modifier(TooltipModifier(text: text, side: side))
    }
}

enum TooltipSide {
    case top, bottom, left, right
}

struct TooltipModifier: ViewModifier {
    let text: String
    let side: TooltipSide

    func body(content: Content) -> some View {
        content
    }
}

#Preview {
    let habit = Habit(name: "Exercise", emoji: "💪")

    NavigationStack {
        HabitDetailView(habit: habit)
    }
    .modelContainer(for: Habit.self, inMemory: true)
}
