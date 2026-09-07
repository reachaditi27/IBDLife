import SwiftUI

struct LabeledTextField: View {

    let title: String?
    let placeholder: String

    @Binding var text: String

    var body: some View {

        VStack(alignment: .leading, spacing: 8) {

            if let title {
                Text(title)
                    .font(.headline)
            }

            TextField(placeholder, text: $text)
                .padding()
                .background(Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(Color.ibdBorder, lineWidth: 1)
                )
                .clipShape(RoundedRectangle(cornerRadius: 14))
        }
    }
}

#Preview {

    @Previewable @State var value = ""

    LabeledTextField(
        title: "Age",
        placeholder: "Years",
        text: $value
    )
    .padding()
}

