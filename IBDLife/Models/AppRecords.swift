import Foundation

struct TreatmentPlan: Identifiable, Codable, Hashable {
    var id: String
    var forms: Set<AdministrationForm> = []
    var frequency: DosingFrequency?
    var customIntervalDays: Int?
    var startDate: Date?
    var lastDoseDate: Date?
    // Optional so existing version-1 saved plans still decode unchanged.
    var startSlot: Int?
    var lastTakenSlot: Int?
    var sites: [InjectionSite] = InjectionSite.allCases
    var dosesPerOrder: Int?
    var dosesRemaining: Int?

    var medication: Medication? { MedicationDatabase.medications.first { $0.id == id } }
    var isInjection: Bool { !forms.isDisjoint(with: [.autoInjector, .prefilledSyringe]) }
    var isNutrition: Bool { medication?.isNutrition == true }
    var orderedForms: [AdministrationForm] { AdministrationForm.allCases.filter { forms.contains($0) } }
    var intervalDays: Int? {
        frequency == .everyNDays ? customIntervalDays : frequency?.intervalDays
    }
    var scheduleTitle: String {
        if frequency == .everyNDays, let days = customIntervalDays {
            return "Every \(days) day\(days == 1 ? "" : "s")"
        }
        return frequency?.title ?? "Not set up"
    }
}

struct BodyMeasurement: Identifiable, Codable, Hashable {
    var id = UUID()
    var date: Date
    var weightKilograms: Double
    var heightCentimeters: Double

    var bmi: Double {
        let heightMeters = heightCentimeters / 100
        return weightKilograms / (heightMeters * heightMeters)
    }

    func weight(for unitSystem: UnitSystem) -> Double {
        unitSystem == .metric ? weightKilograms : weightKilograms / 0.45359237
    }

    func height(for unitSystem: UnitSystem) -> (primary: Double, secondary: Double?) {
        if unitSystem == .metric { return (heightCentimeters, nil) }
        let totalInches = heightCentimeters / 2.54
        return ((totalInches / 12).rounded(.down), totalInches.truncatingRemainder(dividingBy: 12))
    }
}

enum Mood: String, CaseIterable, Codable, Identifiable {
    case great = "Great", okay = "Okay", rough = "Rough", notWell = "Not well"
    var id: String { rawValue }
    var emoji: String {
        switch self {
        case .great: "😊"
        case .okay: "😐"
        case .rough: "😔"
        case .notWell: "🔥"
        }
    }
}

struct SymptomEntry: Identifiable, Codable {
    var id = UUID()
    var date: Date
    var mood: Mood
    var note: String
    var painLocation: PainLocation?
    var painSeverity: Int?
    var stoolConsistency: StoolConsistency?
    var bowelMovementCount: Int?
    var hasBlood: Bool?
    var urgency: Int?
    var fatigue: Int?
    var sleepQuality: Int?
}

enum PainLocation: String, CaseIterable, Codable, Identifiable {
    case none = "No pain", upper = "Upper abdomen", lower = "Lower abdomen"
    case left = "Left side", right = "Right side", allOver = "All over"
    var id: String { rawValue }
}

enum StoolConsistency: String, CaseIterable, Codable, Identifiable {
    case hard = "Hard / separate pieces"
    case formed = "Well formed"
    case soft = "Soft / loose"
    case watery = "Watery"
    var id: String { rawValue }
}

struct DoctorVisit: Identifiable, Codable, Hashable {
    var id = UUID()
    var date: Date
    var clinician: String
    var location: String
    var notes: String
    var reminderLeadDays: Int = 1
}

struct DoseRecord: Identifiable, Codable {
    var id: String
    var treatmentID: String
    var scheduledDate: Date
    var recordedDate: Date
    var site: InjectionSite?
    var doseNumber: Int
}

/// A local exception for one occurrence. The recurring treatment plan remains unchanged.
struct DoseReschedule: Identifiable, Codable, Hashable {
    let id: String
    let treatmentID: String
    let originalDate: Date
    var newDate: Date
    let slot: Int
}

struct ScheduledDose: Identifiable, Hashable {
    var treatmentID: String
    var date: Date
    var originalDate: Date? = nil
    var slot: Int
    var ordinal: Int
    var site: InjectionSite?
    var needsRefill: Bool = false
    // A moved occurrence keeps its original identity so it cannot be recorded twice.
    // The slot distinguishes morning/afternoon/evening on the same calendar day.
    var id: String { "\(treatmentID)-\(Int((originalDate ?? date).timeIntervalSince1970))-\(slot)" }
    var isRescheduled: Bool { originalDate != nil }
    var timeLabel: String {
        switch slot {
        case 1: "Afternoon"
        case 2: "Evening"
        default: "Morning"
        }
    }
}

