import Charts
import SwiftUI

struct MedicationCalendarView: View {
    @EnvironmentObject var onboarding: OnboardingData
    @State private var month = Calendar.current.dateInterval(of: .month, for: Date())!.start
    @State private var selectedDay: Date?
    private var calendar: Calendar { .current }
    private var upcoming: [ScheduledDose] { onboarding.upcoming(days: 730) }
    private var visibleDoses: [ScheduledDose] {
        if let selectedDay {
            if selectedDay < calendar.startOfDay(for: Date()) {
                return onboarding.doses(from: selectedDay, through: selectedDay)
            }
            return upcoming.filter { calendar.isDate($0.date, inSameDayAs: selectedDay) }
        }
        return Array(upcoming.filter { $0.date >= month }.prefix(12))
    }
    private var monthDoses: [ScheduledDose] {
        let end = calendar.date(byAdding: .month, value: 1, to: month)!
        return onboarding.doses(from: month, through: end, includeRecorded: true)
    }
    private var refillDates: [Date] {
        upcoming.filter(\.needsRefill).compactMap { calendar.date(byAdding: .day, value: -7, to: $0.date) }
    }
    var body: some View {
        AppPage {
            HStack {
                Text(month.formatted(.dateTime.month(.wide).year())).font(AppStyle.serif(25))
                Spacer()
                monthButton("Previous month", icon: "chevron.left", offset: -1)
                monthButton("Next month", icon: "chevron.right", offset: 1)
            }
            VStack(spacing: 12) {
                let symbols = calendar.shortStandaloneWeekdaySymbols
                HStack {
                    ForEach(0..<7) { column in
                        Text(symbols[(column + calendar.firstWeekday - 1) % 7].uppercased())
                            .font(.system(size: 11, weight: .semibold)).foregroundStyle(AppStyle.muted)
                            .frame(maxWidth: .infinity)
                    }
                }
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 4), count: 7), spacing: 10) {
                    ForEach(0..<(leadingDays + daysInMonth), id: \.self) { cell in
                        if cell < leadingDays { Color.clear.frame(height: 42).accessibilityHidden(true) }
                        else { dayCell(cell - leadingDays + 1) }
                    }
                }
            }
            HStack(spacing: 12) {
                legend(onboarding.treatments.count == 1 ? "Dose day (\(onboarding.treatments.first?.medication?.brandName ?? ""))" : "Dose day", color: AppStyle.green)
                legend("Refill reminder", color: AppStyle.refill)
                HStack(spacing: 5) {
                    Circle().stroke(AppStyle.green).frame(width: 12, height: 12)
                    Text("Today").font(.system(size: 11)).foregroundStyle(AppStyle.muted)
                }
            }.padding(.vertical, 8)
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    AppSectionLabel(title: selectedDay.map { $0.formatted(date: .abbreviated, time: .omitted) } ?? "Upcoming doses")
                    Spacer()
                    if selectedDay != nil {
                        Button("Show all") { selectedDay = nil }.font(.system(size: 13)).foregroundStyle(AppStyle.green)
                    }
                }
                if visibleDoses.isEmpty && !(selectedDay.map { day in
                    onboarding.doseRecords.contains { calendar.isDate($0.recordedDate, inSameDayAs: day) }
                    || refillDates.contains { calendar.isDate($0, inSameDayAs: day) }
                } ?? false) {
                    EmptyMessage(title: "No doses scheduled", detail: "Choose another date or view all upcoming doses.")
                }
                ForEach(visibleDoses) { dose in
                    NavigationLink { UpcomingDoseDetailView(dose: dose, encouragement: "Every dose is an act of strength. You're doing this.") } label: {
                        AppCard(padding: 16) {
                            HStack {
                                VStack(alignment: .leading, spacing: 5) {
                                    Text(dose.date.formatted(date: .long, time: .omitted)).font(.system(size: 14, weight: .medium))
                                    if onboarding.treatments.count > 1 {
                                        Text(onboarding.plan(for: dose.treatmentID).medication?.brandName ?? dose.treatmentID)
                                            .font(.system(size: 12)).foregroundStyle(AppStyle.muted)
                                    }
                                    Text(dose.site.map { "Site: \($0.title)" } ?? dose.timeLabel)
                                        .font(.system(size: 12)).foregroundStyle(AppStyle.muted)
                                }
                                Spacer(minLength: 0)
                                if dose.needsRefill { RefillBadge(title: "REFILL SOON") }
                                Image(systemName: "chevron.right").font(.system(size: 11)).foregroundStyle(AppStyle.muted)
                            }
                        }
                    }.buttonStyle(.plain)
                }
                if let selectedDay {
                    ForEach(onboarding.doseRecords.filter { calendar.isDate($0.recordedDate, inSameDayAs: selectedDay) }) { record in
                        DoseHistoryRow(record: record)
                    }
                    if refillDates.contains(where: { calendar.isDate($0, inSameDayAs: selectedDay) }) {
                        EmptyMessage(title: "Refill reminder", detail: "Contact your pharmacy to arrange your next prescription.")
                    }
                }
            }
        }
    }
    private var leadingDays: Int { (calendar.component(.weekday, from: month) - calendar.firstWeekday + 7) % 7 }
    private var daysInMonth: Int { calendar.range(of: .day, in: .month, for: month)!.count }
    private func monthButton(_ label: String, icon: String, offset: Int) -> some View {
        Button {
            month = calendar.date(byAdding: .month, value: offset, to: month)!
            selectedDay = nil
        } label: {
            Image(systemName: icon).font(.system(size: 12)).frame(width: 36, height: 36)
                .background(.white, in: Circle()).overlay(Circle().stroke(AppStyle.border))
        }.buttonStyle(.plain).accessibilityLabel(label)
    }
    private func legend(_ text: String, color: Color) -> some View {
        HStack(spacing: 5) {
            Circle().fill(color).frame(width: 12, height: 12)
            Text(text).font(.system(size: 11)).foregroundStyle(AppStyle.muted)
        }
    }
    private func dayCell(_ day: Int) -> some View {
        let date = calendar.date(byAdding: .day, value: day - 1, to: month)!
        let hasDose = monthDoses.contains { calendar.isDate($0.date, inSameDayAs: date) }
        let hasRefill = refillDates.contains { calendar.isDate($0, inSameDayAs: date) }
        let isToday = calendar.isDateInToday(date)
        let selected = selectedDay.map { calendar.isDate($0, inSameDayAs: date) } ?? false
        return Button { selectedDay = selected ? nil : date } label: {
            Text("\(day)").font(.system(size: 14, weight: hasDose ? .semibold : .regular))
                .frame(maxWidth: .infinity).frame(height: 42)
                .foregroundStyle(hasDose ? .white : AppStyle.ink)
                .background(hasDose ? AppStyle.green : .clear, in: RoundedRectangle(cornerRadius: 14))
                .overlay(RoundedRectangle(cornerRadius: 14).stroke(isToday || selected ? AppStyle.green : .clear, lineWidth: selected ? 2 : 1))
                .overlay {
                    if hasDose && (isToday || selected) {
                        RoundedRectangle(cornerRadius: 11).stroke(.white.opacity(0.8), lineWidth: 1).padding(3)
                    }
                }
                .overlay(alignment: .topTrailing) {
                    if hasRefill { Circle().fill(AppStyle.refill).frame(width: 5, height: 5).padding(4) }
                }
        }.buttonStyle(.plain)
            .accessibilityLabel("\(date.formatted(date: .long, time: .omitted))\(hasDose ? ", dose day" : "")\(hasRefill ? ", refill reminder" : "")")
    }
}

