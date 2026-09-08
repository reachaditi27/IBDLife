import SwiftUI

struct AboutYouView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var onboarding: OnboardingData

    var body: some View {

        ScrollView(showsIndicators: false) {

            VStack(alignment: .leading, spacing: 0) {

                // MARK: Back

                Button {
                    dismiss()
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 14, weight: .semibold))

                        Text("Back")
                            .fontWeight(.medium)
                    }
                    .foregroundColor(.ibdSecondaryText)
                }
                .buttonStyle(.plain)
                .padding(.top, 8)

                Spacer()
                    .frame(height: 28)

                // MARK: Progress

                Text("STEP 1 OF 7")
                    .font(.caption.weight(.bold))
                    .tracking(1.5)
                    .foregroundColor(.ibdSecondaryText)

                Spacer()
                    .frame(height: 14)

                // MARK: Title

                VStack(alignment: .leading, spacing: 2) {

                    Text("Tell us a little")
                        .font(
                            .system(
                                size: 38,
                                weight: .bold,
                                design: .serif
                            )
                        )

                    Text("about yourself")
                        .font(
                            .system(
                                size: 34,
                                design: .serif
                            )
                        )
                        .italic()
                }

                Spacer()
                    .frame(height: 18)

                // MARK: Description

                Text(
                    "This helps us provide more relevant guidance and dosage context."
                )
                .font(.subheadline)
                .foregroundColor(.ibdSecondaryText)
                .lineSpacing(4)

                Spacer()
                    .frame(height: 8)

                Text("All fields are optional • Stored only on your device")
                    .font(.footnote)
                    .foregroundColor(.ibdSecondaryText)

                Spacer()
                    .frame(height: 40)

                // MARK: Personal

                Text("PERSONAL")
                    .font(.caption.weight(.bold))
                    .tracking(1.2)
                    .foregroundColor(.ibdSecondaryText)

                Spacer()
                    .frame(height: 16)

                // Age

                LabeledTextField(
                    title: "Age",
                    placeholder: "e.g. 18",
                    text: $onboarding.age
                )

                Spacer()
                    .frame(height: 24)

                // Gender

                VStack(alignment: .leading, spacing: 12) {

                    Text("Gender")
                        .font(.headline)

                    HStack(spacing: 10) {

                        SelectionChip(
                            title: "Male",
                            selected: onboarding.gender == .male
                        ) {
                            onboarding.gender = .male
                        }

                        SelectionChip(
                            title: "Female",
                            selected: onboarding.gender == .female
                        ) {
                            onboarding.gender = .female
                        }
                    }

                    HStack(spacing: 10) {

                        SelectionChip(
                            title: "Non-binary",
                            selected: onboarding.gender == .nonBinary
                        ) {
                            onboarding.gender = .nonBinary
                        }

                        SelectionChip(
                            title: "Prefer not to say",
                            selected: onboarding.gender == .preferNotToSay
                        ) {
                            onboarding.gender = .preferNotToSay
                        }
                    }
                }

                Spacer()
                    .frame(height: 48)

                // MARK: Measurements

                Text("MEASUREMENTS")
                    .font(.caption.weight(.bold))
                    .tracking(1.2)
                    .foregroundColor(.ibdSecondaryText)

                Spacer()
                    .frame(height: 16)

                Text("Units")
                    .font(.headline)

                Spacer()
                    .frame(height: 10)

                UnitPicker(selectedUnit: $onboarding.unitSystem)

                Spacer()
                    .frame(height: 28)

                // Weight

                LabeledTextField(
                    title: "Weight",
                    placeholder: onboarding.unitSystem == .imperial
                        ? "e.g. 160"
                        : "e.g. 72",
                    text: $onboarding.weight
                )

                Spacer()
                    .frame(height: 24)

                // Height

                Text("Height")
                    .font(.headline)

                Spacer()
                    .frame(height: 10)

                if onboarding.unitSystem == .imperial {

                    HStack(spacing: 12) {

                        UnitTextField(
                            placeholder: "5",
                            unit: "ft",
                            text: $onboarding.heightFeet
                        )

                        UnitTextField(
                            placeholder: "11",
                            unit: "in",
                            text: $onboarding.heightInches
                        )
                    }

                } else {

                    UnitTextField(
                        placeholder: "170",
                        unit: "cm",
                        text: $onboarding.heightCentimeters
                    )
                }

                Spacer()
                    .frame(height: 64)

                // MARK: Continue

                NavigationLink {
                    DiagnosisView()
                } label: {
                    PrimaryButton(title: "Continue")
                }

                Spacer()
                    .frame(height: 24)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 32)
        }
        .background(Color.ibdCream)
        .navigationBarBackButtonHidden(true)
    }
}

#Preview {
    NavigationStack {
        AboutYouView()
            .environmentObject(OnboardingData())
    }
}
