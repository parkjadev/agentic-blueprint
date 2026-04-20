# Plan — Process Tweaks After #88

**Slug:** `process-tweaks-after-88`
**Branch:** `chore/process-tweaks-after-88`
**Status:** Approved — ready for /build <!-- status: pending -->

---

## Linked artefacts

- Technical spec — [`docs/specs/process-tweaks-after-88/technical-spec.md`](../specs/process-tweaks-after-88/technical-spec.md)
- Retro — `/root/.claude/plans/how-did-it-go-moonlit-spark.md` (session-local)
- Predecessor PR — #88 (release-strategy template)

## Goal

Four small harness tweaks surfaced during the retro of #88. One chore PR, mirrored across `.claude/` and `claude-config/.claude/`.

## Tweaks

1. **`/plan` step 3** — spawn `spec-writer` once per spec (not bundled) to avoid stream-idle timeouts.
2. **`/plan` preconditions** — require branch prefix to match hook-guarded target directories (e.g. `docs/*` / `templates/*` when editing `docs/templates/`).
3. **`/ship` steps 3–5 reorder** — create the PR before appending the changelog entry, since `append-entry.sh` requires `--pr`.
4. **`/plan` step 6** — mandate the `<!-- status: pending -->` HTML-comment marker on the plan's status line so `update-plan-status.sh` can auto-flip at Stage 5.

## Out of scope

- Adding `chore/*` to the Rule 5/6 exemption in `hard-rules-check` — tracked separately per user direction.

## Risks

| Risk | Mitigation |
|---|---|
| Root `.claude/` and mirror `claude-config/.claude/` drift | All four edits applied verbatim to both paths; diff reviewable in the PR |
| Wording change in `/plan` step 3 misinterpreted as "always parallel" | Explicit wording: "once per spec. Do not bundle." Independent specs MAY be parallel; not required |

## Next step

`/ship` — gates, PR, changelog.

---

*Plan generated as a retro follow-up. See `CLAUDE.md` Hard Rules 5 and 6.*
