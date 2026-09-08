import SwiftUI

struct SymptomCheckInView: View {
    let mood: Mood
    @EnvironmentObject var onboarding: OnboardingData
    @State private var note = ""
    @State private var saved = false
    @FocusState private var isEditing: Bool

    var body: some View {
        Group {
            if saved { SymptomLogView() }
            else {
                AppPage {
                    Text("\(mood.emoji)  \(mood.rawValue)").font(AppStyle.serif(24))
                    VStack(alignment: .leading, spacing: 0) {
                        Text("Want to add").font(AppStyle.serif(36))
                        Text("anything?").font(AppStyle.italic(36))
                    }
                    Text("Add a note about how you're feeling. This is completely optional.")
                        .font(.system(size: 15)).foregroundStyle(AppStyle.muted).lineSpacing(6)
                    ZStack(alignment: .topLeading) {
                        TextEditor(text: $note).scrollContentBackground(.hidden).focused($isEditing)
                            .font(.system(size: 15)).padding(10).frame(minHeight: 142)
                            .accessibilityLabel("Check-in note")
                        if note.isEmpty {
                            Text("Write a note…").font(.system(size: 15)).foregroundStyle(AppStyle.muted)
                                .padding(.horizontal, 15).padding(.top, 18).allowsHitTesting(false)
                        }
                    }
                    .background(.white, in: RoundedRectangle(cornerRadius: 16))
                    .overlay(RoundedRectangle(cornerRadius: 16).stroke(isEditing ? AppStyle.green : AppStyle.border))
                    .padding(.vertical, 8)
                    VStack(spacing: 8) {
                        Button { save() } label: { AppActionLabel(title: "Save check-in") }
                        Button("Skip →") { save(withoutNote: true) }
                            .font(.system(size: 14)).foregroundStyle(AppStyle.muted)
                            .frame(maxWidth: .infinity, minHeight: 44)
                    }
                }
            }
        }
    }
    private func save(withoutNote: Bool = false) {
        guard !saved else { return }
        onboarding.addSymptom(mood: mood, note: withoutNote ? "" : note)
        isEditing = false; saved = true
    }
}

struct SymptomLogView: View {
    @EnvironmentObject var onboarding: OnboardingData
    private var days: [Date] {
        Set(onboarding.symptoms.map { Calendar.current.startOfDay(for: $0.date) }).sorted(by: >)
    }
    var body: some View {
        AppPage(title: "Symptom log") {
            if days.isEmpty {
                EmptyMessage(title: "No check-ins yet", detail: "Choose how you're feeling on your home screen to start your log.")
            }
            ForEach(days, id: \.self) { day in
                VStack(alignment: .leading, spacing: 14) {
                    AppSectionLabel(title: Calendar.current.isDateInToday(day) ? "Today" : day.formatted(date: .abbreviated, time: .omitted))
                    ForEach(onboarding.symptoms.filter { Calendar.current.isDate($0.date, inSameDayAs: day) }.sorted { $0.date > $1.date }) { entry in
                        AppCard {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("\(Calendar.current.isDateInToday(entry.date) ? "TODAY" : entry.date.formatted(.dateTime.month(.abbreviated).day()).uppercased()) · \(entry.date.formatted(date: .omitted, time: .shortened))")
                                    .font(.system(size: 11, weight: .semibold)).tracking(0.8).foregroundStyle(AppStyle.muted)
                                Text("\(entry.mood.emoji)  \(entry.mood.rawValue)").font(.system(size: 15, weight: .medium))
                                if !entry.note.isEmpty {
                                    Text("“\(entry.note)”").font(.system(size: 14)).foregroundStyle(AppStyle.muted).lineSpacing(4)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
