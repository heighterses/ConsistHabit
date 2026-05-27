import CloudKit
import Foundation

@MainActor
final class CloudKitManager {
    static let shared = CloudKitManager()

    private let container = CKContainer.default()
    private let database: CKDatabase

    private(set) var syncStatus: SyncStatus = .notStarted
    var isCloudKitAvailable = false

    enum SyncStatus {
        case notStarted
        case syncing
        case synced
        case error(String)
    }

    private init() {
        database = container.privateCloudDatabase
        checkCloudKitAvailability()
    }

    private func checkCloudKitAvailability() {
        container.accountStatus { status, error in
            DispatchQueue.main.async {
                self.isCloudKitAvailable = (status == .available)
            }
        }
    }

    func enableCloudKitSync(for userSession: UserSession) {
        guard isCloudKitAvailable else {
            syncStatus = .error("CloudKit is not available")
            return
        }

        syncStatus = .syncing

        let record = CKRecord(recordType: "UserSession")
        record["username"] = userSession.displayName
        record["isPremium"] = userSession.isPremium
        record["streakRewardSlots"] = userSession.streakRewardSlots
        record["lastActiveAt"] = userSession.lastActiveAt

        database.save(record) { record, error in
            DispatchQueue.main.async {
                if let error = error {
                    self.syncStatus = .error(error.localizedDescription)
                } else {
                    self.syncStatus = .synced
                }
            }
        }
    }

    func syncHabit(_ habit: Habit) {
        guard isCloudKitAvailable else { return }

        let record = CKRecord(recordType: "Habit")
        record["name"] = habit.name
        record["emoji"] = habit.emoji
        record["colorHex"] = habit.colorHex
        record["reminderTime"] = habit.reminderTime
        record["reminderEnabled"] = habit.reminderEnabled
        record["isArchived"] = habit.isArchived

        database.save(record) { _, error in
            if let error = error {
                print("Sync error: \(error.localizedDescription)")
            }
        }
    }

    func syncDailyLog(_ log: DailyLog) {
        guard isCloudKitAvailable else { return }

        let record = CKRecord(recordType: "DailyLog")
        record["date"] = log.date
        record["completedAt"] = log.completedAt

        database.save(record) { _, error in
            if let error = error {
                print("Sync error: \(error.localizedDescription)")
            }
        }
    }

    func fetchRemoteData(completion: @escaping ([CKRecord]?) -> Void) {
        guard isCloudKitAvailable else {
            completion(nil)
            return
        }

        let query = CKQuery(recordType: "UserSession", predicate: NSPredicate(value: true))
        database.perform(query, inZoneWith: nil) { records, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("Fetch error: \(error.localizedDescription)")
                    completion(nil)
                } else {
                    completion(records)
                }
            }
        }
    }

    func disableCloudKitSync() {
        syncStatus = .notStarted
        print("CloudKit sync disabled")
    }
}
