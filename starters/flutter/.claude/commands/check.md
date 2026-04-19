---
description: Run the starter's clean-boot check — analyse + test.
allowed-tools: Bash, Read
---

# /check — Flutter starter clean-boot

Runs the full Hard Rule 3 check suite for this starter.

## Steps

1. Verify `.dart_tool/` exists (i.e. `pub get` has run). If not, ask
   the user to run `flutter pub get` — don't run it silently.
2. Run the analyser and tests in sequence:

   ```bash
   flutter analyze && flutter test
   ```

3. **If either step fails**, surface the first 20 lines of error
   output and stop. Don't auto-fix.
4. **If both pass**, print a one-line success summary.

## Don't

- Don't run `flutter pub get` without asking — it can hit the network.
- Don't run `flutter build` here — production build is a separate gate.
- Don't run `flutter test --coverage` here unless the user asks; it's
  noticeably slower.
