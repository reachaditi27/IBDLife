import SwiftUI

struct DosingScheduleView: View {

    let medication: Medication

    @Environment(\.dismiss) private var dismiss

    @State private var selectedFrequency: DosingFrequency?
    @State private var hasTakenDose: Bool?
    @State private var doseDate: Date = Date()
    @State private var showDatePicker = false

    // MARK: Body

    var body: some View {

        VStack(spacing: 0) {

            ScrollView(
                showsIndicators: false
            ) {

                VStack(
                    alignment: .leading,
                    spacing: 0
                ) {

                    // MARK: Back

                    Button {

                        dismiss()

                    } label: {

                        HStack(spacing: 6) {

                            Image(
                                systemName:
                                    "chevron.left"
                            )
                            .font(
                                .system(
                                    size: 14,
                                    weight: .semibold
                                )
                            )

                            Text("Back")
                                .fontWeight(.medium)
                        }
                        .foregroundColor(
                            .ibdSecondaryText
                        )
                    }
                    .buttonStyle(.plain)
                    .padding(.top, 8)

                    Spacer()
                        .frame(height: 28)

                    // MARK: Progress

                    Text("STEP 6 OF 7")
                        .font(
                            .caption.weight(.bold)
                        )
                        .tracking(1.5)
                        .foregroundColor(
                            .ibdSecondaryText
                        )

                    Spacer()
                        .frame(height: 14)

                    // MARK: Title

                    VStack(
                        alignment: .leading,
                        spacing: 2
                    ) {

                        Text("Set up your")
                            .font(
                                .system(
                                    size: 34,
                                    weight: .bold,
                                    design: .serif
                                )
                            )

                        Text("dosing schedule")
                            .font(
                                .system(
                                    size: 32,
                                    design: .serif
                                )
                            )
                            .italic()
                    }

                    Spacer()
                        .frame(height: 18)

                    Text(
                        "We'll use this to send timely reminders and track your adherence over time."
                    )
                    .font(.subheadline)
                    .foregroundColor(
                        .ibdSecondaryText
                    )
                    .lineSpacing(4)

                    Spacer()
                        .frame(height: 30)

                    // MARK: Frequency

                    Text(
                        "How often do you take your medication?"
                    )
                    .font(
                        .system(
                            size: 14,
                            weight: .semibold
                        )
                    )

                    Spacer()
                        .frame(height: 10)

                    VStack(spacing: 8) {

                        ForEach(
                            availableFrequencies
                        ) { frequency in

                            FrequencyCard(
                                frequency: frequency,
                                selected:
                                    selectedFrequency ==
                                    frequency
                            ) {

                                selectedFrequency =
                                    frequency
                            }
                        }
                    }

                    Spacer()
                        .frame(height: 28)

                    // MARK: Previous Dose

                    Text(
                        "Have you already taken a dose of this medication?"
                    )
                    .font(
                        .system(
                            size: 14,
                            weight: .semibold
                        )
                    )
                    .fixedSize(
                        horizontal: false,
                        vertical: true
                    )

                    Spacer()
                        .frame(height: 10)

                    HStack(spacing: 10) {

                        DoseAnswerButton(
                            title: "Yes, I have",
                            selected:
                                hasTakenDose == true
                        ) {

                            hasTakenDose = true
                        }

                        DoseAnswerButton(
                            title: "No, not yet",
                            selected:
                                hasTakenDose == false
                        ) {

                            hasTakenDose = false
                        }
                    }

                    // MARK: Date

                    if let hasTakenDose {

                        Spacer()
                            .frame(height: 24)

                        Text(
                            hasTakenDose
                            ? "When was your last dose?"
                            : "When is your next scheduled dose?"
                        )
                        .font(
                            .system(
                                size: 14,
                                weight: .semibold
                            )
                        )

                        Spacer()
                            .frame(height: 10)

                        Button {

                            showDatePicker.toggle()

                        } label: {

                            HStack {

                                Text(
                                    doseDate.formatted(
                                        .dateTime
                                            .month(.twoDigits)
                                            .day(.twoDigits)
                                            .year(.defaultDigits)
                                    )
                                )
                                .foregroundColor(
                                    .primary
                                )

                                Spacer()

                                Image(
                                    systemName:
                                        "calendar"
                                )
                                .foregroundColor(
                                    .ibdSecondaryText
                                )
                            }
                            .padding(.horizontal, 14)
                            .frame(height: 48)
                            .background(
                                RoundedRectangle(
                                    cornerRadius: 13
                                )
                                .fill(Color.white)
                            )
                            .overlay(
                                RoundedRectangle(
                                    cornerRadius: 13
                                )
                                .stroke(
                                    Color.black.opacity(0.08),
                                    lineWidth: 1
                                )
                            )
                        }
                        .buttonStyle(.plain)

                        if showDatePicker {

                            DatePicker(
                                "",
                                selection:
                                    $doseDate,
                                displayedComponents:
                                    .date
                            )
                            .datePickerStyle(
                                .graphical
                            )
                            .padding(
                                .horizontal,
                                4
                            )
                            .background(
                                RoundedRectangle(
                                    cornerRadius: 15
                                )
                                .fill(Color.white)
                            )
                            .onChange(
                                of: doseDate
                            ) { _, _ in

                                showDatePicker = false
                            }
                        }

                        Spacer()
                            .frame(height: 8)

                        Text(
                            hasTakenDose
                            ? "We'll calculate your next dose from this date."
                            : "We'll set up your schedule from this date."
                        )
                        .font(.caption)
                        .foregroundColor(
                            .ibdSecondaryText
                        )
                    }

                    Spacer()
                        .frame(height: 30)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 120)
            }

            // MARK: Bottom Bar

            bottomBar
        }
        .background(
            Color.ibdCream
                .ignoresSafeArea()
        )
        .navigationBarBackButtonHidden(true)
    }

