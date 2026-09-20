import Foundation

extension OnboardingData {
    static func launchStore() -> OnboardingData {
        #if DEBUG
        if let index = ProcessInfo.processInfo.arguments.firstIndex(of: "--review-scenario"),
           ProcessInfo.processInfo.arguments.indices.contains(index + 1) {
            return reviewStore(scenario: ProcessInfo.processInfo.arguments[index + 1])
        }
        #endif
        return OnboardingData()
    }

    #if DEBUG
    /// Explicit development-only fixtures. In-memory storage never touches the user's saved profile.
    static func reviewStore(scenario: String) -> OnboardingData {
        let store = OnboardingData(fileURL: nil)
        guard scenario != "onboarding" else { return store }
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        func offset(_ days: Int) -> Date { calendar.date(byAdding: .day, value: days, to: today)! }
        store.name = scenario == "no-dose" ? "Test" : ""
        store.diagnoses = [Diagnosis.crohns.rawValue]
        store.updateBodyMeasurement(unitSystem: .imperial, weight: "162", heightFeet: "5", heightInches: "10",
                                    at: offset(-30))
        store.updateBodyMeasurement(unitSystem: .imperial, weight: "160", heightFeet: "5", heightInches: "10",
                                    at: today)
        store.selectMedications(MedicationDatabase.medications.filter { $0.id == "humira" })
        var plan = store.plan(for: "humira")
        plan.forms = [.autoInjector]
        plan.sites = scenario == "no-dose" ? [.leftThigh] : InjectionSite.allCases
        plan.dosesPerOrder = 2; plan.dosesRemaining = 2
        store.updatePlan(plan)
        store.configureSchedule(id: "humira", frequency: scenario == "no-dose" ? .everyTwoWeeks : .onceDaily,
                                date: scenario == "no-dose" ? offset(-9) : offset(-1), alreadyTaken: true)
        if scenario == "no-dose" {
            store.doseRecords = (0..<6).map { index in
                DoseRecord(id: "review-history-\(index)", treatmentID: "humira", scheduledDate: offset(-9 - index * 14),
                           recordedDate: offset(-9 - index * 14), site: InjectionSite.allCases[index], doseNumber: 6 - index)
            }
        }
        store.symptoms = [SymptomEntry(date: Date(), mood: .okay, note: "I am feeling Okay")]
        store.completedOnboarding = true
        if scenario == "recorded", let dose = store.doses(from: today, through: today).first {
            store.recordDose(dose, site: dose.site)
        }
        return store
    }
    #endif
}
