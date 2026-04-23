# Beat — Spec

> Frame the problem, define done. Research + plan collapsed into one continuous motion.

## Why this beat exists

Most AI-assisted delivery fails not because the code is bad, but because the wrong thing gets built. Tools that optimise for speed-to-code (IDE agents, instant scaffolders) provide no dedicated surface for *thinking* — when your only tool is a code generator, every idea looks like a feature to ship.

The **Spec** beat is the antidote. Before brainstorming solutions, you need to understand the competitive landscape, user behaviour, and technical constraints. Deep-research tools synthesise dozens of sources in minutes, surfacing risks and opportunities you would otherwise discover weeks into implementation. Skipping this step means building on assumptions instead of evidence.

v4 collapses the v3 Research & Think + Plan stages into one beat because Claude Code now closes the loop from raw idea to shipping branch in one continuous motion — the spec IS the plan.

## Sub-verbs (scope-aware)

`/spec` accepts a sub-verb that sets the scope of the work:

| Sub-verb | Scope | Artefacts |
|---|---|---|
| `/spec idea <product>` | Whole product | research brief → product PRD (`scope: product`) → architecture → milestone + feature-backlog issues |
| `/spec epic <slug> --parent <idea>` | Multi-feature initiative | epic PRD + technical-spec → issue labelled `epic` |
| `/spec feature <slug> [--parent <epic\|idea>]` | One feature | feature PRD + technical-spec → branch + issue. Auto-detects parent if one exists |
| `/spec fix <issue-id>` | One bug | Minimal technical-spec (Problem / Root cause / Fix / Regression test) → branch + linked issue |
| `/spec chore <slug>` | One task | Branch + issue only; commit with `[infra]` or `[docs]` prefix |

Sub-verbs aren't just labels — they change the **weight** of the spec produced. An idea gets a product PRD with a feature matrix; a fix gets four sections and no PRD.

## How it works

### 1. Define the question

Before any tool, write down what you're trying to answer:

- For an idea: "Who are the top 5 competitors and what do they charge? What regulatory requirements apply? Who is the primary user and what is their alternative today?"
- For a feature: "Does this fit the product's north star? What's the minimum that ships value? What breaks if we don't do it?"
- For a fix: "What's the reproduction? What's the root cause? What's the smallest change that prevents recurrence?"

Vague questions produce vague answers. Falsifiable, bounded questions produce briefs worth reading.

### 2. Spawn the `spec-researcher` subagent

`/spec idea` and `/spec feature` (when no parent research exists) invoke the `spec-researcher` subagent in isolation. It:

- Reads `docs/templates/research-brief.md` — preserves every section header.
- Inventories internal context first (repo glob, prior briefs).
- Runs external research via WebSearch / WebFetch; cites every non-obvious claim.
- **Write-first protocol**: within 90 seconds, writes a minimal skeleton draft to disk — so a stream-idle timeout leaves a usable file to upgrade on rerun.
- Returns a ≤10-line summary (recommendation, top 3 risks, file path). Never pastes the full brief back.

`/spec fix` and `/spec chore` skip the research step.

### 3. Confirm the brief before drafting specs

Read the returned summary. Redirect if the framing is off. The brief is cheap to regenerate — specs built on a wrong brief are expensive to undo.

### 4. Spawn the `spec-author` subagent

Two-pass in a single agent (merged v3 spec-writer + spec-reviewer):

- **Pass 1 — Draft.** Reads the brief, parent spec if any, and the template. Writes to `docs/specs/<slug>.md` (flat — v4 default) or `docs/specs/<slug>/<spec>.md` (legacy folder layout for adopters that prefer it). Sets `scope:`, `parent:`, `status: Draft` in frontmatter.
- **Pass 2 — Self-review.** Checks section completeness (every header from template present), Hard Rules compliance, internal consistency (PRD problem ↔ tech-spec solution), and prose quality (Australian spelling, no hand-waving).

Returns a ≤20-line summary of specs produced + key design decisions + self-review findings + open questions. Never pastes full spec text.

### 5. Create branch and issue

On confirmation, the command creates the feature branch (`feat/<issue-id>-<slug>`) from `main` and files the GitHub issue, linked to parent epic/idea via the `parent:` frontmatter field.

### 6. Hand off to the Ship beat

The returned next-best command is `/ship`. Specs are the contract; Ship is where the contract gets honoured.

## Templates used (Rule 4 — sacred)

- `docs/templates/research-brief.md`
- `docs/templates/PRD.md` (scope: product | epic | feature)
- `docs/templates/technical-spec.md` (scope: epic | feature | fix)
- `docs/templates/architecture.md` (typically for idea scope)

The scope-aware frontmatter on PRD and technical-spec toggles conditional sections — Feature Matrix only for product scope, Problem/Root-cause/Fix/Regression-test for fix scope.

## Exit criteria

- Research brief (if applicable) and required specs are committed under `docs/research/` and `docs/specs/`.
- All open questions resolved or explicitly documented as frontmatter.
- Parent linkage (`parent:`) is correct for epic/feature specs.
- Hard Rule 3 (Spec-before-Ship) passes on the branch.

## Anti-patterns

| Anti-pattern | Why it fails | Do this instead |
|---|---|---|
| Skip to `/ship` without a spec | Implementation becomes guesswork; review has no contract to check against | Always run `/spec feature <slug>` first; `[infra]`/`[docs]` prefixes are for genuinely spec-less work |
| Generate the full spec chain from a one-line idea | Produces pages of plausible-looking nonsense | `/spec` is interactive; confirm research brief before specs, confirm specs before branch |
| Edit templates mid-spec | Breaks Rule 4; every downstream spec inherits the corruption | Template changes land on a `[release]`-tagged commit; fill specs never mutate templates |
| Open 3 feature branches simultaneously | Context fragments; nothing ships; `/beat status` warns at >1 | Finish one before starting the next — use `/spec epic` if the features truly need parallel tracks |

---

*Next beat: [Ship](beat-ship.md)*
