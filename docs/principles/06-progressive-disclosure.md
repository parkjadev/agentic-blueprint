# 6. Progressive disclosure

> Meta-principle. Not hook-gated; read by skill-authors and reviewers.

## The rule

Skills load their detail on demand, not upfront. A skill's `SKILL.md` surfaces the frontmatter description + a short prompt; heavier content (examples, references, scripts) lives under `references/` or `assets/` and is loaded only when the skill is actually invoked.

## Why

The main Claude Code conversation has finite context. A skill that dumps 3,000 words of reference material the instant it loads consumes tokens for every future turn, not just the one where the skill's knowledge is needed. Progressive disclosure keeps the main conversation lean and shifts heavy context into isolated loads when required.

This principle shapes the harness: `spec-author`'s template references load when drafting; `hard-rules-check`'s per-rule detail pages load only when a rule fires. The user experience is "the skill knows everything" without paying for "everything" on every prompt.

## In practice

- `SKILL.md` stays under 100 lines; use `references/<topic>.md` for deep context.
- Scripts and asset files load via tool calls when the skill runs them, not via inline markdown.
- Cross-skill references are lazy: skill A mentions skill B by name, skill B's content doesn't embed into A.
- Subagents are the extreme case of progressive disclosure — their entire context lives in a separate conversation window that never pollutes the caller's.

## When it fails

- Symptom: the main conversation becomes slow or gets compaction hits unusually early.
- Diagnosis: a recently-added skill is inlining too much content. Move the heavy parts to `references/` and link rather than embed.

## Related

- Principle 7 (context economy) — the related rule for subagents.
- `.claude/skills/*/references/` — the canonical progressive-disclosure pattern.
