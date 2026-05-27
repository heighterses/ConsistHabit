import SwiftData
import Foundation

@Model
final class DailyLog {
    @Attribute(.unique) var id: UUID
    var date: Date
    var completedAt: Date
    var note: String?

    @Relationship(deleteRule: .cascade) var habit: Habit?

    init(
        id: UUID = UUID(),
        date: Date,
        completedAt: Date = Date(),
        note: String? = nil
    ) {
        self.id = id
        let calendar = Calendar.current
        self.date = calendar.startOfDay(for: date)
        self.completedAt = completedAt
        self.note = note
    }
}
