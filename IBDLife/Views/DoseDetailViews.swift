import SwiftUI

struct UpcomingDoseDetailView: View {
    let dose: ScheduledDose
    var encouragement = "This moment of self-care matters more than you know."
    var body: some View { DoseDetailContent(dose: dose, encouragement: encouragement) }
}

struct DoseDayView: View {
    let dose: ScheduledDose
    var onRecorded: (() -> Void)? = nil
    var body: some View { DoseDetailContent(dose: dose, onRecorded: onRecorded) }
}

private struct DoseDetailContent: View {
    let dose: ScheduledDose
    private var isToday: Bool { Calendar.current.isDateInToday(dose.date) }
    private var isPast: Bool { dose.date < Calendar.current.startOfDay(for: Date()) }
    private var isRecorded: Bool { onboarding.doseRecords.contains { $0.id == dose.id } }
    var encouragement = "Every dose is an act of strength. You're doing this."
    var onRecorded: (() -> Void)? = nil
    @EnvironmentObject var onboarding: OnboardingData
    private var plan: TreatmentPlan { onboarding.plan(for: dose.treatmentID) }
    var body: some View {
        AppPage {
            VStack(alignment: .leading, spacing: 12) {
                AppSectionLabel(title: (isToday ? "Today · " : "") + dose.date.formatted(.dateTime.month(.wide).day().year()))
                VStack(alignment: .leading, spacing: 0) {
                    Text(isPast ? "Past scheduled dose" : isToday ? "It's dose day" : "Upcoming dose").font(AppStyle.serif(36))
                    Text("you've got this.").font(AppStyle.italic(36))
                }
            }
            Text("“\(encouragement)”")
                .font(.custom("Georgia-Italic", size: 16, relativeTo: .body)).lineSpacing(5)
                .foregroundStyle(AppStyle.green).padding(20)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(AppStyle.paleGreen, in: RoundedRectangle(cornerRadius: 16))
                .padding(.vertical, 8)
            AppCard {
                VStack(alignment: .leading, spacing: 12) {
                    AppSectionLabel(title: "Your medication")
                    VStack(alignment: .leading, spacing: 6) {
                        Text(plan.medication?.brandName ?? plan.id).font(.system(size: 16, weight: .medium))
                        Text([plan.medication?.genericName, plan.medication?.category.title.capitalized].compactMap { $0 }.joined(separator: " · "))
                            .font(.system(size: 14)).foregroundStyle(AppStyle.muted)
                        Text(plan.frequency?.title ?? "Schedule not set").font(.system(size: 14)).foregroundStyle(AppStyle.muted)
                        if (plan.frequency?.dosesPerDay ?? 1) > 1 {
                            Text(dose.timeLabel + " dose").font(.system(size: 14, weight: .medium))
                        }
                    }
                }
            }
            if let site = dose.site {
                AppCard {
                    VStack(alignment: .leading, spacing: 22) {
                        AppSectionLabel(title: isToday ? "Today's injection site" : "Injection site")
                        HStack(spacing: 18) {
                            InjectionSiteIllustration(site: site).frame(width: 105, height: 190)
                            VStack(alignment: .leading, spacing: 10) {
                                Text(site.title).font(AppStyle.serif(20))
                                Text(site.subtitle).font(.system(size: 14)).foregroundStyle(AppStyle.muted).lineSpacing(5)
                                Label("Dose #\(dose.ordinal) · Site \((plan.sites.firstIndex(of: site) ?? 0) + 1) of \(plan.sites.count)", systemImage: "arrow.counterclockwise")
                                    .font(.system(size: 12, weight: .medium)).foregroundStyle(AppStyle.green)
                            }
                        }.frame(maxWidth: .infinity, alignment: .leading)
                        Divider()
                        Text("Tip: Choose a spot at least 1 inch away from your last injection and avoid areas that are bruised, red, or irritated.")
                            .font(.system(size: 12)).foregroundStyle(AppStyle.muted).lineSpacing(5)
                    }
                }
            } else {
                AppCard {
                    VStack(alignment: .leading, spacing: 10) {
                        AppSectionLabel(title: "Your treatment")
                        ForEach(plan.orderedForms) { form in
                            Text("\(form.icon)  \(form.rawValue)").font(.system(size: 15))
                        }
                        Text("Follow the instructions provided with your prescription.")
                            .font(.system(size: 13)).foregroundStyle(AppStyle.muted)
                    }
                }
            }
            if dose.needsRefill {
                AppCard {
                    VStack(alignment: .leading, spacing: 10) {
                        RefillBadge(title: "REFILL SOON")
                        Text("Check your supply before this dose.").font(.system(size: 15))
                        NavigationLink("Update doses remaining →") { DosesPerOrderEditorView(treatmentID: dose.treatmentID) }
                            .font(.system(size: 14, weight: .semibold)).foregroundStyle(AppStyle.green)
                    }
                }
            }
            if isRecorded {
                EmptyMessage(title: "Dose recorded", detail: "This dose is already in your history.")
            } else if isToday || isPast {
                VStack(spacing: 6) {
                    if isPast {
                        Text("Record a dose you already took. This is not an instruction to take an extra dose.")
                            .font(.subheadline).foregroundStyle(AppStyle.muted)
                    }
                    NavigationLink { DoseConfirmationView(dose: dose, onRecorded: onRecorded) } label: { AppActionLabel(title: isPast ? "Record a taken dose" : "I'm ready") }
                    NavigationLink("I need a moment") { SupportMomentView() }
                        .font(.system(size: 14)).foregroundStyle(AppStyle.muted)
                        .frame(maxWidth: .infinity, minHeight: 44)
                }
            }
        }
    }
}

