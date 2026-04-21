# v4 Rebuild — Plan Marker

**Authoritative plan:** `/root/.claude/plans/ok-agentic-os-v4-polymorphic-backus.md`

This file exists to satisfy Hard Rule 6 (plan-before-code) on the v4 bootstrap
branch `claude/agentic-os-blueprint-lgulh`. The authoritative plan lives in
the Claude Code plan-mode path above and was approved by the user on
2026-04-21. v4's §1 folder-structure simplification removes the `docs/plans/`
directory entirely; this file will be deleted in PR 6.

## Six-PR migration order (from the plan, §6)

1. [release] PR 1 — Templates: archive 5 retired templates with redirect stubs,
   create `delivery.md`, add `incident-runbook.md`, rewrite v4 research brief,
   add `scope:` frontmatter to PRD + technical-spec.
2. [docs] PR 2 — Principles: collapse 12 → 8 (merge #5+#6, #8+#9, drop Zod
   #4), renumber, grep-and-replace citations, update hard-rules-check script
   to parse exception prefixes.
3. [infra] PR 3 — Commands + agents + skills + hooks: delete 7 old commands,
   add 4 new (`/spec <idea|epic|feature|fix|chore>`, `/ship`, `/signal`,
   `/beat`), collapse 5 agents → 2, restructure 5 skills → 4, rewrite three
   hooks.
4. [docs] PR 4 — Guides: replace 5 stage guides with 3 beat guides, rewrite
   `tool-reference.md` as a 2-profile × 3-beat matrix.
5. [docs] PR 5 — CLAUDE.md + README.md + skill keywords: rewrite master
   narrative, refresh public README, update skill frontmatter.
6. [infra] PR 6 — claude-config mirror + MIGRATION-v3-to-v4.md + install +
   update scripts + scheduled-tasks.yaml + GHA workflow + ISSUE_TEMPLATE
   + remove transitional markers (this file, docs/specs/<slug>/).

Each PR is atomic and reversible. Rollback plan: revert the `v4-beats` merge
commit (or the equivalent sequence of squash-merges on this branch).
