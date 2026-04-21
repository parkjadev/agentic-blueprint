# v4 Rebuild — Spec Marker

**Status:** In progress (meta-rebuild; v4 collapses this layout to a flat file per §1 of the plan)
**Scope:** release — harness rebuild, not a product feature
**Primary plan:** `/root/.claude/plans/ok-agentic-os-v4-polymorphic-backus.md`

## Summary

This branch (`claude/agentic-os-blueprint-lgulh`) executes the v4 rebuild of the
Agentic Blueprint — collapsing the five-stage lifecycle to three beats
(Spec → Ship → Signal), streamlining primitives (commands, agents, skills,
hooks, principles, templates), and adding a production-ready adoption flow
with tagged commit-exception prefixes and security/cost guardrails.

## Why this file exists

Hard Rules 5 and 6 require a spec directory and a plan file under the branch
slug before commits can land on this branch. The approved v4 plan (see path
above) is the authoritative design; this file exists to satisfy the v3 gate
during the bootstrap PRs (PR 1 of 6). PR 6 removes the `docs/plans/` directory
entirely and collapses `docs/specs/<slug>/` folders to flat files per the
plan's §1 folder-structure simplification.

## Exit criteria

- Six PRs merged in order (§6 of the plan): Templates → Principles → Commands
  + Agents + Skills + Hooks → Guides → CLAUDE.md + README.md + Skills
  keywords → claude-config mirror + migration guide + install/update scripts.
- Fresh clone + quickstart reaches `/spec` with no v3 terminology.
- Adopt-in-place test on a sample existing repo leaves source code untouched.

## Acceptance

All 26 verification steps in the approved plan pass on a fresh clone.
