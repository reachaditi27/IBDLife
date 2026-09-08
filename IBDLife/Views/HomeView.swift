import SwiftUI

struct HomeView: View {
    @EnvironmentObject var onboarding: OnboardingData
    @State private var path = NavigationPath()
    @State private var now = Date()
    @Environment(\.scenePhase) private var scenePhase
    private var todayDoses: [ScheduledDose] {
        onboarding.doses(from: now, through: now).sorted {
            let left = onboarding.plan(for: $0.treatmentID).isInjection
            let right = onboarding.plan(for: $1.treatmentID).isInjection
            return left == right ? ($0.slot, $0.treatmentID) < ($1.slot, $1.treatmentID) : left
        }
    }
    private var todayRecords: [DoseRecord] {
        onboarding.doseRecords.filter { Calendar.current.isDate($0.recordedDate, inSameDayAs: now) }
    }
    private var upcoming: [ScheduledDose] { onboarding.upcoming(from: now) }
    private var greeting: String {
        let hour = Calendar.current.component(.hour, from: now)
        return hour < 12 ? "Good morning" : hour < 17 ? "Good afternoon" : "Good evening"
    }

    var body: some View {
        NavigationStack(path: $path) {
            AppPage(back: false) {
                VStack(alignment: .leading, spacing: 7) {
                    Text(now.formatted(.dateTime.weekday(.wide).month(.wide).day()))
                        .font(.system(size: 13)).foregroundStyle(AppStyle.muted)
                    Text(greeting + (onboarding.name.trimmingCharacters(in: .whitespaces).isEmpty ? "" : ","))
                        .font(AppStyle.serif(38))
                    if !onboarding.name.trimmingCharacters(in: .whitespaces).isEmpty {
                        Text(onboarding.name).font(AppStyle.italic(38))
                    }
                }.padding(.bottom, 10)
                VStack(alignment: .leading, spacing: 14) {
                    AppSectionLabel(title: "Today's medications")
                    if todayDoses.isEmpty && todayRecords.isEmpty {
                        AppCard {
                            VStack(alignment: .leading, spacing: 5) {
                                Text("No doses today").font(.system(size: 15, weight: .medium))
                                if let next = upcoming.first {
                                    Text("Next: \(name(for: next.treatmentID)) on \(next.date.formatted(.dateTime.month(.abbreviated).day())) (\(daysUntil(next.date)) days)")
                                        .font(.system(size: 13)).foregroundStyle(AppStyle.muted)
                                } else {
                                    Text("Your next scheduled dose will appear here.").font(.system(size: 13)).foregroundStyle(AppStyle.muted)
                                }
                            }
                        }
                    }
                    ForEach(todayRecords) { record in
                        if onboarding.plan(for: record.treatmentID).isInjection { completedCard(record) }
                        recordedDoseRow(record)
                    }
                    ForEach(todayDoses) { dose in
                        if onboarding.plan(for: dose.treatmentID).isInjection {
                            NavigationLink(value: dose) { dueCard(dose) }.buttonStyle(.plain)
                        }
                        NavigationLink(value: dose) { routineDoseRow(dose) }.buttonStyle(.plain)
                    }
                    ForEach(onboarding.treatments.filter { $0.frequency == .asNeeded }) { plan in
                        NavigationLink(value: ScheduledDose(treatmentID: plan.id,
                                date: Calendar.current.startOfDay(for: now), slot: onboarding.doseRecords.filter { $0.treatmentID == plan.id }.count,
                                ordinal: onboarding.doseRecords.filter { $0.treatmentID == plan.id }.count + 1,
                                site: plan.isInjection ? plan.sites.first : nil)) {
                            AppCard { Label("Record \(name(for: plan.id)) as needed", systemImage: "plus.circle").font(.system(size: 14)) }
                        }.buttonStyle(.plain)
                    }
                }
                VStack(alignment: .leading, spacing: 14) {
                    AppSectionLabel(title: "Symptoms")
                    AppCard {
                        VStack(alignment: .leading, spacing: 14) {
                            Text("How are you feeling today?").font(.system(size: 15, weight: .medium))
                            HStack(spacing: 8) {
                                ForEach(Mood.allCases) { mood in
                                    NavigationLink { SymptomCheckInView(mood: mood) } label: {
                                        VStack(spacing: 8) {
                                            Text(mood.emoji).font(.system(size: 25))
                                            Text(mood.rawValue).font(.system(size: 12)).foregroundStyle(AppStyle.muted)
                                        }.frame(maxWidth: .infinity, minHeight: 76)
                                            .background(.white, in: RoundedRectangle(cornerRadius: 15))
                                            .overlay(RoundedRectangle(cornerRadius: 15).stroke(AppStyle.border))
                                    }.buttonStyle(.plain)
                                }
                            }
                        }
                    }
                }
                VStack(alignment: .leading, spacing: 14) {
                    AppSectionLabel(title: "Need some support?")
                    NavigationLink { SupportMomentView() } label: {
                        AppCard {
                            VStack(alignment: .leading, spacing: 7) {
                                Text("Having a hard day?").font(.system(size: 15, weight: .medium))
                                Text("Get a little support before you continue with your day.")
                                    .font(.system(size: 14)).foregroundStyle(AppStyle.muted).lineSpacing(5)
                                Text("Take a moment →").font(.system(size: 14, weight: .semibold))
                                    .foregroundStyle(AppStyle.green).padding(.top, 8)
                            }
                        }
                    }.buttonStyle(.plain)
                }
                VStack(alignment: .leading, spacing: 14) {
                    AppSectionLabel(title: "Upcoming")
                    if upcoming.isEmpty {
                        EmptyMessage(title: "No upcoming doses", detail: "Your medication schedule will appear here once set up in My Profile.")
                    }
                    ForEach(Array(upcoming.filter { $0.date > Calendar.current.startOfDay(for: now) }.prefix(3))) { dose in
                        NavigationLink { UpcomingDoseDetailView(dose: dose) } label: {
                            UpcomingDoseRow(dose: dose)
                        }.buttonStyle(.plain)
                    }
                }
                VStack(alignment: .leading, spacing: 14) {
                    AppSectionLabel(title: "Quick actions")
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                        NavigationLink { MedicationCalendarView() } label: { quickAction("Calendar", "View all dose dates", "calendar") }
                        NavigationLink { ProfileView() } label: { quickAction("My Profile", "Conditions & meds", "person") }
                        NavigationLink { SymptomLogView() } label: { quickAction("Symptom log", "Track how you're feeling", "pills") }
                        NavigationLink { DoseHistoryView() } label: { quickAction("Dose history", "View your medication record", "clock.arrow.circlepath") }
                    }.buttonStyle(.plain)
                }
            }.onAppear { now = Date() }
            .onChange(of: scenePhase) { _, phase in if phase == .active { now = Date() } }
            .navigationDestination(for: ScheduledDose.self) { dose in
                DoseDayView(dose: dose, onRecorded: { path = NavigationPath() })
            }
        }
    }

    private func name(for id: String) -> String { onboarding.plan(for: id).medication?.brandName ?? id }
    private func daysUntil(_ date: Date) -> Int {
        Calendar.current.dateComponents([.day], from: Calendar.current.startOfDay(for: now), to: date).day ?? 0
    }
    private func quickAction(_ title: String, _ detail: String, _ icon: String) -> some View {
        AppCard(padding: 16) {
            VStack(alignment: .leading, spacing: 9) {
                Image(systemName: icon).font(.system(size: 18)).foregroundStyle(AppStyle.green)
                Text(title).font(.system(size: 15, weight: .medium))
                Text(detail).font(.system(size: 12)).foregroundStyle(AppStyle.muted).lineLimit(2)
            }.frame(maxWidth: .infinity, minHeight: 100, alignment: .topLeading)
        }
    }
    private func recordedDoseRow(_ record: DoseRecord) -> some View {
        AppCard(padding: 15) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(name(for: record.treatmentID)).font(.system(size: 14, weight: .medium))
                    Text("Dose recorded").font(.system(size: 12)).foregroundStyle(AppStyle.muted)
                }
                Spacer()
                Image(systemName: "checkmark.circle.fill").font(.system(size: 23)).foregroundStyle(AppStyle.green)
            }
        }.accessibilityElement(children: .combine)
    }
    private func routineDoseRow(_ dose: ScheduledDose) -> some View {
        AppCard(padding: 15) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(name(for: dose.treatmentID)).font(.system(size: 14, weight: .medium))
                    Text([dose.timeLabel, onboarding.plan(for: dose.treatmentID).medication?.genericName].compactMap { $0 }.joined(separator: " · "))
                        .font(.system(size: 12)).foregroundStyle(AppStyle.muted)
                }
                Spacer()
                Image(systemName: "circle").font(.system(size: 23)).foregroundStyle(AppStyle.border)
            }
        }
    }
    private func dueCard(_ dose: ScheduledDose) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 7) {
                Text("DOSE DAY").font(.system(size: 11, weight: .semibold)).tracking(1).opacity(0.7)
                Text(name(for: dose.treatmentID)).font(AppStyle.serif(22))
                Text(onboarding.plan(for: dose.treatmentID).medication?.genericName ?? "")
                    .font(.system(size: 13))
                Text(dose.site.map { "📍 \($0.title)" } ?? dose.timeLabel).font(.system(size: 12))
            }
            Spacer()
            VStack(spacing: 6) {
                Text("TAP TO").font(.system(size: 9))
                Text("Begin").font(.system(size: 14, weight: .semibold))
            }.padding(12).background(.white.opacity(0.18), in: RoundedRectangle(cornerRadius: 13))
        }.padding(20).foregroundStyle(.white)
            .background(AppStyle.green, in: RoundedRectangle(cornerRadius: 17))
    }
    private func completedCard(_ record: DoseRecord) -> some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 8) {
                Text(onboarding.plan(for: record.treatmentID).isInjection ? "ALL DONE!" : "DOSE RECORDED").font(.system(size: 11, weight: .semibold)).tracking(1)
                Text(name(for: record.treatmentID)).font(AppStyle.serif(22))
                Text("Dose recorded today").font(.system(size: 13))
                Text([record.site?.title, "Dose #\(record.doseNumber)"].compactMap { $0 }.joined(separator: " · "))
                    .font(.system(size: 12))
                if let next = upcoming.first(where: { $0.treatmentID == record.treatmentID }) {
                    Text("Next dose: \(next.date.formatted(.dateTime.month(.abbreviated).day()))").font(.system(size: 13))
                }
            }
            Spacer()
            Image(systemName: "checkmark.circle").padding(10).background(AppStyle.green.opacity(0.1), in: Circle())
        }.foregroundStyle(AppStyle.green).padding(20)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(AppStyle.paleGreen, in: RoundedRectangle(cornerRadius: 17))
    }
}

struct UpcomingDoseRow: View {
    let dose: ScheduledDose
    @EnvironmentObject var onboarding: OnboardingData
    var body: some View {
        AppCard(padding: 14) {
            HStack(spacing: 12) {
                DateBadge(date: dose.date)
                VStack(alignment: .leading, spacing: 4) {
                    Text(onboarding.plan(for: dose.treatmentID).medication?.brandName ?? dose.treatmentID)
                        .font(.system(size: 14, weight: .medium))
                    Text([relativeDay, dose.site?.title ?? dose.timeLabel].joined(separator: " · "))
                        .font(.system(size: 12)).foregroundStyle(AppStyle.muted)
                }
                Spacer(minLength: 0)
                if dose.needsRefill { RefillBadge() }
                Image(systemName: "chevron.right").font(.system(size: 11)).foregroundStyle(AppStyle.muted)
            }
        }
    }
    private var relativeDay: String {
        let days = Calendar.current.dateComponents([.day], from: Calendar.current.startOfDay(for: Date()), to: dose.date).day ?? 0
        return days == 0 ? "Today" : days == 1 ? "Tomorrow" : "In \(days) days"
    }
}
