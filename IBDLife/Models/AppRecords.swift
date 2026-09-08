import Foundation

struct TreatmentPlan: Identifiable, Codable, Hashable {
    var id: String
    var forms: Set<AdministrationForm> = []
    var frequency: DosingFrequency?
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
    var orderedForms: [AdministrationForm] { AdministrationForm.allCases.filter { forms.contains($0) } }
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
}

struct DoseRecord: Identifiable, Codable {
    var id: String
    var treatmentID: String
    var scheduledDate: Date
    var recordedDate: Date
    var site: InjectionSite?
    var doseNumber: Int
}

struct ScheduledDose: Identifiable, Hashable {
    var treatmentID: String
    var date: Date
    var slot: Int
    var ordinal: Int
    var site: InjectionSite?
    var needsRefill: Bool = false
    var id: String { "\(treatmentID)-\(Int(date.timeIntervalSince1970))-\(slot)" }
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
        case .asNeeded: nil
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
                      records: [DoseRecord], calendar: Calendar = .current) -> [ScheduledDose] {
        guard let frequency = plan.frequency, let interval = frequency.intervalDays,
              let anchor = plan.startDate else { return [] }
        let start = calendar.startOfDay(for: anchor)
        let lower = calendar.startOfDay(for: from)
        let upper = calendar.startOfDay(for: through)
        guard upper >= start else { return [] }
        let elapsed = max(0, calendar.dateComponents([.day], from: start, to: lower).day ?? 0)
        var index = elapsed / interval
        var result: [ScheduledDose] = []
        let baseline = plan.lastDoseDate == nil ? 0 : 1
        let firstPosition = frequency.slots.firstIndex(of: plan.startSlot ?? 0) ?? 0
        let siteRecords = records.filter { $0.treatmentID == plan.id && $0.site != nil }
        while let day = calendar.date(byAdding: .day, value: index * interval, to: start), day <= upper {
            if day >= lower {
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
        return result
    }
}