struct DoseHistoryView: View {
    var body: some View {
        TreatmentHistoryView(kind: .medication)
    }
}

struct NutritionHistoryView: View {
    var body: some View {
        TreatmentHistoryView(kind: .nutrition)
    }
}

private enum TreatmentHistoryKind {
    case medication
    case nutrition

    var title: String { self == .medication ? "Dose history" : "Nutrition history" }
    var totalLabel: String { self == .medication ? "Doses recorded" : "Servings recorded" }
    var emptyTitle: String { self == .medication ? "No recorded doses yet" : "No recorded nutrition yet" }
    var emptyDetail: String {
        self == .medication
            ? "After you confirm a medication dose, your activity chart will appear here."
            : "After you confirm a nutrition serving, your activity chart will appear here."
    }
    var color: Color { self == .medication ? AppStyle.green : AppStyle.refill }
    var isNutrition: Bool { self == .nutrition }
}

private struct TreatmentHistoryView: View {
    let kind: TreatmentHistoryKind
    @EnvironmentObject var onboarding: OnboardingData
    private let calendar = Calendar.current

    private var records: [DoseRecord] {
        onboarding.doseRecords
            .filter { onboarding.plan(for: $0.treatmentID).isNutrition == kind.isNutrition }
            .sorted { $0.recordedDate > $1.recordedDate }
    }
    private var buckets: [TreatmentHistoryBucket] {
        let currentWeek = calendar.dateInterval(of: .weekOfYear, for: Date())!.start
        let firstWeek = calendar.date(byAdding: .weekOfYear, value: -11, to: currentWeek)!
        return (0..<12).map { offset in
            let start = calendar.date(byAdding: .weekOfYear, value: offset, to: firstWeek)!
            let end = calendar.date(byAdding: .weekOfYear, value: 1, to: start)!
            return TreatmentHistoryBucket(
                weekStart: start,
                count: records.count { $0.recordedDate >= start && $0.recordedDate < end }
            )
        }
    }
    private var visibleTotal: Int { buckets.reduce(0) { $0 + $1.count } }
    private var activeWeeks: Int { buckets.count { $0.count > 0 } }
    private var chartSummary: String {
        let noun = kind == .medication ? "doses" : "nutrition servings"
        return "\(visibleTotal) \(noun) recorded across \(activeWeeks) of the last 12 weeks."
    }