struct DoseConfirmationView: View {
    let dose: ScheduledDose
    var onRecorded: (() -> Void)? = nil
    @EnvironmentObject var onboarding: OnboardingData
    @Environment(\.dismiss) private var dismiss
    @State private var selectedSite: InjectionSite?
    @State private var recorded = false
    @State private var takenDate = Date()
    var body: some View {
        AppPage(title: recorded ? "Dose recorded" : "Have you taken\nyour dose?") {
            if recorded {
                EmptyMessage(title: "All done!", detail: "Your dose has been added to your history.")
                Button { if let onRecorded { onRecorded() } else { dismiss() } } label: {
                    AppActionLabel(title: onRecorded == nil ? "Back to dose" : "Back to home")
                }
            } else {
                Text("Only confirm once you've taken your medication. Being ready doesn't record a dose.")
                    .font(.system(size: 15)).foregroundStyle(AppStyle.muted).lineSpacing(5)
                AppCard {
                    VStack(alignment: .leading, spacing: 12) {
                        Text(onboarding.plan(for: dose.treatmentID).medication?.brandName ?? dose.treatmentID)
                            .font(AppStyle.serif(24))
                        Text(dose.date.formatted(date: .long, time: .omitted)).font(.system(size: 14)).foregroundStyle(AppStyle.muted)
                        if (onboarding.plan(for: dose.treatmentID).frequency?.dosesPerDay ?? 1) > 1 {
                            Text(dose.timeLabel + " dose").font(.system(size: 14, weight: .medium))
                        }
                        if dose.date < Calendar.current.startOfDay(for: Date()) {
                            DatePicker("Date taken", selection: $takenDate,
                                       in: dose.date...Date(), displayedComponents: .date)
                                .tint(AppStyle.green)
                        }
                        if dose.site != nil {
                            Picker("Site used", selection: $selectedSite) {
                                ForEach(onboarding.plan(for: dose.treatmentID).sites) { site in
                                    Text(site.title).tag(Optional(site))
                                }
                            }.tint(AppStyle.green)
                        }
                    }
                }
                Button {
                    onboarding.recordDose(dose, site: selectedSite, at: takenDate)
                    recorded = true
                    onRecorded?()
                } label: { AppActionLabel(title: "Yes, I've taken my dose", systemImage: "checkmark") }
                Button("Not yet") { dismiss() }.font(.system(size: 15)).foregroundStyle(AppStyle.muted)
                    .frame(maxWidth: .infinity, minHeight: 44)
            }
        }.onAppear {
            selectedSite = dose.site
            takenDate = Calendar.current.isDateInToday(dose.date) ? Date() : dose.date
        }
    }
}

/// Read-only version of the existing onboarding body map, highlighting just the scheduled site.
struct InjectionSiteIllustration: View {
    let site: InjectionSite
    private let bodyColor = Color(red: 232/255, green: 230/255, blue: 225/255)
    var body: some View {
        ZStack {
            Circle().fill(bodyColor).frame(width: 31, height: 31).offset(y: -67)
            RoundedRectangle(cornerRadius: 9).fill(bodyColor).frame(width: 51, height: 71).offset(y: -16)
            RoundedRectangle(cornerRadius: 9).fill(bodyColor).frame(width: 17, height: 58).offset(x: -36, y: -17)
            RoundedRectangle(cornerRadius: 9).fill(bodyColor).frame(width: 17, height: 58).offset(x: 36, y: -17)
            RoundedRectangle(cornerRadius: 7).fill(bodyColor).frame(width: 20, height: 74).offset(x: -15, y: 56)
            RoundedRectangle(cornerRadius: 7).fill(bodyColor).frame(width: 20, height: 74).offset(x: 15, y: 56)
            Circle().fill(AppStyle.green.opacity(0.18)).frame(width: 18, height: 18)
                .overlay(Circle().fill(AppStyle.green.opacity(0.5)).frame(width: 9, height: 9))
                .offset(x: position.x, y: position.y)
        }.accessibilityLabel("Injection site: \(site.title)")
    }
    private var position: CGPoint {
        switch site {
        case .leftAbdomen: CGPoint(x: -14, y: -4)
        case .rightAbdomen: CGPoint(x: 14, y: -4)
        case .leftThigh: CGPoint(x: -15, y: 42)
        case .rightThigh: CGPoint(x: 15, y: 42)
        case .leftUpperArm: CGPoint(x: -36, y: -20)
        case .rightUpperArm: CGPoint(x: 36, y: -20)
        }
    }
}
