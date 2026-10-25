# IBDLife: reviewer walkthrough

IBDLife brings medication routines, nutrition tracking, symptoms, and visit
preparation into one native iPhone interface for people living with IBD.

## Source access

- Repository: https://github.com/reachaditi27/IBDLife
- Latest code ZIP: https://github.com/reachaditi27/IBDLife/archive/refs/heads/main.zip
- Tagged versions: https://github.com/reachaditi27/IBDLife/tags
- Setup and architecture: [README](../README.md)
- Development tools and AI assistance: [disclosure](AI_USAGE.md)

The latest-main link can change as development continues. For a competition entry,
also provide the exact submitted commit or tag and its ZIP link so reviewers can
inspect the version shown in the demonstration. Future improvements should not
replace that submitted snapshot.

## Run without a personal account or patient data

Use the iPhone Simulator instructions in the README. For a quick review, run the
Debug scheme with `--review-scenario dose-day`. This uses synthetic, temporary
data. No account or external service is required. To examine onboarding instead,
use `--review-scenario onboarding`.

## Suggested walkthrough

1. **Onboarding:** enter fictional details, select a condition and a treatment,
   choose its form, schedule, injection sites where applicable, and current supply.
   Nutrition selection is a separate step. Continue to Home.
2. **Dose tracking:** open a due dose. “I'm ready” leads to a separate confirmation;
   it does not record anything by itself. Try “Not yet,” then confirm a test dose.
   Check the resulting history and stock count. Injection confirmation allows the
   actual site used to differ from the suggestion.
3. **Calendar:** inspect future dates and the detail view. Reschedule one test
   occurrence and check that the rest of the recurring schedule stays unchanged.
4. **Symptoms and support:** save a mood and optional GI details, view the symptom
   log, and visit “I need a moment” to try the calming screen.
5. **Profile:** inspect treatment editors, add a fictional dated body measurement
   and GI office visit, and inspect their history/reminder options.
6. **Export:** choose sections and prepare a health summary. Preview it using test
   data. Sending it is optional; no message to a clinician is sent automatically.
7. **Persistence:** remove review launch arguments, use fictional data in a normal
   launch, then close/reopen the app. Confirm records persist. Fixture launches
   intentionally reset on relaunch and cannot demonstrate this behavior.

## What to inspect in the code

- `DoseSchedule`: calendar-day recurrence, slots, rotation, and reschedule exceptions.
- `ScheduledDose.id`: stable identity across a one-time date change.
- `OnboardingData.recordDose`: duplicate/future guards and stock changes.
- `OnboardingData` snapshot: local persistence and compatibility with earlier fields.
- `MedicationReminderPlanner`: deterministic planning independently of iOS permission.
- `Tests/ModelChecks.swift`: executable assertions covering core state transitions.

This prototype tracks user-entered plans; it does not prescribe medication or
diagnose disease. See the README for notification, privacy, and testing limitations.

## Submission checklist for the project owner

The [official 2026 rules](https://www.congressionalappchallenge.us/wp-content/uploads/2026/05/2026-CAC-Rules.pdf)
specify an October 26, 2026, **12:00 noon EDT** deadline and a public 1–3 minute
YouTube or Vimeo demonstration. Include participant names, app name, purpose,
audience, tools/languages, and working functionality. Disclose all AI assistance
and explain your own contributions and technical understanding in the application.
Review district-specific instructions as well. Do not put registration addresses,
parent contact information, or real patient records in this public repository.

Before submitting:

- Confirm the repository and download link work while signed out of GitHub.
- Record the exact submitted revision; keep that revision unchanged after submission.
- Provide the public demo-video URL separately in the official application.
- Verify the development disclosure and add other assistance/tools if applicable.
- Submit through the official application portal; publishing GitHub code alone is
  not a Congressional App Challenge submission.
