import SwiftUI

struct ProfileConditionsEditor: View {
    @EnvironmentObject private var onboarding: OnboardingData
    @Environment(\.dismiss) private var dismiss
    @State private var primary: Diagnosis?
    @State private var additional: Set<Diagnosis> = []
    @State private var showAdditional = false

    var body: some View {
        AppPage(title: "Edit conditions") {
            Text("Choose your primary diagnosis. Medication choices remain unchanged until you edit them separately.")
                .font(.system(size: 14)).foregroundStyle(AppStyle.muted).lineSpacing(4)
            VStack(spacing: 12) {
                ForEach(Diagnosis.allCases, id: \.self) { diagnosis in
                    Button {
                        if showAdditional, let oldPrimary = primary, oldPrimary != diagnosis {
                            additional.insert(oldPrimary)
                        } else if !showAdditional {
                            additional.removeAll()
                        }
                        primary = diagnosis
                        additional.remove(diagnosis)
                    } label: {
                        AppCard(padding: 16) {
                            HStack {
                                Text(diagnosis.displayName).font(.system(size: 15, weight: .medium))
                                Spacer()
                                Image(systemName: primary == diagnosis ? "largecircle.fill.circle" : "circle")
                                    .foregroundStyle(primary == diagnosis ? AppStyle.green : AppStyle.muted)
                            }
                        }
                    }.buttonStyle(.plain)
                }
            }
            if primary != nil {
                if showAdditional {
                    VStack(alignment: .leading, spacing: 12) {
                        AppSectionLabel(title: "Additional conditions")
                        ForEach(Diagnosis.allCases.filter { $0 != primary }, id: \.self) { diagnosis in
                            additionalRow(diagnosis)
                        }
                        Button("Use one condition only") {
                            additional.removeAll()
                            showAdditional = false
                        }
                        .font(.system(size: 14)).foregroundStyle(AppStyle.muted).underline()
                        .frame(maxWidth: .infinity, minHeight: 44)
                    }
                } else {
                    Button {
                        showAdditional = true
                    } label: {
                        Label("Add another condition", systemImage: "plus.circle")
                            .font(.system(size: 14, weight: .medium)).foregroundStyle(AppStyle.green)
                            .frame(maxWidth: .infinity, minHeight: 48)
                            .background(.white, in: RoundedRectangle(cornerRadius: 14))
                            .overlay(RoundedRectangle(cornerRadius: 14).stroke(AppStyle.border))
                    }.buttonStyle(.plain)
                }
            }
            Button {
                onboarding.diagnoses = primary.map { [$0.rawValue] } ?? []
                onboarding.diagnoses += Diagnosis.allCases.filter(additional.contains).map(\.rawValue)
                dismiss()
            } label: { AppActionLabel(title: "Save conditions", systemImage: "checkmark") }
                .disabled(primary == nil).opacity(primary == nil ? 0.45 : 1)
        }
        .onAppear {
            primary = onboarding.primaryDiagnosis
            additional = Set(onboarding.additionalDiagnoses)
            showAdditional = !additional.isEmpty
        }
    }

    private func additionalRow(_ diagnosis: Diagnosis) -> some View {
        let selected = additional.contains(diagnosis)
        return Button {
            if selected { additional.remove(diagnosis) } else { additional.insert(diagnosis) }
        } label: {
            AppCard(padding: 15) {
                HStack {
                    Image(systemName: selected ? "checkmark.square.fill" : "square")
                        .foregroundStyle(selected ? AppStyle.green : AppStyle.muted)
                    Text(diagnosis.displayName).font(.system(size: 14, weight: .medium))
                    Spacer()
                }
            }
        }.buttonStyle(.plain).accessibilityValue(selected ? "Selected" : "Not selected")
    }
}

enum ProfileTreatmentKind {
    case medication
    case nutrition

    var isNutrition: Bool { self == .nutrition }
    var title: String { isNutrition ? "Edit nutrition" : "Edit medications" }
    var saveTitle: String { isNutrition ? "Save nutrition" : "Save medications" }
}

struct ProfileTreatmentsEditor: View {
    let kind: ProfileTreatmentKind
    @EnvironmentObject private var onboarding: OnboardingData
    @Environment(\.dismiss) private var dismiss
    @State private var selection: Set<Medication> = []

    private var diagnoses: Set<Diagnosis> {
        Set(onboarding.diagnoses.compactMap(Diagnosis.init(rawValue:)))
    }
    private var available: [Medication] {
        MedicationDatabase.medications.filter {
            $0.isNutrition == kind.isNutrition &&
            (diagnoses.isEmpty || !$0.diagnoses.isDisjoint(with: diagnoses) || onboarding.medications.contains($0.id))
        }
    }
    private var grouped: [(MedicationCategory, [Medication])] {
        MedicationCategory.allCases.compactMap { category in
            let matches = available.filter { $0.category == category }.sorted { $0.displayOrder < $1.displayOrder }
            return matches.isEmpty ? nil : (category, matches)
        }
    }
    private var selectedAlternativeGroups: [[Medication]] {
        MedicationDatabase.selectedAlternativeGroups(in: Set(selection.map(\.id)))
    }

    var body: some View {
        AppPage(title: kind.title) {
            Text(kind.isNutrition
                 ? "Select all nutrition products you're currently using. Removing one stops its future schedule and reminders; recorded history is retained."
                 : "Select all medications you're currently taking. Removing one stops its future schedule and reminders; recorded dose history is retained.")
                .font(.system(size: 14)).foregroundStyle(AppStyle.muted).lineSpacing(4)
            if !kind.isNutrition {
                ForEach(Array(selectedAlternativeGroups.enumerated()), id: \.offset) { _, medications in
                    MedicationAlternativeNotice(medications: medications)
                }
            }
            ForEach(grouped, id: \.0) { category, medications in
                VStack(alignment: .leading, spacing: 12) {
                    if !kind.isNutrition { AppSectionLabel(title: category.title) }
                    ForEach(medications) { medication in
                        MedicationCard(medication: medication, isSelected: selection.contains(medication)) {
                            if selection.contains(medication) { selection.remove(medication) }
                            else { selection.insert(medication) }
                        }
                    }
                }
            }
            Button {
                let retained = MedicationDatabase.medications.filter {
                    $0.isNutrition != kind.isNutrition && onboarding.medications.contains($0.id)
                }
                let edited = selection.sorted {
                    ($0.category.rawValue, $0.displayOrder) < ($1.category.rawValue, $1.displayOrder)
                }
                onboarding.selectMedications((retained + edited).sorted {
                    ($0.category.rawValue, $0.displayOrder) < ($1.category.rawValue, $1.displayOrder)
                })
                dismiss()
            } label: { AppActionLabel(title: kind.saveTitle, systemImage: "checkmark") }
        }
        .onAppear {
            selection = Set(MedicationDatabase.medications.filter {
                $0.isNutrition == kind.isNutrition && onboarding.medications.contains($0.id)
            })
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
