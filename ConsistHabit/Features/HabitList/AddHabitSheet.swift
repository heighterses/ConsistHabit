import SwiftUI
import SwiftData

struct AddHabitSheet: View {
    @Environment(HabitStore.self) var store
    @Binding var isPresented: Bool
    @State private var habitName = ""
    @State private var selectedEmoji = "🎯"
    @State private var reminderTime = Date()
    @State private var reminderEnabled = false
    @State private var isCreating = false

    let emojiOptions = ["🎯", "💪", "📚", "🧘", "💤", "🥗", "🏃", "🎨", "📝", "🎵", "📱", "☕", "🚴", "🏊", "⛹️", "🤸", "🧗", "🚶", "🌟", "✍️"]

    var habitNameIsValid: Bool {
        !habitName.trimmingCharacters(in: .whitespaces).isEmpty && habitName.count <= 50
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: AppTheme.Spacing.lg) {
                VStack(spacing: AppTheme.Spacing.md) {
                    Text("Emoji")
                        .font(AppTheme.Typography.headingMedium)
                        .foregroundColor(AppTheme.TextColor.primary)
                        .fillMaxWidth(alignment: .leading)

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: AppTheme.Spacing.md) {
                            ForEach(emojiOptions, id: \.self) { emoji in
                                Button {
                                    withAnimation(AppTheme.Animation.springSnappy) {
                                        selectedEmoji = emoji
                                    }
                                    HapticManager.shared.trigger(.selectionChange)
                                } label: {
                                    Text(emoji)
                                        .font(.system(size: 32))
                                        .frame(width: 56, height: 56)
                                        .background(selectedEmoji == emoji ? AppTheme.AccentColor.mint : AppTheme.BackgroundColor.elevated)
                                        .cornerRadius(AppTheme.Radius.md)
                                }
                            }
                        }
                        .padding(.horizontal, AppTheme.Spacing.lg)
                    }
                }

                VStack(spacing: AppTheme.Spacing.md) {
                    Text("Habit Name")
                        .font(AppTheme.Typography.headingMedium)
                        .foregroundColor(AppTheme.TextColor.primary)
                        .fillMaxWidth(alignment: .leading)

                    TextField("e.g., Morning Exercise", text: $habitName)
                        .font(AppTheme.Typography.bodyMedium)
                        .padding(AppTheme.Spacing.md)
                        .background(AppTheme.BackgroundColor.elevated)
                        .cornerRadius(AppTheme.Radius.lg)
                        .foregroundColor(AppTheme.TextColor.primary)
                        .textInputAutocapitalization(.words)

                    if habitName.count > 40 {
                        Text("\(50 - habitName.count) characters remaining")
                            .font(AppTheme.Typography.bodySmall)
                            .foregroundColor(AppTheme.TextColor.secondary)
                            .fillMaxWidth(alignment: .trailing)
                    }
                }

                VStack(spacing: AppTheme.Spacing.md) {
                    Toggle("Daily Reminder", isOn: $reminderEnabled)
                        .font(AppTheme.Typography.bodyLarge)
                        .tint(AppTheme.AccentColor.mint)

                    if reminderEnabled {
                        VStack(spacing: AppTheme.Spacing.sm) {
                            Text("Time")
                                .font(AppTheme.Typography.bodyMedium)
                                .foregroundColor(AppTheme.TextColor.primary)
                                .fillMaxWidth(alignment: .leading)

                            DatePicker("", selection: $reminderTime, displayedComponents: .hourAndMinute)
                                .datePickerStyle(.wheel)
                                .frame(height: 150)
                        }
                        .padding(AppTheme.Spacing.md)
                        .background(AppTheme.BackgroundColor.elevated)
                        .cornerRadius(AppTheme.Radius.lg)
                    }
                }

                Spacer()

                Button {
                    createHabit()
                } label: {
                    if isCreating {
                        ProgressView()
                            .tint(.black)
                    } else {
                        Text("Create Habit")
                            .font(AppTheme.Typography.headingMedium)
                    }
                }
                .fillMaxWidth()
                .frame(height: 56)
                .background(AppTheme.AccentColor.mint)
                .foregroundColor(.black)
                .cornerRadius(AppTheme.Radius.lg)
                .disabled(!habitNameIsValid || isCreating)
                .opacity(habitNameIsValid && !isCreating ? 1.0 : 0.5)
            }
            .padding(AppTheme.Spacing.lg)
            .background(AppTheme.BackgroundColor.primary)
            .navigationTitle("New Habit")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        isPresented = false
                    }
                    .foregroundColor(AppTheme.AccentColor.mint)
                }
            }
        }
    }

    private func createHabit() {
        let trimmedName = habitName.trimmingCharacters(in: .whitespaces)
        guard !trimmedName.isEmpty && trimmedName.count <= 50 else {
            store.showToast("Please enter a valid habit name")
            HapticManager.shared.trigger(.errorOccurred)
            return
        }

        isCreating = true

        if reminderEnabled {
            let habit = Habit(name: trimmedName, emoji: selectedEmoji, reminderTime: reminderTime, reminderEnabled: true)
            store.addHabitWithReminder(habit: habit)
        } else {
            store.addHabit(name: trimmedName, emoji: selectedEmoji)
        }

        HapticManager.shared.trigger(.habitComplete)
        isPresented = false
    }
}

#Preview {
    @Previewable @State var isPresented = true

    return AddHabitSheet(isPresented: $isPresented)
        .modelContainer(for: Habit.self, inMemory: true)
}
