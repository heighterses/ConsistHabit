import SwiftUI
import SwiftData

struct AppRootView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var store: HabitStore?
    @State private var notificationDelegate = AppNotificationDelegate()

    var body: some View {
        ZStack {
            if let store = store {
                if let session = store.userSession {
                    DashboardView()
                        .environment(store)
                } else {
                    OnboardingView()
                        .environment(store)
                }

                if let achievement = store.celebrationAchievement {
                    AchievementCelebrationView(achievement: achievement)
                        .environment(store)
                        .transition(.opacity)
                }

                if let message = store.toastMessage {
                    ToastView(message: message)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                        .padding()
                }
            } else {
                ProgressView()
            }
        }
        .onAppear {
            if store == nil {
                store = HabitStore(modelContext: modelContext)

                Task {
                    let authorized = await NotificationManager.shared.requestNotificationPermission()
                    if authorized {
                        NotificationManager.shared.setNotificationDelegate(notificationDelegate)
                    }
                }
            }
        }
    }
}

private class AppNotificationDelegate: NSObject, UNUserNotificationCenterDelegate {
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.banner, .sound, .badge])
    }
}

#Preview {
    AppRootView()
        .modelContainer(for: UserSession.self, inMemory: true)
}
