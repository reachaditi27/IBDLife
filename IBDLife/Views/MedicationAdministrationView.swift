import SwiftUI

struct MedicationAdministrationView: View {

    // MARK: - Input

    let medications: [Medication]

    // MARK: - Environment

    @Environment(\.dismiss) private var dismiss

    // MARK: - State

    @State private var currentIndex = 0

    @State private var selectedForms:
        [UUID: Set<AdministrationForm>] = [:]

    // MARK: - Navigation

    @State private var goToDosingSchedule = false

    // MARK: - Current Medication

    private var currentMedication: Medication {
        medications[currentIndex]
    }

    // MARK: - Available Forms

    private var availableForms: [AdministrationForm] {

        MedicationAdministrationDatabase.forms(
            for: currentMedication.brandName
        )
    }

    // MARK: - Current Selection

    private var currentSelection:
        Set<AdministrationForm> {

        selectedForms[currentMedication.id] ?? []
    }

    // MARK: - Last Treatment

    private var isLastMedication: Bool {

        currentIndex ==
        medications.count - 1
    }

    // MARK: - Body

    var body: some View {

        VStack(spacing: 0) {

            ScrollView(
                showsIndicators: false
            ) {

                VStack(
                    alignment: .leading,
                    spacing: 0
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
                                .fontWeight(.medium)
                        }
                        .foregroundColor(
                            .ibdSecondaryText
                        )
                    }
                    .buttonStyle(.plain)

                    Spacer()
                        .frame(height: 28)

                    // MARK: Step

                    Text("STEP 4 OF 7")
                        .font(
                            .caption.weight(.bold)
                        )
                        .tracking(1.5)
                        .foregroundColor(
                            .ibdSecondaryText
                        )

                    Spacer()
                        .frame(height: 14)

                    // MARK: Treatment Number

                    Text(
                        "TREATMENT \(currentIndex + 1) OF \(medications.count)"
                    )
                    .font(
                        .caption.weight(.bold)
                    )
                    .tracking(1.2)
                    .foregroundColor(
                        .ibdGreen
                    )

                    Spacer()
                        .frame(height: 12)

                    // MARK: Title

                    VStack(
                        alignment: .leading,
                        spacing: 2
                    ) {

                        Text("How do you take")
                            .font(
                                .system(
                                    size: 34,
                                    weight: .bold,
                                    design: .serif
                                )
                            )

                        Text("your treatment?")
                            .font(
                                .system(
                                    size: 32,
                                    design: .serif
                                )
                            )
                            .italic()
                    }

                    Spacer()
                        .frame(height: 18)

                    // MARK: Medication Name

                    Text(
                        currentMedication.brandName
                    )
                    .font(.headline)
                    .foregroundColor(
                        .ibdGreen
                    )

                    if let genericName =
                        currentMedication.genericName,
                       !genericName.isEmpty {

                        Text(genericName)
                            .font(.subheadline)
                            .foregroundColor(
                                .ibdSecondaryText
                            )
                    }

                    Spacer()
                        .frame(height: 8)

                    // MARK: Explanation

                    Text(
                        "Select all forms that apply. This helps us tailor reminders and preparation steps to your routine."
                    )
                    .font(.subheadline)
                    .foregroundColor(
                        .ibdSecondaryText
                    )
                    .lineSpacing(4)

                    Spacer()
                        .frame(height: 28)

                    // MARK: Administration Forms

                    if availableForms.isEmpty {

                        EmptyTreatmentFormsView()

                    } else {

                        VStack(spacing: 12) {

                            ForEach(
                                availableForms
                            ) { form in

                                AdministrationFormCard(
                                    form: form,
                                    selected:
                                        currentSelection
                                        .contains(form)
                                ) {

                                    toggle(
                                        form
                                    )
                                }
                            }
                        }
                    }

                    Spacer()
                        .frame(height: 30)
                }
                .padding(.horizontal, 24)
                .padding(.top, 8)
                .padding(.bottom, 130)
            }

            // MARK: Bottom Bar

