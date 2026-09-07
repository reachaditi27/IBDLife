import SwiftUI

struct PrimaryButton: View {

    let title: String

    var body: some View {

        HStack(spacing: 8) {

            Text(title)
                .font(.headline)
                .fontWeight(.semibold)

            Image(systemName: "arrow.right")
                .font(.subheadline)

        }
        .foregroundColor(Color.ibdGreen)
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
}

#Preview {
    ZStack {
        Color.ibdGreen
            .ignoresSafeArea()

        VStack {
            Spacer()

            PrimaryButton(title: "Get Started")

        }
        .padding()
    }
}
