import SwiftUI
import SwiftData

struct ProfileView: View {
    @Environment(HabitStore.self) var store
    @Environment(\.dismiss) var dismiss
    @State private var showPremiumSheet = false

    var body: some View {
        ZStack {
            AppTheme.BackgroundColor.primary.ignoresSafeArea()

            if let session = store.userSession {
                ScrollView {
                    VStack(spacing: AppTheme.Spacing.lg) {
                        profileHeaderSection(session)

                        achievementSection(session)

                        streakProgressSection(session)

                        statsSection(session)

                        archivedHabitsSection(session)

                        subscriptionSection(session)

                        signOutButton
                    }
                    .padding(AppTheme.Spacing.lg)
                }
            }
        }
        .navigationTitle("Profile")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func profileHeaderSection(_ session: UserSession) -> some View {
        VStack(spacing: AppTheme.Spacing.md) {
            UserAvatarView(session: session, size: 100)

            VStack(spacing: AppTheme.Spacing.xs) {
                Text(session.displayName)
                    .font(AppTheme.Typography.displayMedium)
                    .foregroundColor(AppTheme.TextColor.primary)

                Text("Member since \(session.createdAt.formattedMonthDay())")
                    .font(AppTheme.Typography.bodyMedium)
                    .foregroundColor(AppTheme.TextColor.secondary)
            }
        }
        .fillMaxWidth()
        .padding(AppTheme.Spacing.lg)
        .background(AppTheme.BackgroundColor.elevated)
        .cornerRadius(AppTheme.Radius.lg)
    }

    private func achievementSection(_ session: UserSession) -> some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
            Text("Achievements")
                .font(AppTheme.Typography.headingMedium)
                .foregroundColor(AppTheme.TextColor.primary)

            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: AppTheme.Spacing.md) {
                ForEach(AchievementType.allCases, id: \.self) { type in
                    let isUnlocked = session.achievements.contains { $0.type == type }
                    VStack(spacing: AppTheme.Spacing.xs) {
                        Text(type.icon)
                            .font(.system(size: 24))
                            .frame(height: 40)
                            .opacity(isUnlocked ? 1.0 : 0.3)

                        Text(type.title)
                            .font(AppTheme.Typography.labelSmall)
                            .foregroundColor(isUnlocked ? AppTheme.TextColor.primary : AppTheme.TextColor.tertiary)
                            .lineLimit(2)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(AppTheme.Spacing.sm)
                    .background(isUnlocked ? AppTheme.BackgroundColor.elevated : AppTheme.BackgroundColor.elevated.opacity(0.5))
                    .cornerRadius(AppTheme.Radius.md)
                }
            }
        }
        .padding(AppTheme.Spacing.lg)
        .background(AppTheme.BackgroundColor.elevated)
        .cornerRadius(AppTheme.Radius.lg)
    }

    private func streakProgressSection(_ session: UserSession) -> some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
            Text("Streak Rewards")
                .font(AppTheme.Typography.headingMedium)
                .foregroundColor(AppTheme.TextColor.primary)

            VStack(spacing: AppTheme.Spacing.md) {
                streakProgressRow(
                    icon: "🔥",
                    milestone: "14-day Streak",
                    earned: session.streakRewardSlots >= 1,
                    progress: min(Double(session.currentStreak) / 14.0, 1.0)
                )

                streakProgressRow(
                    icon: "👑",
                    milestone: "30-day Streak",
                    earned: session.streakRewardSlots >= 2,
                    progress: min(Double(session.currentStreak) / 30.0, 1.0)
                )
            }

            Text("Current Streak: \(session.currentStreak) days")
                .font(AppTheme.Typography.bodyMedium)
                .foregroundColor(AppTheme.AccentColor.coral)
                .padding(AppTheme.Spacing.md)
                .background(AppTheme.AccentColor.coral.opacity(0.1))
                .cornerRadius(AppTheme.Radius.lg)
                .fillMaxWidth()
        }
        .padding(AppTheme.Spacing.lg)
        .background(AppTheme.BackgroundColor.elevated)
        .cornerRadius(AppTheme.Radius.lg)
    }

    private func streakProgressRow(icon: String, milestone: String, earned: Bool, progress: Double) -> some View {
        HStack(spacing: AppTheme.Spacing.md) {
            Text(icon).font(.system(size: 20))

            VStack(alignment: .leading, spacing: AppTheme.Spacing.xs) {
                Text(milestone)
                    .font(AppTheme.Typography.bodyMedium)
                    .foregroundColor(AppTheme.TextColor.primary)
                ProgressView(value: progress)
                    .tint(AppTheme.AccentColor.mint)
            }

            Spacer()

            if earned {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(AppTheme.AccentColor.mint)
            }
        }
    }

    private func statsSection(_ session: UserSession) -> some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
            Text("Statistics")
                .font(AppTheme.Typography.headingMedium)
                .foregroundColor(AppTheme.TextColor.primary)

            VStack(spacing: AppTheme.Spacing.sm) {
                statRow(label: "Total Habits Completed", value: "\(session.activeHabits.reduce(0) { $0 + $1.totalCompletions })")
                Divider()
                statRow(label: "Days Tracked", value: "\(session.totalDaysTracked)")
                Divider()
                statRow(label: "Active Habits", value: "\(session.activeHabits.count)")
            }
            .padding(AppTheme.Spacing.md)
            .background(AppTheme.BackgroundColor.card)
            .cornerRadius(AppTheme.Radius.lg)
        }
        .padding(AppTheme.Spacing.lg)
        .background(AppTheme.BackgroundColor.elevated)
        .cornerRadius(AppTheme.Radius.lg)
    }

    private func statRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .font(AppTheme.Typography.bodyMedium)
                .foregroundColor(AppTheme.TextColor.secondary)

            Spacer()

            Text(value)
                .font(AppTheme.Typography.numeric)
                .foregroundColor(AppTheme.AccentColor.mint)
        }
    }

    private func archivedHabitsSection(_ session: UserSession) -> some View {
        let archivedHabits = session.habits.filter { $0.isArchived }

        return Group {
            if !archivedHabits.isEmpty {
                VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
                    Text("Archived Habits")
                        .font(AppTheme.Typography.headingMedium)
                        .foregroundColor(AppTheme.TextColor.primary)

                    VStack(spacing: AppTheme.Spacing.sm) {
                        ForEach(archivedHabits, id: \.id) { habit in
                            HStack {
                                Text("\(habit.emoji) \(habit.name)")
                                    .font(AppTheme.Typography.bodyMedium)
                                    .foregroundColor(AppTheme.TextColor.secondary)

                                Spacer()

                                Button {
                                    store.restoreHabit(habit)
                                } label: {
                                    Text("Restore")
                                        .font(AppTheme.Typography.bodySmall)
                                        .foregroundColor(AppTheme.AccentColor.mint)
                                }
                            }
                            .padding(AppTheme.Spacing.md)
                            .background(AppTheme.BackgroundColor.card)
                            .cornerRadius(AppTheme.Radius.lg)
                        }
                    }
                }
                .padding(AppTheme.Spacing.lg)
                .background(AppTheme.BackgroundColor.elevated)
                .cornerRadius(AppTheme.Radius.lg)
            }
        }
    }

    private func subscriptionSection(_ session: UserSession) -> some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
            Text("Subscription")
                .font(AppTheme.Typography.headingMedium)
                .foregroundColor(AppTheme.TextColor.primary)

            if session.isPremium {
                HStack {
                    VStack(alignment: .leading, spacing: AppTheme.Spacing.xs) {
                        Text("Premium Active")
                            .font(AppTheme.Typography.bodyMedium)
                            .foregroundColor(AppTheme.TextColor.primary)

                        Text("Thank you for supporting the app!")
                            .font(AppTheme.Typography.bodySmall)
                            .foregroundColor(AppTheme.TextColor.secondary)
                    }

                    Spacer()

                    Text("⭐")
                        .font(.system(size: 24))
                }
                .padding(AppTheme.Spacing.md)
                .background(AppTheme.BackgroundColor.card)
                .cornerRadius(AppTheme.Radius.lg)
            } else {
                VStack(spacing: AppTheme.Spacing.md) {
                    HStack {
                        VStack(alignment: .leading, spacing: AppTheme.Spacing.xs) {
                            Text("Free Tier")
                                .font(AppTheme.Typography.bodyMedium)
                                .foregroundColor(AppTheme.TextColor.primary)

                            Text("\(session.activeHabits.count)/\(session.totalFreeSlots) habit slots used")
                                .font(AppTheme.Typography.bodySmall)
                                .foregroundColor(AppTheme.TextColor.secondary)
                        }

                        Spacer()
                    }

                    Button {
                        showPremiumSheet = true
                    } label: {
                        Text("Upgrade to Premium")
                            .font(AppTheme.Typography.bodyMedium)
                            .foregroundColor(.black)
                            .fillMaxWidth()
                            .frame(height: 44)
                            .background(AppTheme.AccentColor.gold)
                            .cornerRadius(AppTheme.Radius.lg)
                    }
                }
                .padding(AppTheme.Spacing.md)
                .background(AppTheme.BackgroundColor.card)
                .cornerRadius(AppTheme.Radius.lg)
            }
        }
        .padding(AppTheme.Spacing.lg)
        .background(AppTheme.BackgroundColor.elevated)
        .cornerRadius(AppTheme.Radius.lg)
        .sheet(isPresented: $showPremiumSheet) {
            PremiumUpgradeSheet(isPresented: $showPremiumSheet)
                .environment(store)
        }
    }

    private var signOutButton: some View {
        Button {
            store.signOut()
            dismiss()
        } label: {
            Text("Sign Out")
                .font(AppTheme.Typography.bodyLarge)
                .foregroundColor(AppTheme.AccentColor.coral)
                .fillMaxWidth()
                .frame(height: 48)
                .background(AppTheme.AccentColor.coral.opacity(0.1))
                .cornerRadius(AppTheme.Radius.lg)
        }
    }
}

#Preview {
    NavigationStack {
        ProfileView()
    }
    .modelContainer(for: UserSession.self, inMemory: true)
}
