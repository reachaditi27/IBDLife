import Charts
import SwiftUI

struct BMIHistoryView: View {
    @EnvironmentObject private var onboarding: OnboardingData
    private var measurements: [BodyMeasurement] {
        onboarding.bodyMeasurements.sorted { $0.date < $1.date }
    }
    private var bmiDomain: ClosedRange<Double> {
        guard let minimum = measurements.map(\.bmi).min(),
              let maximum = measurements.map(\.bmi).max() else { return 0...1 }
        let spread = max(maximum - minimum, 2)
        let padding = spread * 0.25
        return max(0, minimum - padding)...(maximum + padding)
    }
    private var accessibilitySummary: String {
        guard let first = measurements.first, let latest = measurements.last else { return "No BMI history." }
        return "\(measurements.count) measurements from \(first.date.formatted(date: .abbreviated, time: .omitted)) to \(latest.date.formatted(date: .abbreviated, time: .omitted)). Latest BMI \(formattedBMI(latest.bmi))."
    }

    var body: some View {
        AppPage(title: "BMI History") {
            Text("BMI is calculated from your locally saved height and weight. It is a general screening measure, not a diagnosis.")
                .font(.system(size: 14)).foregroundStyle(AppStyle.muted).lineSpacing(4)

            if measurements.isEmpty {
                EmptyMessage(title: "No BMI history yet",
                             detail: "Add your height and weight in My Profile to start your history.")
            } else {
                AppCard {
                    VStack(alignment: .leading, spacing: 18) {
                        HStack(alignment: .firstTextBaseline) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("BMI trend").font(.system(size: 15, weight: .semibold))
                                Text(dateRangeLabel).font(.system(size: 12)).foregroundStyle(AppStyle.muted)
                            }
                            Spacer()
                            if let latest = measurements.last {
                                VStack(alignment: .trailing, spacing: 2) {
                                    Text(formattedBMI(latest.bmi)).font(AppStyle.serif(26)).foregroundStyle(AppStyle.green)
                                    Text("Latest").font(.system(size: 11)).foregroundStyle(AppStyle.muted)
                                }
                            }
                        }

                        Chart(measurements) { measurement in
                            LineMark(
                                x: .value("Date", measurement.date),
                                y: .value("BMI", measurement.bmi)
                            )
                            .foregroundStyle(AppStyle.green)
                            .lineStyle(StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round))

                            PointMark(
                                x: .value("Date", measurement.date),
                                y: .value("BMI", measurement.bmi)
                            )
                            .foregroundStyle(AppStyle.green)
                            .symbolSize(55)
                            .accessibilityLabel(measurement.date.formatted(date: .long, time: .omitted))
                            .accessibilityValue("BMI \(formattedBMI(measurement.bmi))")

                            if measurement.id == measurements.last?.id {
                                PointMark(
                                    x: .value("Date", measurement.date),
                                    y: .value("BMI", measurement.bmi)
                                )
                                .foregroundStyle(AppStyle.green)
                                .annotation(position: .top, spacing: 7) {
                                    Text(formattedBMI(measurement.bmi))
                                        .font(.system(size: 11, weight: .semibold))
                                        .foregroundStyle(AppStyle.green)
                                }
                            }
                        }
                        .chartYScale(domain: bmiDomain)
                        .chartXScale(range: .plotDimension(startPadding: 18, endPadding: 24))
                        .chartXAxis {
                            AxisMarks(values: .automatic(desiredCount: min(4, measurements.count))) {
                                AxisGridLine().foregroundStyle(.clear)
                                AxisTick().foregroundStyle(AppStyle.border)
                                AxisValueLabel(format: .dateTime.month(.twoDigits).day(.twoDigits))
                                    .foregroundStyle(AppStyle.muted)
                            }
                        }
                        .chartYAxis {
                            AxisMarks(position: .leading, values: .automatic(desiredCount: 4)) {
                                AxisGridLine().foregroundStyle(AppStyle.border.opacity(0.65))
                                AxisTick().foregroundStyle(.clear)
                                AxisValueLabel().foregroundStyle(AppStyle.muted)
                            }
                        }
                        .frame(height: 230)
                        .accessibilityElement(children: .contain)
                        .accessibilityLabel("BMI history line graph")
                        .accessibilityHint(accessibilitySummary)

                        if measurements.count == 1 {
                            Text("Add another measurement later to begin seeing your trend.")
                                .font(.system(size: 12)).foregroundStyle(AppStyle.muted)
                        }

                        if let latest = measurements.last {
                            Divider()
                            HStack(spacing: 8) {
                                Image(systemName: "scalemass").foregroundStyle(AppStyle.green)
                                Text("Latest measurement · \(measurementSummary(latest))")
                                    .font(.system(size: 12)).foregroundStyle(AppStyle.muted)
                            }
                        }
                    }
                }
            }
        }
    }

    private var dateRangeLabel: String {
        guard let first = measurements.first, let latest = measurements.last else { return "" }
        if Calendar.current.isDate(first.date, inSameDayAs: latest.date) {
            return latest.date.formatted(date: .long, time: .omitted)
        }
        return "\(first.date.formatted(.dateTime.month(.abbreviated).day())) – \(latest.date.formatted(.dateTime.month(.abbreviated).day().year()))"
    }

    private func formattedBMI(_ bmi: Double) -> String {
        bmi.formatted(.number.precision(.fractionLength(1)))
    }

    private func measurementSummary(_ measurement: BodyMeasurement) -> String {
        let weight = measurement.weight(for: onboarding.unitSystem)
        let height = measurement.height(for: onboarding.unitSystem)
        if onboarding.unitSystem == .metric {
            return "\(weight.formatted(.number.precision(.fractionLength(1)))) kg · \(height.primary.formatted(.number.precision(.fractionLength(1)))) cm"
        }
        return "\(weight.formatted(.number.precision(.fractionLength(1)))) lb · \(Int(height.primary)) ft \(Int((height.secondary ?? 0).rounded())) in"
    }
}

