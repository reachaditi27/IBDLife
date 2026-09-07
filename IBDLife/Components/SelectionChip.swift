import SwiftUI

struct SelectionChip: View {

    let title: String
    let selected: Bool
    let action: () -> Void

    var body: some View {

        Button(action: action) {

            Text(title)
                .font(.subheadline)
                .fontWeight(.medium)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(
                    selected
                    ? Color.ibdGreen
                    : Color.white
                )
                .foregroundColor(
                    selected
                    ? .white
                    : .primary
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(Color.ibdBorder)
                )
                .clipShape(RoundedRectangle(cornerRadius: 14))
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    VStack(spacing: 20) {

        SelectionChip(
            title: "Male",
            selected: true
        ) {}

        SelectionChip(
            title: "Female",
            selected: false
        ) {}
    }
    .padding()
}
