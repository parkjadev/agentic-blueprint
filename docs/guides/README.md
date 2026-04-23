# Stage Guides

Long-form guides for the v4 three-beat lifecycle: **Spec → Ship → Signal**.

Read them end to end for the narrative, or jump to the beat you need. Each guide includes why the beat exists, how it works, exit criteria, platform notes (Claude-native / OutSystems ODC), and anti-patterns.

## Guides

| Beat | Guide | What it covers |
|---|---|---|
| 1 | [Spec](beat-spec.md) | Research + plan collapsed. Sub-verbs: `idea`, `epic`, `feature`, `fix`, `chore`. Produces research brief + PRD + technical-spec + branch + issue |
| 2 | [Ship](beat-ship.md) | Build + test + deploy + release as one idempotent PR-driven loop. CI gates, preview smoke-test, squash-merge, post-deploy verification |
| 3 | [Signal](beat-signal.md) | Run + monitor + learn + scheduled automation. Sub-verbs: `init`, `sync`, `audit`, `status`. Feeds back into the next Spec via `docs/signal/learnings.md` |

Plus a cross-cutting reference:

- [Tool Reference](tool-reference.md) — role mapping and beat × profile matrix across Claude-native and OutSystems ODC.

## Related surfaces

- [Principles](../principles/) — the 4 Hard Rules (1, 3, 4, 5) + 3 meta-principles (6–8) that underpin every beat. (Rule 2 retired in v5.0; numbering preserved.)
- [Templates](../templates/) — the sacred spec templates filled during `/spec`.
- [Operations](../operations/) — Signal-beat runbooks (incident response, post-mortems).

## v3 → v4 migration note

Earlier versions of the blueprint described a five-stage lifecycle (Research & Think → Plan → Build → Ship → Run). v4 collapses this to three beats because Claude Code now handles Plan → Build → Ship in one continuous motion. The v3 stage guides have been retired; `beat-spec.md` absorbs the Research + Plan content, `beat-ship.md` absorbs Build + Ship, and `beat-signal.md` absorbs Run. Historical guides live in the earlier commit history if needed.
