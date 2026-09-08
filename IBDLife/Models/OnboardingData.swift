import Foundation
import Combine

enum Gender: String, CaseIterable, Identifiable, Codable {
    case male = "Male", female = "Female", nonBinary = "Non-binary", preferNotToSay = "Prefer not to say"
    var id: String { rawValue }
}

enum UnitSystem: String, CaseIterable, Identifiable, Codable {
    case imperial = "Imperial (lbs / ft)", metric = "Metric (kg / cm)"
    var id: String { rawValue }
}

/// One local store shared by onboarding and the app. No account or network dependency.
final class OnboardingData: ObservableObject {
    @Published var name = "" { didSet { save() } }
    @Published var age = "" { didSet { save() } }
    @Published var gender: Gender? { didSet { save() } }
    @Published var unitSystem: UnitSystem = .imperial { didSet { save() } }
    @Published var weight = "" { didSet { save() } }
    @Published var heightFeet = "" { didSet { save() } }
    @Published var heightInches = "" { didSet { save() } }
    @Published var heightCentimeters = "" { didSet { save() } }
    @Published var diagnoses: [String] = [] { didSet { save() } }
    @Published var medications: [String] = [] { didSet { save() } }
    @Published var treatments: [TreatmentPlan] = [] { didSet { save() } }
    @Published var symptoms: [SymptomEntry] = [] { didSet { save() } }
    @Published var doseRecords: [DoseRecord] = [] { didSet { save() } }
    @Published var completedOnboarding = false { didSet { save() } }
    @Published var storageError: String?

    private let fileURL: URL?
    private var isLoading = true

    init(fileURL: URL? = OnboardingData.defaultURL) {
        self.fileURL = fileURL
        defer { isLoading = false }
        guard let fileURL, FileManager.default.fileExists(atPath: fileURL.path) else { return }
        do {
            let data = try JSONDecoder().decode(Snapshot.self, from: Data(contentsOf: fileURL))
            name = data.name; age = data.age; gender = data.gender; unitSystem = data.unitSystem
            weight = data.weight; heightFeet = data.heightFeet; heightInches = data.heightInches
            heightCentimeters = data.heightCentimeters; diagnoses = data.diagnoses
            medications = data.medications; treatments = data.treatments; symptoms = data.symptoms
            doseRecords = data.doseRecords; completedOnboarding = data.completedOnboarding
        } catch {
            storageError = "Your saved data could not be opened. Your original file has been kept."
        }
    }

    static var defaultURL: URL {
        URL.applicationSupportDirectory.appending(path: "IBDLife/data.json")
    }

    private struct Snapshot: Codable {
        var version = 1
        var name: String; var age: String; var gender: Gender?; var unitSystem: UnitSystem
        var weight: String; var heightFeet: String; var heightInches: String; var heightCentimeters: String
        var diagnoses: [String]; var medications: [String]; var treatments: [TreatmentPlan]
        var symptoms: [SymptomEntry]; var doseRecords: [DoseRecord]; var completedOnboarding: Bool
    }

    private func save() {
        guard !isLoading, let fileURL, storageError == nil else { return }
        do {
            let snapshot = Snapshot(name: name, age: age, gender: gender, unitSystem: unitSystem,
                                    weight: weight, heightFeet: heightFeet, heightInches: heightInches,
                                    heightCentimeters: heightCentimeters, diagnoses: diagnoses,
                                    medications: medications, treatments: treatments, symptoms: symptoms,
                                    doseRecords: doseRecords, completedOnboarding: completedOnboarding)
            try FileManager.default.createDirectory(at: fileURL.deletingLastPathComponent(), withIntermediateDirectories: true)
            try JSONEncoder().encode(snapshot).write(to: fileURL, options: [.atomic, .completeFileProtectionUnlessOpen])
        } catch {
            storageError = "Your changes could not be saved on this device. Please check available storage."
        }
    }

    func plan(for id: String) -> TreatmentPlan {
        treatments.first { $0.id == id } ?? TreatmentPlan(id: id)
    }

    func updatePlan(_ plan: TreatmentPlan) {
        if let index = treatments.firstIndex(where: { $0.id == plan.id }) {
            treatments[index] = plan
        } else { treatments.append(plan) }
    }