            bottomBar
        }
        .background(
            Color.ibdCream
                .ignoresSafeArea()
        )
        .navigationBarBackButtonHidden(true)

        // -------------------------------------------------
        // IMPORTANT:
        // This destination is ONLY used after the final
        // treatment.
        //
        // It does NOT go to DiagnosisView.
        // -------------------------------------------------

        .navigationDestination(
            isPresented:
                $goToDosingSchedule
        ) {

            DosingScheduleView(
                medication:
                    currentMedication
            )
        }
    }

    // MARK: - Bottom Bar

    private var bottomBar: some View {

        VStack(spacing: 10) {

            Text(
                currentSelection.isEmpty
                ? "Select at least one option"
                : "\(currentSelection.count) form\(currentSelection.count == 1 ? "" : "s") selected"
            )
            .font(.subheadline)
            .foregroundColor(
                .ibdSecondaryText
            )

            Button {

                continueButtonPressed()

            } label: {

                HStack(spacing: 8) {

                    Text(
                        isLastMedication
                        ? "Continue"
                        : "Next treatment"
                    )

                    Image(
                        systemName:
                            "arrow.right"
                    )
                }
                .font(
                    .system(
                        size: 15,
                        weight: .semibold
                    )
                )
                .foregroundColor(.white)
                .frame(
                    maxWidth: .infinity
                )
                .frame(height: 48)
                .background(
                    RoundedRectangle(
                        cornerRadius: 14
                    )
                    .fill(
                        currentSelection.isEmpty
                        ? Color.ibdSecondaryText
                            .opacity(0.35)
                        : Color.ibdGreen
                    )
                )
            }
            .buttonStyle(.plain)
            .disabled(
                currentSelection.isEmpty
            )
        }
        .padding(.horizontal, 24)
        .padding(.top, 14)
        .padding(.bottom, 20)
        .background(
            .ultraThinMaterial
        )
    }

    // MARK: - Toggle Form

    private func toggle(
        _ form: AdministrationForm
    ) {

        var forms =
            selectedForms[
                currentMedication.id
            ] ?? []

        if forms.contains(form) {

            forms.remove(form)

        } else {

            forms.insert(form)
        }

        selectedForms[
            currentMedication.id
        ] = forms
    }

    // MARK: - Continue

    private func continueButtonPressed() {

        // Safety check

        guard !currentSelection.isEmpty else {
            return
        }

        // -------------------------------------------------
        // More treatments remaining
        // -------------------------------------------------

        if !isLastMedication {

            withAnimation(
                .easeInOut(duration: 0.2)
            ) {

                currentIndex += 1
            }

            return
        }

        // -------------------------------------------------
        // FINAL TREATMENT
        //
        // Go to Dosing Schedule.
        //
        // DO NOT go to DiagnosisView.
        // -------------------------------------------------

        goToDosingSchedule = true
    }
}


// MARK: - Administration Form Card

struct AdministrationFormCard: View {

    let form: AdministrationForm

    let selected: Bool

    let action: () -> Void

    var body: some View {

        Button(
            action: action
        ) {

            HStack(
                alignment: .top,
                spacing: 14
            ) {

                // MARK: Icon

                Text(form.icon)
                    .font(
                        .system(
                            size: 22
                        )
                    )
                    .frame(
                        width: 30
                    )

                // MARK: Text

                VStack(
                    alignment: .leading,
                    spacing: 5
                ) {

                    Text(
                        form.rawValue
                    )
                    .font(
                        .system(
                            size: 15,
                            weight: .semibold
                        )
                    )
                    .foregroundColor(
                        .primary
                    )

                    Text(
                        form.description
                    )
                    .font(
                        .system(
                            size: 12.5
                        )
                    )
                    .foregroundColor(
                        .ibdSecondaryText
                    )
                    .multilineTextAlignment(
                        .leading
                    )
                    .lineSpacing(2)
                }

                Spacer()

                // MARK: Selection

                Image(
                    systemName:
                        selected
                        ? "checkmark.circle.fill"
                        : "circle"
                )
                .font(
                    .system(
                        size: 18
                    )
                )
                .foregroundColor(
                    selected
                    ? Color.ibdGreen
                    : Color.ibdSecondaryText
                        .opacity(0.35)
                )
            }
            .padding(16)
            .background(
                RoundedRectangle(
                    cornerRadius: 15
                )
                .fill(
                    selected
                    ? Color.ibdGreen
                        .opacity(0.08)
                    : Color.white
                )
            )
            .overlay(
                RoundedRectangle(
                    cornerRadius: 15
                )
                .stroke(
                    selected
                    ? Color.ibdGreen
                    : Color.black.opacity(0.07),
                    lineWidth:
                        selected
                        ? 1.2
                        : 1
                )
            )
        }
        .buttonStyle(.plain)
    }
}


// MARK: - Empty State

struct EmptyTreatmentFormsView: View {

    var body: some View {

        VStack(
            alignment: .leading,
            spacing: 12
        ) {

            Text(
                "We need one more detail"
            )
            .font(.headline)

            Text(
                "We don't have a verified administration form for this treatment yet. You can go back and choose another treatment."
            )
            .font(.subheadline)
            .foregroundColor(
                .ibdSecondaryText
            )
            .lineSpacing(4)
        }
        .padding(18)
        .frame(
            maxWidth: .infinity,
            alignment: .leading
        )
        .background(
            RoundedRectangle(
                cornerRadius: 15
            )
            .fill(Color.white)
        )
    }
}
