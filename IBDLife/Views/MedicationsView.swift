import SwiftUI

struct MedicationsView: View {

    let selectedDiagnoses: Set<Diagnosis>
    @EnvironmentObject var onboarding: OnboardingData

    @Environment(\.dismiss) private var dismiss

    @State private var selectedMedications:
        Set<Medication> = []

    private var filteredMedications: [Medication] {

        MedicationDatabase.medications.filter {

            !$0.diagnoses.isDisjoint(
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

                    Text("Current Treatments")
                        .font(
                            .system(
                                size: 34,
                                weight: .bold
                            )
                        )

                    // MARK: Description

                    Text(
                        "We've filtered this list based on your diagnosis. Select all treatments you're currently taking."
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
                        Text("No treatments in our current list match your diagnosis. You can continue without a treatment schedule.")
                            .foregroundStyle(Color.ibdSecondaryText)
                        NavigationLink("Continue without treatments") {
                            Step7PlaceholderView()
                        }.simultaneousGesture(TapGesture().onEnded { onboarding.selectMedications([]) })
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
                    ? "No treatments selected"
                    : "\(selectedMedications.count) treatment\(selectedMedications.count == 1 ? "" : "s") selected"
                )
                .font(
                    .subheadline
                )
                .foregroundColor(
                    .ibdSecondaryText
                )

                NavigationLink {

                    MedicationAdministrationView(
                        medications:
                            selectedMedications
                            .sorted {
                                $0.displayOrder <
                                $1.displayOrder
                            }
                    )

                } label: {

                    PrimaryButton(
                        title: "Continue"
                    )
                }
                .simultaneousGesture(TapGesture().onEnded {
                    onboarding.selectMedications(selectedMedications.sorted { ($0.category.rawValue, $0.displayOrder) < ($1.category.rawValue, $1.displayOrder) })
                })
                .disabled(selectedMedications.isEmpty)
                .opacity(
                    selectedMedications.isEmpty
                    ? 0.45
                    : 1
                )
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
}