    var body: some View {
        AppPage {
            VStack(alignment: .leading, spacing: 12) {
                Text(kind.title).font(AppStyle.serif())
                Text("Your recorded activity over the last 12 weeks")
                    .font(.system(size: 14)).foregroundStyle(AppStyle.muted)
            }
            if records.isEmpty {
                EmptyMessage(title: kind.emptyTitle, detail: kind.emptyDetail)
            } else {
                AppCard {
                    VStack(alignment: .leading, spacing: 20) {
                        HStack(spacing: 18) {
                            historyMetric(value: "\(visibleTotal)", label: kind.totalLabel)
                            Divider().frame(height: 38)
                            historyMetric(value: "\(activeWeeks)", label: "Active weeks")
                        }

                        Chart(buckets) { bucket in
                            BarMark(
                                x: .value("Week", bucket.weekStart, unit: .weekOfYear),
                                y: .value(kind.totalLabel, bucket.count)
                            )
                            .foregroundStyle(kind.color)
                            .cornerRadius(4)
                            .accessibilityLabel(bucket.weekStart.formatted(.dateTime.month(.abbreviated).day()))
                            .accessibilityValue("\(bucket.count) \(kind == .medication ? "doses" : "servings")")
                        }
                        .chartXAxis {
                            AxisMarks(values: .stride(by: .weekOfYear, count: 2)) {
                                AxisGridLine().foregroundStyle(.clear)
                                AxisTick().foregroundStyle(AppStyle.border)
                                AxisValueLabel(format: .dateTime.month(.abbreviated).day())
                                    .foregroundStyle(AppStyle.muted)
                            }
                        }
                        .chartYAxis {
                            AxisMarks(position: .leading) {
                                AxisGridLine().foregroundStyle(AppStyle.border.opacity(0.65))
                                AxisTick().foregroundStyle(.clear)
                                AxisValueLabel().foregroundStyle(AppStyle.muted)
                            }
                        }
                        .frame(height: 210)
                        .accessibilityElement(children: .contain)
                        .accessibilityLabel("12-week \(kind.title.lowercased()) chart")
                        .accessibilityHint(chartSummary)

                        if let latest = records.first?.recordedDate {
                            HStack(spacing: 7) {
                                Image(systemName: "checkmark.circle.fill").foregroundStyle(kind.color)
                                Text("Most recent · \(latest.formatted(date: .abbreviated, time: .omitted))")
                                    .font(.system(size: 13, weight: .medium))
                            }
                        }
                    }
                }
            }
        }
    }

    private func historyMetric(value: String, label: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(value).font(AppStyle.serif(28)).foregroundStyle(kind.color)
            Text(label).font(.system(size: 12)).foregroundStyle(AppStyle.muted)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

private struct TreatmentHistoryBucket: Identifiable {
    let weekStart: Date
    let count: Int
    var id: Date { weekStart }
}

struct DoseHistoryRow: View {
    let record: DoseRecord
    @EnvironmentObject var onboarding: OnboardingData
    var body: some View {
        AppCard(padding: 14) {
            HStack(spacing: 12) {
                DateBadge(date: record.recordedDate)
                VStack(alignment: .leading, spacing: 5) {
                    Text(onboarding.plan(for: record.treatmentID).medication?.brandName ?? record.treatmentID)
                        .font(.system(size: 14, weight: .medium))
                    Text([record.recordedDate.formatted(date: .long, time: .omitted), record.site?.title].compactMap { $0 }.joined(separator: " · "))
                        .font(.system(size: 12)).foregroundStyle(AppStyle.muted)
                }
            }
        }
    }
}
