---
description: Run build_runner to regenerate freezed, json_serializable, and riverpod code.
allowed-tools: Bash, Read
---

# /generate — Run build_runner

Regenerates generated Dart files (`*.freezed.dart`, `*.g.dart`)
after editing source annotations.

## When to use

- After editing a class annotated with `@freezed`
- After editing a class annotated with `@JsonSerializable`
- After editing providers annotated with `@riverpod`

## Steps

1. Verify `.dart_tool/` exists. If not, ask the user to run
   `flutter pub get` first.
2. Run:

   ```bash
   dart run build_runner build --delete-conflicting-outputs
   ```

3. If the command surfaces conflicts it couldn't resolve, read the
   offending files and show the user — don't attempt a second run
   with `--delete-conflicting-outputs` hiding the real cause.
4. Suggest running `/check` next to confirm the regenerated code
   still passes analyse + test.

## Don't

- Don't run `build_runner watch` from a slash command — that's a
  long-running dev process, not a one-shot task.
- Don't delete `.g.dart` or `.freezed.dart` files by hand. They're
  generated; `--delete-conflicting-outputs` handles stale files.
