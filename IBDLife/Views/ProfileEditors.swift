import SwiftUI

struct ProfileConditionsEditor: View {
    @EnvironmentObject private var onboarding: OnboardingData
    @Environment(\.dismiss) private var dismiss
    @State private var selection: Set<Diagnosis> = []

    var body: some View {
        AppPage(title: "Edit conditions") {
            Text("Choose all conditions that apply. Medication choices remain unchanged until you edit them separately.")
                .font(.system(size: 14)).foregroundStyle(AppStyle.muted).lineSpacing(4)
            VStack(spacing: 12) {
                ForEach(Diagnosis.allCases, id: \.self) { diagnosis in
                    Button {
                        if selection.contains(diagnosis) { selection.remove(diagnosis) }
                        else { selection.insert(diagnosis) }
                    } label: {
                        AppCard(padding: 16) {
                            HStack {
                                Text(diagnosis.displayName).font(.system(size: 15, weight: .medium))
                                Spacer()
                                Image(systemName: selection.contains(diagnosis) ? "checkmark.circle.fill" : "circle")
                                    .foregroundStyle(selection.contains(diagnosis) ? AppStyle.green : AppStyle.muted)
                            }
                        }
                    }.buttonStyle(.plain)
                }
            }
            Button {
                onboarding.diagnoses = Diagnosis.allCases.filter(selection.contains).map(\.rawValue)
                dismiss()
            } label: { AppActionLabel(title: "Save conditions", systemImage: "checkmark") }
        }
        .onAppear { selection = Set(onboarding.diagnoses.compactMap(Diagnosis.init(rawValue:))) }
    }
}

struct ProfileMedicationsEditor: View {
    @EnvironmentObject private var onboarding: OnboardingData
    @Environment(\.dismiss) private var dismiss
    @State private var selection: Set<Medication> = []

    private var diagnoses: Set<Diagnosis> {
        Set(onboarding.diagnoses.compactMap(Diagnosis.init(rawValue:)))
    }
    private var available: [Medication] {
        MedicationDatabase.medications.filter {
            diagnoses.isEmpty || !$0.diagnoses.isDisjoint(with: diagnoses) || onboarding.medications.contains($0.id)
        }
    }
    private var grouped: [(MedicationCategory, [Medication])] {
        MedicationCategory.allCases.compactMap { category in
            let matches = available.filter { $0.category == category }.sorted { $0.displayOrder < $1.displayOrder }
            return matches.isEmpty ? nil : (category, matches)
        }
    }

    var body: some View {
        AppPage(title: "Edit medications") {
            Text("Add or remove current treatments. Removing a treatment stops its future schedule and reminders; recorded dose history is retained.")
                .font(.system(size: 14)).foregroundStyle(AppStyle.muted).lineSpacing(4)
            ForEach(grouped, id: \.0) { category, medications in
                VStack(alignment: .leading, spacing: 12) {
                    AppSectionLabel(title: category.title)
                    ForEach(medications) { medication in
                        MedicationCard(medication: medication, isSelected: selection.contains(medication)) {
                            if selection.contains(medication) { selection.remove(medication) }
                            else { selection.insert(medication) }
                        }
                    }
                }
            }
            Button {
                let medications = selection.sorted {
                    ($0.category.rawValue, $0.displayOrder) < ($1.category.rawValue, $1.displayOrder)
                }
                onboarding.selectMedications(medications)
                dismiss()
            } label: { AppActionLabel(title: "Save medications", systemImage: "checkmark") }
        }
        .onAppear {
            selection = Set(MedicationDatabase.medications.filter { onboarding.medications.contains($0.id) })
        }
    }
}

struct ProfilePrescriptionFormEditor: View {
    let treatmentID: String
    @EnvironmentObject private var onboarding: OnboardingData
    @Environment(\.dismiss) private var dismiss
    @State private var selection: Set<AdministrationForm> = []

    private var medication: Medication? { onboarding.plan(for: treatmentID).medication }
    private var availableForms: [AdministrationForm] {
        guard let medication else { return AdministrationForm.allCases }
        let known = MedicationAdministrationDatabase.forms(for: medication.brandName)
        return known.isEmpty ? AdministrationForm.allCases : known
    }

    var body: some View {
        AppPage(title: "Prescription form") {
            if let medication {
                VStack(alignment: .leading, spacing: 4) {
                    Text(medication.brandName).font(.headline).foregroundStyle(AppStyle.green)
                    if let genericName = medication.genericName {
                        Text(genericName).font(.system(size: 13)).foregroundStyle(AppStyle.muted)
                    }
                }
            }
            Text("Select all forms that apply to this treatment.")
                .font(.system(size: 14)).foregroundStyle(AppStyle.muted)
            VStack(spacing: 12) {
                ForEach(availableForms) { form in
                    AdministrationFormCard(form: form, selected: selection.contains(form)) {
                        if selection.contains(form) { selection.remove(form) }
                        else { selection.insert(form) }
                    }
                }
            }
            Button {
                var plan = onboarding.plan(for: treatmentID)
                plan.forms = selection
                onboarding.updatePlan(plan)
                dismiss()
            } label: { AppActionLabel(title: "Save prescription form", systemImage: "checkmark") }
                .disabled(selection.isEmpty).opacity(selection.isEmpty ? 0.45 : 1)
        }
        .onAppear { selection = onboarding.plan(for: treatmentID).forms }
    }
}
