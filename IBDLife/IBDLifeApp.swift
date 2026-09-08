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
            .environmentObject(onboarding)
            .preferredColorScheme(.light)
            .onChange(of: onboarding.storageError, initial: true) { _, error in showStorageError = error != nil }
            .alert("Local storage", isPresented: $showStorageError) {
                Button("OK", role: .cancel) { }
            } message: { Text(onboarding.storageError ?? "") }
        }
    }
}
