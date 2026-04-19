---
description: Run the starter's clean-boot check — type-check, lint, unit tests.
allowed-tools: Bash, Read
---

# /check — Next.js starter clean-boot

Runs the full Hard Rule 3 check suite for this starter. Use before
committing, before opening a PR, or whenever the starter needs a
sanity pass.

## Steps

1. Verify `node_modules/` exists. If not, ask the user to run
   `pnpm install` (don't run it silently — it may take minutes).
2. Run `pnpm check:all`:

   ```bash
   pnpm check:all
   ```

   This executes `pnpm type-check && pnpm lint && pnpm test:ci` in
   sequence.

3. **If any step fails**, surface the first 20 lines of error output
   and stop. Don't auto-fix — the human decides next steps.
4. **If all pass**, print a one-line success summary.

## Don't

- Don't run `pnpm install` without asking.
- Don't run `pnpm build` here — production build is a separate gate.
- Don't run `pnpm test:e2e` here — Playwright is too slow for a
  general-purpose check.
