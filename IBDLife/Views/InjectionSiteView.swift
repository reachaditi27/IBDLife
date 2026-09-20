import SwiftUI

struct InjectionSiteView: View {
    var treatmentID: String? = nil
    var onContinue: (() -> Void)? = nil
    var onBack: (() -> Void)? = nil
    @EnvironmentObject var onboarding: OnboardingData

    @Environment(\.dismiss) private var dismiss

    @State private var selectedSites: Set<InjectionSite> =
        Set(InjectionSite.allCases)

    var body: some View {

        VStack(spacing: 0) {

            ScrollView(showsIndicators: false) {

                VStack(alignment: .leading, spacing: 0) {

                    // MARK: Back

                    Button {
                        if let onBack { onBack() } else { dismiss() }
                    } label: {

                        HStack(spacing: 6) {

                            Image(systemName: "chevron.left")
                                .font(
                                    .system(
                                        size: 14,
                                        weight: .semibold
                                    )
                                )

                            Text("Back")
                                .fontWeight(.medium)
                        }
                        .foregroundColor(
                            .ibdSecondaryText
                        )
                    }
                    .buttonStyle(.plain)

                    Spacer()
                        .frame(height: 28)

                    // MARK: Progress

                    Text("STEP 5 OF 7")
                        .font(.caption.weight(.bold))
                        .tracking(1.5)
                        .foregroundColor(
                            .ibdSecondaryText
                        )

                    Spacer()
                        .frame(height: 14)

                    // MARK: Title

                    VStack(
                        alignment: .leading,
                        spacing: 2
                    ) {

                        Text("Injection site")
                            .font(
                                .system(
                                    size: 34,
                                    weight: .bold,
                                    design: .serif
                                )
                            )

                        Text("preferences")
                            .font(
                                .system(
                                    size: 32,
                                    design: .serif
                                )
                            )
                            .italic()
                    }

                    Spacer()
                        .frame(height: 18)

                    Text(
                        "Tap any site on the body or use the cards below to remove sites you'd prefer to avoid. We'll rotate only through your preferred sites."
                    )
                    .font(.subheadline)
                    .foregroundColor(
                        .ibdSecondaryText
                    )
                    .lineSpacing(4)

                    Spacer()
                        .frame(height: 26)

                    // MARK: Body

                    VStack(spacing: 3) {
                        Text("FRONT VIEW")
                            .font(.caption2.weight(.bold))
                            .tracking(1.3)
                        Text("Your right appears on the left side of the screen")
                            .font(.caption)
                    }
                    .foregroundColor(.ibdSecondaryText)
                    .frame(maxWidth: .infinity)

                    HStack {
                        Text("YOUR RIGHT")
                        Spacer()
                        Text("YOUR LEFT")
                    }
                    .font(.caption2.weight(.bold))
                    .tracking(0.8)
                    .foregroundColor(.ibdSecondaryText)
                    .padding(.horizontal, 28)
                    .padding(.top, 12)

                    InjectionBodyMap(
                        selectedSites: $selectedSites
                    )
                    .frame(maxWidth: .infinity)
                    .frame(height: 250)

                    Text("Tap dots to toggle sites")
                        .font(.caption)
                        .foregroundColor(
                            .ibdSecondaryText
                        )
                        .frame(maxWidth: .infinity)

                    Spacer()
                        .frame(height: 28)

                    // MARK: Count

                    HStack {

                        Text(
                            "\(selectedSites.count) of \(InjectionSite.allCases.count) sites selected"
                        )
                        .font(
                            .subheadline.weight(.semibold)
                        )

                        Spacer()

                        Button("Clear all") {
                            selectedSites.removeAll()
                        }
                        .font(.subheadline)
                        .foregroundColor(
                            .ibdSecondaryText
                        )
                    }

                    Spacer()
                        .frame(height: 12)

                    // MARK: Cards

                    VStack(spacing: 10) {

                        ForEach(
                            InjectionSite.allCases
                        ) { site in

                            InjectionSiteCard(
                                site: site,
                                selected:
                                    selectedSites.contains(site)
                            ) {

                                toggle(site)
                            }
                        }
                    }

                    Spacer()
                        .frame(height: 24)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 120)
            }

            // MARK: Bottom

            HStack {

                Button("Use all sites") {

                    selectedSites =
                        Set(InjectionSite.allCases)
                }
                .font(.subheadline)
                .foregroundColor(
                    .ibdSecondaryText
                )
                .underline()

                Spacer()

                Button {
                    if let treatmentID {
                        var plan = onboarding.plan(for: treatmentID)
                        plan.sites = InjectionSite.allCases.filter { selectedSites.contains($0) }
                        onboarding.updatePlan(plan)
                    }
                    onContinue?()
                } label: {

                    HStack(spacing: 8) {

                        Text("Continue")

                        Image(
                            systemName: "arrow.right"
                        )
                    }
                    .font(
                        .system(
                            size: 15,
                            weight: .semibold
                        )
                    )
                    .foregroundColor(.white)
                    .frame(
                        width: 116,
                        height: 48
                    )
                    .background(
                        RoundedRectangle(
                            cornerRadius: 14
                        )
                        .fill(
                            selectedSites.isEmpty
                            ? Color.ibdSecondaryText.opacity(0.4)
                            : Color.ibdGreen
                        )
                    )
                }
                .disabled(selectedSites.isEmpty)
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 18)
            .background(.ultraThinMaterial)
        }
        .background(
            Color.ibdCream
                .ignoresSafeArea()
        )
        .onAppear {
            if let treatmentID { selectedSites = Set(onboarding.plan(for: treatmentID).sites) }
        }
        .navigationBarBackButtonHidden(true)
    }

