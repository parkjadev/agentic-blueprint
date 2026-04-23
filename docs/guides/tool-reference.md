# Tool Reference

> Which tool for which role — a decision framework, not a vendor pitch. v5 drops the two-profile matrix that v4 carried; stack selection now happens during the Spec beat per project, and the blueprint describes roles rather than nominating tools.

## Roles × inputs

The blueprint recognises seven roles. Any tool can fill any role; the *inputs* each role needs are stable across stacks. Pick tools per project based on the research output from `/spec idea` — not from a fixed list here.

| Role | What it does | Inputs it needs |
|---|---|---|
| Research tool | Deep research, market analysis, source synthesis | Problem statement · web search / WebFetch · prior briefs in `docs/research/` |
| Thinking partner | Brainstorm, PRD drafting, strategy, critical assessment | Repo context (CLAUDE.md, templates, briefs) · persistent chat state |
| Agentic coder / builder | Read, write, run tests, commit | Repo checkout · CLI access · approved spec at `docs/specs/<slug>/` |
| Deployment pipeline | CI/CD, preview deploys, rollback | Git hosting (GitHub / GitLab / …) · runtime target credentials · health endpoints |
| Scheduled automation | Recurring tasks, monitoring, triage | Cron / scheduler surface · AI API key · access to the repo's Signal artefacts (`docs/signal/`) |
| Ops surface | Non-code file processing, document generation, runbooks | `docs/templates/incident-runbook.md` · structured input data · output target (email, Slack, PDF) |
| Mobile supervision | Remote monitoring, async delegation | Push notification surface · permission to send commands to an active session |

Gaps are meaningful. If the project's toolset has no native equivalent for a role, the adopter fills the gap with external tooling (typically GitHub Actions cron + an AI API) or accepts the gap and moves on.

## Beat × roles

Spec and Signal roles are largely stable regardless of stack; Ship diverges most by runtime target.

| Beat | Primary roles engaged |
|---|---|
| **Spec** | Research tool + Thinking partner. `spec-researcher` fills Research; `spec-author` fills Thinking partner. |
| **Ship** | Agentic coder + Deployment pipeline (+ Mobile supervision during long builds). `/ship` orchestrates the loop. |
| **Signal** | Scheduled automation + Ops surface. `/signal init` wires the automation; the `signal-sync` skill closes the loop post-merge. |

## Canonical flow (Claude Code + GitHub Actions — the profile in active use)

One concrete example, not a prescription. A project whose `/spec idea` research recommends a different stack changes only the deployment target and CI platform; the role wiring is identical.

```
/spec feature checkout-flow
  → spec-researcher writes research brief
  → spec-author drafts PRD + technical-spec (two-pass with self-review)
  → branch feat/42-checkout-flow created, issue #42 filed
/ship
  → implementation → CI green → PR → preview smoke-test → squash-merge → production deploy
  → signal-sync appends CHANGELOG [Unreleased] entry
/signal sync
  → plan-status markers updated, cross-reference audit green
```

## MCP integrations worth naming

- **Deployment MCP (platform-specific)** — deployment inspection and log tail during `/ship` preview smoke-test. Match to the runtime target chosen in the Spec brief; projects commonly use Vercel, Azure (via `az`), AWS (via CDK/Terraform), or Fly.io.
- **GitHub MCP** — issue, PR, review, and label operations. Covers all `/spec` and `/ship` GitHub interactions.
- **Anthropic Admin API** — for `/signal status` API-spend reporting when `ANTHROPIC_ADMIN_KEY` is configured.

Additional MCP integrations are added as the ecosystem grows. The blueprint doesn't mandate any specific MCP server — the research output from `/spec idea` names the ones each project needs.

## Doc-sweep checklist (post-ship)

After the Ship beat, verify these surfaces stay in sync — `/signal sync` automates most:

- `README.md` — top-level description still accurate
- `CHANGELOG.md` — `[Unreleased]` entry present for user-visible changes
- `CLAUDE.md` — primitive map still matches the harness
- Architecture diagrams (if any) — still reflect data flow
- Repo description + topics on GitHub — for discoverability

---

*Related: [principles](../principles/) · [templates](../templates/) · [contracts](../contracts/) · [guides index](./README.md)*
