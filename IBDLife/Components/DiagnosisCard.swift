import SwiftUI

struct DiagnosisCard: View {

    let title: String
    let description: String
    let tags: [String]
    let selected: Bool
    let action: () -> Void

    var body: some View {

        Button(action: action) {

            HStack(alignment: .top, spacing: 14) {

                // MARK: Radio Button

                ZStack {

                    Circle()
                        .stroke(
                            selected ? Color.ibdGreen : Color.ibdBorder,
                            lineWidth: 1.5
                        )
                        .frame(width: 18, height: 18)

                    if selected {

                        Circle()
                            .fill(Color.ibdGreen)
                            .frame(width: 9, height: 9)
                    }
                }
                .padding(.top, 4)

                // MARK: Text

                VStack(alignment: .leading, spacing: 10) {

                    HStack(alignment: .top) {

                        Text(title)
                            .font(.system(size: 19, weight: .semibold))
                            .foregroundColor(.primary)
                            .fixedSize(horizontal: false, vertical: true)

                        Spacer(minLength: 10)

                        VStack(alignment: .trailing, spacing: 5) {

                            ForEach(tags, id: \.self) { tag in

                                Text(tag)
                                    .font(.system(size: 10, weight: .medium))
                                    .foregroundColor(.ibdSecondaryText)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 3)
                                    .background(Color.ibdCream)
                                    .clipShape(Capsule())
                            }
                        }
                    }

                    Text(description)
                        .font(.system(size: 15))
                        .foregroundColor(.ibdSecondaryText)
                        .lineSpacing(3)
                        .multilineTextAlignment(.leading)
                }
            }
            .padding(.horizontal, 18)
            .padding(.vertical, 18)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                selected
                    ? Color.ibdGreen.opacity(0.06)
                    : Color.white
            )
            .overlay(

                RoundedRectangle(cornerRadius: 14)
                    .stroke(
                        selected
                            ? Color.ibdGreen
                            : Color.ibdBorder,
                        lineWidth: selected ? 2 : 1
                    )
            )
            .clipShape(RoundedRectangle(cornerRadius: 14))
        }
        .buttonStyle(.plain)
        .animation(.easeInOut(duration: 0.2), value: selected)
    }
}

#Preview {

    VStack(spacing: 16) {

        DiagnosisCard(
            title: "Crohn's Disease",
            description: "Inflammation anywhere along the GI tract, often in patches. Can affect the full thickness of the bowel wall.",
            tags: [
                "SMALL INTESTINE",
                "LARGE INTESTINE",
                "MOUTH TO ANUS"
            ],
            selected: false
        ) {}

        DiagnosisCard(
            title: "Ulcerative Colitis",
            description: "Continuous inflammation of the colon and rectum. Affects only the innermost lining of the large intestine.",
            tags: [
                "COLON",
                "RECTUM"
            ],
            selected: true
        ) {}
    }
    .padding()
    .background(Color.ibdCream)
}
