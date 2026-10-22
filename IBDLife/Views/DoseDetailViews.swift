import SwiftUI

struct UpcomingDoseDetailView: View {
    let dose: ScheduledDose
    var encouragement: String? = nil
    var body: some View { DoseDetailContent(dose: dose, encouragement: encouragement) }
}

struct DoseDayView: View {
    let dose: ScheduledDose
    var onRecorded: (() -> Void)? = nil
    var body: some View { DoseDetailContent(dose: dose, onRecorded: onRecorded) }
}

private struct DoseDetailContent: View {
    private let scheduledDose: ScheduledDose
    private var isToday: Bool { Calendar.current.isDateInToday(dose.date) }
    private var isPast: Bool { dose.date < Calendar.current.startOfDay(for: Date()) }
    private var isRecorded: Bool { onboarding.doseRecords.contains { $0.id == dose.id } }
    private let encouragement: String?
    private let onRecorded: (() -> Void)?
    @EnvironmentObject var onboarding: OnboardingData
    private var dose: ScheduledDose { onboarding.applyingReschedule(to: scheduledDose) }
    private var plan: TreatmentPlan { onboarding.plan(for: dose.treatmentID) }
    private var itemName: String { plan.isNutrition ? "serving" : "dose" }
    private var itemNameTitle: String { plan.isNutrition ? "Serving" : "Dose" }
    private var displayedEncouragement: String {
        encouragement ?? (plan.isNutrition
            ? "Every serving is an act of care. You're doing this."
            : "Every dose is an act of strength. You're doing this.")
    }

    init(dose: ScheduledDose,
         encouragement: String? = nil,
         onRecorded: (() -> Void)? = nil) {
        scheduledDose = dose
        self.encouragement = encouragement
        self.onRecorded = onRecorded
    }

    var body: some View {
        AppPage {
            VStack(alignment: .leading, spacing: 12) {
                AppSectionLabel(title: (isToday ? "Today · " : "") + dose.date.formatted(.dateTime.month(.wide).day().year()))
                VStack(alignment: .leading, spacing: 0) {
                    Text(isPast ? "Past scheduled \(itemName)" : isToday ? "It's \(itemName) day" : "Upcoming \(itemName)").font(AppStyle.serif(36))
                    Text("you've got this.").font(AppStyle.italic(36))
                }
            }
            Text("“\(displayedEncouragement)”")
                .font(.custom("Georgia-Italic", size: 16, relativeTo: .body)).lineSpacing(5)
                .foregroundStyle(AppStyle.green).padding(20)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(AppStyle.paleGreen, in: RoundedRectangle(cornerRadius: 16))
                .padding(.vertical, 8)
            AppCard {
                VStack(alignment: .leading, spacing: 12) {
                    AppSectionLabel(title: plan.isNutrition ? "Your nutrition" : "Your medication")
                    VStack(alignment: .leading, spacing: 6) {
                        Text(plan.medication?.brandName ?? plan.id).font(.system(size: 16, weight: .medium))
                        Text([plan.medication?.genericName, plan.medication?.category.title.capitalized].compactMap { $0 }.joined(separator: " · "))
                            .font(.system(size: 14)).foregroundStyle(AppStyle.muted)
                        Text(plan.frequency?.title ?? "Schedule not set").font(.system(size: 14)).foregroundStyle(AppStyle.muted)
                        if (plan.frequency?.dosesPerDay ?? 1) > 1 {
                            Text(dose.timeLabel + " " + itemName).font(.system(size: 14, weight: .medium))
                        }
                    }
                }
            }
            if !isRecorded, plan.frequency?.intervalDays != nil {
                AppCard {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            AppSectionLabel(title: plan.isNutrition ? "Serving date" : "Dose date")
                            Spacer()
                            if dose.isRescheduled {
                                Text("RESCHEDULED")
                                    .font(.system(size: 9, weight: .bold))
                                    .foregroundStyle(AppStyle.refill)
                            }
                        }
                        if let originalDate = dose.originalDate {
                            Text("Moved from \(originalDate.formatted(date: .long, time: .omitted)) to \(dose.date.formatted(date: .long, time: .omitted))")
                                .font(.system(size: 13)).foregroundStyle(AppStyle.muted)
                        } else {
                            Text(dose.date.formatted(date: .long, time: .omitted))
                                .font(.system(size: 14))
                        }
                        NavigationLink(dose.isRescheduled ? "Change rescheduled date →" : "Reschedule this \(plan.isNutrition ? "serving" : "dose") →") {
                            RescheduleDoseView(dose: dose)
                        }
                        .font(.system(size: 14, weight: .semibold)).foregroundStyle(AppStyle.green)
                        if dose.isRescheduled {
                            Button("Restore original date") {
                                onboarding.restoreScheduledDate(for: dose)
                            }
                            .font(.system(size: 13)).foregroundStyle(AppStyle.muted)
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
                        Text("Check your supply before this \(itemName).").font(.system(size: 15))
                        NavigationLink("Update \(plan.isNutrition ? "servings" : "doses") remaining →") { DosesPerOrderEditorView(treatmentID: dose.treatmentID) }
                            .font(.system(size: 14, weight: .semibold)).foregroundStyle(AppStyle.green)
                    }
                }
            }
            if isRecorded {
                EmptyMessage(title: "\(itemNameTitle) recorded", detail: "This \(itemName) is already in your history.")
            } else if isToday || isPast {
                VStack(spacing: 6) {
                    if isPast {
                        Text(plan.isNutrition
                             ? "Record a serving you already had. This does not add another serving to your schedule."
                             : "Record a dose you already took. This is not an instruction to take an extra dose.")
                            .font(.subheadline).foregroundStyle(AppStyle.muted)
                    }
                    NavigationLink { DoseConfirmationView(dose: dose, onRecorded: onRecorded) } label: {
                        AppActionLabel(title: isPast ? "Record a \(plan.isNutrition ? "completed serving" : "taken dose")" : "I'm ready")
                    }
                    NavigationLink("I need a moment") { SupportMomentView() }
                        .font(.system(size: 14)).foregroundStyle(AppStyle.muted)
                        .frame(maxWidth: .infinity, minHeight: 44)
                }
            }
        }
    }
}

