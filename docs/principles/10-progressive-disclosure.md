# 10. Progressive disclosure

> Meta-principle. Shapes how `.claude/skills/` is organised.

## The idea

Skills load context on demand, not upfront. A skill's entry point
(`SKILL.md`) fits in a single page and describes *when* to reach for
it; detailed references, worked examples, and assets live in
sub-files loaded only when needed.

## Why

The main conversation's context window is the scarcest resource an
agent has. Every token spent on "just-in-case" documentation is a
token that can't be spent on the actual problem. Loading a 50 KB
spelling wordlist into every session — even sessions that aren't
writing prose — is a silent tax on quality.

Progressive disclosure flips the default: sessions pay only for the
context they actually use. A session that writes no prose never loads
the wordlist. A session that never opens a PR never loads the
changelog entry template.

## In practice

- Each skill has:
  - `SKILL.md` — entry point, ≤ 1 page, names when to reach for the skill.
  - `references/` — loaded on demand by the assistant (Read tool).
  - `scripts/` — runnable from Bash; prefer running over reading.
  - `assets/` — static inputs the scripts consume.
- Skill prompts say "reach for this skill when…" so the assistant
  knows the trigger; they don't inline the skill's detailed behaviour.
- Subagent prompts list the skills they have access to, not the skill
  contents.

## Anti-patterns to avoid

- A `SKILL.md` that inlines the full wordlist, template, or worked
  example instead of linking to a sub-file.
- A skill that reads its own script source instead of executing it
  (context economy — output costs tokens; source does not).
- A subagent prompt that pastes a principle document instead of
  pointing at it.

## Related

- Rule 11 (context economy) — the closely-linked subagent version
  of the same principle.
