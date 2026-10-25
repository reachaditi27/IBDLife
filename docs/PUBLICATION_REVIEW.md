# Publication preparation review — October 25, 2026

Scope: prepare the existing app for source-code review, preserve working flows,
inspect publication risks, document setup and development assistance, and run
focused model/build verification. This is not a clinical validation, penetration
test, or complete re-test of every device and interface.

## Findings and preparation

- Added a root README, judge walkthrough, and development-assistance disclosure.
- Added a shared Xcode scheme so a fresh checkout has a named runnable target.
- Added ignore rules for local Xcode state, build output, signing material,
  runtime snapshots/exports, and the existing local mentor-presentation drafts.
- Added comments around occurrence identity, rescheduling, snapshots, explicit
  confirmation, the bundled catalog, finite reminders, and manual export.
- Fixed a defensive scheduling defect: a custom interval of zero could divide by
  zero; negative intervals could prevent schedule generation from terminating.
  Invalid intervals now produce no projected doses. Added focused regression checks.
- Retained the existing Apple team setting to preserve the owner's device workflow;
  reviewers must choose their own team for physical-device builds.

## Publication inventory

The seven locally available commits and 157 unique blobs were checked before these
preparation changes for common private-key/token patterns and sensitive filenames.
No matches were found for those patterns or for signing bundles, provisioning
profiles, runtime `data.json`, or health-summary exports. This heuristic scan is
not a guarantee that no sensitive information exists.

The existing history contains the Git author name/email, an Apple development-team
identifier, and local Xcode user-state paths. These are not private signing keys,
but publishing the existing history exposes them. Ignore rules and removal from
the current tree do not erase older commits. No history rewrite was performed.

Untracked `Deliverables/` and the mentor-review PowerPoint are excluded from this
publication. They were not treated as app source or evidence of clinical review.
The Figma PNGs are original design references; this pass did not re-audit every
image's embedded metadata. Remote-only branches, issues, Actions logs, attachments,
and GitHub settings require a signed-in remote review before visibility changes.

## Remaining engineering limitations

- Notification scheduling is a finite, best-effort queue; it refreshes on app launch
  and saved state changes. Delivery and background behavior need continued physical
  device testing. Asynchronous resynchronizations and failed notification requests
  would benefit from explicit serialization and visible error reporting.
- A snapshot read/write error is reported, but recovery/export of a damaged snapshot
  is not yet implemented. There is no cloud synchronization.
- Export leaves a temporary plain-text summary in the app's temporary directory.
  Local reset does not revoke already shared copies or explicitly purge that file.
- Time-zone changes, long histories, all accessibility sizes, and non-iPhone target
  platforms have not been exhaustively verified.
- The medication catalog, dose timing, injection text, and BMI presentation require
  independent clinical review before clinical claims or broad patient deployment.
- `ContentView` and the old placeholder type names remain as cleanup opportunities.
  No broad refactor or onboarding rewrite was performed for publication.

## Verification results

- **PASS:** Debug and Release simulator builds with Xcode 26.6 (17F113), the shared
  scheme, a generic iOS Simulator destination, and code signing disabled. Xcode's
  AppIntents metadata warning remains informational (no AppIntents dependency).
- **PASS:** model regression executable, including zero/negative custom intervals.
- **PASS:** shared-scheme XML parsing, relative documentation links, and Git whitespace checks.
- Remote `main` and all five existing tags matched the locally reviewed history.
  GitHub showed no configured Actions workflows and zero open/closed issues at review.

Earlier simulator and physical-device testing is described in the development
history; it should not be represented as a new exhaustive UI test in this pass.
