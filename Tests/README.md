# Local model checks

These dependency-free checks compile the Foundation/Combine models on macOS and use an isolated temporary data file. They do not modify simulator or app data.

```sh
swiftc -parse-as-library -module-cache-path /private/tmp/IBDLifeSwiftCache IBDLife/Models/*.swift Tests/ModelChecks.swift -o /private/tmp/ibdlife-model-checks
/private/tmp/ibdlife-model-checks
```

Coverage includes recurrence across DST, one-time dose rescheduling, partial-day setup, actual-site overrides,
stable dose identities, historical recording, duplicate/future guards, stock,
GI symptom details, condition/medication/nutrition selection, rotating support, multiple treatments, persistence, dated BMI calculation/history, flexible day intervals, medication/refill/office-visit reminder planning and limits,
local data reset, and older saved-plan compatibility.

Simulator verification is described in `IMPLEMENTATION.md` at the project root.
