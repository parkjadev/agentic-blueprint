# Technical Spec — Process Tweaks After #88

**Author:** Claude (main agent, retro follow-up)
**Date:** 2026-04-20
**Status:** Shipped (#90)
**PRD:** Not applicable — this is a harness-hygiene chore with no product-facing user. Scope captured inline below.
**Issue:** Retro of the release-strategy template session; no GitHub issue.

---

## Overview

Four small, unrelated harness tweaks surfaced during the retro for PR #88 (release-strategy template). Each closes a friction point we actually hit. Shipped together as a chore: the individual changes are too small to warrant separate PRs, but each is independently motivated.

## What's Already in Place (excluded from this plan)

| Capability | Where it lives | Notes |
|---|---|---|
| `/plan` command | `.claude/commands/plan.md`, `claude-config/.claude/commands/plan.md` | Existing Stage 2 entry point; edited here to fix the three plan-side issues |
| `/ship` command | `.claude/commands/ship.md`, `claude-config/.claude/commands/ship.md` | Existing Stage 4 entry point; edited here to reorder changelog-entry vs PR creation |
| `spec-writer` subagent | `.claude/agents/spec-writer.md` | Unchanged — fix is in the caller (`/plan`), not the agent |
| `template-guard` hook | `.claude/hooks/template-guard.sh` | Unchanged — /plan preconditions now cross-reference it |
| `update-plan-status.sh` | `claude-config/scripts/update-plan-status.sh` | Unchanged — /plan now requires the status marker it expects |

**Excluded from scope:** the hard-rules-check Rule 5/6 exemption for `chore/*` branches — tracked as a separate follow-up PR per user direction.

## Data Model Changes

None.

### Migration Strategy

Not applicable.

## API Changes

None.

## Auth & Authorisation

None.

## Background Jobs

None.

## UI Changes

None.

## Testing Strategy

### Unit Tests
- [ ] Not applicable.

### Integration Tests
- [ ] Not applicable.

### E2E Tests
- [ ] Not applicable.

### Verification Steps
- [ ] `bash .claude/skills/hard-rules-check/scripts/check-all.sh` exits 0 on `chore/process-tweaks-after-88`.
- [ ] `bash .claude/skills/australian-spelling/scripts/check.sh .claude/commands/plan.md .claude/commands/ship.md claude-config/.claude/commands/plan.md claude-config/.claude/commands/ship.md` exits 0.
- [ ] Manual read-through of each tweak against the retro items in `/root/.claude/plans/how-did-it-go-moonlit-spark.md`.

## Rollout Plan

### Phase 1: Land the four tweaks <!-- status: shipped (#90) -->

Edits applied directly:

1. **Split spec-writer per spec** — `/plan` step 3 now spawns `spec-writer` once per spec instead of bundling, avoiding the stream-idle timeout we hit twice in the #88 session.
2. **Branch-prefix precondition** — `/plan` preconditions now require the branch to match the hook-guarded target directory (e.g. `docs/*` or `templates/*` when editing `docs/templates/`). Catches the mismatch at Stage 2 instead of Stage 3.
3. **Reorder `/ship`** — step 4 creates the PR and step 5 appends the changelog entry with the real PR number. Aligns the doc with what the `changelog-entry` script actually requires.
4. **Default plan status marker** — `/plan` step 6 now mandates the `<!-- status: pending -->` HTML-comment marker on the plan's status line, so `update-plan-status.sh` can auto-flip at Stage 5.

Each edit is mirrored in both `.claude/` (root) and `claude-config/.claude/` (copy-ready bundle).

### Production rollout

1. **Preview:** PR opens → reviewers eyeball the four diff hunks × two mirror copies.
2. **Production:** Squash-merge to `main` → future `/plan` and `/ship` invocations see the updated guidance.
3. **Rollback trigger:** If any tweak regresses `/plan` or `/ship` behaviour → revert the PR; no runtime risk.

## Dependencies

None.

## Open Questions

| # | Question | Owner | Due |
|---|---|---|---|
| 1 | Should `chore/*` branches be exempted from Rule 5/6 (same as `main`/`release/*`)? Out of scope here; tracked for a separate follow-up PR. | Human reviewer | Before the next chore PR |

---

*Template from [agentic-blueprint](https://github.com/parkjadev/agentic-blueprint)*
