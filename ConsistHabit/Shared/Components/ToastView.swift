import SwiftUI

struct ToastView: View {
    let message: String
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        VStack {
            Spacer()

            HStack(spacing: AppTheme.Spacing.md) {
                Image(systemName: "exclamationmark.circle.fill")
                    .font(.system(size: 18))
                    .foregroundColor(AppTheme.AccentColor.coral)

                Text(message)
                    .font(AppTheme.Typography.bodyMedium)
                    .foregroundColor(AppTheme.TextColor.primary)
                    .lineLimit(2)

                Spacer()
            }
            .padding(AppTheme.Spacing.md)
            .background(AppTheme.BackgroundColor.elevated)
            .cornerRadius(AppTheme.Radius.lg)
            .applyThemeShadow()
            .padding(AppTheme.Spacing.md)
        }
        .fillMaxWidth()
    }
}

#Preview {
    ZStack {
        AppTheme.BackgroundColor.primary.ignoresSafeArea()

        ToastView(message: "Failed to add habit. Please try again.")
    }
}
