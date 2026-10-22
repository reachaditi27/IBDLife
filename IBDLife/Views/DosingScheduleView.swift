import SwiftUI

struct DosingScheduleView: View {

    let medication: Medication
    var onContinue: (() -> Void)? = nil
    var onBack: (() -> Void)? = nil
    var isProfileEdit = false
    @EnvironmentObject var onboarding: OnboardingData
    @State private var showCompletion = false

    @Environment(\.dismiss) private var dismiss

    @State private var selectedFrequency: DosingFrequency?
    @State private var customIntervalDays = ""
    @State private var hasTakenDose: Bool?
    @State private var lastTakenSlot: Int?
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

                        if let onBack { onBack() } else { dismiss() }

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

                    if !isProfileEdit {
                        Text(medication.isNutrition
                             ? "NUTRITION SETUP · SERVING SCHEDULE"
                             : "MEDICATION SETUP · DOSING SCHEDULE")
                            .font(
                                .caption.weight(.bold)
                            )
                            .tracking(1.5)
                            .foregroundColor(
                                .ibdSecondaryText
                            )

                        Spacer()
                            .frame(height: 14)
                    }

                    // MARK: Title

                    VStack(
                        alignment: .leading,
                        spacing: 2
                    ) {

                        Text(isProfileEdit ? "Edit your" : "Set up your")
                            .font(
                                .system(
                                    size: 34,
                                    weight: .bold,
                                    design: .serif
                                )
                            )

                        Text(medication.isNutrition ? "serving schedule" : "dosing schedule")
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
                        medication.isNutrition
                            ? "We'll use this to send timely nutrition reminders and track your routine over time."
                            : "We'll use this to send timely reminders and track your adherence over time."
                    )
                    .font(.subheadline)
                    .foregroundColor(
                        .ibdSecondaryText
                    )
                    .lineSpacing(4)

                    Spacer()
                        .frame(height: 30)

                    Text(medication.brandName).font(.headline).foregroundStyle(Color.ibdGreen)
                        .padding(.bottom, 18)

                    // MARK: Frequency

