import WidgetKit
import SwiftUI
import SwiftData

struct ConsistHabitWidgetEntryView: View {
    var entry: SimpleEntry

    var body: some View {
        ZStack {
            Color(red: 0.06, green: 0.06, blue: 0.07)
                .ignoresSafeArea()

            VStack(spacing: 12) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Today")
                            .font(.caption)
                            .foregroundColor(.gray)

                        Text("ConsistHabit")
                            .font(.headline)
                            .foregroundColor(.white)
                    }

                    Spacer()

                    ZStack {
                        Circle()
                            .stroke(Color.gray.opacity(0.3), lineWidth: 3)

                        Circle()
                            .trim(from: 0, to: entry.completionRatio)
                            .stroke(Color(red: 0.20, green: 0.84, blue: 0.82), style: StrokeStyle(lineWidth: 3, lineCap: .round))
                            .rotationEffect(.degrees(-90))

                        VStack(spacing: 0) {
                            Text(entry.completedCount.description)
                                .font(.system(size: 16, weight: .black, design: .rounded))
                                .foregroundColor(Color(red: 0.20, green: 0.84, blue: 0.82))

                            Text("of \(entry.totalHabits)")
                                .font(.caption2)
                                .foregroundColor(.gray)
                        }
                    }
                    .frame(width: 60, height: 60)
                }

                Divider()
                    .background(Color.gray.opacity(0.3))

                HStack(spacing: 8) {
                    HStack(spacing: 4) {
                        Image(systemName: "flame.fill")
                            .font(.system(size: 12))
                            .foregroundColor(Color(red: 0.91, green: 0.48, blue: 0.45))

                        Text("\(entry.streak)")
                            .font(.system(size: 14, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                    }
                    .padding(.vertical, 6)
                    .padding(.horizontal, 10)
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(8)

                    HStack(spacing: 4) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 12))
                            .foregroundColor(Color(red: 0.20, green: 0.84, blue: 0.82))

                        Text("\(entry.completedCount)")
                            .font(.system(size: 14, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                    }
                    .padding(.vertical, 6)
                    .padding(.horizontal, 10)
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(8)

                    Spacer()
                }
            }
            .padding(16)
        }
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let completionRatio: Double
    let completedCount: Int
    let totalHabits: Int
    let streak: Int
}

struct ConsistHabitWidgetProvider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(
            date: Date(),
            completionRatio: 0.75,
            completedCount: 3,
            totalHabits: 4,
            streak: 14
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> Void) {
        let entry = SimpleEntry(
            date: Date(),
            completionRatio: 0.5,
            completedCount: 2,
            totalHabits: 4,
            streak: 7
        )
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<SimpleEntry>) -> Void) {
        var entries: [SimpleEntry] = []

        let baseEntry = SimpleEntry(
            date: Date(),
            completionRatio: 0.5,
            completedCount: 2,
            totalHabits: 4,
            streak: 7
        )

        entries.append(baseEntry)

        let nextUpdate = Calendar.current.date(byAdding: .minute, value: 15, to: Date()) ?? Date()
        let timeline = Timeline(entries: entries, policy: .after(nextUpdate))
        completion(timeline)
    }
}

@main
struct ConsistHabitWidget: Widget {
    let kind: String = "ConsistHabitWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: ConsistHabitWidgetProvider()) { entry in
            ConsistHabitWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Today's Habits")
        .description("See your daily habit progress at a glance.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

#Preview(as: .systemSmall) {
    ConsistHabitWidget()
} timeline: {
    SimpleEntry(date: .now, completionRatio: 0.75, completedCount: 3, totalHabits: 4, streak: 14)
    SimpleEntry(date: .now, completionRatio: 1.0, completedCount: 4, totalHabits: 4, streak: 15)
}
