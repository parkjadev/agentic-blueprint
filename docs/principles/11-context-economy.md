# 11. Context economy

> Meta-principle. Shapes how `.claude/agents/` is organised.

## The idea

Subagents protect the main conversation from noise. Work that produces
a lot of tool output — full-repo greps, multi-minute builds, page-long
research summaries — happens in an isolated subagent context. The main
conversation receives a tight summary, not the raw output.

## Why

The assistant's effective working memory is bounded. Every large tool
result that lands in the main context pushes earlier context out of
reach (eventually compressed or dropped). The cost isn't the token
count today — it's the decisions the assistant can't make tomorrow
because the context is gone.

Subagents let us trade "the assistant did it themselves" for "the
assistant delegated and got a clean summary". The trade-off is almost
always worth it for any task that would otherwise produce > 100 lines
of tool output.

## In practice

- Research (Stage 1) → `researcher` subagent. Main context sees a
  3–5 bullet recommendation, not the full brief.
- Spec drafting (Stage 2) → `spec-writer` + `spec-reviewer`. Main
  context sees "specs produced + punch-list", not draft text.
- Starter boot verification → `starter-verifier`. Main context sees
  PASS/FAIL + first 10 lines on failure, not the full test log.
- Docs audit → `docs-inspector`. Main context sees a punch-list,
  not every markdown file inspected.

## Rules of thumb

- Output likely > 100 lines? Delegate.
- Output contains sensitive / noisy output (stack traces, build
  warnings, LLM draft text)? Delegate.
- Output is needed verbatim for the next step? Don't delegate — the
  summary loses information.

## Anti-patterns

- Delegating a task that produces a single line of output.
- Running a subagent that just re-does work the main context already
  started. (Subagents are isolated, so handoff context is limited.)
- Having a subagent return the full draft it wrote instead of a
  summary + path.

## Related

- Rule 10 (progressive disclosure) — the skill-level version of the
  same principle.
- `.claude/agents/` — subagent definitions.