                    Text(
                        medication.isNutrition ? "How often do you use this nutrition?" : "How often do you take your medication?"
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

                    if selectedFrequency == .everyNDays {
                        HStack {
                            Text("Repeat every").font(.system(size: 14, weight: .medium))
                            TextField("5", text: $customIntervalDays)
                                .keyboardType(.numberPad)
                                .multilineTextAlignment(.trailing)
                                .frame(width: 64)
                                .padding(12)
                                .background(.white, in: RoundedRectangle(cornerRadius: 12))
                                .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.ibdBorder))
                                .accessibilityLabel("Custom interval in days")
                            Text("days").font(.system(size: 14)).foregroundStyle(Color.ibdSecondaryText)
                            Spacer()
                        }
                        .padding(.top, 12)
                    }

                    Spacer()
                        .frame(height: 28)

                    // MARK: Previous Dose

                    Text(
                        medication.isNutrition
                            ? "Have you already had a serving today?"
                            : "Have you already taken a dose of this medication?"
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

                    if hasTakenDose == true, let selectedFrequency, selectedFrequency.dosesPerDay > 1 {
                        VStack(alignment: .leading, spacing: 10) {
                            Text(medication.isNutrition ? "Which serving did you last have?" : "Which dose did you last take?")
                                .font(.subheadline.weight(.semibold))
                            Picker(medication.isNutrition ? "Last serving" : "Last dose", selection: $lastTakenSlot) {
                                Text(medication.isNutrition ? "Choose a serving" : "Choose a dose").tag(Optional<Int>.none)
                                ForEach(selectedFrequency.slots, id: \.self) { slot in
                                    Text(slot == 0 ? "Morning" : slot == 1 ? "Afternoon" : "Evening").tag(Optional(slot))
                                }
                            }.tint(.ibdGreen)
                        }.padding(.top, 24)
                    }

                    if let hasTakenDose {

                        Spacer()
                            .frame(height: 24)

                        Text(
                            hasTakenDose
                            ? (medication.isNutrition ? "When was your last serving?" : "When was your last dose?")
                            : (medication.isNutrition ? "When is your next scheduled serving?" : "When is your next scheduled dose?")
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
                                selection: $doseDate,
                                in: hasTakenDose ? Date.distantPast...Date() : Calendar.current.startOfDay(for: Date())...Date.distantFuture,
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
                            ? (medication.isNutrition ? "We'll calculate your next serving from this date." : "We'll calculate your next dose from this date.")
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
        .onAppear {
            let plan = onboarding.plan(for: medication.id)
            selectedFrequency = plan.frequency
            customIntervalDays = plan.customIntervalDays.map(String.init) ?? ""
            lastTakenSlot = plan.lastTakenSlot
            if let last = plan.lastDoseDate { hasTakenDose = true; doseDate = last }
            else if let next = plan.startDate { hasTakenDose = false; doseDate = next }
        }
        .onChange(of: selectedFrequency) { _, frequency in
            if let lastTakenSlot, !(frequency?.slots.contains(lastTakenSlot) ?? false) { self.lastTakenSlot = nil }
        }
        .navigationDestination(isPresented: $showCompletion) { Step7PlaceholderView() }
        .navigationBarBackButtonHidden(true)
    }

    private func advance() {
        if let onContinue { onContinue() } else { showCompletion = true }
    }

    // MARK: Available Frequencies

    private var availableFrequencies:
        [DosingFrequency] {

        switch medication.brandName.lowercased() {

        // ---------------------------------------------------------
        // HUMIRA / ADALIMUMAB
        // ---------------------------------------------------------

        case "humira", "adalimumab":

            return [
                .weekly,
                .everyTwoWeeks,
                .everyNDays,
                .asNeeded
            ]

        // ---------------------------------------------------------
        // REMICADE / INFLIXIMAB
        // ---------------------------------------------------------

        case "remicade", "infliximab":

            return [
                .everyFourWeeks,
                .everySixWeeks,
                .everyEightWeeks,
                .everyNDays,
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
                .everyNDays,
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
                .everyNDays,
                .asNeeded
            ]

        // ---------------------------------------------------------
        // NUTRITIONAL SUPPLEMENTS
        // ---------------------------------------------------------

        case "ensure plus",
             "boost plus",
             "modulen ibd",
             "kate farms":

            return [
                .onceDaily,
                .twiceDaily,
                .threeTimesDaily,
                .everyNDays,
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
                .everyNDays,
                .asNeeded
            ]
        }
    }

    // MARK: Bottom Bar

    private var bottomBar: some View {

        HStack {

            Button {

                onboarding.configureSchedule(id: medication.id, frequency: nil, date: nil, alreadyTaken: false)
                advance()

            } label: {

                Text(isProfileEdit ? "Clear schedule" : "Skip for now")
                    .font(.subheadline)
                    .underline()
                    .foregroundColor(
                        .ibdSecondaryText
                    )
            }
            .buttonStyle(.plain)

            Spacer()

            Button {
                onboarding.configureSchedule(id: medication.id, frequency: selectedFrequency,
                                             date: selectedFrequency == .asNeeded ? nil : doseDate,
                                             alreadyTaken: selectedFrequency != .asNeeded && hasTakenDose == true,
                                             lastTakenSlot: lastTakenSlot,
                                             customIntervalDays: Int(customIntervalDays))
                advance()
            } label: {

                HStack(spacing: 8) {

                    Text(isProfileEdit ? "Save" : "Continue")

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

        let customIntervalIsValid = selectedFrequency != .everyNDays || ((Int(customIntervalDays) ?? 0) > 0 && (Int(customIntervalDays) ?? 0) <= 365)
        return selectedFrequency == .asNeeded || (selectedFrequency != nil && customIntervalIsValid && hasTakenDose != nil &&
            (hasTakenDose != true || (selectedFrequency?.dosesPerDay ?? 1) == 1 || lastTakenSlot != nil) &&
            (hasTakenDose == true ? doseDate <= Date() : doseDate >= Calendar.current.startOfDay(for: Date())))
    }
}


// MARK: - Dosing Frequency

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

    @EnvironmentObject var onboarding: OnboardingData

    var body: some View {

        VStack(
            alignment: .leading,
            spacing: 20
        ) {

            Text("SETUP COMPLETE")
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
                "Your treatment schedules are ready. Turn on reminders for medication doses, nutrition servings, and upcoming supplies."
            )
            .font(.subheadline)
            .foregroundColor(
                .ibdSecondaryText
            )
            .lineSpacing(4)

            AppCard(padding: 16) {
                MedicationReminderToggle()
            }

            Spacer()
            Button {
                onboarding.completedOnboarding = true
            } label: {
                AppActionLabel(title: "Continue to App")
            }
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
