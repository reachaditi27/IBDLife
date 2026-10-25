import SwiftUI

struct ExportDetailsView: View {
    @EnvironmentObject private var onboarding: OnboardingData
    @State private var includeProfile = true
    @State private var includeBMI = true
    @State private var includeDoseHistory = true
    @State private var includeSymptoms = true
    @State private var includeVisits = true
    @State private var exportURL: URL?
    @State private var errorMessage: String?

    private var hasSelection: Bool { includeProfile || includeBMI || includeDoseHistory || includeSymptoms || includeVisits }

    var body: some View {
        AppPage(title: "Export details") {
            Text("Choose exactly what to include. IBDLife creates a plain-text health summary that you can attach to a MyChart message or share another way.")
                .font(.system(size: 14)).foregroundStyle(AppStyle.muted).lineSpacing(4)
            AppCard(padding: 16) {
                VStack(spacing: 16) {
                    exportToggle("Conditions & current treatment plan", isOn: $includeProfile)
                    exportToggle("BMI history", isOn: $includeBMI)
                    exportToggle("Dose & nutrition history", isOn: $includeDoseHistory)
                    exportToggle("Symptom log", isOn: $includeSymptoms)
                    exportToggle("GI office visits", isOn: $includeVisits)
                }
            }
            Button { prepareExport() } label: { AppActionLabel(title: "Prepare selected details", systemImage: "doc") }
                .disabled(!hasSelection).opacity(hasSelection ? 1 : 0.45)
            if let exportURL {
                ShareLink(item: exportURL, preview: SharePreview("IBDLife Health Summary")) {
                    Label("Share or attach to MyChart", systemImage: "square.and.arrow.up")
                        .font(.system(size: 15, weight: .semibold)).foregroundStyle(AppStyle.green)
                        .frame(maxWidth: .infinity, minHeight: 52)
                        .background(.white, in: RoundedRectangle(cornerRadius: 14))
                        .overlay(RoundedRectangle(cornerRadius: 14).stroke(AppStyle.green))
                }
            }
            if let errorMessage { Text(errorMessage).font(.system(size: 12)).foregroundStyle(.red) }
            Text("Review the file before sending. It may contain sensitive health information.")
                .font(.system(size: 12)).foregroundStyle(AppStyle.muted)
        }
        .onChange(of: includeProfile) { exportURL = nil }
        .onChange(of: includeBMI) { exportURL = nil }
        .onChange(of: includeDoseHistory) { exportURL = nil }
        .onChange(of: includeSymptoms) { exportURL = nil }
        .onChange(of: includeVisits) { exportURL = nil }
    }

    private func exportToggle(_ title: String, isOn: Binding<Bool>) -> some View {
        Toggle(title, isOn: isOn).tint(AppStyle.green).font(.system(size: 14))
    }

    private func prepareExport() {
        // Preparing a file does not transmit it. The user selects a destination in ShareLink.
        // MyChart is a possible manual destination, not an authenticated API integration.
        let url = FileManager.default.temporaryDirectory.appending(path: "IBDLife-Health-Summary.txt")
        do {
            try reportText().write(to: url, atomically: true, encoding: .utf8)
            exportURL = url; errorMessage = nil
        } catch {
            exportURL = nil; errorMessage = "The export could not be prepared. Please try again."
        }
    }

    private func reportText() -> String {
        var lines = ["IBDLife Health Summary", "Created \(Date().formatted(date: .long, time: .shortened))", ""]
        if includeProfile {
            lines += ["CONDITIONS", onboarding.diagnoses.compactMap { Diagnosis(rawValue: $0)?.displayName }.joined(separator: ", ").nilIfEmpty ?? "None recorded", "", "CURRENT TREATMENTS"]
            if onboarding.treatments.isEmpty { lines.append("None recorded") }
            for plan in onboarding.treatments {
                lines.append("• \(plan.medication?.brandName ?? plan.id) — \(plan.scheduleTitle)")
            }
            lines.append("")
        }
        if includeBMI {
            lines.append("BMI HISTORY")
            if onboarding.bodyMeasurements.isEmpty { lines.append("None recorded") }
            for item in onboarding.bodyMeasurements.sorted(by: { $0.date < $1.date }) {
                lines.append("• \(item.date.formatted(date: .abbreviated, time: .omitted)): BMI \(item.bmi.formatted(.number.precision(.fractionLength(1))))")
            }
            lines.append("")
        }
        if includeDoseHistory {
            lines.append("DOSE & NUTRITION HISTORY")
            if onboarding.doseRecords.isEmpty { lines.append("None recorded") }
            for record in onboarding.doseRecords.sorted(by: { $0.recordedDate > $1.recordedDate }) {
                let plan = onboarding.plan(for: record.treatmentID)
                lines.append("• \(record.recordedDate.formatted(date: .abbreviated, time: .shortened)): \(plan.medication?.brandName ?? record.treatmentID) \(plan.isNutrition ? "serving" : "dose")")
            }
            lines.append("")
        }
        if includeSymptoms {
            lines.append("SYMPTOM LOG")
            if onboarding.symptoms.isEmpty { lines.append("None recorded") }
            for item in onboarding.symptoms.sorted(by: { $0.date > $1.date }) {
                var details = [item.mood.rawValue]
                if let pain = item.painLocation { details.append("pain: \(pain.rawValue) \(item.painSeverity ?? 0)/5") }
                if let stool = item.stoolConsistency { details.append("stool: \(stool.rawValue)") }
                if let count = item.bowelMovementCount { details.append("bowel movements: \(count)") }
                if let blood = item.hasBlood { details.append("blood: \(blood ? "yes" : "no")") }
                if let urgency = item.urgency { details.append("urgency: \(urgency)/5") }
                if let fatigue = item.fatigue { details.append("fatigue: \(fatigue)/5") }
                if let sleep = item.sleepQuality { details.append("sleep: \(sleep)/5") }
                if !item.note.isEmpty { details.append("note: \(item.note)") }
                lines.append("• \(item.date.formatted(date: .abbreviated, time: .shortened)): \(details.joined(separator: "; "))")
            }
            lines.append("")
        }
        if includeVisits {
            lines.append("GI OFFICE VISITS")
            if onboarding.doctorVisits.isEmpty { lines.append("None recorded") }
            for visit in onboarding.doctorVisits.sorted(by: { $0.date < $1.date }) {
                lines.append("• \(visit.date.formatted(date: .long, time: .shortened)): \(visit.clinician.nilIfEmpty ?? "GI office visit")\(visit.location.isEmpty ? "" : " — \(visit.location)")")
            }
        }
        return lines.joined(separator: "\n")
    }
}

private extension String {
    var nilIfEmpty: String? { isEmpty ? nil : self }
}
