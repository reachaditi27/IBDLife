# IBDLife implementation checkpoints

Existing SwiftUI/Xcode project; onboarding is retained. `OnboardingData` is the shared,
local JSON store. `TreatmentPlan`, `DoseSchedule`, and explicit `DoseRecord` entries
drive Home, Calendar, Profile, and History. No third-party dependencies or account service.

## Baseline

The 21 PNGs in `DesignReferences` have corresponding screens: onboarding completion;
Home before/after a dose; dose details; support; four mood check-ins and notes;
symptom log; calendar; upcoming dose details; profile and prescription editor; history.
“I'm ready” opens a separate confirmation. Only confirmation records a dose.
The profile prescription editor deliberately omits the onboarding step label.

Prior verification: Debug/Release simulator builds and model checks passed; primary
flows and reference layouts were reviewed on iPhone 17 Pro. Remaining checkpoints:

1. Preserve this baseline and document verification.
2. Correct daily schedule setup after a reported dose, actual-site rotation, and
   access to today's and past unrecorded doses; add focused model regressions.
3. Bounded simulator regression pass, including a smaller iPhone and larger text.

## Repeatable verification

Run from the repository root (requires Xcode and an installed iOS simulator runtime):

```sh
swiftc -parse-as-library -module-cache-path /private/tmp/IBDLifeSwiftCache IBDLife/Models/*.swift Tests/ModelChecks.swift -o /private/tmp/ibdlife-model-checks
/private/tmp/ibdlife-model-checks
xcodebuild -project IBDLife.xcodeproj -scheme IBDLife -sdk iphonesimulator -destination 'generic/platform=iOS Simulator' -derivedDataPath /private/tmp/IBDLifeBuild CODE_SIGNING_ALLOWED=NO build
```

Add `-configuration Release` to check Release. Model checks use a temporary store.
DEBUG-only `--review-scenario onboarding`, `no-dose`, `dose-day`, or `recorded`
launch arguments use in-memory fixtures. Launch without arguments for persistent
data in the simulator app's `Application Support/IBDLife/data.json`.

## Remaining scope outside these checkpoints

Local notification delivery, broader profile/schedule editing, data export/recovery UI,
physical-device/distribution checks, and comprehensive accessibility testing are not
part of this bounded pass. Refill indicators are estimates based on recorded supply,
not pharmacy integration. Existing unused `ContentView` and `Step6PlaceholderView`
are retained to avoid unrelated cleanup. The setup reminder wording predates actual
notification support.

## Current pass results

Pending. Record concrete checks and limitations here before the final commit/tag.