    // MARK: Available Frequencies

    private var availableFrequencies:
        [DosingFrequency] {

        switch medication.brandName.lowercased() {

        // ---------------------------------------------------------
        // HUMIRA / ADALIMUMAB
        // ---------------------------------------------------------

        case "humira",
             "adalimumab",
             "hyrimoz",
             "amjevita",
             "cyltezo",
             "adalimumab-adbm":

            return [
                .weekly,
                .everyTwoWeeks,
                .asNeeded
            ]

        // ---------------------------------------------------------
        // REMICADE / INFLIXIMAB
        // ---------------------------------------------------------

        case "remicade",
             "infliximab",
             "renflexis",
             "inflectra",
             "avsola":

            return [
                .everyFourWeeks,
                .everySixWeeks,
                .everyEightWeeks,
                .asNeeded
            ]

        // ---------------------------------------------------------
        // STELARA
        // ---------------------------------------------------------

        case "stelara",
             "ustekinumab":

            return [
                .everyEightWeeks,
                .everyTwelveWeeks,
                .asNeeded
            ]

        // ---------------------------------------------------------
        // ENTYVIO
        // ---------------------------------------------------------

        case "entyvio",
             "vedolizumab":

            return [
                .everyFourWeeks,
                .everyEightWeeks,
                .asNeeded
            ]

        // ---------------------------------------------------------
        // NUTRITIONAL SUPPLEMENTS
        // ---------------------------------------------------------

        case "ensure plus",
             "boost plus",
             "modulen ibd",
             "kate farms standard 1.4":

            return [
                .onceDaily,
                .twiceDaily,
                .threeTimesDaily,
                .asNeeded
            ]

        // ---------------------------------------------------------
        // DEFAULT
        // ---------------------------------------------------------

        default:

            return [
                .onceDaily,
                .twiceDaily,
                .weekly,
                .everyTwoWeeks,
                .everyFourWeeks,
                .everyEightWeeks,
                .asNeeded
            ]
        }
    }

    // MARK: Bottom Bar

    private var bottomBar: some View {

        HStack {

            Button {

                // Intentionally allows the user
                // to proceed without setting
                // up the schedule.

            } label: {

                Text("Skip for now")
                    .font(.subheadline)
                    .underline()
                    .foregroundColor(
                        .ibdSecondaryText
                    )
            }
            .buttonStyle(.plain)

            Spacer()

            NavigationLink {

                Step7PlaceholderView()

            } label: {

                HStack(spacing: 8) {

                    Text("Continue")

                    Image(
                        systemName:
                            "arrow.right"
                    )
                }
                .font(
                    .system(
                        size: 15,
                        weight: .semibold
                    )
                )
                .foregroundColor(.white)
                .frame(
                    width: 108,
                    height: 48
                )
                .background(
                    RoundedRectangle(
                        cornerRadius: 14
                    )
                    .fill(
                        canContinue
                        ? Color.ibdGreen
                        : Color.ibdSecondaryText
                            .opacity(0.35)
                    )
                )
            }
            .disabled(!canContinue)
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 18)
        .background(
            .ultraThinMaterial
        )
    }

    // MARK: Validation

    private var canContinue: Bool {

        selectedFrequency != nil &&
        hasTakenDose != nil
    }
}


// MARK: - Dosing Frequency

