import SwiftUI

enum TreatmentSetupCompletion {
    case nutritionSelection
    case finish
}

/// Reuses the existing schedule, injection-site, and supply screens for each chosen treatment.
struct TreatmentSetupFlow: View {
    let medications: [Medication]
    var completion: TreatmentSetupCompletion = .nutritionSelection
    @EnvironmentObject var onboarding: OnboardingData
    @Environment(\.dismiss) private var dismiss
    @State private var index = 0
    @State private var phase = 0

    var body: some View {
        Group {
            if index >= medications.count {
                switch completion {
                case .nutritionSelection:
                    NutritionSelectionView(onBack: returnToLastTreatment)
                case .finish:
                    Step7PlaceholderView()
                }
            } else {
                let medication = medications[index]
                let plan = onboarding.plan(for: medication.id)
                if phase == 0 {
                    DosingScheduleView(
                        medication: medication,
                        onContinue: { phase = plan.isInjection ? 1 : 2 },
                        onBack: goBack
                    )
                } else if phase == 1 {
                    InjectionSiteView(treatmentID: medication.id, onContinue: { phase = 2 }, onBack: { phase = 0 })
                } else {
                    DosesPerOrderEditorView(treatmentID: medication.id, isSetup: true, onComplete: {
                        index += 1; phase = 0
                    }, onBack: { phase = plan.isInjection ? 1 : 0 })
                }
            }
        }.id("\(index)-\(phase)")
    }

    private func goBack() {
        if index > 0 { index -= 1; phase = 2 }
        else { dismiss() }
    }

    private func returnToLastTreatment() {
        guard !medications.isEmpty else { dismiss(); return }
        index = medications.count - 1
        phase = 2
    }
}