    func selectMedications(_ selection: [Medication]) {
        medications = selection.map(\.id)
        treatments = selection.map { plan(for: $0.id) }
    }

    func configureSchedule(id: String, frequency: DosingFrequency?, date: Date?, alreadyTaken: Bool,
                           lastTakenSlot: Int? = nil) {
        var plan = plan(for: id)
        plan.frequency = frequency
        plan.lastDoseDate = alreadyTaken ? date : nil
        plan.lastTakenSlot = alreadyTaken ? lastTakenSlot : nil
        plan.startSlot = nil
        if let date {
            if alreadyTaken, let frequency, let lastTakenSlot,
               let position = frequency.slots.firstIndex(of: lastTakenSlot), position + 1 < frequency.slots.count {
                plan.startDate = date
                plan.startSlot = frequency.slots[position + 1]
            } else {
                plan.startDate = alreadyTaken
                    ? Calendar.current.date(byAdding: .day, value: frequency?.intervalDays ?? 1, to: date) : date
            }
        } else { plan.startDate = nil }
        // Only a dose the user explicitly reported is added to history, never projected doses.
        doseRecords.removeAll { $0.id == "initial-\(id)" }
        if alreadyTaken, let date {
            doseRecords.append(DoseRecord(id: "initial-\(id)", treatmentID: id, scheduledDate: date,
                                          recordedDate: date, site: nil, doseNumber: 1))
        }
        updatePlan(plan)
    }

    func doses(from: Date, through: Date, includeRecorded: Bool = false) -> [ScheduledDose] {
        let recorded = Set(doseRecords.map(\.id))
        return treatments.flatMap { plan in
            DoseSchedule.doses(for: plan, from: from, through: through, records: doseRecords)
                .filter { includeRecorded || !recorded.contains($0.id) }
        }.sorted { ($0.date, $0.slot, $0.treatmentID) < ($1.date, $1.slot, $1.treatmentID) }
    }

    func upcoming(from now: Date = Date(), days: Int = 180) -> [ScheduledDose] {
        let end = Calendar.current.date(byAdding: .day, value: days, to: now) ?? now
        var upcoming = doses(from: now, through: end)
        for plan in treatments {
            guard let remaining = plan.dosesRemaining, let order = plan.dosesPerOrder, order > 0 else { continue }
            let indices = upcoming.indices.filter { upcoming[$0].treatmentID == plan.id }
            for (offset, index) in indices.enumerated() {
                upcoming[index].needsRefill = offset >= max(0, remaining - 1)
                    && (offset - max(0, remaining - 1)) % order == 0
            }
        }
        return upcoming
    }

    /// Home surfaces recent unrecorded doses; older dates remain accessible in Calendar.
    func unrecordedPastDoses(asOf now: Date = Date()) -> [ScheduledDose] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: now)
        return doses(from: calendar.date(byAdding: .day, value: -90, to: today)!,
                     through: calendar.date(byAdding: .day, value: -1, to: today)!)
            .sorted { ($0.date, $0.slot, $0.treatmentID) > ($1.date, $1.slot, $1.treatmentID) }
    }

    func recordDose(_ dose: ScheduledDose, site: InjectionSite?, at date: Date = Date()) {
        guard !doseRecords.contains(where: { $0.id == dose.id }),
              date <= Date(),
              Calendar.current.startOfDay(for: dose.date) <= Calendar.current.startOfDay(for: date) else { return }
        doseRecords.append(DoseRecord(id: dose.id, treatmentID: dose.treatmentID,
                                     scheduledDate: dose.date, recordedDate: date, site: site, doseNumber: dose.ordinal))
        var plan = plan(for: dose.treatmentID)
        if let remaining = plan.dosesRemaining { plan.dosesRemaining = max(0, remaining - 1) }
        updatePlan(plan)
    }

    func addSymptom(mood: Mood, note: String) {
        symptoms.insert(SymptomEntry(date: Date(), mood: mood,
                                    note: note.trimmingCharacters(in: .whitespacesAndNewlines)), at: 0)
    }
}
