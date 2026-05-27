import SwiftUI

struct ConsistencyMatrixView: View {
    let habits: [Habit]
    @State private var weeks: [MatrixWeek] = []
    @State private var selectedDay: MatrixDay?
    @State private var scrollToWeek: UUID?

    var body: some View {
        VStack(spacing: AppTheme.Spacing.md) {
            legendRow

            ScrollViewReader { scrollProxy in
                ScrollView(.horizontal, showsIndicators: false) {
                    LazyHStack(spacing: AppTheme.Spacing.sm) {
                        ForEach(0..<weeks.count, id: \.self) { weekIndex in
                            matrixWeekView(weeks[weekIndex], id: UUID())
                                .id(weekIndex)
                        }
                    }
                    .padding(.horizontal, AppTheme.Spacing.lg)
                }
                .onAppear {
                    let currentIndex = weeks.count - 1
                    if currentIndex >= 0 {
                        withAnimation(AppTheme.Animation.easeDefault) {
                            scrollProxy.scrollTo(currentIndex, anchor: .trailing)
                        }
                    }
                }
            }

            if let selectedDay = selectedDay {
                selectedDayBanner(selectedDay)
            }
        }
        .padding(.vertical, AppTheme.Spacing.lg)
        .padding(.horizontal, AppTheme.Spacing.lg)
        .background(AppTheme.BackgroundColor.elevated)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 4)
        .onAppear {
            weeks = MatrixCalculator.calculateMatrix(habits: habits)
        }
        .onChange(of: habits) { _, newHabits in
            weeks = MatrixCalculator.calculateMatrix(habits: newHabits)
        }
    }

    private var legendRow: some View {
        VStack(spacing: AppTheme.Spacing.sm) {
            Text("Consistency Matrix")
                .font(AppTheme.Typography.headingMedium)
                .foregroundColor(AppTheme.TextColor.primary)
                .fillMaxWidth(alignment: .leading)
                .padding(.horizontal, AppTheme.Spacing.lg)

            HStack(spacing: AppTheme.Spacing.md) {
                Text("Less")
                    .font(AppTheme.Typography.bodySmall)
                    .foregroundColor(AppTheme.TextColor.secondary)

                HStack(spacing: 2) {
                    ForEach([0.0, 0.25, 0.5, 0.75, 1.0], id: \.self) { ratio in
                        RoundedRectangle(cornerRadius: AppTheme.Matrix.cornerRadius)
                            .fill(AppTheme.AccentColor.mint.opacity(AppTheme.Matrix.opacityForRatio(ratio)))
                            .frame(width: 10, height: 10)
                    }
                }

                Text("More")
                    .font(AppTheme.Typography.bodySmall)
                    .foregroundColor(AppTheme.TextColor.secondary)

                Spacer()
            }
            .padding(.horizontal, AppTheme.Spacing.lg)
        }
    }

    private func matrixWeekView(_ week: MatrixWeek, id: UUID) -> some View {
        VStack(spacing: AppTheme.Spacing.xs) {
            if let monthLabel = week.monthLabel {
                Text(monthLabel)
                    .font(AppTheme.Typography.labelSmall)
                    .foregroundColor(AppTheme.TextColor.secondary)
                    .frame(height: 16)
            } else {
                Color.clear.frame(height: 16)
            }

            VStack(spacing: AppTheme.Spacing.sm) {
                ForEach(["M", "W", "F", "S"], id: \.self) { day in
                    Text(day)
                        .font(AppTheme.Typography.labelSmall)
                        .foregroundColor(AppTheme.TextColor.tertiary)
                        .frame(width: 12, height: 12)
                }
            }
            .frame(width: 12)

            HStack(spacing: AppTheme.Spacing.sm) {
                VStack(spacing: AppTheme.Spacing.xs) {
                    ForEach(0..<7, id: \.self) { dayIndex in
                        if dayIndex < week.days.count {
                            MatrixTileView(day: week.days[dayIndex], isSelected: selectedDay?.date == week.days[dayIndex].date)
                                .onTapGesture {
                                    withAnimation(AppTheme.Animation.springSnappy) {
                                        selectedDay = week.days[dayIndex]
                                    }
                                }
                        }
                    }
                }
            }
        }
    }

    private func selectedDayBanner(_ day: MatrixDay) -> some View {
        VStack(spacing: AppTheme.Spacing.sm) {
            HStack {
                VStack(alignment: .leading, spacing: AppTheme.Spacing.xs) {
                    Text(day.date.formattedFullDate())
                        .font(AppTheme.Typography.bodyLarge)
                        .foregroundColor(AppTheme.TextColor.primary)

                    Text("\(day.completedCount)/\(day.totalHabits) completed")
                        .font(AppTheme.Typography.bodyMedium)
                        .foregroundColor(AppTheme.TextColor.secondary)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: AppTheme.Spacing.xs) {
                    Text("\(Int(day.completionRatio * 100))%")
                        .font(AppTheme.Typography.numeric)
                        .foregroundColor(AppTheme.AccentColor.mint)

                    Text("Complete")
                        .font(AppTheme.Typography.bodySmall)
                        .foregroundColor(AppTheme.TextColor.secondary)
                }
            }
            .padding(AppTheme.Spacing.md)
            .background(AppTheme.BackgroundColor.card)
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 4)
        }
        .padding(.horizontal, AppTheme.Spacing.lg)
        .transition(.opacity.combined(with: .move(edge: .bottom)))
    }
}

#Preview {
    let habit1 = Habit(name: "Exercise", emoji: "💪")
    let habit2 = Habit(name: "Read", emoji: "📚")

    ConsistencyMatrixView(habits: [habit1, habit2])
        .padding()
        .background(AppTheme.BackgroundColor.primary)
}
