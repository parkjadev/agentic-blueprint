# Technical Spec — Release Strategy Template

**Author:** Claude (main agent, drafting after spec-writer timeouts)
**Date:** 2026-04-20
**Status:** Shipped (#88)
**PRD:** [`docs/specs/release-strategy-template-Hhjow/PRD.md`](./PRD.md)
**Issue:** [parkjadev/agentic-blueprint#86](https://github.com/parkjadev/agentic-blueprint/issues/86)

---

## Overview

Materialise a single new sacred template at `docs/templates/release-strategy.md`. The deliverable is a markdown file that downstream projects copy into their own repos to document their chosen release strategy. This is a docs-only feature: no code, no schema, no API, no UI. The file's structure is dictated by issue #86 and its structural conventions are inherited from existing sacred templates.

## What's Already in Place (excluded from this plan)

| Capability | Where it lives | Notes |
|---|---|---|
| Release-strategy guide prose and profile descriptions | `docs/guides/stage-4-ship.md`, `docs/guides/tool-reference.md` | Shipped in PR #84; this spec does not touch them |
| Sacred template conventions (metadata block, inline guidance comments, footer) | `docs/templates/deployment.md:1-11`, `docs/templates/technical-spec.md:1-9`, `docs/templates/data-model-spec.md:1-9` | Used as structural reference; unchanged |
| Template-guard hook | `.claude/hooks/template-guard.sh` | Already prevents in-PR edits to `docs/templates/`; will apply automatically once this file lands on `main` |
| Hard Rules enforcement | `.claude/skills/hard-rules-check/scripts/check-all.sh` | Runs Australian spelling, tool-agnostic, spec-present, plan-present gates |
| Australian spelling wordlist | `.claude/skills/australian-spelling/references/wordlist.md` | Used to validate prose in the new template |

**Excluded from scope:** the `docs/guides/` prose, the starters, the CI workflow, the pre-commit gate, the template catalogue in `docs/templates/README.md` (only a single-line addition pointing at the new file — see Rollout Plan below).

## Data Model Changes

None. This feature adds a markdown file, not a data structure.

### Migration Strategy

- [x] **Pre-launch?** Not applicable — this is a docs artefact; no database is involved.
- [x] Migration is additive (no column drops, renames, or type changes) — N/A.
- [x] If destructive: split into expand → migrate → contract PRs — N/A.
- [x] Tested on the Supabase dev project before merging to `main` — N/A.
- [x] Rollback plan documented — see Rollout Plan below (rollback = revert the PR).

## API Changes

None. No endpoints added or modified.

## Auth & Authorisation

None. No runtime access-control surface is added; the file is governed by the template-guard hook once merged (see Hard Rule 7).

## Background Jobs

None.

## UI Changes

No application UI. The artefact is a markdown file rendered in GitHub and copied into downstream project repos.

## Testing Strategy

### Unit Tests
- [ ] N/A — no executable code.

### Integration Tests
- [ ] N/A — no integrations.

### E2E Tests
- [ ] N/A — no user flow to exercise.

### Verification Steps (replaces unit/integration/E2E for a docs artefact)
- [ ] `bash .claude/skills/hard-rules-check/scripts/check-all.sh` exits 0 on the feature branch (covers Rules 1, 5, 6, 7, 8 directly).
- [ ] `bash .claude/skills/australian-spelling/scripts/check.sh docs/templates/release-strategy.md` exits 0.
- [ ] Manual link check — every internal cross-reference in the new template resolves to an existing file on the feature branch.
- [ ] Spec-reviewer pass confirms: metadata block and footer match at least two existing sacred templates; every one of the nine sections from issue #86 is present; no vendor appears as a requirement inside guidance comments.
- [ ] Read-through by the user to confirm the open question on a worked example (see Open Questions below) has been decided before Stage 3.

## Rollout Plan

This feature is a single file and does not require phasing, feature flags, or a staged rollout. One commit, one PR, one merge.

### Phase 1: Draft the template and register it in the catalogue <!-- status: pending -->

- Create `docs/templates/release-strategy.md` with the nine sections from issue #86, preserved in this exact order:
  1. Chosen release profile
  2. Precondition verification
  3. Branch model and environment mapping
  4. Preview-environment approach
  5. Feature flag implementation (owner and lifecycle)
  6. Schema migration methodology
  7. Approval and CAB workflow
  8. Rollback procedures
  9. Unresolved questions
- Each section contains an HTML-comment guidance block describing what to write and pointing to the relevant blueprint resources in `docs/guides/` and `docs/principles/`. No vendor names appear as requirements — only roles.
- Metadata block at the top matches the convention used by `docs/templates/deployment.md` (Author, Date, Status).
- Footer matches the standard sacred-template footer (`*Template from [agentic-blueprint](https://github.com/parkjadev/agentic-blueprint)*`).
- Add one line to `docs/templates/README.md` registering the new template in the catalogue. This file also sits under `docs/templates/` and is guarded by the same hook; the `docs/release-strategy-template-Hhjow` branch name satisfies the `docs/*` escape-hatch and unblocks both edits.

### Phase 2 and 3

Not applicable — single-file change.

### Production rollout

1. **Preview:** PR opens → reviewers read the rendered markdown on GitHub → run verification steps (see Testing Strategy).
2. **Production:** Squash-merge to `main` → template is immediately available for downstream projects to copy.
3. **Rollback trigger:** Structural issue discovered post-merge → revert the PR; there is no runtime risk.

## Dependencies

- The existing sacred templates in `docs/templates/` — referenced for structural conventions only; not modified.
- The stage-4 guide and profile descriptions in `docs/guides/` — cross-referenced from the new template's guidance comments; not modified.
- GitHub issue #86 — source of truth for the section list.

## Open Questions

| # | Question | Owner | Due |
|---|---|---|---|
| 1 | ~~Should a filled-in worked example accompany the blank template?~~ **Resolved 2026-04-20:** deferred to a follow-up PR. This PR ships only the P0 blank template. Tracked in PRD §Open Questions #1. | Human reviewer | Resolved |
| 2 | ~~Does adding a line to `docs/templates/README.md` trip the `template-guard` hook?~~ **Resolved 2026-04-20:** yes — `docs/templates/README.md` matches `docs/templates/*` in `.claude/hooks/template-guard.sh:33`. The branch was renamed to `docs/release-strategy-template-Hhjow` to satisfy the escape-hatch at `template-guard.sh:39`, which unblocks both the new template file and the catalogue edit. | Build agent | Resolved |

---

*Template from [agentic-blueprint](https://github.com/parkjadev/agentic-blueprint)*
