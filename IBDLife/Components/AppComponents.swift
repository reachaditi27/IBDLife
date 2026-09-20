import SwiftUI

/// The post-onboarding palette follows the prototype without changing existing onboarding colors.
enum AppStyle {
    static let green = Color(red: 105/255, green: 128/255, blue: 111/255)
    static let background = Color(red: 250/255, green: 247/255, blue: 244/255)
    static let ink = Color(red: 47/255, green: 44/255, blue: 40/255)
    static let muted = Color(red: 139/255, green: 124/255, blue: 113/255)
    static let paleGreen = Color(red: 237/255, green: 243/255, blue: 238/255)
    static let border = Color.black.opacity(0.09)
    static let refill = Color(red: 193/255, green: 126/255, blue: 99/255)
    static func serif(_ size: CGFloat = 30) -> Font { .custom("Georgia-Bold", size: size, relativeTo: .title) }
    static func italic(_ size: CGFloat = 30) -> Font { .custom("Georgia-Italic", size: size, relativeTo: .title) }
}

struct AppPage<Content: View>: View {
    var title: String? = nil
    var back = true
    var topInset: CGFloat? = nil
    @ViewBuilder var content: () -> Content
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                if back { AppBackButton() }
                if let title { Text(title).font(AppStyle.serif()).accessibilityAddTraits(.isHeader) }
                content()
            }
            .frame(maxWidth: 600, alignment: .leading)
            .padding(.horizontal, 24)
            .padding(.top, topInset ?? (back ? 36 : 52))
            .padding(.bottom, 32)
            .frame(maxWidth: .infinity)
        }
        .scrollIndicators(.hidden)
        .scrollDismissesKeyboard(.interactively)
        .ignoresSafeArea(.container, edges: .top)
        .statusBarHidden(true)
        .background(AppStyle.background.ignoresSafeArea())
        .foregroundStyle(AppStyle.ink)
        .toolbar(.hidden, for: .navigationBar)
        .navigationBarBackButtonHidden(true)
    }
}

struct AppBackButton: View {
    @Environment(\.dismiss) private var dismiss
    var action: (() -> Void)? = nil
    var body: some View {
        Button { if let action { action() } else { dismiss() } } label: {
            Label("Back", systemImage: "chevron.left")
                .font(.system(size: 14)).foregroundStyle(AppStyle.muted)
                .frame(minHeight: 32, alignment: .leading)
                .contentShape(Rectangle())
        }.buttonStyle(.plain)
    }
}

struct AppSectionLabel: View {
    let title: String
    var body: some View {
        Text(title.uppercased()).font(.system(size: 12, weight: .semibold))
            .tracking(1).foregroundStyle(AppStyle.muted).accessibilityAddTraits(.isHeader)
    }
}

struct AppCard<Content: View>: View {
    var padding: CGFloat = 18
    @ViewBuilder var content: () -> Content
    var body: some View {
        content().frame(maxWidth: .infinity, alignment: .leading).padding(padding)
            .background(.white, in: RoundedRectangle(cornerRadius: 17))
            .overlay(RoundedRectangle(cornerRadius: 17).stroke(AppStyle.border, lineWidth: 1))
    }
}

struct AppActionLabel: View {
    let title: String
    var systemImage = "arrow.right"
    var leadingIcon = false
    var body: some View {
        HStack(spacing: 10) {
            if leadingIcon { Image(systemName: systemImage) }
            Text(title)
            if !leadingIcon { Image(systemName: systemImage) }
        }
        .font(.system(size: 16, weight: .semibold))
        .frame(maxWidth: .infinity).frame(minHeight: 54)
        .foregroundStyle(.white)
        .background(AppStyle.green, in: RoundedRectangle(cornerRadius: 15))
        .contentShape(RoundedRectangle(cornerRadius: 15))
    }
}

struct DateBadge: View {
    let date: Date
    var body: some View {
        VStack(spacing: 0) {
            Text(date.formatted(.dateTime.month(.abbreviated)).uppercased()).font(.system(size: 10, weight: .medium))
            Text(date.formatted(.dateTime.day())).font(.system(size: 20, weight: .semibold))
        }.foregroundStyle(AppStyle.green).frame(width: 42, height: 44)
            .background(AppStyle.paleGreen, in: RoundedRectangle(cornerRadius: 14))
    }
}

struct RefillBadge: View {
    var title = "REFILL"
    var body: some View {
        Text(title).font(.system(size: 9, weight: .bold))
            .foregroundStyle(AppStyle.refill).padding(.horizontal, 8).padding(.vertical, 5)
            .background(AppStyle.refill.opacity(0.09), in: Capsule())
    }
}

struct EmptyMessage: View {
    let title: String
    let detail: String
    var body: some View {
        AppCard {
            VStack(alignment: .leading, spacing: 8) {
                Text(title).font(.system(size: 15, weight: .medium))
                Text(detail).font(.system(size: 14)).foregroundStyle(AppStyle.muted).lineSpacing(4)
            }
        }
    }
}

struct MedicationReminderToggle: View {
    @EnvironmentObject private var onboarding: OnboardingData
    @State private var isRequesting = false
    @State private var showPermissionMessage = false

    var body: some View {
        Toggle(isOn: Binding(
            get: { onboarding.medicationRemindersEnabled },
            set: updatePreference
        )) {
            VStack(alignment: .leading, spacing: 5) {
                Text("Medication reminders").font(.system(size: 15, weight: .medium))
                Text("Dose times and refill reminders")
                    .font(.system(size: 12)).foregroundStyle(AppStyle.muted)
            }
        }
        .tint(AppStyle.green)
        .disabled(isRequesting)
        .alert("Notifications are off", isPresented: $showPermissionMessage) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Allow notifications for IBDLife in Settings to turn on medication reminders.")
        }
    }

    private func updatePreference(_ enabled: Bool) {
        guard enabled else {
            onboarding.medicationRemindersEnabled = false
            return
        }
        isRequesting = true
        Task {
            let granted = await MedicationReminderService.shared.requestAuthorization()
            onboarding.medicationRemindersEnabled = granted
            isRequesting = false
            showPermissionMessage = !granted
        }
    }
}
