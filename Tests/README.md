# Local model checks

These dependency-free checks compile the Foundation/Combine models on macOS and use an isolated temporary data file. They do not modify simulator or app data.

```sh
swiftc -parse-as-library IBDLife/Models/*.swift Tests/ModelChecks.swift -o /private/tmp/ibdlife-model-checks
/private/tmp/ibdlife-model-checks
```

Simulator verification is described in `IMPLEMENTATION.md` at the project root.
