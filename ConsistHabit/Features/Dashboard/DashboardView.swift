import SwiftUI
import SwiftData
import PhotosUI

struct DashboardView: View {
    @Environment(HabitStore.self) var store
    @Environment(\.modelContext) var modelContext
    @State private var showAddHabitSheet = false
    @State private var showPremiumSheet = false
    @State private var selectedMatrixDay: MatrixDay?

    @Query private var habits: [Habit]

    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.BackgroundColor.primary.ignoresSafeArea()

                if let session = store.userSession {
                    VStack(spacing: 0) {
                        headerSection(session)

                        statsRow(session)
                            .padding(.horizontal, AppTheme.Spacing.lg)
                            .padding(.vertical, AppTheme.Spacing.md)

                        if !session.activeHabits.isEmpty {
                            ConsistencyMatrixView(habits: session.activeHabits)
                                .padding(AppTheme.Spacing.lg)
                        }

                        HabitListView(habits: session.activeHabits)

                        Spacer()

                        if session.activeHabits.count >= session.totalFreeSlots && !session.isPremium {
                            capacityBanner(session)
                                .padding(AppTheme.Spacing.lg)
                        }
                    }

                    VStack {
                        Spacer()
                        HStack {
                            Spacer()
                            addHabitButton
                                .padding(AppTheme.Spacing.lg)
                        }
                    }
                }
            }
            .sheet(isPresented: $showAddHabitSheet) {
                if store.userSession?.canAddHabit == false {
                    PremiumUpgradeSheet(isPresented: $showPremiumSheet)
                } else {
                    AddHabitSheet(isPresented: $showAddHabitSheet)
                        .environment(store)
                }
            }
            .sheet(isPresented: $showPremiumSheet) {
                PremiumUpgradeSheet(isPresented: $showPremiumSheet)
                    .environment(store)
            }
            .navigationDestination(for: UUID.self) { sessionId in
                if let session = store.userSession, session.id == sessionId {
                    ProfileView()
                        .environment(store)
                }
            }
        }
    }

    private func headerSection(_ session: UserSession) -> some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
            HStack {
                VStack(alignment: .leading, spacing: AppTheme.Spacing.xs) {
                    Text(timeBasedGreeting())
                        .font(AppTheme.Typography.bodyMedium)
                        .foregroundColor(AppTheme.TextColor.secondary)

                    Text(session.displayName)
                        .font(AppTheme.Typography.displayMedium)
                        .foregroundColor(AppTheme.TextColor.primary)
                        .lineLimit(1)
                }

                Spacer()

                NavigationLink(value: session.id) {
                    UserAvatarView(session: session, size: 56)
                }
            }
            .padding(AppTheme.Spacing.lg)
        }
        .background(AppTheme.BackgroundColor.elevated)
    }

    private func statsRow(_ session: UserSession) -> some View {
        HStack(spacing: AppTheme.Spacing.md) {
            StatBadgeView(
                icon: "🔥",
                value: "\(session.currentStreak)",
                label: "Streak",
                accentColor: session.currentStreak > 0 ? AppTheme.AccentColor.coral : AppTheme.TextColor.tertiary
            )

            StatBadgeView(
                icon: "📋",
                value: "\(session.activeHabits.count)",
                label: "Habits",
                accentColor: AppTheme.AccentColor.mint
            )

            let completedToday = session.activeHabits.filter { $0.isCompletedToday }.count
            StatBadgeView(
                icon: "✓",
                value: "\(completedToday)/\(session.activeHabits.count)",
                label: "Today",
                accentColor: AppTheme.AccentColor.gold
            )
        }
    }

    private func capacityBanner(_ session: UserSession) -> some View {
        VStack(spacing: AppTheme.Spacing.sm) {
            HStack {
                VStack(alignment: .leading, spacing: AppTheme.Spacing.xs) {
                    Text("Free Tier Limit Reached")
                        .font(AppTheme.Typography.headingMedium)
                        .foregroundColor(.black)

                    Text("\(session.activeHabits.count)/\(session.totalFreeSlots) habit slots used")
                        .font(AppTheme.Typography.bodySmall)
                        .foregroundColor(Color.black.opacity(0.7))
                }

                Spacer()

                Button {
                    showPremiumSheet = true
                } label: {
                    Text("Upgrade")
                        .font(AppTheme.Typography.bodyMedium)
                        .foregroundColor(AppTheme.AccentColor.gold)
                }
            }
            .padding(AppTheme.Spacing.md)
            .background(AppTheme.AccentColor.gold.opacity(0.2))
            .cornerRadius(AppTheme.Radius.lg)
        }
    }

    private var addHabitButton: some View {
        Button {
            if store.userSession?.canAddHabit == false {
                showPremiumSheet = true
            } else {
                showAddHabitSheet = true
            }
        } label: {
            HStack(spacing: AppTheme.Spacing.sm) {
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 18, weight: .semibold))
                Text("New Habit")
                    .font(AppTheme.Typography.bodyLarge)
            }
            .foregroundColor(.white)
            .padding(.vertical, AppTheme.Spacing.md)
            .padding(.horizontal, AppTheme.Spacing.lg)
            .background(AppTheme.AccentColor.mint)
            .cornerRadius(AppTheme.Radius.full)
            .shadow(color: AppTheme.AccentColor.mint.opacity(0.4), radius: 12, x: 0, y: 6)
        }
    }

    private func timeBasedGreeting() -> String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12:
            return "Good Morning"
        case 12..<17:
            return "Good Afternoon"
        case 17..<21:
            return "Good Evening"
        default:
            return "Good Night"
        }
    }
}

#Preview {
    DashboardView()
        .modelContainer(for: UserSession.self, inMemory: true)
}