    private func toggle(
        _ site: InjectionSite
    ) {

        if selectedSites.contains(site) {
            selectedSites.remove(site)
        } else {
            selectedSites.insert(site)
        }
    }
}


// MARK: - Injection Site

// MARK: - Site Card

struct InjectionSiteCard: View {

    let site: InjectionSite
    let selected: Bool
    let action: () -> Void

    var body: some View {

        Button(action: action) {

            HStack(spacing: 12) {

                Circle()
                    .fill(
                        selected
                        ? Color.ibdGreen
                        : Color.ibdSecondaryText.opacity(0.25)
                    )
                    .frame(
                        width: 10,
                        height: 10
                    )

                VStack(
                    alignment: .leading,
                    spacing: 3
                ) {

                    Text(site.title)
                        .font(
                            .system(
                                size: 14,
                                weight: .semibold
                            )
                        )
                        .foregroundColor(
                            selected
                            ? Color.ibdGreen
                            : .primary
                        )

                    Text(site.subtitle)
                        .font(.caption)
                        .foregroundColor(
                            .ibdSecondaryText
                        )
                }

                Spacer()

                Image(
                    systemName:
                        selected
                        ? "checkmark.circle"
                        : "circle"
                )
                .foregroundColor(
                    selected
                    ? Color.ibdGreen
                    : Color.ibdSecondaryText.opacity(0.35)
                )
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(
                    cornerRadius: 14
                )
                .fill(Color.white)
            )
            .overlay(
                RoundedRectangle(
                    cornerRadius: 14
                )
                .stroke(
                    selected
                    ? Color.ibdGreen
                    : Color.black.opacity(0.07),
                    lineWidth: selected ? 1.1 : 1
                )
            )
        }
        .buttonStyle(.plain)
    }
}


// MARK: - Body Map

struct InjectionBodyMap: View {

    @Binding var selectedSites:
        Set<InjectionSite>

    var body: some View {

        ZStack {

            // Head
            Circle()
                .fill(
                    Color.ibdSecondaryText.opacity(0.10)
                )
                .frame(width: 42, height: 42)
                .offset(y: -90)

            // Torso
            RoundedRectangle(cornerRadius: 18)
                .fill(
                    Color.ibdSecondaryText.opacity(0.10)
                )
                .frame(width: 82, height: 105)
                .offset(y: -20)

            // Arms
            RoundedRectangle(cornerRadius: 14)
                .fill(
                    Color.ibdSecondaryText.opacity(0.10)
                )
                .frame(width: 30, height: 88)
                .offset(x: -58, y: -20)

            RoundedRectangle(cornerRadius: 14)
                .fill(
                    Color.ibdSecondaryText.opacity(0.10)
                )
                .frame(width: 30, height: 88)
                .offset(x: 58, y: -20)

            // Legs
            RoundedRectangle(cornerRadius: 12)
                .fill(
                    Color.ibdSecondaryText.opacity(0.10)
                )
                .frame(width: 30, height: 105)
                .offset(x: -20, y: 82)

            RoundedRectangle(cornerRadius: 12)
                .fill(
                    Color.ibdSecondaryText.opacity(0.10)
                )
                .frame(width: 30, height: 105)
                .offset(x: 20, y: 82)

            // Dots
            siteDot(.rightUpperArm, x: -58, y: -20)
            siteDot(.leftUpperArm, x: 58, y: -20)

            siteDot(.rightAbdomen, x: -20, y: -10)
            siteDot(.leftAbdomen, x: 20, y: -10)

            siteDot(.rightThigh, x: -20, y: 50)
            siteDot(.leftThigh, x: 20, y: 50)
        }
    }

    private func siteDot(
        _ site: InjectionSite,
        x: CGFloat,
        y: CGFloat
    ) -> some View {

        Button {

            if selectedSites.contains(site) {
                selectedSites.remove(site)
            } else {
                selectedSites.insert(site)
            }

        } label: {

            Circle()
                .fill(
                    selectedSites.contains(site)
                    ? Color.ibdGreen
                    : Color.ibdSecondaryText.opacity(0.25)
                )
                .frame(width: 10, height: 10)
                .padding(6)
                .background(
                    Circle()
                        .fill(
                            selectedSites.contains(site)
                            ? Color.ibdGreen.opacity(0.12)
                            : Color.clear
                        )
                )
        }
        .buttonStyle(.plain)
        .accessibilityLabel(site.title)
        .accessibilityValue(selectedSites.contains(site) ? "Selected" : "Not selected")
        .offset(x: x, y: y)
    }
}


// MARK: - Temporary Step 6

struct Step6PlaceholderView: View {

    var body: some View {

        VStack(spacing: 16) {

            Text("Step 6")
                .font(.largeTitle.bold())

            Text("We'll build this screen next.")
                .foregroundColor(
                    .ibdSecondaryText
                )
        }
        .frame(
            maxWidth: .infinity,
            maxHeight: .infinity
        )
        .background(
            Color.ibdCream
                .ignoresSafeArea()
        )
    }
}
