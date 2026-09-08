import SwiftUI

struct UnitPicker: View {

    @Binding var selectedUnit: UnitSystem

    var body: some View {

        VStack(alignment: .leading, spacing: 12) {

            
            HStack(spacing: 12) {

                unitButton(
                    title: "lbs / ft",
                    unit: .imperial
                )

                unitButton(
                    title: "kg / cm",
                    unit: .metric
                )
            }
        }
    }

    @ViewBuilder
    private func unitButton(
        title: String,
        unit: UnitSystem
    ) -> some View {

        Button {

            withAnimation(.easeInOut(duration: 0.2)) {
                selectedUnit = unit
            }

        } label: {

            Text(title)
                .font(.subheadline.weight(.semibold))
                .frame(maxWidth: .infinity)
                .frame(height: 52)
                .background(
                    selectedUnit == unit
                    ? Color.ibdGreen
                    : Color.white
                )
                .foregroundStyle(
                    selectedUnit == unit
                    ? .white
                    : .primary
                )
                .overlay {
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(
                            Color.ibdBorder,
                            lineWidth: 1
                        )
                }
                .clipShape(
                    RoundedRectangle(cornerRadius: 16)
                )
        }
        .buttonStyle(.plain)
    }
}

#Preview {

    @Previewable @State var unit: UnitSystem = .imperial

    UnitPicker(selectedUnit: $unit)
        .padding()
        .background(Color.ibdCream)
}
