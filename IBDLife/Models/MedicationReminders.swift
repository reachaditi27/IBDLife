import Foundation

enum MedicationReminderKind: String, Hashable {
    case dose
    case refill
}

struct MedicationReminder: Identifiable, Hashable {
    let id: String
    let kind: MedicationReminderKind
    let date: Date
    let title: String
    let body: String
}

/// Produces a bounded, deterministic notification plan without depending on iOS APIs.
/// The app refreshes this rolling window whenever locally saved treatment data changes.
enum MedicationReminderPlanner {
    static let maximumPending = 60

    static func reminders(treatments: [TreatmentPlan], records: [DoseRecord], now: Date = Date(),
                          calendar: Calendar = .current, horizonDays: Int = 365) -> [MedicationReminder] {
        let today = calendar.startOfDay(for: now)
        guard let end = calendar.date(byAdding: .day, value: horizonDays, to: today) else { return [] }
        let recordedIDs = Set(records.map(\.id))
        var reminders: [MedicationReminder] = []

        for plan in treatments {
            let medicationName = plan.medication?.brandName ?? plan.id
            let doseNoun = plan.isNutrition ? "serving" : "dose"
            let doses = DoseSchedule.doses(for: plan, from: today, through: end,
                                            records: records, calendar: calendar)
                .filter { !recordedIDs.contains($0.id) }

            for dose in doses {
                guard let fireDate = doseTime(for: dose, calendar: calendar), fireDate > now else { continue }
                reminders.append(MedicationReminder(
                    id: "ibdlife.dose.\(dose.id)",
                    kind: .dose,
                    date: fireDate,
                    title: plan.isNutrition ? "Nutrition reminder" : "Medication reminder",
                    body: "Your \(dose.timeLabel.lowercased()) \(doseNoun) of \(medicationName) is scheduled now."
                ))
            }

            guard let remaining = plan.dosesRemaining,
                  let orderSize = plan.dosesPerOrder, orderSize > 0 else { continue }
            let firstRefillOffset = max(0, remaining - 1)
            var scheduledCatchUp = false
            for (offset, dose) in doses.enumerated()
            where offset >= firstRefillOffset && (offset - firstRefillOffset).isMultiple(of: orderSize) {
                guard let idealDate = calendar.date(byAdding: .day, value: -7, to: dose.date),
                      let idealFireDate = calendar.date(bySettingHour: 9, minute: 0, second: 0, of: idealDate),
                      dose.date >= today else { continue }
                let fireDate: Date
                if idealFireDate > now {
                    fireDate = idealFireDate
                } else {
                    guard !scheduledCatchUp else { continue }
                    scheduledCatchUp = true
                    fireDate = calendar.date(byAdding: .minute, value: 1, to: now) ?? now
                }
                reminders.append(MedicationReminder(
                    id: "ibdlife.refill.\(dose.id)",
                    kind: .refill,
                    date: fireDate,
                    title: plan.isNutrition ? "Nutrition supply reminder" : "Refill reminder",
                    body: plan.isNutrition
                        ? "Your \(medicationName) supply is projected to run out soon. Plan your next order."
                        : "Your \(medicationName) supply is projected to run out soon. Contact your pharmacy or specialty mail service."
                ))
            }
        }

        return reminders.sorted {
            if $0.date != $1.date { return $0.date < $1.date }
            if $0.kind != $1.kind { return $0.kind == .refill }
            return $0.id < $1.id
        }.prefix(maximumPending).map { $0 }
    }

    private static func doseTime(for dose: ScheduledDose, calendar: Calendar) -> Date? {
        let hour: Int
        switch dose.slot {
        case 1: hour = 13
        case 2: hour = 19
        default: hour = 9
        }
        return calendar.date(bySettingHour: hour, minute: 0, second: 0, of: dose.date)
    }
}
