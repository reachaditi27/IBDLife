# Local model checks

These dependency-free checks compile the Foundation/Combine models on macOS and use an isolated temporary data file. They do not modify simulator or app data.

```sh
swiftc -parse-as-library -module-cache-path /private/tmp/IBDLifeSwiftCache IBDLife/Models/*.swift Tests/ModelChecks.swift -o /private/tmp/ibdlife-model-checks
/private/tmp/ibdlife-model-checks
```

Coverage includes recurrence across DST, partial-day setup, actual-site overrides,
stable dose identities, historical recording, duplicate/future guards, stock,
symptoms, multiple treatments, persistence, BMI calculation/history, reminder/refill planning and limits,
and older saved-plan compatibility.

Simulator verification is described in `IMPLEMENTATION.md` at the project root.
