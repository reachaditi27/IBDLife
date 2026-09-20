import SwiftUI

struct BMIHistoryView: View {
    @EnvironmentObject private var onboarding: OnboardingData

    var body: some View {
        AppPage(title: "BMI History") {
            Text("BMI is calculated from your locally saved height and weight. It is a general screening measure, not a diagnosis.")
                .font(.system(size: 14)).foregroundStyle(AppStyle.muted).lineSpacing(4)

            if onboarding.bodyMeasurements.isEmpty {
                EmptyMessage(title: "No BMI history yet",
                             detail: "Add your height and weight in My Profile to start your history.")
            } else {
                VStack(spacing: 12) {
                    ForEach(onboarding.bodyMeasurements.sorted { $0.date > $1.date }) { measurement in
                        measurementCard(measurement)
                    }
                }
            }
        }
    }

    private func measurementCard(_ measurement: BodyMeasurement) -> some View {
        AppCard(padding: 16) {
            HStack(spacing: 14) {
                DateBadge(date: measurement.date)
                VStack(alignment: .leading, spacing: 5) {
                    Text("BMI \(measurement.bmi.formatted(.number.precision(.fractionLength(1))))")
                        .font(.system(size: 16, weight: .semibold))
                    Text(measurementSummary(measurement))
                        .font(.system(size: 12)).foregroundStyle(AppStyle.muted)
                }
                Spacer()
            }
        }
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
                                                    heightCentimeters: heightCentimeters) {
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
