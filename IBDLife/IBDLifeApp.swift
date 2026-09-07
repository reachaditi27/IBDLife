import SwiftUI

@main
struct IBDLifeApp: App {

    @StateObject private var onboarding = OnboardingData()

    var body: some Scene {
        WindowGroup {
            WelcomeView()
                .environmentObject(onboarding)
        }
    }
}
