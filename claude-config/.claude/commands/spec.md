---
description: Spec — frame the problem, define done. v4 sub-verbs — idea / epic / feature / fix / chore.
argument-hint: <idea|epic|feature|fix|chore> <slug> [--parent <parent-slug>]
allowed-tools: Bash Read Write Edit Glob Grep
---

# /spec — Spec beat (v4)

The **Spec** beat collapses the v3 Research & Think + Plan stages into one continuous motion. Frame the problem, define done, produce the spec artefacts, open the issue, create the branch.

## Sub-verbs

| Sub-verb | Scope | Artefacts produced |
|---|---|---|
| `/spec idea <product>` | Whole product | research brief → product PRD (`scope: product`) → architecture → GitHub milestone + feature-backlog issues |
| `/spec epic <slug> --parent <idea>` | Multi-feature initiative | epic PRD (`scope: epic`) → epic technical-spec → issue labelled `epic` → child feature issues queued |
| `/spec feature <slug> [--parent <epic\|idea>]` | One feature | feature PRD → technical-spec → branch → issue. Auto-detects parent if one exists under `docs/specs/` |
| `/spec fix <issue-id>` | One bug | minimal technical-spec (`scope: fix`; Problem / Root cause / Fix / Regression test) → branch → issue linked |
| `/spec chore <slug>` | One task | branch + issue only. Commit with `[infra]` or `[docs]` prefix to skip Rule 3 |

`/spec` without sub-verb is interactive — ask the user which mode before proceeding. Default short form is `/spec feature <slug>`.

## Steps — `/spec idea <product>`

1. Confirm product name and one-paragraph vision with the user.
2. **Spawn `spec-researcher` subagent** (isolation) with the product name + research questions. It writes `docs/research/<product>-brief.md`.
3. Summarise the brief in 3 bullets, confirm with user before proceeding.
4. **Spawn `spec-author` subagent** to draft the product PRD (`scope: product`) and architecture document under `docs/specs/<product>.md` (flat file, v4 layout).
5. Decompose the feature matrix into child issues on the GitHub milestone.
6. Return: slug, milestone URL, count of child issues, next command (`/spec feature <first-feature> --parent <product>`).

## Steps — `/spec epic <slug> --parent <idea>`

1. Confirm parent idea exists at `docs/specs/<idea>.md`. If not, abort with a suggestion to run `/spec idea` first.
2. **Spawn `spec-author` subagent** to draft epic PRD (`scope: epic`, `parent: <idea>`) and technical-spec.
3. File epic issue labelled `epic`; queue placeholder issues for each child feature listed in the epic PRD.
4. Return: slug, issue URL, child issues, next command.

## Steps — `/spec feature <slug>`

1. Detect parent: glob `docs/specs/` for any product or epic whose PRD mentions this slug, or use `--parent` if passed.
2. Confirm with user that the parent is correct (or that none exists — that's fine).
3. **Spawn `spec-researcher` subagent** only if no parent research exists. Otherwise, read the parent's brief and skip fresh research.
4. **Spawn `spec-author` subagent** (two-pass internal: draft then self-review) to produce feature PRD + technical-spec at `docs/specs/<slug>.md` (flat) or `docs/specs/<slug>/` (folder, legacy — flat preferred in v4).
5. Create branch `feat/<issue-id>-<slug>` from `main`.
6. File the GitHub issue, linked to parent epic/idea if present.
7. Return: slug, branch, issue URL, spec path, next command (`/ship`).

## Steps — `/spec fix <issue-id>`

1. Fetch the GitHub issue for context.
2. **Spawn `spec-author` subagent** with `scope: fix` hint — produces a minimal technical-spec (four sections: Problem, Root cause, Fix, Regression test). Skips research brief and PRD.
3. Create branch `fix/<issue-id>-<slug>` from `main`.
4. Return: slug, branch, spec path.

## Steps — `/spec chore <slug>`

1. Confirm with the user this is genuinely a chore (no user-visible behaviour change, no spec value).
2. Create branch `chore/<slug>` from `main`.
3. File an issue if one doesn't exist.
4. Return: branch, next step — commit with `[infra]` or `[docs]` prefix per the task.

## What this command does NOT do

- Write code (that's `/ship`)
- Skip the templates — all spec output uses `docs/templates/` (sacred, Rule 4)
- Create folder-per-slug unless an adopter project prefers the legacy layout — v4 default is `docs/specs/<slug>.md` flat

## Focus nudge

If an open feature branch already exists locally and the user runs `/spec feature <another>`, pause and ask: "Finish <open-branch>'s spec first?" Branch hygiene warning is enforced in `/beat status`.
