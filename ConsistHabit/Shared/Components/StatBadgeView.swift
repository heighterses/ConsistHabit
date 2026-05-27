import SwiftUI

struct StatBadgeView: View {
    let icon: String
    let value: String
    let label: String
    let accentColor: Color

    var body: some View {
        VStack(spacing: AppTheme.Spacing.xs) {
            HStack(spacing: AppTheme.Spacing.sm) {
                Text(icon)
                    .font(.system(size: 18))

                Text(value)
                    .font(AppTheme.Typography.numeric)
                    .contentTransition(.numericText())
                    .lineLimit(1)
            }
            .foregroundColor(accentColor)

            Text(label)
                .font(AppTheme.Typography.bodySmall)
                .foregroundColor(AppTheme.TextColor.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(AppTheme.Spacing.md)
        .background(AppTheme.BackgroundColor.elevated)
        .cornerRadius(AppTheme.Radius.lg)
    }
}

#Preview {
    HStack(spacing: AppTheme.Spacing.md) {
        StatBadgeView(icon: "🔥", value: "14", label: "Current Streak", accentColor: AppTheme.AccentColor.coral)
        StatBadgeView(icon: "📋", value: "5", label: "Habits", accentColor: AppTheme.AccentColor.mint)
        StatBadgeView(icon: "✓", value: "4/5", label: "Today", accentColor: AppTheme.AccentColor.gold)
    }
    .padding()
    .background(AppTheme.BackgroundColor.primary)
}
