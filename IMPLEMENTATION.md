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

Notification action routing, broader profile/schedule editing, data export/recovery UI,
physical-device/distribution checks, and comprehensive accessibility testing are not
part of this bounded pass. Refill indicators are estimates based on recorded supply,
not pharmacy integration. Local dose and refill notifications are opt-in, use the
saved schedule's morning/afternoon/evening slots (9 AM/1 PM/7 PM local time), and
refresh on launch and relevant local plan changes. Existing unused `ContentView` and
`Step6PlaceholderView` are retained to avoid unrelated cleanup.

## September 8, 2026 checkpoint results

Completed checkpoints 1–3. Baseline commit: `c225619`. The final checkpoint is tagged
`v0.1.0-mvp` (a local development milestone, not a distribution release).

- Debug and Release iOS simulator builds: **passed**. Only Xcode's informational
  AppIntents metadata warning (no AppIntents dependency) remains.
- Model checks: **passed** recurrence/DST, daily slots, multiple treatments,
  explicit-only history, duplicate/future guards, stock, symptoms, persistence,
  actual-site overrides, historical recording, and version-1 plan compatibility.
- iPhone 17 Pro, iOS 26.5: existing saved profile reopened; Calendar → today's
  dose → confirmation → Not yet retained the pending dose; confirmation removed
  only that slot; Back to dose worked and prevented a second confirmation.
  Selecting September 7 exposed its unrecorded evening slot, allowed a date-taken
  confirmation, and saved it under September 7 without changing today's evening slot.
  The saved JSON and subsequent launch verified these records and no duplicates.
- iPhone 17e, iOS 26.5: fresh onboarding → Crohn's → Ensure Plus → oral drink →
  twice daily → already took Morning → supply → Continue to App. Morning was
  recorded and Evening remained pending today. The last-slot choice was required.
  Symptom note saving, support/return, evening confirmation/return Home, and profile
  supply editing all passed. Supply decremented once; updating it changed refill
  indicators. Relaunch and the saved JSON verified all entries and schedule fields.
- iPhone 17e at `accessibility-medium`: Home and injection detail/confirmation
  remained usable with wrapping headings and scrolling content. In an isolated
  injection fixture, changing the actual site from right abdomen to left thigh
  changed the next suggestion to right thigh. Standard text size was restored.
- Standard-size dose details were visually compared with ` Dose-day-top.png`;
  typography, palette, cards, body map, and spacing preserve the reference layout
  on the smaller phone. This was a bounded regression review, not a new pixel audit
  of all 21 references or every accessibility text size.

### Behavior and limits

Daily setup stores optional `startSlot`/`lastTakenSlot` fields. Existing saved plans
retain their prior start dates; new setup can retain later slots on the same day.
Suggested sites follow recorded actual sites; changing a suggestion never changes
a dose identity or a historical record. Today and historical slots use a separate
confirmation; future slots remain read-only. Home shows the three most recent
unrecorded doses within 90 days; Calendar exposes older selected dates. Historical
entries record the chosen date taken and do not instruct users to take catch-up doses.

Several existing body labels use fixed font sizes; comprehensive Dynamic Type and
VoiceOver support remain outside this pass. Testing used simulators, not a physical
iPhone. Debug review fixtures use memory only; both simulators were restored to
normal persistent launches, and the smaller simulator was shut down afterward.
