---
description: Run the starter's clean-boot check — build, test, format.
allowed-tools: Bash, Read
---

# /check — .NET + Azure starter clean-boot

Runs the full Hard Rule 2 check suite for this starter. Use before
committing, before opening a PR, or whenever the starter needs a
sanity pass.

## Steps

1. Verify the .NET SDK is available. If `dotnet --version` fails, ask
   the user to install the .NET 9 SDK — don't install it silently.
2. Run the three checks in sequence:

   ```bash
   dotnet build
   dotnet test
   dotnet format --verify-no-changes
   ```

3. **If any step fails**, surface the first 20 lines of error output
   and stop. Don't auto-fix — the human decides next steps.
4. **If all pass**, print a one-line success summary.

## Don't

- Don't run `dotnet restore` as a separate step — `dotnet build`
  restores as part of its flow; a separate call is redundant.
- Don't run `dotnet publish` here — production build is a separate
  gate and produces artefacts not needed for clean-boot verification.
- Don't run integration tests requiring Docker (Testcontainers) unless
  the user asks; they take longer and need a Docker daemon. Filter
  with `dotnet test --filter "Category!=Integration"` if needed.
- Don't run `dotnet format` without `--verify-no-changes` — that would
  silently rewrite files. The verify form surfaces drift without
  mutating.
