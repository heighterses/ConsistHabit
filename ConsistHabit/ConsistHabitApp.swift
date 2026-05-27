import SwiftUI
import SwiftData
import Foundation

@main
struct ConsistHabitApp: App {
    let modelContainer: ModelContainer

    var body: some Scene {
        WindowGroup {
            AppRootView()
        }
        .modelContainer(modelContainer)
    }

    init() {
        let schema = Schema([UserSession.self, Habit.self, DailyLog.self, Achievement.self])

        do {
            let appSupportURL = try FileManager.default.url(
                for: .applicationSupportDirectory,
                in: .userDomainMask,
                appropriateFor: nil,
                create: true
            )

            let storeURL = appSupportURL.appending(path: "ConsistHabit.store")
            let directoryURL = storeURL.deletingLastPathComponent()

            try FileManager.default.createDirectory(
                at: directoryURL,
                withIntermediateDirectories: true,
                attributes: nil
            )

            let modelConfiguration = ModelConfiguration(
                "ConsistHabit",
                schema: schema,
                isStoredInMemoryOnly: false
            )

            modelContainer = try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            print("⚠️ Failed to initialize persistent ModelContainer: \(error)")
            print("💾 Falling back to in-memory storage")

            let schema = Schema([UserSession.self, Habit.self, DailyLog.self, Achievement.self])
            let fallbackConfiguration = ModelConfiguration(
                schema: schema,
                isStoredInMemoryOnly: true
            )

            do {
                modelContainer = try ModelContainer(for: schema, configurations: [fallbackConfiguration])
            } catch {
                fatalError("❌ Could not initialize ModelContainer even with in-memory fallback: \(error)")
            }
        }
    }
}