struct RescheduleDoseView: View {
    let dose: ScheduledDose
    @EnvironmentObject private var onboarding: OnboardingData
    @Environment(\.dismiss) private var dismiss
    @State private var selectedDate = Date()
    private let calendar = Calendar.current
    private var plan: TreatmentPlan { onboarding.plan(for: dose.treatmentID) }
    private var itemName: String { plan.isNutrition ? "serving" : "dose" }
    private var today: Date { calendar.startOfDay(for: Date()) }
    private var latestDate: Date { calendar.date(byAdding: .year, value: 1, to: today)! }
    private var currentDate: Date { calendar.startOfDay(for: dose.date) }

    var body: some View {
        AppPage(title: "Reschedule this \(itemName)") {
            AppCard {
                VStack(alignment: .leading, spacing: 7) {
                    Text(plan.medication?.brandName ?? plan.id).font(AppStyle.serif(22))
                    Text("Currently scheduled for \(currentDate.formatted(date: .long, time: .omitted))")
                        .font(.system(size: 14)).foregroundStyle(AppStyle.muted)
                    if let originalDate = dose.originalDate {
                        Text("Original date: \(originalDate.formatted(date: .long, time: .omitted))")
                            .font(.system(size: 12)).foregroundStyle(AppStyle.muted)
                    }
                }
            }

            DatePicker("New date", selection: $selectedDate, in: today...latestDate,
                       displayedComponents: .date)
                .datePickerStyle(.graphical)
                .tint(AppStyle.green)

            Text(plan.isNutrition
                 ? "This changes only this serving. Your recurring nutrition schedule stays the same."
                 : "This changes only this dose, not your prescription or recurring schedule. If illness, travel, or a missed dose affects when you should take your medication, confirm the timing with your care team or pharmacist.")
                .font(.system(size: 13)).foregroundStyle(AppStyle.muted).lineSpacing(5)
                .padding(16).frame(maxWidth: .infinity, alignment: .leading)
                .background(AppStyle.paleGreen, in: RoundedRectangle(cornerRadius: 15))

            Button {
                if onboarding.rescheduleDose(dose, to: selectedDate) { dismiss() }
            } label: {
                AppActionLabel(title: "Save new date", systemImage: "calendar.badge.clock")
            }
            .disabled(calendar.isDate(selectedDate, inSameDayAs: currentDate))
            .opacity(calendar.isDate(selectedDate, inSameDayAs: currentDate) ? 0.45 : 1)

            Button("Keep current date") { dismiss() }
                .font(.system(size: 14)).foregroundStyle(AppStyle.muted)
                .frame(maxWidth: .infinity, minHeight: 44)
        }
        .onAppear { selectedDate = max(today, currentDate) }
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
    private var plan: TreatmentPlan { onboarding.plan(for: dose.treatmentID) }
    private var itemName: String { plan.isNutrition ? "serving" : "dose" }
    private var itemNameTitle: String { plan.isNutrition ? "Serving" : "Dose" }
    var body: some View {
        AppPage(title: recorded ? "\(itemNameTitle) recorded" : plan.isNutrition ? "Have you had\nyour serving?" : "Have you taken\nyour dose?") {
            if recorded {
                EmptyMessage(title: "All done!", detail: "Your \(itemName) has been added to your history.")
                Button { if let onRecorded { onRecorded() } else { dismiss() } } label: {
                    AppActionLabel(title: onRecorded == nil ? "Back to \(itemName)" : "Back to home")
                }
            } else {
                Text(onboarding.plan(for: dose.treatmentID).isNutrition
                     ? "Only confirm once you've had this serving. Being ready doesn't record it."
                     : "Only confirm once you've taken your medication. Being ready doesn't record a dose.")
                    .font(.system(size: 15)).foregroundStyle(AppStyle.muted).lineSpacing(5)
                AppCard {
                    VStack(alignment: .leading, spacing: 12) {
                        Text(onboarding.plan(for: dose.treatmentID).medication?.brandName ?? dose.treatmentID)
                            .font(AppStyle.serif(24))
                        Text(dose.date.formatted(date: .long, time: .omitted)).font(.system(size: 14)).foregroundStyle(AppStyle.muted)
                        if (plan.frequency?.dosesPerDay ?? 1) > 1 {
                            Text(dose.timeLabel + " " + itemName).font(.system(size: 14, weight: .medium))
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
                } label: {
                    AppActionLabel(title: plan.isNutrition ? "Yes, I've had my serving" : "Yes, I've taken my dose",
                                   systemImage: "checkmark")
                }
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
        case .leftAbdomen: CGPoint(x: 14, y: -4)
        case .rightAbdomen: CGPoint(x: -14, y: -4)
        case .leftThigh: CGPoint(x: 15, y: 42)
        case .rightThigh: CGPoint(x: -15, y: 42)
        case .leftUpperArm: CGPoint(x: 36, y: -20)
        case .rightUpperArm: CGPoint(x: -36, y: -20)
        }
    }
}
