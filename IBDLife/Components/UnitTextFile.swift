import SwiftUI

struct UnitTextField: View {

    let placeholder: String
    let unit: String

    @Binding var text: String

    var body: some View {

        HStack {

            TextField(placeholder, text: $text)
                .keyboardType(.decimalPad)

            Text(unit)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color.white)
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color.ibdBorder)
        )
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }
}

#Preview {

    @Previewable @State var feet = "5"

    UnitTextField(
        placeholder: "5",
        unit: "ft",
        text: $feet
    )
    .padding()
}
