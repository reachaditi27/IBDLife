import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var onboarding: OnboardingData
    var body: some View {
        AppPage(title: "My Profile") {
            VStack(alignment: .leading, spacing: 12) {
                sectionHeader("Conditions") { ProfileConditionsEditor() }
                if onboarding.diagnoses.isEmpty {
                    Text("No conditions added").foregroundStyle(AppStyle.muted)
                }
                ForEach(onboarding.diagnoses, id: \.self) { diagnosis in
                    AppCard(padding: 15) {
                        Label {
                            Text(Diagnosis(rawValue: diagnosis)?.displayName ?? diagnosis)
                        } icon: { Image(systemName: "checkmark.circle").foregroundStyle(AppStyle.green) }
                            .font(.system(size: 14))
                    }
                }
            }
            VStack(alignment: .leading, spacing: 10) {
                sectionHeader("BMI") { BodyMeasurementEditorView() }
                AppCard(padding: 16) {
                    if let measurement = onboarding.currentBodyMeasurement {
                        HStack(alignment: .firstTextBaseline) {
                            VStack(alignment: .leading, spacing: 6) {
                                Text("BMI \(measurement.bmi.formatted(.number.precision(.fractionLength(1))))")
                                    .font(AppStyle.serif(23))
                                Text(currentMeasurementSummary(measurement))
                                    .font(.system(size: 13)).foregroundStyle(AppStyle.muted)
                            }
                            Spacer()
                            NavigationLink("History") { BMIHistoryView() }
                                .font(.system(size: 13, weight: .medium)).foregroundStyle(AppStyle.green)
                        }
                    } else {
                        Text("Add height and weight to calculate BMI.")
                            .font(.system(size: 14)).foregroundStyle(AppStyle.muted)
                    }
                }
            }
            VStack(alignment: .leading, spacing: 10) {
                AppSectionLabel(title: "Reminders")
                AppCard(padding: 15) { MedicationReminderToggle() }
            }
            VStack(alignment: .leading, spacing: 12) {
                sectionHeader("Medications") { ProfileMedicationsEditor() }
                if onboarding.treatments.isEmpty {
                    EmptyMessage(title: "No medications added", detail: "You can still use symptom check-ins and support.")
                } else {
                    ForEach(onboarding.treatments) { plan in
                        AppCard(padding: 15) {
                            Text("\(plan.medication?.brandName ?? plan.id)\(Text(plan.medication?.genericName.map { " (\($0))" } ?? "").foregroundColor(AppStyle.muted))")
                                .font(.system(size: 14))
                        }
                    }
                }
            }
            ForEach(onboarding.treatments) { plan in
                VStack(alignment: .leading, spacing: 22) {
                    Text(plan.medication?.brandName ?? plan.id)
                        .font(AppStyle.serif(24)).padding(.top, 4)
                    editableSection("Prescription form") {
                        ProfilePrescriptionFormEditor(treatmentID: plan.id)
                    } content: {
                        VStack(alignment: .leading, spacing: 10) {
                            if plan.orderedForms.isEmpty {
                                Text("Not set up").foregroundStyle(AppStyle.muted)
                            } else {
                                ForEach(plan.orderedForms) { form in
                                    Text("\(form.icon)  \(form.rawValue)").font(.system(size: 14))
                                }
                            }
                        }
                    }
                    VStack(alignment: .leading, spacing: 10) {
                        sectionHeader("Dosing schedule", actionTitle: plan.frequency == nil ? "Set up" : "Edit") {
                            ProfileScheduleEditor(treatmentID: plan.id)
                        }
                        AppCard(padding: 15) {
                            VStack(alignment: .leading, spacing: 5) {
                                Text(plan.frequency?.title ?? "Not set up").font(.system(size: 14))
                                if let last = onboarding.doseRecords.filter({ $0.treatmentID == plan.id }).map(\.recordedDate).max() {
                                    Text("Last dose: \(last.formatted(date: .long, time: .omitted))")
                                        .font(.system(size: 12)).foregroundStyle(AppStyle.muted)
                                }
                            }
                        }
                    }
                    VStack(alignment: .leading, spacing: 10) {
                        sectionHeader("Doses per order") {
                            DosesPerOrderEditorView(treatmentID: plan.id)
                        }
                        AppCard(padding: 15) {
                            VStack(alignment: .leading, spacing: 5) {
                                Text(plan.dosesPerOrder.map { "\($0) doses per prescription" } ?? "Not set up")
                                    .font(.system(size: 14))
                                if let remaining = plan.dosesRemaining {
                                    Text("\(remaining) doses remaining").font(.system(size: 12)).foregroundStyle(AppStyle.muted)
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    private func currentMeasurementSummary(_ measurement: BodyMeasurement) -> String {
        let weight = measurement.weight(for: onboarding.unitSystem)
        let height = measurement.height(for: onboarding.unitSystem)
        if onboarding.unitSystem == .metric {
            return "\(weight.formatted(.number.precision(.fractionLength(1)))) kg · \(height.primary.formatted(.number.precision(.fractionLength(1)))) cm"
        }
        return "\(weight.formatted(.number.precision(.fractionLength(1)))) lb · \(Int(height.primary)) ft \(Int((height.secondary ?? 0).rounded())) in"
    }

    private func sectionHeader<Destination: View>(_ title: String, actionTitle: String = "Edit",
                                                   @ViewBuilder destination: () -> Destination) -> some View {
        HStack {
            AppSectionLabel(title: title)
            Spacer()
            NavigationLink(actionTitle, destination: destination)
                .font(.system(size: 13)).foregroundStyle(AppStyle.green)
        }
    }

    private func editableSection<Destination: View, Content: View>(_ title: String,
                               @ViewBuilder destination: () -> Destination,
                               @ViewBuilder content: @escaping () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            sectionHeader(title, destination: destination)
            AppCard(padding: 15, content: content)
        }
    }
}

struct DosesPerOrderEditorView: View {
    let treatmentID: String
    var isSetup = false
    var onComplete: (() -> Void)? = nil
    var onBack: (() -> Void)? = nil
    @EnvironmentObject var onboarding: OnboardingData
    @Environment(\.dismiss) private var dismiss
    @State private var order = ""
    @State private var remaining = ""
    private var valid: Bool {
        guard let quantity = Int(order), let stock = Int(remaining) else { return false }
        return quantity > 0 && quantity <= 9999 && stock >= 0 && stock <= 9999
    }

    var body: some View {
        AppPage(back: false, topInset: 36) {
            AppBackButton(action: onBack)
            VStack(alignment: .leading, spacing: 0) {
                Text("How many doses\ncome").font(AppStyle.serif(34))
                Text("with each\nprescription?").font(AppStyle.italic(34))
            }
            Text("We'll use this to remind you when it's time to request a refill — before you run out.")
                .font(.system(size: 15)).foregroundStyle(AppStyle.muted).lineSpacing(5)
            if onboarding.treatments.count > 1 {
                Text(onboarding.plan(for: treatmentID).medication?.brandName ?? treatmentID)
                    .font(.headline).foregroundStyle(AppStyle.green)
            }
            VStack(alignment: .leading, spacing: 20) {
                doseField("Number of doses per order", placeholder: "e.g. 2", text: $order)
                doseField("Doses remaining in your current prescription", placeholder: "e.g. 1", text: $remaining)
                Text("For example: 2 doses per shipment, with 1 dose currently remaining.")
                    .font(.system(size: 12)).foregroundStyle(AppStyle.muted).lineSpacing(4)
            }
            Text("Refill reminders will appear on your calendar one week before you're scheduled to run out, giving you time to contact your pharmacy or specialty mail service.")
                .font(.system(size: 14)).lineSpacing(5).foregroundStyle(AppStyle.green)
                .padding(18).frame(maxWidth: .infinity, alignment: .leading)
                .background(AppStyle.paleGreen, in: RoundedRectangle(cornerRadius: 16))
            Button {
                var plan = onboarding.plan(for: treatmentID)
                plan.dosesPerOrder = Int(order); plan.dosesRemaining = Int(remaining)
                onboarding.updatePlan(plan)
                finish()
            } label: { AppActionLabel(title: isSetup ? "Finish setup" : "Save changes") }
                .disabled(!valid).opacity(valid ? 1 : 0.45)
            if isSetup {
                Button("Skip for now", action: finish)
                    .font(.system(size: 14)).foregroundStyle(AppStyle.muted).underline()
                    .frame(maxWidth: .infinity, minHeight: 44)
            }
        }
        .onAppear {
            let plan = onboarding.plan(for: treatmentID)
            order = plan.dosesPerOrder.map(String.init) ?? ""
            remaining = plan.dosesRemaining.map(String.init) ?? ""
        }
    }

    private func finish() { if let onComplete { onComplete() } else { dismiss() } }
    private func doseField(_ title: String, placeholder: String, text: Binding<String>) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title).font(.system(size: 14, weight: .medium))
            HStack {
                TextField(placeholder, text: text).keyboardType(.numberPad).accessibilityLabel(title)
                Text("doses").foregroundStyle(AppStyle.muted)
            }.font(.system(size: 15)).padding(16)
                .background(.white, in: RoundedRectangle(cornerRadius: 14))
                .overlay(RoundedRectangle(cornerRadius: 14).stroke(AppStyle.border))
        }
    }
}

private struct ProfileScheduleEditor: View {
    let treatmentID: String
    @EnvironmentObject var onboarding: OnboardingData
    @Environment(\.dismiss) private var dismiss
    var body: some View {
        if let medication = onboarding.plan(for: treatmentID).medication {
            DosingScheduleView(medication: medication, onContinue: { dismiss() }, isProfileEdit: true)
        }
    }
}
