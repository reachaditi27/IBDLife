import SwiftUI

struct DiagnosisView: View {

    @Environment(\.dismiss) private var dismiss

    @EnvironmentObject var onboarding: OnboardingData
    @State private var showAdditionalConditions = false
    private var selectedDiagnoses: Set<Diagnosis> {
        Set(onboarding.diagnoses.compactMap(Diagnosis.init(rawValue:)))
    }

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

                Text("STEP 2 · CONDITION")
                    .font(.caption.weight(.bold))
                    .tracking(1.6)
                    .foregroundColor(.ibdSecondaryText)

                Spacer()
                    .frame(height: 14)

                // MARK: Title

                VStack(alignment: .leading, spacing: 0) {

                    Text("Which IBD")
                        .font(.system(size: 38, weight: .bold, design: .serif))

                    Text("condition")
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

                Text("Choose your primary diagnosis. Your selection helps us personalize medication reminders, symptom logging, and medication management.")
                    .font(.system(size: 16))
                    .foregroundColor(.ibdSecondaryText)
                    .lineSpacing(4)

                Spacer()
                    .frame(height: 30)

                // MARK: Crohn's

                DiagnosisCard(
                    title: "Crohn's Disease",
                    description: "Inflammation anywhere along the GI tract, often in patches. Can affect the full thickness of the bowel wall.",
                    tags: [],
                    selected: onboarding.primaryDiagnosis == .crohns
                ) {
                    selectPrimary(.crohns)
                }

                Spacer()
                    .frame(height: 12)

                // MARK: UC

                DiagnosisCard(
                    title: "Ulcerative Colitis",
                    description: "Continuous inflammation of the colon and rectum. Affects only the innermost lining of the large intestine.",
                    tags: [],
                    selected: onboarding.primaryDiagnosis == .ulcerativeColitis
                ) {
                    selectPrimary(.ulcerativeColitis)
                }

                Spacer()
                    .frame(height: 12)

                // MARK: IBDU

                DiagnosisCard(
                    title: "IBD Unclassified (IBDU)",
                    description: "Features of both Crohn's and UC that cannot be clearly distinguished. Sometimes called indeterminate colitis.",
                    tags: [],
                    selected: onboarding.primaryDiagnosis == .ibdUnclassified
                ) {
                    selectPrimary(.ibdUnclassified)
                }

                Spacer()
                    .frame(height: 20)

                if onboarding.primaryDiagnosis != nil {
                    if showAdditionalConditions {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("ADDITIONAL CONDITIONS")
                                .font(.caption.weight(.bold)).tracking(1.2)
                                .foregroundColor(.ibdSecondaryText)
                            ForEach(Diagnosis.allCases.filter { $0 != onboarding.primaryDiagnosis }, id: \.self) { diagnosis in
                                additionalConditionRow(diagnosis)
                            }
                            Button("Use one condition only") {
                                onboarding.removeAdditionalDiagnoses()
                                showAdditionalConditions = false
                            }
                            .font(.system(size: 14)).foregroundColor(.ibdSecondaryText).underline()
                            .frame(maxWidth: .infinity, minHeight: 44)
                        }
                    } else {
                        Button {
                            showAdditionalConditions = true
                        } label: {
                            Label("Add another condition", systemImage: "plus.circle")
                                .font(.system(size: 14, weight: .medium)).foregroundColor(.ibdGreen)
                                .frame(maxWidth: .infinity, minHeight: 48)
                                .background(.white, in: RoundedRectangle(cornerRadius: 14))
                                .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.ibdBorder))
                        }.buttonStyle(.plain)
                    }

                    Spacer().frame(height: 20)
                }

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
        .onAppear { showAdditionalConditions = onboarding.diagnoses.count > 1 }
        .navigationBarBackButtonHidden(true)
    }

    private func selectPrimary(_ diagnosis: Diagnosis) {
        onboarding.setPrimaryDiagnosis(diagnosis, preservingAdditional: showAdditionalConditions)
    }

    private func additionalConditionRow(_ diagnosis: Diagnosis) -> some View {
        let selected = onboarding.additionalDiagnoses.contains(diagnosis)
        return Button {
            onboarding.setAdditionalDiagnosis(diagnosis, selected: !selected)
        } label: {
            HStack {
                Image(systemName: selected ? "checkmark.square.fill" : "square")
                    .font(.system(size: 20)).foregroundColor(selected ? .ibdGreen : .ibdSecondaryText)
                Text(diagnosis.displayName).font(.system(size: 15, weight: .medium)).foregroundColor(.primary)
                Spacer()
            }
            .padding(16).background(.white, in: RoundedRectangle(cornerRadius: 14))
            .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.ibdBorder))
        }
        .buttonStyle(.plain)
        .accessibilityValue(selected ? "Selected" : "Not selected")
    }
}

#Preview {

    NavigationStack {

        DiagnosisView().environmentObject(OnboardingData(fileURL: nil))
    }
}
