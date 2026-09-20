import SwiftUI

@main
struct IBDLifeApp: App {

    @StateObject private var onboarding = OnboardingData.launchStore()

    @State private var showStorageError = false

    var body: some Scene {
        WindowGroup {
            Group {
                #if DEBUG
                if ProcessInfo.processInfo.arguments.contains("--review-profile") {
                    NavigationStack { ProfileView() }
                } else if ProcessInfo.processInfo.arguments.contains("--review-bmi-history") {
                    NavigationStack { BMIHistoryView() }
                } else if onboarding.completedOnboarding { HomeView() }
                else { WelcomeView() }
                #else
                if onboarding.completedOnboarding { HomeView() }
                else { WelcomeView() }
                #endif
            }
            .environmentObject(onboarding)
            .preferredColorScheme(.light)
            .task(id: onboarding.reminderRevision) {
                await MedicationReminderService.shared.synchronize(with: onboarding)
            }
            .onChange(of: onboarding.storageError, initial: true) { _, error in showStorageError = error != nil }
            .alert("Local storage", isPresented: $showStorageError) {
                Button("OK", role: .cancel) { }
            } message: { Text(onboarding.storageError ?? "") }
        }
    }
}
