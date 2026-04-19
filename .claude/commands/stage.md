---
description: Report current lifecycle stage, blockers, and the next-best action.
allowed-tools: Bash, Read, Glob, Grep
---

# /stage — Lifecycle Status

Read-only snapshot: where are we in the five-stage lifecycle right now, and what's blocking progress?

## Steps

1. **Run `claude-config/scripts/update-plan-status.sh --dry-run`** (if present) to gather the current state.
2. **Inspect in parallel:**
   - Current branch name (`git branch --show-current`)
   - `docs/research/` — any briefs? how recent?
   - `docs/specs/<slug>/` for the current feature — present? which specs?
   - `docs/plans/<slug>.md` — present? status markers?
   - `CHANGELOG.md` — any `Unreleased` entry?
   - Open PR against `main` (via GitHub MCP if configured)
3. **Classify the current stage** using this heuristic:
   - On `main`, clean tree → between features (Stage 5)
   - On feature branch, no brief → **Stage 1** (run `/research`)
   - Brief exists, no specs → **Stage 2** (run `/plan`)
   - Specs approved, no code → **Stage 3** (run `/build`)
   - Code written, tests pass, no PR → **Stage 4** (run `/ship`)
   - PR merged, docs drift → **Stage 5** (run `/run memory-sync`)
4. **Print a short report:**

```
Stage: <N> — <name>
Branch: <branch>
Blockers: <list, one per line, or "none">
Next: <one concrete suggestion>
```

Keep the report to ≤ 15 lines. This command is meant to be cheap to invoke.
