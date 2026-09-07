import SwiftUI

struct WelcomeView: View {

    @EnvironmentObject var onboarding: OnboardingData

    private let ibdGreen = Color(
        red: 0.43,
        green: 0.51,
        blue: 0.45
    )

    private let softGreen = Color(
        red: 0.52,
        green: 0.59,
        blue: 0.54
    )

    var body: some View {
        NavigationStack {
            ZStack {
                ibdGreen
                    .ignoresSafeArea()

                VStack(spacing: 0) {

                    Spacer()
                        .frame(height: 18)

                    // MARK: - Heartbeat Icon

                    ZStack {
                        RoundedRectangle(cornerRadius: 15)
                            .fill(softGreen)
                            .frame(width: 48, height: 48)

                        Image(systemName: "waveform.path.ecg")
                            .font(.system(size: 24, weight: .medium))
                            .foregroundStyle(.white)
                    }

                    Spacer()
                        .frame(height: 32)

                    // MARK: - Eyebrow

                    Text("YOUR DAILY COMPANION")
                        .font(.system(size: 12, weight: .semibold))
                        .tracking(1.5)
                        .foregroundStyle(.white.opacity(0.72))

                    Spacer()
                        .frame(height: 22)

                    // MARK: - Main Title

                    VStack(spacing: 0) {
                        Text("Welcome to")
                            .font(
                                .custom("Georgia", size: 40)
                            )
                            .fontWeight(.bold)
                            .foregroundStyle(.white)

                        Text("IBD Life")
                            .font(
                                .custom("Georgia-Italic", size: 40)
                            )
                            .foregroundStyle(.white)
                    }

                    Spacer()
                        .frame(height: 25)

                    // MARK: - Description

                    Text(
                        "Relieve medication anxiety, manage\n" +
                        "medications, and understand your condition —\n" +
                        "built specifically for people living with\n" +
                        "inflammatory bowel disease."
                    )
                    .font(.system(size: 15.5))
                    .lineSpacing(6)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.white.opacity(0.88))
                    .padding(.horizontal, 25)

                    Spacer()
                        .frame(height: 34)

                    // MARK: - Feature Pills

                    HStack(spacing: 10) {

                        FeaturePill(
                            title: "Symptom\nlogging"
                        )

                        FeaturePill(
                            title: "Medication\nreminders"
                        )

                        FeaturePill(
                            title: "Medication\nmanagement"
                        )
                    }
                    .padding(.horizontal, 24)

                    Spacer()
                        .frame(height: 25)

                    // MARK: - Name Input

                    VStack(alignment: .leading, spacing: 8) {

                        Text("What's your first name? (optional)")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(.white.opacity(0.75))

                        TextField(
                            "e.g. Sarah",
                            text: $onboarding.name
                        )
                        .font(.system(size: 16))
                        .foregroundStyle(.white)
                        .tint(.white)
                        .textInputAutocapitalization(.words)
                        .autocorrectionDisabled()
                        .padding(.horizontal, 15)
                        .frame(height: 48)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.white.opacity(0.10))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(
                                    Color.white.opacity(0.35),
                                    lineWidth: 1
                                )
                        )
                    }
                    .padding(.horizontal, 29)

                    Spacer()
                        .frame(height: 10)

                    // MARK: - Get Started

                    NavigationLink {
                        AboutYouView()
                    } label: {

                        HStack(spacing: 8) {

                            Text(getStartedText)

                            Image(systemName: "arrow.right")
                        }
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(ibdGreen)
                        .frame(maxWidth: .infinity)
                        .frame(height: 46)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(.white)
                        )
                        .shadow(
                            color: .black.opacity(0.12),
                            radius: 7,
                            y: 4
                        )
                    }
                    .padding(.horizontal, 29)

                    Spacer()
                        .frame(height: 10)

                    // MARK: - Footer

                    Text("Free to use · No account required")
                        .font(.system(size: 11.5))
                        .foregroundStyle(.white.opacity(0.62))

                    Spacer()
                        .frame(height: 22)
                }
            }
            .toolbar(.hidden, for: .navigationBar)
        }
    }

    // MARK: - Dynamic Button Text

    private var getStartedText: String {

        let trimmedName = onboarding.name
            .trimmingCharacters(in: .whitespacesAndNewlines)

        if trimmedName.isEmpty {
            return "Get started"
        } else {
            return "Let's go, \(trimmedName)"
        }
    }
}

// MARK: - Feature Pill

struct FeaturePill: View {

    let title: String

    var body: some View {

        Text(title)
            .font(.system(size: 11, weight: .medium))
            .multilineTextAlignment(.center)
            .foregroundStyle(.white.opacity(0.95))
            .lineSpacing(1)
            .frame(maxWidth: .infinity)
            .frame(height: 49)
            .background(
                RoundedRectangle(cornerRadius: 13)
                    .fill(Color.white.opacity(0.13))
            )
    }
}

// MARK: - Preview

#Preview {
    WelcomeView()
        .environmentObject(OnboardingData())
}
