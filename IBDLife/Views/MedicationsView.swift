import SwiftUI

struct MedicationsView: View {

    let selectedDiagnoses: Set<Diagnosis>
    @EnvironmentObject var onboarding: OnboardingData

    @Environment(\.dismiss) private var dismiss

    @State private var selectedMedications:
        Set<Medication> = []
    @State private var continueOnboarding = false

    private var filteredMedications: [Medication] {

        MedicationDatabase.medications.filter {

            !$0.isNutrition && !$0.diagnoses.isDisjoint(
                with: selectedDiagnoses
            )
        }
    }

    private var groupedMedications:
        [(MedicationCategory, [Medication])] {

        MedicationCategory.allCases.compactMap {
            category in

            let medications =
                filteredMedications
                .filter {
                    $0.category == category
                }
                .sorted {
                    $0.displayOrder <
                    $1.displayOrder
                }

            guard !medications.isEmpty else {
                return nil
            }

            return (
                category,
                medications
            )
        }
    }

    private var selectedAlternativeGroups: [[Medication]] {
        MedicationDatabase.selectedAlternativeGroups(in: Set(selectedMedications.map(\.id)))
    }

    var body: some View {

        VStack(spacing: 0) {

            ScrollView(
                showsIndicators: false
            ) {

                VStack(
                    alignment: .leading,
                    spacing: 28
                ) {

                    // MARK: Back

                    Button {

                        dismiss()

                    } label: {

                        HStack(spacing: 6) {

                            Image(
                                systemName:
                                    "chevron.left"
                            )
                            .font(
                                .system(
                                    size: 14,
                                    weight: .semibold
                                )
                            )

                            Text("Back")
                                .fontWeight(
                                    .medium
                                )
                        }
                        .foregroundColor(
                            .ibdSecondaryText
                        )
                    }
                    .buttonStyle(.plain)

                    // MARK: Title

                    Text("STEP 3 · MEDICATIONS")
                        .font(.caption.weight(.bold)).tracking(1.5)
                        .foregroundStyle(Color.ibdSecondaryText)

                    Text("Current Medications")
                        .font(
                            .system(
                                size: 34,
                                weight: .bold
                            )
                        )

                    // MARK: Description

                    Text(
                        "We've filtered this list based on your diagnosis. Select all medications you're currently taking. Nutrition drinks come in a separate step."
                    )
                    .font(
                        .system(size: 16)
                    )
                    .foregroundColor(
                        .ibdSecondaryText
                    )
                    .lineSpacing(3)

                    ForEach(Array(selectedAlternativeGroups.enumerated()), id: \.offset) { _, medications in
                        MedicationAlternativeNotice(medications: medications)
                    }

                    if filteredMedications.isEmpty {
                        Text("No medications in our current list match your diagnosis. You can continue to nutrition options.")
                            .foregroundStyle(Color.ibdSecondaryText)
                    }

                    // MARK: Categories

                    ForEach(
                        groupedMedications,
                        id: \.0
                    ) {
                        category,
                        medications in

                        VStack(
                            alignment: .leading,
                            spacing: 16
                        ) {

                            Text(
                                category.title
                            )
                            .font(
                                .caption.weight(
                                    .bold
                                )
                            )
                            .tracking(0.8)
                            .foregroundColor(
                                .ibdSecondaryText
                            )

                            ForEach(
                                medications
                            ) {
                                medication in

                                MedicationCard(
                                    medication:
                                        medication,
                                    isSelected:
                                        selectedMedications
                                        .contains(
                                            medication
                                        )
                                ) {

                                    toggleMedication(
                                        medication
                                    )
                                }
                            }
                        }
                    }

                    Spacer()
                        .frame(height: 20)
                }
                .padding(
                    .horizontal,
                    24
                )
                .padding(
                    .top,
                    12
                )
                .padding(
                    .bottom,
                    130
                )
            }

            // MARK: Bottom

            VStack(spacing: 12) {

                Text(
                    selectedMedications.isEmpty
                    ? "No medications selected"
                    : "\(selectedMedications.count) medication\(selectedMedications.count == 1 ? "" : "s") selected"
                )
                .font(
                    .subheadline
                )
                .foregroundColor(
                    .ibdSecondaryText
                )

                Button {
                    saveMedicationSelection()
                    continueOnboarding = true
                } label: {
                    PrimaryButton(
                        title: selectedMedications.isEmpty ? "Continue without medications" : "Continue"
                    )
                }
                .buttonStyle(.plain)
            }
            .padding(
                .horizontal,
                24
            )
            .padding(
                .top,
                14
            )
            .padding(
                .bottom,
                20
            )
            .background(
                Color.white
            )
        }
        .background(
            Color.ibdCream
                .ignoresSafeArea()
        )
        .onAppear {
            selectedMedications = Set(filteredMedications.filter { onboarding.medications.contains($0.id) })
        }
        .navigationDestination(isPresented: $continueOnboarding) {
            let medications = selectedMedications.sorted { ($0.category.rawValue, $0.displayOrder) < ($1.category.rawValue, $1.displayOrder) }
            if medications.isEmpty {
                NutritionSelectionView()
            } else {
                MedicationAdministrationView(medications: medications)
            }
        }
        .navigationBarBackButtonHidden(
            true
        )
        .navigationBarTitleDisplayMode(
            .inline
        )
    }

