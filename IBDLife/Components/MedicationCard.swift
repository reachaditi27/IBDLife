import SwiftUI

struct MedicationCard: View {

    let medication: Medication
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(alignment: .top, spacing: 16) {

                // Multi-select checkbox
                ZStack {
                    RoundedRectangle(cornerRadius: 5)
                        .fill(isSelected ? Color.ibdGreen : Color.white)
                        .frame(width: 24, height: 24)
                    RoundedRectangle(cornerRadius: 5)
                        .stroke(
                            isSelected ? Color.ibdGreen : Color.ibdBorder,
                            lineWidth: 2
                        )
                        .frame(width: 24, height: 24)

                    if isSelected {
                        Image(systemName: "checkmark")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(.white)
                    }
                }

                VStack(alignment: .leading, spacing: 6) {

                    Text(medication.brandName)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.primary)

                    if let generic = medication.genericName {
                        Text(generic)
                            .font(.system(size: 15))
                            .foregroundColor(.secondary)
                    }

                    if let details = medication.details {
                        Text(details)
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(Color.ibdGreen)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(Color.ibdGreen.opacity(0.12))
                            .clipShape(Capsule())
                    }
                }

                Spacer()
            }
            .padding(18)
            .background(
                RoundedRectangle(cornerRadius: 18)
                    .fill(Color.white)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 18)
                    .stroke(
                        isSelected ? Color.ibdGreen : Color.ibdBorder,
                        lineWidth: isSelected ? 2 : 1
                    )
            )
        }
        .buttonStyle(.plain)
        .accessibilityValue(isSelected ? "Selected" : "Not selected")
    }
}

struct MedicationAlternativeNotice: View {
    let medications: [Medication]

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: "info.circle").foregroundStyle(AppStyle.refill).padding(.top, 2)
            Text("\(medications.map(\.brandName).joined(separator: " and ")) may be alternatives or biosimilars. Confirm that you currently take both.")
                .font(.system(size: 13)).foregroundStyle(AppStyle.muted).lineSpacing(3)
        }
        .padding(15).frame(maxWidth: .infinity, alignment: .leading)
        .background(AppStyle.refill.opacity(0.08), in: RoundedRectangle(cornerRadius: 14))
    }
}
#Preview {
    MedicationCard(
        medication: Medication(
            brandName: "Humira",
            genericName: "adalimumab",
            category: .biologic,
            diagnoses: [.crohns],
            details: "Biologic",
            displayOrder: 1
        ),
        isSelected: true,
        onTap: {}
    )
    .padding()
    .background(Color.ibdCream)
}
