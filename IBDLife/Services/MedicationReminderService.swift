import Foundation
import UserNotifications

@MainActor
final class MedicationReminderService {
    static let shared = MedicationReminderService()

    private let center: UNUserNotificationCenter
    private let identifierPrefix = "ibdlife."

    init(center: UNUserNotificationCenter = .current()) {
        self.center = center
    }

    func requestAuthorization() async -> Bool {
        let settings = await center.notificationSettings()
        switch settings.authorizationStatus {
        case .authorized, .provisional, .ephemeral:
            return true
        case .denied:
            return false
        case .notDetermined:
            return (try? await center.requestAuthorization(options: [.alert, .sound])) == true
        @unknown default:
            return false
        }
    }

    func synchronize(with store: OnboardingData) async {
        let pending = await center.pendingNotificationRequests()
        let ownedIdentifiers = pending.map(\.identifier).filter { $0.hasPrefix(identifierPrefix) }
        center.removePendingNotificationRequests(withIdentifiers: ownedIdentifiers)

        guard store.completedOnboarding, store.medicationRemindersEnabled else { return }
        let settings = await center.notificationSettings()
        guard settings.authorizationStatus == .authorized || settings.authorizationStatus == .provisional ||
                settings.authorizationStatus == .ephemeral else { return }

        let reminders = MedicationReminderPlanner.reminders(treatments: store.treatments,
                                                             records: store.doseRecords,
                                                             reschedules: store.doseReschedules,
                                                             doctorVisits: store.doctorVisits)
        for reminder in reminders {
            let content = UNMutableNotificationContent()
            content.title = reminder.title
            content.body = reminder.body
            content.sound = .default
            content.userInfo = ["kind": reminder.kind.rawValue]
            let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute],
                                                              from: reminder.date)
            let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
            try? await center.add(UNNotificationRequest(identifier: reminder.id,
                                                        content: content, trigger: trigger))
        }
    }
}
