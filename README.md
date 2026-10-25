# IBDLife

IBDLife is a native SwiftUI iPhone app for people living with inflammatory bowel
disease to organize medication and nutrition routines, record symptoms, and prepare
information for conversations with their care team.

**Judges:** start with the [reviewer walkthrough](docs/JUDGES.md).
For development assistance and tool attribution, see [AI usage and credits](docs/AI_USAGE.md).

## What the app does

- Guided onboarding for health details, conditions, treatments, schedules, and supply.
- Separate medication and nutrition tracking, daily slots, custom day intervals,
  calendar views, and one-occurrence rescheduling.
- Explicit confirmation that a dose was taken, preferred injection-site rotation,
  recorded history, and supply-based refill estimates.
- Mood and GI symptom logging, including optional notes and symptom details.
- Dated height/weight measurements and BMI history.
- GI office visits and optional local dose, refill, and appointment reminders.
- Editable profile and treatment details, selective plain-text health-summary export,
  a calming support screen, and a confirmed local-data reset.

This is a student-developed tracking prototype, not a diagnostic, prescribing,
drug-interaction, or emergency-care service. Treatment choices, schedules, and
injection instructions must be confirmed with the user's care team. The bundled
medication catalog and BMI calculation are not clinically validated decision tools.

## Download and run

- [Browse the latest source](https://github.com/reachaditi27/IBDLife)
- [Download the latest main branch as a ZIP](https://github.com/reachaditi27/IBDLife/archive/refs/heads/main.zip)
- [Browse tagged versions](https://github.com/reachaditi27/IBDLife/tags)

The ZIP contains **source code**, not an installable iPhone app. A public repository
lets judges read the code without Xcode; running the native app requires a Mac.

### Requirements

- macOS with Xcode and its iOS Simulator runtime installed.
- Current project deployment target: **iOS 26.5**. Use an Xcode version with a
  compatible SDK/runtime; this project was verified with **Xcode 26.6 (17F113)**.
- No third-party package downloads, API keys, backend service, or app account.

### Fastest route: iPhone Simulator

1. Download and unzip the source, or clone it:

   ```sh
   git clone https://github.com/reachaditi27/IBDLife.git
   cd IBDLife
   ```

2. Open **IBDLife.xcodeproj** in Xcode.
3. Select the shared **IBDLife** scheme and an **iPhone Simulator** running iOS 26.5
   or newer. Do not select My Mac or a generic build-only destination.
4. Press **Command-R**. A fresh installation opens onboarding.

No Apple Developer membership or personal signing certificate is required for the
simulator. If Simulator shows a black **External Display** window, choose
**I/O → External Displays → Disabled**, then quit and reopen Simulator.

### Run on a physical iPhone

Connect and pair an iPhone running iOS 26.5 or newer. In Xcode's **IBDLife target →
Signing & Capabilities**, select **your own** team with automatic signing enabled.
The existing team identifier belongs to the project's developer; it is not a
credential or permission to sign with that account. If necessary, choose a unique
bundle identifier for your own testing copy. Enable Developer Mode on the phone,
select it as the run destination, and run. Never request or exchange private keys.

## Judge/demo fixtures

In **Product → Scheme → Edit Scheme → Run → Arguments**, add
`--review-scenario` and one of the following values to Arguments Passed On Launch:

| Value | Purpose |
| --- | --- |
| `onboarding` | Empty, temporary store for a fresh onboarding walkthrough |
| `dose-day` | Synthetic injection-day state, including confirmation and support |
| `recorded` | Synthetic state after a confirmed dose |
| `no-dose` | A day without a scheduled dose, plus sample history |
| `nutrition` | Medication and nutrition together |

These arguments work only in **Debug** builds and use an in-memory store. Changes
to these fixtures disappear on relaunch; they do not overwrite a saved profile.
Fixture schedules are demonstration data, not suggested treatment schedules.
Remove the arguments to test normal on-device persistence.

## Architecture

| Location | Responsibility |
| --- | --- |
| `IBDLifeApp.swift` | Chooses onboarding or Home and connects notification refresh |
| `Models/OnboardingData.swift` | Shared observable store, JSON persistence, explicit record mutations |
| `Models/AppRecords.swift` | Codable records, occurrence identity, calendar-based schedule generation |
| `Models/MedicationReminders.swift` | Pure, bounded reminder planning |
| `Services/MedicationReminderService.swift` | Notification permission and iOS notification delivery requests |
| `Models/MedicationDatabase.swift` | Bundled treatment-selection catalog |
| `Views/` | SwiftUI onboarding, tracking, editing, history, and export flows |
| `Components/`, `Theme/` | Shared presentation elements and colors |
| `Tests/ModelChecks.swift` | Dependency-free model regression checks |
| `DesignReferences/` | Original Figma reference exports; not screenshots of every current feature |

The app uses SwiftUI navigation and one shared store rather than a server or a
third-party state-management framework. A forecast is distinct from a confirmed
record. Rescheduling preserves the occurrence ID so the same dose cannot be
recorded twice under different dates.

## Verification

From the repository root:

```sh
swiftc -parse-as-library -module-cache-path /private/tmp/IBDLifeSwiftCache IBDLife/Models/*.swift Tests/ModelChecks.swift -o /private/tmp/ibdlife-model-checks
/private/tmp/ibdlife-model-checks
xcodebuild -project IBDLife.xcodeproj -scheme IBDLife -sdk iphonesimulator -destination 'generic/platform=iOS Simulator' -derivedDataPath /private/tmp/IBDLifeBuild CODE_SIGNING_ALLOWED=NO build
```

Add `-configuration Release` to the build command for a Release check. The model
checks are a standalone executable, **not an XCTest target**; Command-U does not
run them. They use temporary files rather than the user's app data. See
[test coverage](Tests/README.md) and the [publication review](docs/PUBLICATION_REVIEW.md).

## Privacy and current limitations

- No custom backend, analytics, login service, or automatic health-data upload is
  implemented. The app saves JSON in its Application Support directory using an
  atomic write and iOS file protection. Device/OS backup settings may also apply.
- Notifications can display treatment or clinician names; visibility depends on
  the user's system notification settings. Reminders require permission.
- Export prepares a temporary plain-text file. Sharing occurs only when the user
  chooses a destination. MyChart is a manual sharing option, **not an API integration**.
  Copies shared outside the app are not removed by its reset button.
- Reminders are a rolling, finite queue of at most 60 requests. Reopen the app to
  refresh it; reminders are not guaranteed indefinitely without opening the app.
- The catalog is bundled and does not automatically update. Refill estimates use
  user-entered stock and confirmed entries, not pharmacy inventory.
- Data recovery after a damaged snapshot, comprehensive VoiceOver/Dynamic Type
  coverage, and App Store/TestFlight distribution remain future work. Some view
  labels use fixed font sizes. The app icon is still a placeholder.
- iPhone is the reviewed target. The Xcode target also lists other Apple platforms;
  their presence does not imply equivalent testing or release readiness.

## Development and attribution

Development used Swift, SwiftUI, Foundation, Combine, UserNotifications, Xcode,
Figma references, and AI assistance. See [AI usage and credits](docs/AI_USAGE.md)
for the scope of assistance. [IMPLEMENTATION.md](IMPLEMENTATION.md) preserves
earlier checkpoint notes; the current README and publication review describe the
current source tree.

No general-purpose open-source license has been selected. Public source access
should not be described as an MIT-licensed release.
