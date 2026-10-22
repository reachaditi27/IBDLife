import SwiftUI

struct SymptomCheckInView: View {
    let mood: Mood
    @EnvironmentObject var onboarding: OnboardingData
    @State private var note = ""
    @State private var painLocation: PainLocation = .none
    @State private var painSeverity = 0
    @State private var stoolConsistency: StoolConsistency = .formed
    @State private var bowelMovementCount = 1
    @State private var hasBlood = false
    @State private var urgency = 0
    @State private var fatigue = 0
    @State private var sleepQuality = 3
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
                    Text("A few common GI questions can help you and your care team spot patterns. Skip anything you don't want to answer.")
                        .font(.system(size: 15)).foregroundStyle(AppStyle.muted).lineSpacing(6)
                    symptomPicker("Where does your stomach hurt?", selection: $painLocation)
                    if painLocation != .none {
                        ratingControl("Pain severity", value: $painSeverity, low: "None", high: "Severe")
                    }
                    symptomPicker("Was your stool well formed?", selection: $stoolConsistency)
                    Stepper("Bowel movements today: \(bowelMovementCount)", value: $bowelMovementCount, in: 0...30)
                        .font(.system(size: 14, weight: .medium)).padding(16)
                        .background(.white, in: RoundedRectangle(cornerRadius: 14))
                    Toggle("Blood in stool", isOn: $hasBlood).tint(AppStyle.green)
                        .font(.system(size: 14, weight: .medium)).padding(16)
                        .background(.white, in: RoundedRectangle(cornerRadius: 14))
                    ratingControl("Urgency", value: $urgency, low: "None", high: "Severe")
                    ratingControl("Fatigue", value: $fatigue, low: "None", high: "Severe")
                    ratingControl("Sleep quality", value: $sleepQuality, low: "Poor", high: "Excellent")
                    Text("Anything else?").font(.system(size: 14, weight: .semibold)).padding(.top, 4)
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
                    }
                }
            }
        }
    }
    private func save(withoutNote: Bool = false) {
        guard !saved else { return }
        onboarding.addSymptom(mood: mood, note: withoutNote ? "" : note,
                              painLocation: painLocation, painSeverity: painSeverity,
                              stoolConsistency: stoolConsistency, bowelMovementCount: bowelMovementCount,
                              hasBlood: hasBlood, urgency: urgency, fatigue: fatigue,
                              sleepQuality: sleepQuality)
        isEditing = false; saved = true
    }

    private func symptomPicker<Value: CaseIterable & Hashable & Identifiable & RawRepresentable>(
        _ title: String, selection: Binding<Value>
    ) -> some View where Value.RawValue == String, Value.AllCases: RandomAccessCollection {
        VStack(alignment: .leading, spacing: 8) {
            Text(title).font(.system(size: 14, weight: .semibold))
            Picker(title, selection: selection) {
                ForEach(Array(Value.allCases)) { value in Text(value.rawValue).tag(value) }
            }
            .pickerStyle(.menu).tint(AppStyle.green)
        }
        .padding(16).background(.white, in: RoundedRectangle(cornerRadius: 14))
    }

    private func ratingControl(_ title: String, value: Binding<Int>, low: String, high: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack { Text(title).font(.system(size: 14, weight: .semibold)); Spacer(); Text("\(value.wrappedValue) / 5").foregroundStyle(AppStyle.green) }
            Slider(value: Binding(get: { Double(value.wrappedValue) }, set: { value.wrappedValue = Int($0.rounded()) }), in: 0...5, step: 1).tint(AppStyle.green)
            HStack { Text(low); Spacer(); Text(high) }.font(.system(size: 11)).foregroundStyle(AppStyle.muted)
        }
        .padding(16).background(.white, in: RoundedRectangle(cornerRadius: 14))
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
                                if let painLocation = entry.painLocation {
                                    detail("Pain", painLocation == .none ? "None" : "\(painLocation.rawValue), \(entry.painSeverity ?? 0)/5")
                                }
                                if let stool = entry.stoolConsistency { detail("Stool", stool.rawValue) }
                                if let count = entry.bowelMovementCount { detail("Bowel movements", "\(count)") }
                                if let blood = entry.hasBlood { detail("Blood in stool", blood ? "Yes" : "No") }
                                if let urgency = entry.urgency { detail("Urgency", "\(urgency)/5") }
                                if let fatigue = entry.fatigue { detail("Fatigue", "\(fatigue)/5") }
                                if let sleep = entry.sleepQuality { detail("Sleep quality", "\(sleep)/5") }
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

    private func detail(_ label: String, _ value: String) -> some View {
        HStack(alignment: .firstTextBaseline) {
            Text(label).foregroundStyle(AppStyle.muted)
            Spacer()
            Text(value).multilineTextAlignment(.trailing)
        }.font(.system(size: 12))
    }
}
