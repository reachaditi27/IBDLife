import SwiftUI

@main
struct IBDLifeApp: App {

    @StateObject private var onboarding = OnboardingData.launchStore()

    @State private var showStorageError = false

    var body: some Scene {
        WindowGroup {
            Group {
                if onboarding.completedOnboarding { HomeView() }
                else { WelcomeView() }
            }
            .id(onboarding.completedOnboarding)
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
