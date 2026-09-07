import SwiftUI

struct AboutYouView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var onboarding: OnboardingData

    @State private var age = ""
    @State private var weight = ""

    @State private var feet = ""
    @State private var inches = ""
    @State private var centimeters = ""

    @State private var selectedUnit: MeasurementUnit = .imperial
    @State private var selectedGender: String?

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

                Text("STEP 1 OF 6")
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
                    text: $age
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
                            selected: selectedGender == "Male"
                        ) {
                            selectedGender = "Male"
                        }

                        SelectionChip(
                            title: "Female",
                            selected: selectedGender == "Female"
                        ) {
                            selectedGender = "Female"
                        }
                    }

                    HStack(spacing: 10) {

                        SelectionChip(
                            title: "Non-binary",
                            selected: selectedGender == "Non-binary"
                        ) {
                            selectedGender = "Non-binary"
                        }

                        SelectionChip(
                            title: "Prefer not to say",
                            selected: selectedGender == "Prefer not to say"
                        ) {
                            selectedGender = "Prefer not to say"
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

                UnitPicker(selectedUnit: $selectedUnit)

                Spacer()
                    .frame(height: 28)

                // Weight

                LabeledTextField(
                    title: "Weight",
                    placeholder: selectedUnit == .imperial
                        ? "e.g. 160"
                        : "e.g. 72",
                    text: $weight
                )

                Spacer()
                    .frame(height: 24)

                // Height

                Text("Height")
                    .font(.headline)

                Spacer()
                    .frame(height: 10)

                if selectedUnit == .imperial {

                    HStack(spacing: 12) {

                        UnitTextField(
                            placeholder: "5",
                            unit: "ft",
                            text: $feet
                        )

                        UnitTextField(
                            placeholder: "11",
                            unit: "in",
                            text: $inches
                        )
                    }

                } else {

                    UnitTextField(
                        placeholder: "170",
                        unit: "cm",
                        text: $centimeters
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
