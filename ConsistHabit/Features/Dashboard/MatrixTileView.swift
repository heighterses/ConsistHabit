import SwiftUI

struct MatrixTileView: View {
    let day: MatrixDay
    let isSelected: Bool

    var body: some View {
        RoundedRectangle(cornerRadius: AppTheme.Matrix.cornerRadius)
            .fill(
                day.completionRatio == 0 && !day.isFuture
                    ? AppTheme.Matrix.emptyTileColor
                    : AppTheme.AccentColor.mint.opacity(
                        day.isFuture ? 0.45 : AppTheme.Matrix.opacityForRatio(day.completionRatio)
                    )
            )
            .frame(width: AppTheme.Matrix.tileSize, height: AppTheme.Matrix.tileSize)
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.Matrix.cornerRadius)
                    .stroke(
                        day.isToday ? AppTheme.AccentColor.gold : .clear,
                        lineWidth: 1.5
                    )
            )
            .scaleEffect(isSelected ? 1.28 : 1.0)
            .animation(AppTheme.Animation.matrixTransition, value: isSelected)
            .accessibility(label: Text(accessibilityLabel))
    }

    private var accessibilityLabel: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE MMMM d"
        let dateStr = formatter.string(from: day.date)

        return "\(dateStr), \(day.completedCount) of \(day.totalHabits) habits completed"
    }
}

#Preview {
    VStack(spacing: 8) {
        MatrixTileView(day: MatrixDay(date: Date(), completionRatio: 0, completedCount: 0, totalHabits: 5, isToday: false, isFuture: false), isSelected: false)
        MatrixTileView(day: MatrixDay(date: Date(), completionRatio: 0.5, completedCount: 2, totalHabits: 5, isToday: false, isFuture: false), isSelected: false)
        MatrixTileView(day: MatrixDay(date: Date(), completionRatio: 1.0, completedCount: 5, totalHabits: 5, isToday: true, isFuture: false), isSelected: false)
        MatrixTileView(day: MatrixDay(date: Date(), completionRatio: 0, completedCount: 0, totalHabits: 5, isToday: false, isFuture: true), isSelected: false)
    }
    .padding()
    .background(AppTheme.BackgroundColor.primary)
}
