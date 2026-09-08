import Foundation

/// Run with the command in Tests/README.md. These tests use a temporary local store only.
@main
struct ModelChecks {
    static func main() throws {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "America/New_York")!
        func date(_ year: Int, _ month: Int, _ day: Int) -> Date {
            calendar.date(from: DateComponents(year: year, month: month, day: day))!
        }
        let september = date(2026, 9, 7)
        var plan = TreatmentPlan(id: "humira", forms: [.autoInjector], frequency: .everyTwoWeeks,
                                 startDate: september, sites: [.leftThigh, .rightThigh])
        let doses = DoseSchedule.doses(for: plan, from: september, through: date(2026, 10, 6), records: [], calendar: calendar)
        precondition(doses.count == 3, "Fortnightly recurrence")
        precondition(doses.map(\.date) == [september, date(2026, 9, 21), date(2026, 10, 5)])
        precondition(doses.map(\.site) == [.leftThigh, .rightThigh, .leftThigh], "Preferred-site rotation")
        precondition(Set(doses.map(\.id)).count == 3)
        plan.frequency = .twiceDaily
        let daily = DoseSchedule.doses(for: plan, from: september, through: september, records: [], calendar: calendar)
        precondition(daily.count == 2 && daily.map(\.timeLabel) == ["Morning", "Evening"])
        precondition(Set(daily.map(\.id)).count == 2, "Daily slots have distinct identities")
        plan.frequency = .threeTimesDaily
        precondition(DoseSchedule.doses(for: plan, from: september, through: september, records: [], calendar: calendar).count == 3)
        plan.frequency = .asNeeded
        precondition(DoseSchedule.doses(for: plan, from: september, through: date(2027, 1, 1), records: [], calendar: calendar).isEmpty)

        plan.frequency = .weekly; plan.startDate = date(2026, 3, 1)
        let dst = DoseSchedule.doses(for: plan, from: date(2026, 3, 1), through: date(2026, 3, 16), records: [], calendar: calendar)
        precondition(dst.map { calendar.component(.day, from: $0.date) } == [1, 8, 15], "Weekly dates cross DST without drifting")
        precondition(dst.allSatisfy { calendar.component(.hour, from: $0.date) == 0 })

        let temporary = FileManager.default.temporaryDirectory.appendingPathComponent("IBDLife-test-\(UUID().uuidString)/data.json")
        defer { try? FileManager.default.removeItem(at: temporary.deletingLastPathComponent()) }
        let store = OnboardingData(fileURL: temporary)
        store.name = "Persistence Test"; store.age = "30"; store.diagnoses = [Diagnosis.crohns.rawValue]
        let selected = MedicationDatabase.medications.filter { ["humira", "ensure plus"].contains($0.id) }
        store.selectMedications(selected)
        let today = Calendar.current.startOfDay(for: Date())
        var humira = store.plan(for: "humira")
        humira.forms = [.autoInjector]; humira.sites = [.leftThigh]
        humira.dosesPerOrder = 2; humira.dosesRemaining = 2
        store.updatePlan(humira)
        store.configureSchedule(id: "humira", frequency: .everyTwoWeeks, date: today, alreadyTaken: false)
        store.configureSchedule(id: "ensure plus", frequency: .twiceDaily, date: today, alreadyTaken: false)
        precondition(store.doses(from: today, through: today).count == 3, "Multiple treatments keep independent schedules")
        precondition(store.doseRecords.isEmpty, "Projected doses are not history")
        let scheduled = store.doses(from: today, through: today).first { $0.treatmentID == "humira" }!
        store.recordDose(scheduled, site: .leftThigh)
        store.recordDose(scheduled, site: .leftThigh)
        precondition(store.doseRecords.count == 1, "Duplicate confirmation is ignored")
        precondition(store.plan(for: "humira").dosesRemaining == 1)
        precondition(store.doses(from: today, through: today).count == 2)
        let next = store.upcoming().first { $0.treatmentID == "humira" }!
        precondition(next.needsRefill, "Remaining supply drives refill badge")
        store.recordDose(next, site: .leftThigh)
        precondition(store.doseRecords.count == 1, "Future doses cannot be recorded")
        store.addSymptom(mood: .okay, note: "  A test note  ")
        store.addSymptom(mood: .great, note: "")
        store.completedOnboarding = true
        let restored = OnboardingData(fileURL: temporary)
        precondition(restored.name == store.name && restored.age == "30")
        precondition(restored.treatments.count == 2 && restored.completedOnboarding)
        precondition(restored.symptoms.count == 2 && restored.symptoms[1].note == "A test note")
        precondition(restored.doseRecords.count == 1 && restored.plan(for: "humira").dosesRemaining == 1)
        precondition(restored.doses(from: today, through: today).count == 2, "Recorded dose stays recorded after relaunch")
        precondition(restored.storageError == nil)
        print("PASS: recurrence, DST, per-day slots, site rotation, multiple treatments, explicit history, duplicate/future guards, refill counts, symptoms, and persistence")
    }
}
