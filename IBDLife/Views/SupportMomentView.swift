import SwiftUI

struct SupportMomentView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @AppStorage("lastSupportAffirmationSet") private var lastAffirmationSet = -1
    @State private var expanded = false
    @State private var affirmations: [String] = []
    var body: some View {
        AppPage(title: "You're not alone.") {
            Text("It's okay to take a breath. Many people living with IBD feel the same way.")
                .font(.system(size: 15)).foregroundStyle(AppStyle.muted).lineSpacing(6)
            AppCard {
                VStack(spacing: 24) {
                    AppSectionLabel(title: "Try a calming breath")
                    ZStack {
                        Circle().fill(AppStyle.paleGreen).frame(width: 100, height: 100)
                        Circle().fill(AppStyle.green.opacity(0.15)).frame(width: 58, height: 58)
                        Circle().fill(AppStyle.green.opacity(0.38)).frame(width: 29, height: 29)
                    }
                    .scaleEffect(expanded && !reduceMotion ? 1.10 : 0.92)
                    .animation(reduceMotion ? nil : .easeInOut(duration: 4).repeatForever(autoreverses: true), value: expanded)
                    .accessibilityHidden(true)
                    Text("Breathe in slowly · hold · breathe out gently")
                        .font(.system(size: 13)).foregroundStyle(AppStyle.muted).multilineTextAlignment(.center)
                }.frame(maxWidth: .infinity).padding(.vertical, 10)
            }
            VStack(spacing: 10) {
                ForEach(affirmations, id: \.self, content: reassurance)
            }
            Button { dismiss() } label: { AppActionLabel(title: "I feel more ready now", leadingIcon: true) }
        }.onAppear {
            let nextIndex = SupportAffirmations.nextIndex(after: lastAffirmationSet)
            lastAffirmationSet = nextIndex
            affirmations = SupportAffirmations.sets[nextIndex]
            expanded = true
        }
    }
    private func reassurance(_ text: String) -> some View {
        Text(text).font(.system(size: 14)).foregroundStyle(AppStyle.green).lineSpacing(5)
            .frame(maxWidth: .infinity, alignment: .leading).padding(18)
            .background(AppStyle.paleGreen, in: RoundedRectangle(cornerRadius: 16))
    }
}
