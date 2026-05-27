import Foundation

struct MatrixDay {
    let date: Date
    let completionRatio: Double
    let completedCount: Int
    let totalHabits: Int
    let isToday: Bool
    let isFuture: Bool

    var percentageText: String {
        return "\(completedCount)/\(totalHabits)"
    }
}

struct MatrixWeek {
    let mondayDate: Date
    let days: [MatrixDay]
    let monthLabel: String?
}

final class MatrixCalculator {
    static func calculateMatrix(habits: [Habit], weekCount: Int = 26) -> [MatrixWeek] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let activeHabits = habits.filter { !$0.isArchived }

        var weeks: [MatrixWeek] = []
        let endDate = today
        let startDate = calendar.date(byAdding: .day, value: -(weekCount * 7), to: endDate) ?? endDate

        var currentDate = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: startDate))!
        let mondayOfStart = calendar.date(byAdding: .day, value: -calendar.component(.weekday, from: currentDate) + 2, to: currentDate)!

        var currentMonday = mondayOfStart
        while currentMonday <= endDate {
            let weekDays = generateWeekDays(
                startDate: currentMonday,
                activeHabits: activeHabits,
                today: today
            )

            let monthLabel = getMonthLabelForWeek(currentMonday, calendar: calendar)
            let week = MatrixWeek(mondayDate: currentMonday, days: weekDays, monthLabel: monthLabel)
            weeks.append(week)

            guard let nextMonday = calendar.date(byAdding: .day, value: 7, to: currentMonday) else {
                break
            }
            currentMonday = nextMonday
        }

        return weeks
    }

    private static func generateWeekDays(
        startDate: Date,
        activeHabits: [Habit],
        today: Date
    ) -> [MatrixDay] {
        let calendar = Calendar.current
        var days: [MatrixDay] = []

        for dayOffset in 0..<7 {
            let date = calendar.date(byAdding: .day, value: dayOffset, to: startDate) ?? startDate
            let isToday = calendar.startOfDay(for: date) == today
            let isFuture = date > today

            let (completedCount, totalHabits) = countCompletions(for: date, habits: activeHabits)
            let completionRatio = totalHabits > 0 ? Double(completedCount) / Double(totalHabits) : 0.0

            let matrixDay = MatrixDay(
                date: date,
                completionRatio: isFuture ? 0.0 : completionRatio,
                completedCount: isFuture ? 0 : completedCount,
                totalHabits: totalHabits,
                isToday: isToday,
                isFuture: isFuture
            )

            days.append(matrixDay)
        }

        return days
    }

    private static func countCompletions(for date: Date, habits: [Habit]) -> (Int, Int) {
        let calendar = Calendar.current
        let normalizedDate = calendar.startOfDay(for: date)
        var completed = 0

        for habit in habits {
            if habit.dailyLogs.contains(where: { calendar.startOfDay(for: $0.date) == normalizedDate }) {
                completed += 1
            }
        }

        return (completed, habits.count)
    }

    private static func getMonthLabelForWeek(_ mondayDate: Date, calendar: Calendar) -> String? {
        let weekDays = (0..<7).compactMap { offset in
            calendar.date(byAdding: .day, value: offset, to: mondayDate)
        }

        var monthLabel: String?
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM"

        for (index, day) in weekDays.enumerated() {
            if calendar.component(.day, from: day) <= 7 || index == 0 {
                monthLabel = formatter.string(from: day)
                break
            }
        }

        return monthLabel
    }
}
