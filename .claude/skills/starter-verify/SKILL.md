---
name: starter-verify
description: Use during /ship to verify a starter still boots clean (Hard Rule 2). Runs type-check, lint, and tests in isolation so noisy build output stays out of the main conversation. Demoted from v3 starter-verifier agent to a skill in v4 — same behaviour, smaller primitive cost. Keywords — verify starter, clean boot, smoke test, pnpm check, `flutter analyze`.
allowed-tools: Bash, Read, Glob
model: haiku
---

# Starter verify

Run a starter's full check suite in isolation. Verifies Hard Rule 2 (starters stay generic and boot clean).

## When to reach for this skill

- During `/ship` before opening the PR, if the commit touches `starters/**` paths
- When asked to verify a starter manually ("does the Next.js starter still boot?")
- After a dependency bump that might have broken a starter

## How to use it

```bash
# Next.js only
bash .claude/skills/starter-verify/scripts/verify.sh nextjs

# Flutter only
bash .claude/skills/starter-verify/scripts/verify.sh flutter

# .NET + Azure only
bash .claude/skills/starter-verify/scripts/verify.sh dotnet

# All three
bash .claude/skills/starter-verify/scripts/verify.sh all
```

The script:
1. For `nextjs` and `flutter`, delegates to `claude-config/scripts/bootstrap-smoke-test.sh <target>` (the canonical scaffold-then-check smoke-test).
2. For `dotnet`, runs `dotnet build && dotnet test && dotnet format --verify-no-changes` in-tree against `starters/dotnet-azure/`. The dotnet target is skipped (not failed) if the .NET SDK is missing — same pattern as Flutter when its CLI is absent.
3. Captures the exit code.
4. On failure, prints only the first 10 lines of error output — never the full multi-minute log.

## Output

**Pass:**
```
PASS — nextjs (pnpm type-check, lint, test:ci) ✓
PASS — dotnet (dotnet build, test, format --verify-no-changes) ✓
```

**Skip (SDK missing):**
```
SKIP — dotnet — .NET SDK not installed (install .NET 9 to enable)
```

**Fail:**
```
FAIL — nextjs — pnpm type-check exited with 1

<first 10 lines of error output>
```

## Do NOT

- Fix failures from within the skill — the caller (/ship, or you) decides next steps.
- Paste full logs.
- Run `pnpm install`, `flutter pub get`, or `dotnet restore` directly; the smoke-test script handles dependency install as part of its flow, and `dotnet build` restores as part of its flow.
