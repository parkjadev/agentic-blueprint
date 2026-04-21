# 7. Context economy

> Meta-principle. Shapes subagent design and command authorship.

## The rule

Subagents run in isolation so noise stays out of the main conversation. The caller sees only the subagent's final result — never its exploration, tool calls, or transcript. Commands and skills follow the same discipline: surface the decision, hide the deliberation.

## Why

A 90-minute research subagent might issue 40 tool calls and read 20 files. If all of that lands in the main conversation, the user pays tokens for work they didn't ask to see. Context economy says: the main conversation is a scarce, shared resource. Protect it.

This principle is why `researcher` writes briefs to disk rather than pasting findings back; why `starter-verify` runs scripts in isolation; why `docs-inspector` returns a structured summary, not a transcript. Each is a specific application of context economy.

## In practice

- Subagents write durable outputs (briefs, reports, logs) to disk; callers read what they need.
- Subagent prompts explicitly cap response length: "report in under 200 words", "return a 3-bullet summary".
- Slash commands follow the same pattern: `/spec` produces files; it doesn't dump the spec back into chat.
- Skills loaded into the main context are terse by design (Principle 6); heavyweight exploration happens in subagents (this rule).

## When it fails

- Symptom: main conversation transcript gets very long very fast, compaction hits early.
- Diagnosis: a subagent is returning bulk output instead of a summary + file reference, or a skill is pasting content instead of pointing to it.
- Fix: tighten the subagent's response contract; move skill content to `references/`.

## Related

- Principle 6 (progressive disclosure) — the sibling rule for skills.
- Principle 8 (gates over guidance) — the operational sibling for runtime safety.
