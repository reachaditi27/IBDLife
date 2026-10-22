import SwiftUI

struct DoctorVisitsView: View {
    @EnvironmentObject private var onboarding: OnboardingData
    @State private var showingAddVisit = false

    private var visits: [DoctorVisit] { onboarding.doctorVisits.sorted { $0.date < $1.date } }

    var body: some View {
        AppPage(title: "GI office visits") {
            Text("Add GI appointments so they appear in your calendar and, when treatment reminders are on, send a clearly labeled visit reminder.")
                .font(.system(size: 14)).foregroundStyle(AppStyle.muted).lineSpacing(4)
            Button { showingAddVisit = true } label: {
                AppActionLabel(title: "Add GI office visit", systemImage: "calendar.badge.plus")
            }
            if visits.isEmpty {
                EmptyMessage(title: "No visits added", detail: "Upcoming GI office visits will appear here.")
            }
            ForEach(visits) { visit in
                AppCard(padding: 16) {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack(alignment: .top) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(visit.date.formatted(date: .long, time: .shortened)).font(.system(size: 14, weight: .semibold))
                                if !visit.clinician.isEmpty { Text(visit.clinician).font(.system(size: 13)) }
                                if !visit.location.isEmpty { Label(visit.location, systemImage: "mappin.and.ellipse").font(.system(size: 12)).foregroundStyle(AppStyle.muted) }
                            }
                            Spacer()
                            Button(role: .destructive) { onboarding.doctorVisits.removeAll { $0.id == visit.id } } label: {
                                Image(systemName: "trash").frame(width: 36, height: 36)
                            }.accessibilityLabel("Delete visit")
                        }
                        Text(visit.reminderLeadDays == 0 ? "Reminder at visit time" : "Reminder \(visit.reminderLeadDays) day\(visit.reminderLeadDays == 1 ? "" : "s") before")
                            .font(.system(size: 11, weight: .medium)).foregroundStyle(AppStyle.green)
                        if !visit.notes.isEmpty { Text(visit.notes).font(.system(size: 12)).foregroundStyle(AppStyle.muted) }
                    }
                }
            }
        }
        .sheet(isPresented: $showingAddVisit) { NavigationStack { AddDoctorVisitView() } }
    }
}

private struct AddDoctorVisitView: View {
    @EnvironmentObject private var onboarding: OnboardingData
    @Environment(\.dismiss) private var dismiss
    @State private var date = Calendar.current.date(byAdding: .day, value: 7, to: Date()) ?? Date()
    @State private var clinician = ""
    @State private var location = ""
    @State private var notes = ""
    @State private var leadDays = 1

    var body: some View {
        AppPage(title: "Add GI visit") {
            DatePicker("Visit date and time", selection: $date, in: Date()..., displayedComponents: [.date, .hourAndMinute])
                .tint(AppStyle.green)
            field("Doctor or office", text: $clinician, placeholder: "e.g. Dr. Patel")
            field("Location", text: $location, placeholder: "Office or telehealth")
            VStack(alignment: .leading, spacing: 8) {
                Text("Remind me").font(.system(size: 14, weight: .semibold))
                Picker("Reminder timing", selection: $leadDays) {
                    Text("At visit time").tag(0)
                    Text("1 day before").tag(1)
                    Text("2 days before").tag(2)
                    Text("1 week before").tag(7)
                }.pickerStyle(.menu).tint(AppStyle.green)
            }
            field("Notes", text: $notes, placeholder: "Questions, preparation, or other details")
            Button {
                onboarding.doctorVisits.append(DoctorVisit(date: date, clinician: clinician.trimmingCharacters(in: .whitespacesAndNewlines), location: location.trimmingCharacters(in: .whitespacesAndNewlines), notes: notes.trimmingCharacters(in: .whitespacesAndNewlines), reminderLeadDays: leadDays))
                dismiss()
            } label: { AppActionLabel(title: "Save visit", systemImage: "checkmark") }
        }
    }

    private func field(_ title: String, text: Binding<String>, placeholder: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title).font(.system(size: 14, weight: .semibold))
            TextField(placeholder, text: text, axis: .vertical).padding(14)
                .background(.white, in: RoundedRectangle(cornerRadius: 14))
                .overlay(RoundedRectangle(cornerRadius: 14).stroke(AppStyle.border))
        }
    }
}