    // MARK: Toggle

    private func toggleMedication(
        _ medication: Medication
    ) {

        if selectedMedications.contains(
            medication
        ) {

            selectedMedications.remove(
                medication
            )

        } else {

            selectedMedications.insert(
                medication
            )
        }
    }

    private func saveMedicationSelection() {
        let retainedNutrition = MedicationDatabase.medications.filter {
            $0.isNutrition && onboarding.medications.contains($0.id)
        }
        let medications = selectedMedications.sorted {
            ($0.category.rawValue, $0.displayOrder) < ($1.category.rawValue, $1.displayOrder)
        }
        onboarding.selectMedications(medications + retainedNutrition)
    }
}

struct NutritionSelectionView: View {
    var onBack: (() -> Void)? = nil
    @EnvironmentObject private var onboarding: OnboardingData
    @Environment(\.dismiss) private var dismiss
    @State private var selection: Set<Medication> = []
    @State private var continueOnboarding = false

    private var diagnoses: Set<Diagnosis> {
        Set(onboarding.diagnoses.compactMap(Diagnosis.init(rawValue:)))
    }
    private var availableNutrition: [Medication] {
        MedicationDatabase.medications.filter {
            $0.isNutrition && (diagnoses.isEmpty || !$0.diagnoses.isDisjoint(with: diagnoses))
        }.sorted { $0.displayOrder < $1.displayOrder }
    }
    private var sortedSelection: [Medication] {
        selection.sorted { $0.displayOrder < $1.displayOrder }
    }

    var body: some View {
        VStack(spacing: 0) {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 28) {
                    Button {
                        if let onBack { onBack() } else { dismiss() }
                    } label: {
                        Label("Back", systemImage: "chevron.left")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(Color.ibdSecondaryText)
                    }
                    .buttonStyle(.plain)

                    Text("NUTRITION · OPTIONAL")
                        .font(.caption.weight(.bold)).tracking(1.5)
                        .foregroundStyle(Color.ibdSecondaryText)

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Do you use a")
                            .font(.system(size: 34, weight: .bold, design: .serif))
                        Text("nutrition drink?")
                            .font(.system(size: 32, design: .serif)).italic()
                    }

                    Text("Select any nutrition products you currently use. We'll set up serving reminders and supply ordering separately from medication.")
                        .font(.system(size: 16)).foregroundStyle(Color.ibdSecondaryText).lineSpacing(4)

                    if availableNutrition.isEmpty {
                        Text("No nutrition products in our current list match your diagnosis. You can continue without adding one.")
                            .font(.subheadline).foregroundStyle(Color.ibdSecondaryText)
                    } else {
                        VStack(alignment: .leading, spacing: 16) {
                            ForEach(availableNutrition) { nutrition in
                                MedicationCard(medication: nutrition, isSelected: selection.contains(nutrition)) {
                                    if selection.contains(nutrition) { selection.remove(nutrition) }
                                    else { selection.insert(nutrition) }
                                }
                            }
                        }
                    }

                    Spacer().frame(height: 20)
                }
                .padding(.horizontal, 24).padding(.top, 12).padding(.bottom, 130)
            }

            VStack(spacing: 12) {
                Text(selection.isEmpty
                     ? "No nutrition selected"
                     : "\(selection.count) nutrition product\(selection.count == 1 ? "" : "s") selected")
                    .font(.subheadline).foregroundStyle(Color.ibdSecondaryText)
                Button {
                    saveNutritionSelection()
                    continueOnboarding = true
                } label: {
                    PrimaryButton(title: selection.isEmpty ? "Continue without nutrition" : "Continue")
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 24).padding(.top, 14).padding(.bottom, 20)
            .background(Color.white)
        }
        .background(Color.ibdCream.ignoresSafeArea())
        .onAppear {
            selection = Set(availableNutrition.filter { onboarding.medications.contains($0.id) })
        }
        .navigationDestination(isPresented: $continueOnboarding) {
            if sortedSelection.isEmpty {
                Step7PlaceholderView()
            } else {
                TreatmentSetupFlow(medications: sortedSelection, completion: .finish)
            }
        }
        .navigationBarBackButtonHidden(true)
    }

    private func saveNutritionSelection() {
        let retainedMedications = MedicationDatabase.medications.filter {
            !$0.isNutrition && onboarding.medications.contains($0.id)
        }
        onboarding.selectMedications(retainedMedications + sortedSelection)
        for nutrition in sortedSelection {
            var plan = onboarding.plan(for: nutrition.id)
            if plan.forms.isEmpty { plan.forms = [.oralNutritionDrink] }
            onboarding.updatePlan(plan)
        }
    }
}
