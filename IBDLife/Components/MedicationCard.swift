import SwiftUI

struct MedicationCard: View {

    let medication: Medication
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(alignment: .top, spacing: 16) {

                // Selection Circle
                ZStack {
                    Circle()
                        .stroke(
                            isSelected ? Color.ibdGreen : Color.ibdBorder,
                            lineWidth: 2
                        )
                        .frame(width: 24, height: 24)

                    if isSelected {
                        Circle()
                            .fill(Color.ibdGreen)
                            .frame(width: 12, height: 12)
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