enum DosingFrequency:
    String,
    CaseIterable,
    Identifiable,
    Hashable {

    case onceDaily
    case twiceDaily
    case threeTimesDaily
    case weekly
    case everyTwoWeeks
    case everyFourWeeks
    case everySixWeeks
    case everyEightWeeks
    case everyTwelveWeeks
    case asNeeded

    var id: String {
        rawValue
    }

    var title: String {

        switch self {

        case .onceDaily:
            return "Once daily"

        case .twiceDaily:
            return "Twice daily"

        case .threeTimesDaily:
            return "Three times daily"

        case .weekly:
            return "Weekly"

        case .everyTwoWeeks:
            return "Every 2 weeks"

        case .everyFourWeeks:
            return "Every 4 weeks"

        case .everySixWeeks:
            return "Every 6 weeks"

        case .everyEightWeeks:
            return "Every 8 weeks"

        case .everyTwelveWeeks:
            return "Every 12 weeks"

        case .asNeeded:
            return "As needed"
        }
    }

    var subtitle: String {

        switch self {

        case .onceDaily:
            return "Every day"

        case .twiceDaily:
            return "Morning & evening"

        case .threeTimesDaily:
            return "Three times each day"

        case .weekly:
            return "Same day each week"

        case .everyTwoWeeks:
            return "Every 14 days"

        case .everyFourWeeks:
            return "Every 28 days"

        case .everySixWeeks:
            return "Every 6 weeks"

        case .everyEightWeeks:
            return "Every 8 weeks"

        case .everyTwelveWeeks:
            return "Every 12 weeks"

        case .asNeeded:
            return "On-demand or flare use"
        }
    }
}


// MARK: - Frequency Card

struct FrequencyCard: View {

    let frequency: DosingFrequency
    let selected: Bool
    let action: () -> Void

    var body: some View {

        Button(
            action: action
        ) {

            HStack {

                VStack(
                    alignment: .leading,
                    spacing: 4
                ) {

                    Text(frequency.title)
                        .font(
                            .system(
                                size: 14,
                                weight: .semibold
                            )
                        )
                        .foregroundColor(
                            selected
                            ? Color.ibdGreen
                            : .primary
                        )

                    Text(frequency.subtitle)
                        .font(.caption)
                        .foregroundColor(
                            .ibdSecondaryText
                        )
                }

                Spacer()
            }
            .padding(
                .horizontal,
                14
            )
            .padding(
                .vertical,
                11
            )
            .frame(
                minHeight: 56
            )
            .background(
                RoundedRectangle(
                    cornerRadius: 14
                )
                .fill(Color.white)
            )
            .overlay(
                RoundedRectangle(
                    cornerRadius: 14
                )
                .stroke(
                    selected
                    ? Color.ibdGreen
                    : Color.black.opacity(0.08),
                    lineWidth:
                        selected ? 1.2 : 1
                )
            )
        }
        .buttonStyle(.plain)
    }
}


// MARK: - Yes / No Button

struct DoseAnswerButton: View {

    let title: String
    let selected: Bool
    let action: () -> Void

    var body: some View {

        Button(
            action: action
        ) {

            Text(title)
                .font(
                    .system(
                        size: 14,
                        weight: .medium
                    )
                )
                .foregroundColor(
                    selected
                    ? Color.ibdGreen
                    : Color.ibdSecondaryText
                )
                .frame(
                    maxWidth: .infinity
                )
                .frame(height: 48)
                .background(
                    RoundedRectangle(
                        cornerRadius: 13
                    )
                    .fill(Color.white)
                )
                .overlay(
                    RoundedRectangle(
                        cornerRadius: 13
                    )
                    .stroke(
                        selected
                        ? Color.ibdGreen
                        : Color.black.opacity(0.08),
                        lineWidth:
                            selected ? 1.2 : 1
                    )
                )
        }
        .buttonStyle(.plain)
    }
}


// MARK: - Step 7 Placeholder

struct Step7PlaceholderView: View {

    var body: some View {

        VStack(
            alignment: .leading,
            spacing: 20
        ) {

            Text("STEP 7 OF 7")
                .font(
                    .caption.weight(.bold)
                )
                .tracking(1.5)
                .foregroundColor(
                    .ibdSecondaryText
                )

            Text("You're all set")
                .font(
                    .system(
                        size: 36,
                        weight: .bold,
                        design: .serif
                    )
                )

            Text(
                "Your medication schedule is ready. We'll help you stay on track when you need support."
            )
            .font(.subheadline)
            .foregroundColor(
                .ibdSecondaryText
            )
            .lineSpacing(4)

            Spacer()
        }
        .padding(24)
        .frame(
            maxWidth: .infinity,
            maxHeight: .infinity,
            alignment: .topLeading
        )
        .background(
            Color.ibdCream
                .ignoresSafeArea()
        )
        .navigationBarBackButtonHidden(true)
    }
}
