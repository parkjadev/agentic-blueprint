# Document Templates

Reusable markdown templates for spec-driven development in the v4 three-beat lifecycle (**Spec → Ship → Signal**).

Templates are **sacred** (Hard Rule 4 in v4 / #7 in v3). Edit them only during an explicit release rebuild (`AGENTIC_BLUEPRINT_RELEASE=1` or on a `docs/*` / `templates/*` branch), never inside a feature PR.

## Active templates (9)

| Template | Beat | Purpose |
|---|---|---|
| `research-brief.md` | Spec | Structured findings from deep research — lands via `/spec` idea or feature |
| `PRD.md` | Spec | Product Requirements Document; `scope: product \| epic \| feature` frontmatter selects weight |
| `technical-spec.md` | Spec | Feature-level (or epic-level) technical design; absorbs former `api-spec`, `data-model-spec`, `auth-spec` via dedicated sections |
| `architecture.md` | Spec | System-level component map, data flow, integrations, key decisions |
| `api-reference.md` | Ship | Exhaustive read-only catalogue of all endpoints in the system |
| `delivery.md` | Ship | Unified release policy + mechanics (environments, branches, CI/CD, flags, migrations, rollback) — replaces v3 `deployment.md` + `release-strategy.md` |
| `incident-runbook.md` | Signal | Page you open when something is on fire — trigger, severity, mitigation, rollback ladder, post-mortem |
| `CHANGELOG.md` | Signal | keepachangelog-formatted release notes |
| `README.md` | Project-level | Per-project README template |

## Archived in v4 (`_archive/`)

Retained for provenance. Each archived file starts with a redirect stub pointing to its new home.

- `api-spec.md` → `technical-spec.md` § API Changes
- `data-model-spec.md` → `technical-spec.md` § Data Model Changes
- `auth-spec.md` → `technical-spec.md` § Auth & Authorisation
- `deployment.md` → `delivery.md`
- `release-strategy.md` → `delivery.md`

## Scope-aware templates

`PRD.md` and `technical-spec.md` both accept a `scope:` frontmatter field. Rendered sections vary by scope:

- `scope: product` — whole-product: vision, users, journeys, feature matrix, success metrics, non-goals
- `scope: epic` — multi-feature initiative: references parent product, decomposes into features
- `scope: feature` — single feature: acceptance criteria, detailed API/data/auth sections, rollout

Parent linking via a `parent: <slug>` field. `/spec feature` auto-detects a parent epic or product if one exists under `docs/specs/`.

---

*Template from [agentic-blueprint](https://github.com/parkjadev/agentic-blueprint)*
