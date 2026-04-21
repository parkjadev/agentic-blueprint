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

# Both
bash .claude/skills/starter-verify/scripts/verify.sh all
```

The script:
1. Delegates to `claude-config/scripts/smoke-test.sh <target>` (the canonical smoke-test).
2. Captures the exit code.
3. On failure, prints only the first 10 lines of error output — never the full multi-minute log.

## Output

**Pass:**
```
PASS — nextjs (pnpm type-check, lint, test:ci) ✓
```

**Fail:**
```
FAIL — nextjs — pnpm type-check exited with 1

<first 10 lines of error output>
```

## Do NOT

- Fix failures from within the skill — the caller (/ship, or you) decides next steps.
- Paste full logs.
- Run `pnpm install` or `flutter pub get` directly; the smoke-test script handles dependency install as part of its flow.