extension DosingFrequency {
    var slots: [Int] {
        switch self {
        case .twiceDaily: [0, 2]
        case .threeTimesDaily: [0, 1, 2]
        default: [0]
        }
    }
    var intervalDays: Int? {
        switch self {
        case .onceDaily, .twiceDaily, .threeTimesDaily: 1
        case .weekly: 7
        case .everyTwoWeeks: 14
        case .everyFourWeeks: 28
        case .everySixWeeks: 42
        case .everyEightWeeks: 56
        case .everyTwelveWeeks: 84
        case .asNeeded, .everyNDays: nil
        }
    }
    var dosesPerDay: Int {
        switch self {
        case .twiceDaily: 2
        case .threeTimesDaily: 3
        default: 1
        }
    }
}

/// Calendar arithmetic keeps recurring doses on local dates across daylight saving changes.
enum DoseSchedule {
    static func doses(for plan: TreatmentPlan, from: Date, through: Date,
                      records: [DoseRecord], reschedules: [DoseReschedule] = [],
                      calendar: Calendar = .current) -> [ScheduledDose] {
        // Invalid custom intervals must not divide by zero or generate an unbounded loop.
        guard let frequency = plan.frequency, let interval = plan.intervalDays, interval > 0,
              let anchor = plan.startDate else { return [] }
        let start = calendar.startOfDay(for: anchor)
        let lower = calendar.startOfDay(for: from)
        let upper = calendar.startOfDay(for: through)
        let relevantReschedules = reschedules.filter {
            $0.treatmentID == plan.id &&
            ((calendar.startOfDay(for: $0.newDate) >= lower && calendar.startOfDay(for: $0.newDate) <= upper) ||
             (calendar.startOfDay(for: $0.originalDate) >= lower && calendar.startOfDay(for: $0.originalDate) <= upper))
        }
        // Generate original occurrences outside the visible range when an exception moves
        // them into it; filter by the effective date only after applying those exceptions.
        let generationLower = relevantReschedules.map { calendar.startOfDay(for: $0.originalDate) }.min().map { min(lower, $0) } ?? lower
        let generationUpper = relevantReschedules.map { calendar.startOfDay(for: $0.originalDate) }.max().map { max(upper, $0) } ?? upper
        guard generationUpper >= start else { return [] }
        let elapsed = max(0, calendar.dateComponents([.day], from: start, to: generationLower).day ?? 0)
        var index = elapsed / interval
        var result: [ScheduledDose] = []
        let baseline = plan.lastDoseDate == nil ? 0 : 1
        let firstPosition = frequency.slots.firstIndex(of: plan.startSlot ?? 0) ?? 0
        let siteRecords = records.filter { $0.treatmentID == plan.id && $0.site != nil }
        while let day = calendar.date(byAdding: .day, value: index * interval, to: start), day <= generationUpper {
            if day >= generationLower {
                for position in 0..<frequency.dosesPerDay {
                    if index == 0 && position < firstPosition { continue }
                    let slot = frequency.slots[position]
                    let offset = index * frequency.dosesPerDay + position - firstPosition
                    var site = plan.isInjection && !plan.sites.isEmpty
                        ? plan.sites[(offset + baseline) % plan.sites.count] : nil
                    // Keep recorded sites immutable; subsequent suggestions follow actual use.
                    if plan.isInjection, let previous = siteRecords.filter({
                        $0.doseNumber < offset + baseline + 1 && $0.scheduledDate <= day
                    }).max(by: { $0.recordedDate < $1.recordedDate }),
                       let used = previous.site, let usedIndex = plan.sites.firstIndex(of: used) {
                        site = plan.sites[(usedIndex + offset + baseline + 1 - previous.doseNumber) % plan.sites.count]
                    }
                    let doseID = "\(plan.id)-\(Int(day.timeIntervalSince1970))-\(slot)"
                    if let actual = siteRecords.first(where: { $0.id == doseID }) { site = actual.site }
                    result.append(ScheduledDose(treatmentID: plan.id, date: day, slot: slot,
                                                ordinal: offset + baseline + 1, site: site))
                }
            }
            index += 1
        }
        let overrides = reschedules.filter { $0.treatmentID == plan.id }.reduce(into: [String: DoseReschedule]()) {
            $0[$1.id] = $1
        }
        return result.compactMap { dose in
            var adjusted = dose
            if let override = overrides[dose.id] {
                adjusted.originalDate = dose.date
                adjusted.date = calendar.startOfDay(for: override.newDate)
            }
            let effectiveDate = calendar.startOfDay(for: adjusted.date)
            return effectiveDate >= lower && effectiveDate <= upper ? adjusted : nil
        }
        .sorted { ($0.date, $0.slot, $0.treatmentID) < ($1.date, $1.slot, $1.treatmentID) }
    }
}