struct BodyMeasurementEditorView: View {
    @EnvironmentObject private var onboarding: OnboardingData
    @Environment(\.dismiss) private var dismiss
    @State private var unitSystem: UnitSystem = .imperial
    @State private var weight = ""
    @State private var heightFeet = ""
    @State private var heightInches = ""
    @State private var heightCentimeters = ""
    @State private var measurementDate = Date()

    private var valid: Bool {
        guard let parsedWeight = Double(weight), parsedWeight > 0 else { return false }
        if unitSystem == .metric {
            return (Double(heightCentimeters) ?? 0) > 0
        }
        return (Double(heightFeet) ?? 0) * 12 + (Double(heightInches) ?? 0) > 0
    }

    var body: some View {
        AppPage(title: "Update measurements") {
            Text("Your BMI is calculated and stored only on this device.")
                .font(.system(size: 14)).foregroundStyle(AppStyle.muted)
            VStack(alignment: .leading, spacing: 20) {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Measurement date").font(.system(size: 14, weight: .medium))
                    DatePicker("Measurement date", selection: $measurementDate, displayedComponents: .date)
                        .datePickerStyle(.compact).tint(AppStyle.green)
                }
                VStack(alignment: .leading, spacing: 10) {
                    Text("Units").font(.system(size: 14, weight: .medium))
                    UnitPicker(selectedUnit: $unitSystem)
                }
                measurementField("Weight", placeholder: unitSystem == .metric ? "e.g. 72" : "e.g. 160",
                                 unit: unitSystem == .metric ? "kg" : "lb", text: $weight)
                VStack(alignment: .leading, spacing: 10) {
                    Text("Height").font(.system(size: 14, weight: .medium))
                    if unitSystem == .imperial {
                        HStack(spacing: 12) {
                            compactField("Feet", placeholder: "5", unit: "ft", text: $heightFeet)
                            compactField("Inches", placeholder: "11", unit: "in", text: $heightInches)
                        }
                    } else {
                        compactField("Height", placeholder: "170", unit: "cm", text: $heightCentimeters)
                    }
                }
            }
            Button {
                if onboarding.updateBodyMeasurement(unitSystem: unitSystem, weight: weight,
                                                    heightFeet: heightFeet, heightInches: heightInches,
                                                    heightCentimeters: heightCentimeters,
                                                    at: measurementDate) {
                    dismiss()
                }
            } label: { AppActionLabel(title: "Save measurements", systemImage: "checkmark") }
                .disabled(!valid).opacity(valid ? 1 : 0.45)
        }
        .onAppear {
            unitSystem = onboarding.unitSystem
            weight = onboarding.weight
            heightFeet = onboarding.heightFeet
            heightInches = onboarding.heightInches
            heightCentimeters = onboarding.heightCentimeters
        }
    }

    private func measurementField(_ title: String, placeholder: String, unit: String,
                                  text: Binding<String>) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title).font(.system(size: 14, weight: .medium))
            compactField(title, placeholder: placeholder, unit: unit, text: text)
        }
    }

    private func compactField(_ label: String, placeholder: String, unit: String,
                              text: Binding<String>) -> some View {
        HStack {
            TextField(placeholder, text: text).keyboardType(.decimalPad).accessibilityLabel(label)
            Text(unit).foregroundStyle(AppStyle.muted)
        }
        .font(.system(size: 15)).padding(16)
        .background(.white, in: RoundedRectangle(cornerRadius: 14))
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(AppStyle.border))
    }
}
