import SwiftUI

/// Reuses the existing site and schedule screens once for each chosen treatment.
struct TreatmentSetupFlow: View {
    let medications: [Medication]
    @EnvironmentObject var onboarding: OnboardingData
    @Environment(\.dismiss) private var dismiss
    @State private var index = 0
    @State private var phase = 0

    var body: some View {
        Group {
            if index >= medications.count {
                Step7PlaceholderView()
            } else {
                let medication = medications[index]
                let plan = onboarding.plan(for: medication.id)
                if phase == 0 && plan.isInjection {
                    InjectionSiteView(treatmentID: medication.id, onContinue: { phase = 1 }, onBack: goBack)
                } else if phase < 2 {
                    DosingScheduleView(medication: medication, onContinue: { phase = 2 }, onBack: goBack)
                } else {
                    DosesPerOrderEditorView(treatmentID: medication.id, isSetup: true, onComplete: {
                        index += 1; phase = 0
                    }, onBack: { phase = 1 })
                }
            }
        }.id("\(index)-\(phase)")
    }

    private func goBack() {
        if phase == 1 && onboarding.plan(for: medications[index].id).isInjection { phase = 0 }
        else if index > 0 { index -= 1; phase = 2 }
        else { dismiss() }
    }
}
