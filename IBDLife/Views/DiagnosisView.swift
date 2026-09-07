import SwiftUI

struct DiagnosisView: View {

    @Environment(\.dismiss) private var dismiss

    @State private var selectedDiagnoses: Set<Diagnosis> = []

    var body: some View {

        ScrollView(showsIndicators: false) {

            VStack(alignment: .leading, spacing: 0) {

                // MARK: Back

                Button {
                    dismiss()
                } label: {

                    HStack(spacing: 6) {

                        Image(systemName: "chevron.left")
                            .font(.system(size: 13, weight: .semibold))

                        Text("Back")
                            .font(.subheadline)
                    }
                    .foregroundColor(.ibdSecondaryText)
                }

                Spacer()
                    .frame(height: 28)

                // MARK: Step

                Text("STEP 2 OF 6")
                    .font(.caption.weight(.bold))
                    .tracking(1.6)
                    .foregroundColor(.ibdSecondaryText)

                Spacer()
                    .frame(height: 14)

                // MARK: Title

                VStack(alignment: .leading, spacing: 0) {

                    Text("Which IBD")
                        .font(.system(size: 38, weight: .bold, design: .serif))

                    Text("condition(s)")
                        .font(.system(size: 38, weight: .bold, design: .serif))

                    Text("have you been")
                        .font(.system(size: 33, design: .serif))
                        .italic()

                    Text("diagnosed with?")
                        .font(.system(size: 33, design: .serif))
                        .italic()
                }

                Spacer()
                    .frame(height: 18)

                Text("Select all that apply. Your selection helps us personalize medication reminders and symptom logging, and support you with medication management.")
                    .font(.system(size: 16))
                    .foregroundColor(.ibdSecondaryText)
                    .lineSpacing(4)

                Spacer()
                    .frame(height: 30)

                // MARK: Crohn's

                DiagnosisCard(
                    title: "Crohn's Disease",
                    description: "Inflammation anywhere along the GI tract, often in patches. Can affect the full thickness of the bowel wall.",
                    tags: [
                        "SMALL INTESTINE",
                        "LARGE INTESTINE",
                        "MOUTH TO ANUS"
                    ],
                    selected: selectedDiagnoses.contains(.crohns)
                ) {
                    toggle(.crohns)
                }

                Spacer()
                    .frame(height: 12)

                // MARK: UC

                DiagnosisCard(
                    title: "Ulcerative Colitis",
                    description: "Continuous inflammation of the colon and rectum. Affects only the innermost lining of the large intestine.",
                    tags: [
                        "COLON",
                        "RECTUM"
                    ],
                    selected: selectedDiagnoses.contains(.ulcerativeColitis)
                ) {
                    toggle(.ulcerativeColitis)
                }

                Spacer()
                    .frame(height: 12)

                // MARK: Microscopic

                DiagnosisCard(
                    title: "Microscopic Colitis",
                    description: "Inflammation visible only under a microscope. Includes collagenous and lymphocytic colitis subtypes.",
                    tags: [
                        "COLON"
                    ],
                    selected: selectedDiagnoses.contains(.microscopicColitis)
                ) {
                    toggle(.microscopicColitis)
                }

                Spacer()
                    .frame(height: 12)

                // MARK: IBDU

                DiagnosisCard(
                    title: "IBD Unclassified (IBDU)",
                    description: "Features of both Crohn's and UC that cannot be clearly distinguished. Sometimes called indeterminate colitis.",
                    tags: [
                        "COLON",
                        "TERMINAL ILEUM"
                    ],
                    selected: selectedDiagnoses.contains(.ibdUnclassified)
                ) {
                    toggle(.ibdUnclassified)
                }

                Spacer()
                    .frame(height: 20)

                // MARK: Info

                HStack(alignment: .top, spacing: 10) {

                    Image(systemName: "info.circle")
                        .foregroundColor(.ibdSecondaryText)
                        .padding(.top, 2)

                    Text("Not sure of your exact diagnosis? Select your closest match — you can update this at any time from your profile settings.")
                        .font(.system(size: 14))
                        .foregroundColor(.ibdSecondaryText)
                        .lineSpacing(3)
                }
                .padding(16)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.ibdCream.opacity(0.7))
                .clipShape(RoundedRectangle(cornerRadius: 14))

                Spacer()
                    .frame(height: 28)

                NavigationLink {
                    MedicationsView(selectedDiagnoses: selectedDiagnoses)
                } label: {
                    PrimaryButton(title: "Continue")
                        .opacity(selectedDiagnoses.isEmpty ? 0.5 : 1)
                }
                .disabled(selectedDiagnoses.isEmpty)

                Spacer()
                    .frame(height: 28)
            }
            .padding(.horizontal, 24)
            .padding(.top, 12)
            .padding(.bottom, 32)
        }
        .background(Color.ibdCream.ignoresSafeArea())
        .navigationBarBackButtonHidden(true)
    }

    private func toggle(_ diagnosis: Diagnosis) {

        if selectedDiagnoses.contains(diagnosis) {
            selectedDiagnoses.remove(diagnosis)
        } else {
            selectedDiagnoses.insert(diagnosis)
        }
    }
}

#Preview {

    NavigationStack {

        DiagnosisView()
    }
}
