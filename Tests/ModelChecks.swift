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

        let conditionStore = OnboardingData(fileURL: nil)
        conditionStore.setPrimaryDiagnosis(.crohns)
        conditionStore.setAdditionalDiagnosis(.microscopicColitis, selected: true)
        precondition(conditionStore.primaryDiagnosis == .crohns &&
                     conditionStore.additionalDiagnoses == [.microscopicColitis],
                     "Primary and uncommon additional diagnoses remain distinct")
        conditionStore.setPrimaryDiagnosis(.ulcerativeColitis, preservingAdditional: true)
        precondition(conditionStore.primaryDiagnosis == .ulcerativeColitis &&
                     Set(conditionStore.additionalDiagnoses) == [.crohns, .microscopicColitis])
        conditionStore.removeAdditionalDiagnoses()
        precondition(conditionStore.diagnoses == [Diagnosis.ulcerativeColitis.rawValue],
                     "Returning to single-condition mode removes only additional diagnoses")
        precondition(MedicationDatabase.selectedAlternativeGroups(in: ["humira", "amjevita"]).count == 1)
        precondition(MedicationDatabase.selectedAlternativeGroups(in: ["humira", "stelara"]).isEmpty,
                     "Only likely originator/biosimilar alternatives trigger a selection notice")
        precondition(MedicationDatabase.medications.first { $0.id == "ensure plus" }?.isNutrition == true)
        precondition(MedicationDatabase.medications.first { $0.id == "humira" }?.isNutrition == false,
                     "Nutrition products remain distinguishable from medication")
        for previous in SupportAffirmations.sets.indices {
            precondition(SupportAffirmations.nextIndex(after: previous) != previous,
                         "A support visit does not immediately repeat its affirmation set")
        }

        let reminderNow = calendar.date(from: DateComponents(year: 2026, month: 9, day: 7, hour: 8))!
        plan.frequency = .everyTwoWeeks; plan.startDate = september
        plan.dosesPerOrder = 2; plan.dosesRemaining = 2
        let reminders = MedicationReminderPlanner.reminders(treatments: [plan], records: [],
                                                             now: reminderNow, calendar: calendar)
        let doseReminders = reminders.filter { $0.kind == .dose }
        let refillReminders = reminders.filter { $0.kind == .refill }
        precondition(doseReminders.first?.date == calendar.date(from: DateComponents(year: 2026, month: 9, day: 7, hour: 9)),
                     "Morning slot schedules at 9 AM local time")
        precondition(refillReminders.first?.date == calendar.date(from: DateComponents(year: 2026, month: 9, day: 14, hour: 9)),
                     "Refill reminder is one week before the projected last dose")
        let nutritionPlan = TreatmentPlan(id: "ensure plus", forms: [.oralNutritionDrink], frequency: .onceDaily,
                                          startDate: september)
        let nutritionReminder = MedicationReminderPlanner.reminders(treatments: [nutritionPlan], records: [],
                                                                     now: reminderNow, calendar: calendar).first
        precondition(nutritionReminder?.title == "Nutrition reminder" &&
                     nutritionReminder?.body.contains("serving") == true,
                     "Nutrition notifications are not labeled as medication")
        precondition(Set(reminders.map(\.id)).count == reminders.count, "Reminder identifiers are stable and unique")
        let recordedFirst = DoseRecord(id: "humira-\(Int(september.timeIntervalSince1970))-0", treatmentID: "humira",
                                       scheduledDate: september, recordedDate: september, site: nil, doseNumber: 1)
        let afterRecording = MedicationReminderPlanner.reminders(treatments: [plan], records: [recordedFirst],
                                                                 now: reminderNow, calendar: calendar)
        precondition(!afterRecording.contains { $0.id == "ibdlife.dose.\(recordedFirst.id)" },
                     "Recorded doses do not keep pending reminders")
        var depletedPlan = plan
        depletedPlan.frequency = .onceDaily; depletedPlan.dosesPerOrder = 1; depletedPlan.dosesRemaining = 0
        let depletedReminders = MedicationReminderPlanner.reminders(treatments: [depletedPlan], records: [],
                                                                     now: reminderNow, calendar: calendar)
        let catchUpDate = calendar.date(byAdding: .minute, value: 1, to: reminderNow)
        precondition(depletedReminders.filter { $0.kind == .refill && $0.date == catchUpDate }.count == 1,
                     "Overdue refill alerts are coalesced instead of arriving in a burst")
        var frequentPlan = plan
        frequentPlan.frequency = .threeTimesDaily
        precondition(MedicationReminderPlanner.reminders(treatments: [frequentPlan], records: [],
                                                          now: reminderNow, calendar: calendar).count
                     == MedicationReminderPlanner.maximumPending,
                     "Notification plan stays below the system pending-request limit")

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
        precondition(store.updateBodyMeasurement(unitSystem: .imperial, weight: "160",
                                                 heightFeet: "5", heightInches: "10", at: today))
        precondition(abs((store.currentBodyMeasurement?.bmi ?? 0) - 22.96) < 0.02,
                     "Imperial height and weight produce the expected BMI")
        precondition(store.bodyMeasurements.count == 1)
        precondition(store.updateBodyMeasurement(unitSystem: .imperial, weight: "160",
                                                 heightFeet: "5", heightInches: "10", at: today),
                     "Valid unchanged measurements are accepted")
        precondition(store.bodyMeasurements.count == 1, "Unchanged measurements do not duplicate history")
        precondition(!store.updateBodyMeasurement(unitSystem: .metric, weight: "invalid",
                                                  heightCentimeters: "170", at: today))
        precondition(store.unitSystem == .imperial && store.weight == "160" && store.bodyMeasurements.count == 1,
                     "Invalid measurement edits do not replace saved values")
        store.medicationRemindersEnabled = true
        store.completedOnboarding = true
        let restored = OnboardingData(fileURL: temporary)
        precondition(restored.name == store.name && restored.age == "30")
        precondition(restored.treatments.count == 2 && restored.completedOnboarding)
        precondition(restored.medicationRemindersEnabled, "Reminder opt-in persists locally")
        precondition(restored.symptoms.count == 2 && restored.symptoms[1].note == "A test note")
        precondition(restored.bodyMeasurements.count == 1 && abs(restored.bodyMeasurements[0].bmi - 22.96) < 0.02,
                     "BMI history persists locally")
        precondition(restored.doseRecords.count == 1 && restored.plan(for: "humira").dosesRemaining == 1)
        precondition(restored.doses(from: today, through: today).count == 2, "Recorded dose stays recorded after relaunch")
        precondition(restored.storageError == nil)
        UserDefaults.standard.set(2, forKey: "lastSupportAffirmationSet")
        precondition(restored.resetAllData(), "A local reset succeeds")
        precondition(!FileManager.default.fileExists(atPath: temporary.path), "Reset removes the saved snapshot")
        precondition(restored.name.isEmpty && restored.diagnoses.isEmpty && restored.treatments.isEmpty &&
                     restored.symptoms.isEmpty && restored.doseRecords.isEmpty && restored.bodyMeasurements.isEmpty &&
                     !restored.completedOnboarding && !restored.medicationRemindersEnabled,
                     "Reset restores the first-launch in-memory state")
        precondition(UserDefaults.standard.object(forKey: "lastSupportAffirmationSet") == nil,
                     "Reset removes local support-screen preferences")
        let resetStore = OnboardingData(fileURL: temporary)
        precondition(!resetStore.completedOnboarding && resetStore.name.isEmpty,
                     "A reset relaunch starts onboarding")
        // An already-taken morning/afternoon dose must leave later slots today available.
        let partial = OnboardingData(fileURL: nil)
        partial.configureSchedule(id: "ensure plus", frequency: .twiceDaily, date: today,
                                  alreadyTaken: true, lastTakenSlot: 0)
        let evening = partial.doses(from: today, through: today)
        precondition(evening.map(\.slot) == [2] && evening.first?.ordinal == 2)
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: today)!
        precondition(partial.doses(from: tomorrow, through: tomorrow).map(\.ordinal) == [3, 4])
        partial.configureSchedule(id: "ensure plus", frequency: .threeTimesDaily, date: today,
                                  alreadyTaken: true, lastTakenSlot: 1)
        precondition(partial.doses(from: today, through: today).map(\.slot) == [2])
        partial.configureSchedule(id: "ensure plus", frequency: .twiceDaily, date: today,
                                  alreadyTaken: true, lastTakenSlot: 2)
        precondition(partial.doses(from: today, through: today).isEmpty)
        precondition(partial.doses(from: tomorrow, through: tomorrow).map(\.slot) == [0, 2])
        // Version-1 plans without new optional fields still load with their original schedule.
        let oldPlan = Data(#"{"id":"humira","forms":[],"sites":[]}"#.utf8)
        let decoded = try JSONDecoder().decode(TreatmentPlan.self, from: oldPlan)
        precondition(decoded.startSlot == nil && decoded.lastTakenSlot == nil)
        let roundTrip = try JSONDecoder().decode(TreatmentPlan.self, from: JSONEncoder().encode(partial.plan(for: "ensure plus")))
        precondition(roundTrip.lastTakenSlot == 2)
        // The actual site overrides the forecast and does not affect another treatment.
        plan.frequency = .everyTwoWeeks; plan.startDate = september
        plan.sites = [.leftAbdomen, .rightAbdomen, .leftThigh, .rightThigh]
        let override = DoseRecord(id: doses[0].id, treatmentID: plan.id, scheduledDate: september,
                                  recordedDate: september, site: .leftThigh, doseNumber: 1)
        let rotated = DoseSchedule.doses(for: plan, from: september, through: date(2026, 10, 6),
                                        records: [override], calendar: calendar)
        precondition(rotated.map(\.site) == [.leftThigh, .rightThigh, .leftAbdomen])
        precondition(rotated.map(\.id) == doses.map(\.id), "Site changes do not change dose identities")
        let isolated = DoseSchedule.doses(for: plan, from: september, through: september,
                                         records: [DoseRecord(id: "other", treatmentID: "other", scheduledDate: september,
                                                              recordedDate: september, site: .rightThigh, doseNumber: 1)], calendar: calendar)
        precondition(isolated.first?.site == .leftAbdomen)
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: today)!
        partial.configureSchedule(id: "ensure plus", frequency: .twiceDaily, date: yesterday, alreadyTaken: false)
        let overdue = partial.unrecordedPastDoses()
        precondition(overdue.count == 2 && overdue.allSatisfy { $0.date < today })
        partial.recordDose(overdue[0], site: nil, at: yesterday)
        precondition(partial.unrecordedPastDoses().count == 1)
        precondition(partial.doseRecords.last?.recordedDate == yesterday, "Historical entry keeps actual date taken")
        precondition(partial.doses(from: today, through: today).count == 2, "Historical entry leaves today's slots intact")
        print("PASS: recurrence, DST, condition/medication/nutrition selection, rotating support, reminders/refills, BMI/history, local reset, per-day slots, site rotation, multiple treatments, explicit history, duplicate/future guards, refill counts, symptoms, and persistence")
    }
}
