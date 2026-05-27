import SwiftUI
import SwiftData

struct OnboardingView: View {
    @Environment(HabitStore.self) var store
    @State private var username = ""
    @State private var selectedEmojiAvatar = "🎯"
    @State private var selectedPhotoData: Data?
    @State private var usernameError: String?
    @State private var isCreating = false

    var usernameIsValid: Bool {
        let trimmed = username.trimmingCharacters(in: .whitespaces)
        return trimmed.count >= 2 && trimmed.count <= 50
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                ScrollView {
                    VStack(spacing: AppTheme.Spacing.xl) {
                        VStack(spacing: AppTheme.Spacing.md) {
                            Text("ConsistHabit")
                                .font(AppTheme.Typography.displayLarge)
                                .foregroundColor(AppTheme.AccentColor.mint)
                                .transition(.opacity.combined(with: .scale))

                            Text("Build habits. Track consistency.")
                                .font(AppTheme.Typography.bodyMedium)
                                .foregroundColor(AppTheme.TextColor.secondary)
                        }
                        .padding(.vertical, AppTheme.Spacing.xxxl)

                        VStack(spacing: AppTheme.Spacing.lg) {
                            VStack(spacing: AppTheme.Spacing.sm) {
                                Text("Your Name")
                                    .font(AppTheme.Typography.headingMedium)
                                    .foregroundColor(AppTheme.TextColor.primary)
                                    .fillMaxWidth(alignment: .leading)

                                TextField("Enter your name", text: $username)
                                    .font(AppTheme.Typography.bodyMedium)
                                    .padding(AppTheme.Spacing.md)
                                    .background(AppTheme.BackgroundColor.elevated)
                                    .cornerRadius(AppTheme.Radius.lg)
                                    .foregroundColor(AppTheme.TextColor.primary)
                                    .onChange(of: username) { _, _ in
                                        usernameError = nil
                                    }

                                if let error = usernameError {
                                    Text(error)
                                        .font(AppTheme.Typography.bodySmall)
                                        .foregroundColor(AppTheme.AccentColor.coral)
                                        .fillMaxWidth(alignment: .leading)
                                        .transition(.opacity)
                                }
                            }

                            AvatarPickerView(
                                selectedEmojiAvatar: $selectedEmojiAvatar,
                                selectedPhotoData: $selectedPhotoData
                            )
                        }
                        .padding(.vertical, AppTheme.Spacing.lg)
                    }
                    .padding(AppTheme.Spacing.lg)
                }

                Button {
                    validateAndCreateSession()
                } label: {
                    if isCreating {
                        ProgressView()
                            .tint(.white)
                    } else {
                        Text("Get Started")
                            .font(AppTheme.Typography.headingMedium)
                    }
                }
                .fillMaxWidth()
                .frame(height: 56)
                .background(AppTheme.AccentColor.mint)
                .foregroundColor(.black)
                .cornerRadius(AppTheme.Radius.lg)
                .disabled(!usernameIsValid || isCreating)
                .opacity(usernameIsValid && !isCreating ? 1.0 : 0.5)
                .padding(AppTheme.Spacing.lg)
            }
            .background(AppTheme.BackgroundColor.primary)
        }
    }

    private func validateAndCreateSession() {
        let trimmed = username.trimmingCharacters(in: .whitespaces)

        guard trimmed.count >= 2 else {
            usernameError = "Name must be at least 2 characters"
            HapticManager.shared.trigger(.errorOccurred)
            return
        }

        guard trimmed.count <= 50 else {
            usernameError = "Name must be 50 characters or less"
            HapticManager.shared.trigger(.errorOccurred)
            return
        }

        isCreating = true
        store.createSession(
            username: trimmed,
            avatarIdentifier: selectedEmojiAvatar,
            avatarImageData: selectedPhotoData
        )
        HapticManager.shared.trigger(.onboardingComplete)
    }
}

#Preview {
    OnboardingView()
        .background(AppTheme.BackgroundColor.primary)
        .modelContainer(for: UserSession.self, inMemory: true)
}
