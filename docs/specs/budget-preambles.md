---
scope: fix
status: Draft
---

# Fix — Budget preambles on research-brief + PRD templates

## Problem

Three stream-idle-timeout failures across two sessions on `/spec idea agentic-blueprint-v5-agnostic`. Root cause is a combination of (a) large single-`Write` payloads and (b) agents that don't know there's a budget. The agent-definition changes on `chore/spec-agent-chunked-write` fix (a); the templates themselves still say nothing about word caps, so a future author can still author a 7000-word brief and hit the same wall.

## Root cause

`docs/templates/research-brief.md` and `docs/templates/PRD.md` have no budget declaration. Authoring agents see the template structure and assume unlimited scope.

## Fix

Add a single `<!-- Budget: ... -->` comment block near the top of each template, declaring word caps, section caps, and pointing at the authoring-agent write-first protocol:

- `research-brief.md`: words ≤ 4000, research questions ≤ 10, findings sections ≤ 8
- `PRD.md`: words ≤ 4500, feature-matrix rows ≤ 30, open questions ≤ 10

No structural changes. No header additions or removals. No changes to the sacred-template contract — preambles are comment-level metadata for the authoring agent.

## Regression test

Re-run `/spec idea <product>` after merge. Verify the authoring agent:

1. Reads the budget comment during template ingestion
2. Produces a brief ≤ 4000 words (current v5-agnostic brief is 3867 — at the ceiling by design)
3. Uses chunked Write + Edit when output would exceed 1500 words in any single tool call

Pairs with PR on branch `chore/spec-agent-chunked-write` (agent-definition updates). The two land together; neither is fully effective alone.
