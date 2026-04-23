---
scope: feature
parent: agentic-blueprint-v5-agnostic
status: Draft
---

# Feature — `docs/contracts/` reference library bootstrap

## Problem

v4 shipped the `ApiResponse<T>` envelope, error-code taxonomy, and optional-service gating pattern as inline conventions inside the starter codebases (`starters/nextjs/src/lib/api-response.ts`, etc.). When the starters were retired in PR #109, those patterns lost their home. They are load-bearing IP — the contract discipline that made cross-runtime consistency possible — but no longer exist anywhere in the repo.

The v5 PRD (#115) defines `docs/contracts/` as the first-class reference library that replaces this. This feature bootstraps it with the four day-one contracts called out in the PRD's Feature Matrix.

## Solution overview

Create `docs/contracts/` with five files:

- `README.md` — index, protection contract, "how to consume" guidance
- `api-response.md` — the `ApiResponse<T>` envelope
- `error-taxonomy.md` — canonical error codes and their semantics
- `auth-token.md` — auth-token shape (access + refresh), claims
- `telemetry.md` — structured-log + event-telemetry schema

Each contract file follows a single format: **Purpose → Shape (prose + JSON Schema where applicable) → Behaviour → Examples → References.** Stack-agnostic — no Next.js, Drizzle, or Supabase references. Examples use pseudocode or two contrasting implementations where helpful.

Extend the `template-guard` hook to protect `docs/contracts/` the same way `docs/templates/` is protected. Any edit requires a `[release]` commit prefix or a `docs/*` / `templates/*` / `contracts/*` branch name. This is the Rule 4 extension the PRD promised.

## Changes

| Path | Change |
|---|---|
| `docs/contracts/README.md` | New. Index + protection contract + consumption guide. |
| `docs/contracts/api-response.md` | New. `ApiResponse<T>` envelope. Port from retired `starters/nextjs/src/lib/api-response.ts` convention. |
| `docs/contracts/error-taxonomy.md` | New. Canonical error codes (`UNAUTHENTICATED`, `FORBIDDEN`, `NOT_FOUND`, `VALIDATION_ERROR`, `RATE_LIMITED`, `INTERNAL_ERROR`, etc.) + when to use each. |
| `docs/contracts/auth-token.md` | New. Access + refresh token shape, minimum claims, rotation pattern. Language-neutral JWT description. |
| `docs/contracts/telemetry.md` | New. Structured log schema + event-telemetry envelope; required fields (trace id, timestamp, severity), optional fields (user id, request id, feature flag). |
| `.claude/hooks/template-guard.sh` | Extended to also gate edits on `docs/contracts/**`. |

## Technical notes

- **Format convention:** each contract file is a single Markdown document with fixed top-level sections (Purpose, Shape, Behaviour, Examples, References). No separate JSON Schema files — inline JSON Schema blocks in the Markdown. This keeps the contract + spec + example in one place.
- **JSON Schema draft:** use draft 2020-12. No consumer tooling in v5.0 — schemas are specification, not validation. When a project needs validation it converts the inline schema into whatever its stack supports (Zod for TypeScript, dataclass-validator for Python, etc.).
- **No sample implementations in `docs/contracts/`.** Runnable code belongs in projects that consume the contract, not in the reference library. Examples in the Markdown use pseudocode or two-line illustrative snippets.
- **Protection mechanism:** replicate the existing `template-guard.sh` logic for `docs/contracts/`. A single `protected_dirs` array in the hook avoids duplicating the branch/env-var dispatch.
- **Australian spelling** applies throughout (Rule 1). Check passes in CI.

## Testing

Manual smoke:

1. Create a commit touching `docs/contracts/api-response.md` from a `feature/*` branch → template-guard blocks with "docs/contracts/ is sacred" message.
2. Re-run with branch `contracts/test` → guard allows.
3. Re-run with `AGENTIC_BLUEPRINT_RELEASE=1` env var on `feature/*` → guard allows.
4. Re-run with `[release]` commit subject on `feature/*` → guard allows only if the hook respects subject; template-guard currently gates on branch/env, not subject. **Keep behaviour aligned with `docs/templates/`** — if `docs/templates/` accepts `[release]` subjects, so does `docs/contracts/`; if it doesn't, neither does.

Automated smoke: none in v5.0. CI Hard Rules check runs on PR and will surface Rule 4 violations if the gate misfires.

## Acceptance criteria

- [x] Five files exist under `docs/contracts/`
- [x] Each contract follows the five-section format
- [x] Australian spelling passes on all files
- [x] `template-guard.sh` protects `docs/contracts/` equivalently to `docs/templates/`
- [x] Manual smoke tests 1–3 pass

## Out of scope

- Sample implementations in any specific language (belongs in consuming projects)
- Automated JSON Schema validation tooling (v5.x if needed)
- Contract versioning mechanism (v5.x — contracts evolve via `[release]` commits and `_archive/` moves, matching template conventions)

## References

- v5 PRD: `docs/specs/agentic-blueprint-v5-agnostic/PRD.md` (Feature Matrix row 1)
- v5 architecture: `docs/specs/agentic-blueprint-v5-agnostic/architecture.md` (Component Map — Reference contracts row)
- Research brief: `docs/research/agentic-blueprint-v5-agnostic-brief.md` (Finding 3 Option C; Finding 8 IP angle)
- Retired v4 starter conventions: `git show 3bb4c27:starters/nextjs/CLAUDE.md`
