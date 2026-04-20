# Research Brief — Simplified Release Model for the Blueprint

**Date:** 2026-04-19
**Researcher:** Claude (researcher subagent)
**Tool:** Claude web search + internal repo analysis
**Confidence:** High

---

## Research Questions

1. What placement option (principle, platform profile, stage guide update, spec template, starter config, or case study) best expresses a "simplified release model" without violating Principles 7, 8, or 9?
2. What does external evidence say about trunk-based development (TBD), ephemeral preview environments, and feature-flag-gated releases — specifically the risks and preconditions that any blueprint guidance must surface?
3. What already exists in the blueprint that covers or partially covers this topic, so we do not duplicate work?
4. What open questions must be resolved before a Stage 2 plan can be written?

---

## Key Findings

### Finding 1 — The blueprint already describes the simplified model, but incompletely

The existing `docs/templates/deployment.md` template contains a "Branch Strategy" section that explicitly describes GitHub Flow: one long-lived branch (`main`), short-lived feature branches, per-PR Vercel preview deployments, and squash-merge to production. The template's environment matrix shows only three rows — local, preview, production — with no `staging` or `develop` tier.

`docs/guides/stage-4-ship.md` similarly describes "merge to `main` equals production deploy" as the default, with versioned releases treated as an optional exception for libraries and app-store submissions.

`docs/guides/_archive/release-workflow.md` explicitly records the historical decision to abandon a two-tier `staging → main` promotion flow, documenting the reason (SHAs drift on every promotion with "Rebase and merge").

**What is missing:** none of this content is labelled as a distinct, opt-in *strategy*. There is no surface that says "this is one of several valid release models" alongside a description of what each model looks like, when to choose it, and what infrastructure it requires. The blueprint currently presents the simplified model as *the* way, which is slightly at odds with Principles 8 and 9 (tool-agnostic, descriptive not prescriptive) and creates no guidance for teams with different needs (compliance-gated, multi-environment enterprise deployments).

### Finding 2 — Trunk-based development is well-evidenced for high-delivery teams, but requires preconditions

The 2018 *Accelerate* research (Forsgren, Humble, Kim) and subsequent DORA surveys consistently show that high-performing engineering teams favour trunk-based development or GitHub Flow over GitFlow. 2024 data shows gaps as large as 182× in deployment frequency and 127× faster change lead times for elite versus low performers. ([Mergify comparison](https://mergify.com/blog/trunk-based-development-vs-gitflow-which-branching-model-actually-works/), [Atlassian TBD guide](https://www.atlassian.com/continuous-delivery/continuous-integration/trunk-based-development))

However, these same sources identify mandatory preconditions:

- Comprehensive automated test coverage (unit, integration, at minimum smoke tests)
- Per-PR preview environments that mirror production closely enough to catch integration issues
- A mechanism to separate *deployment* from *activation* — i.e. feature flags — so that incomplete work ships dark and is turned on selectively ([LaunchDarkly on TBD](https://academy.launchdarkly.com/tech-talk-trunk-based-development), [Vercel feature flags guide](https://dev.classmethod.jp/en/articles/vercel-feature-flags-introduction/))
- A fast rollback path (platform promote is the recommended first lever, confirmed by the existing `stage-4-ship.md`)

Without these, shipping directly to production on every merge is genuinely risky, not just theoretically so.

### Finding 3 — Schema migrations are the sharpest edge of trunk-based delivery

Under continuous deployment, multiple versions of application code may run simultaneously against the same database during a rolling deploy. A destructive migration (column drop, rename, type change) in the same PR as application code that depends on the new schema can cause a race condition: old replicas reading a column that no longer exists. ([Defacto database migrations guide](https://www.getdefacto.com/article/database-schema-migrations), [Harness TBD for databases](https://developer.harness.io/docs/database-devops/gitops/trunk-based-development/))

The mitigation — expand-migrate-contract — is already referenced in `docs/templates/deployment.md` ("Schema-change discipline: destructive changes follow the expand-migrate-contract Hard Rule in `CLAUDE.md`") but is not taught in any stage guide. Any expanded guidance on the simplified release model must surface this pattern prominently.

### Finding 4 — Ephemeral preview environments are well-supported across providers, but not equivalent

Per-PR preview environments are native on Vercel and Railway. On Fly.io they require GitHub Actions integration. Self-hosted CI/CD (Jenkins, GitLab CI) requires custom configuration. ([Uffizzi preview environments guide](https://www.uffizzi.com/preview-environments-guide), [Fly.io review apps guide](https://fly.io/docs/blueprints/review-apps-guide/))

This matters for blueprint placement: if expanded guidance assumes Vercel-native previews, it violates Principle 8. The guidance must describe the *role* (per-PR isolated environment) and list common tools that fill it, not prescribe a specific provider.

### Finding 5 — Feature flag providers range from free/self-hosted to enterprise

Common providers: LaunchDarkly (mature, governance tooling, expensive), PostHog (all-in-one analytics + flags, more affordable, open source option), Unleash (self-hosted open source), GrowthBook (open source, analytics-integrated), Statsig, Flipt. ([PostHog feature flag comparison](https://posthog.com/blog/best-feature-flag-software-for-developers))

For the blueprint's purposes, feature flags should be described as a *role* (runtime activation control) with provider examples — consistent with Principle 8. The blueprint need not prescribe LaunchDarkly or PostHog specifically.

### Finding 6 — Compliance and regulated industries represent a genuine carve-out

Change Advisory Board (CAB) processes exist in banking, healthcare, and government because regulations require pre-production human sign-off on changes affecting production systems. Modern DevOps practitioners have shown that CABs correlate negatively with deployment frequency without improving change failure rate ([Atlassian CAB explainer](https://www.atlassian.com/itsm/change-management/change-advisory-board)), but this does not make them optional where regulations mandate them.

Any blueprint guidance on the simplified release model must be framed as opt-in and must note that it is inappropriate where regulatory or contractual obligations require a separate QA environment or human pre-approval for production changes.

### Finding 7 — Placement analysis: evaluating the six options

**Option 1 — New principle in `docs/principles/`**
Hard no. Principles are prescriptive hard rules enforced by hooks. Adding "use simplified release model" as a principle would contradict Principles 8 and 9. The nine existing hard rules govern process discipline and spelling; they do not mandate a branching strategy.

**Option 2 — New release-strategy platform profile (descriptive)**
Strong fit for part of the work. `docs/guides/tool-reference.md` already contains three platform implementation profiles (Claude-native, Cursor + Perplexity, OutSystems ODC) that describe *how* a toolchain fills the five lifecycle roles. A parallel "release-strategy profile" concept maps well to the same file. Two profiles could be added: (a) Simplified / GitHub Flow, and (b) Multi-environment / GitFlow, each describing required infrastructure roles and when to choose them. This is descriptive (Principle 9) and tool-agnostic (Principle 8).

**Option 3 — Update `docs/guides/stage-4-ship.md` and `stage-5-run.md`**
Appropriate as a complementary action. `stage-4-ship.md` already describes the simplified model as the default. A modest expansion to add a section titled "Choosing a release strategy" — covering TBD/GitHub Flow vs multi-environment approaches, with preconditions for each — would make the existing implicit guidance explicit without changing the fundamental structure of the guide. This is the lowest-friction change and has the highest discovery value because teams read the stage guides.

**Option 4 — New spec template in `docs/templates/`**
High bar, probably premature. A "release-strategy spec" template would capture decisions about branching model, environment matrix, preview infrastructure, feature flag provider, and migration strategy for a specific project. This is genuinely useful but it presupposes that we know the template's sections are stable. Creating a new template is a separate PR (Principle 7 requires template changes in isolated PRs with explicit reviewer approval). It should be Stage 2 output from this research, not done speculatively here.

**Option 5 — Reference starter config in `starters/nextjs/` or `starters/flutter/`**
The Next.js starter already embeds GitHub Flow via `vercel.json`, `ci.yml`, and `deployment.md`. Additional CI configuration for feature-flag-gated deployments or smoke-test gates would belong here, but only in a subsequent build stage and only as opt-in patterns (consistent with Principles 2 and 4 — no domain logic, optional services).

**Option 6 — Documented case study under `docs/research/`**
This brief *is* Stage 1 output and lives under `docs/research/`. A separate case study for Sentinel OS would be appropriate if Sentinel OS is a real, named project whose specifics can be documented. However, the value of a case study is bounded: it illustrates one instance. The prescriptive work (profiles, guide update) is more durable. A case study is a useful supplement, not the primary vehicle.

---

## Market Landscape

| Branching model | Typical adopters | Strengths | Weaknesses |
|---|---|---|---|
| Trunk-based development / GitHub Flow (simplified release) | Startups, SaaS product teams, high-deployment-frequency teams | Minimal merge conflicts, fast lead time, natural CI alignment, simple mental model | Requires strong test automation, feature flags, and preview environments; risky without these |
| GitFlow | Versioned software (libraries, mobile apps), enterprise teams with multiple supported release streams | Clear release artefacts, parallel hotfix + feature work, familiar to large teams | Long-lived branches accumulate drift, complex merge ceremonies, poor fit for continuous deployment |
| Multi-environment promotion (staging/UAT/prod) | Regulated industries, enterprises with CAB requirements, teams sharing a staging environment across QA, PMs, and external stakeholders | Visible pre-production validation, regulatory compliance path, shared QA surface | Long cycle times, staging-production drift, false confidence from an environment that doesn't match production |
| Feature-flag-gated TBD | Mature product teams with analytics infrastructure | Deployment decoupled from activation, instant rollback without git ops, progressive rollout and A/B testing | Operational overhead of flag lifecycle management, risk of stale flags accumulating technical debt |

---

## Implications

- The blueprint's core positioning already aligns with the simplified model. The needed work is clarification and explicit opt-in framing, not a reversal.
- The recommended combination is **Option 3 + Option 2**: update `stage-4-ship.md` with a "Choosing a release strategy" section (modest, high-discovery), and add release-strategy profiles to `docs/guides/tool-reference.md` (descriptive, tool-agnostic, consistent with the existing profile format).
- A new `docs/templates/` entry for a release-strategy spec is worth commissioning as a Stage 2 output from this research, but must live in its own isolated PR per Principle 7. Do not bundle it with the guide updates.
- The Next.js starter config already implements GitHub Flow. No changes are needed there for the simplified model; additions for feature-flag patterns should wait until concrete use-case requirements exist (Principle 2 — no speculative domain logic).
- The Sentinel OS experience is best referenced inline in the guide update as an illustrative example, not as a separate case study document, unless the user specifically wants a formal case study artefact.
- All new content must be tool-agnostic: describe the *role* (per-PR preview environment, runtime activation control, expand-migrate-contract migrations) and list common tools. Never say "you must use Vercel" or "you must use LaunchDarkly."

---

## Open Questions

- **Feature flags on Sentinel OS** — *Resolved (2026-04-20):* assumed yes; provider unspecified. Guide will describe feature flags as the runtime-activation *role* per Principle 8, not prescribe a provider. Flag lifecycle-management responsibility is out of scope for the guide and belongs in a team's own release-strategy decisions.
- **Preview environment provider on Sentinel OS** — *Resolved (2026-04-20):* not used as a named example. Guide describes the per-PR preview *role* generically.
- **Migration strategy on Sentinel OS** — *Deferred:* still genuinely open. If Sentinel OS migration stories exist they should be captured in the Stage 2 spec, but absence does not block the plan — the risks section already cites expand-migrate-contract from public sources.
- **Scope of profile addition** — *Resolved (2026-04-20):* release-strategy profiles will live in `docs/guides/tool-reference.md` as a sibling `## Release strategy profiles` section, following the existing `Profile A/B/C` convention used for platform implementation profiles. A new `docs/guides/profiles/` subdirectory is not created — premature without a second family of profiles needing it.
- **Template commission** — *Resolved (2026-04-20):* defer to a separate PR. Principle 7 requires template changes on a dedicated `docs/*` or `templates/*` branch, and bundling a template with guide+profile updates inflates review surface. Queue a follow-up PR referencing this brief once the guide+profile changes settle.
- **Compliance carve-out depth** — *Resolved (2026-04-20):* a single note in the "Choosing a release strategy" section is sufficient for now. Teams in regulated contexts are pointed to Profile B (Multi-environment / GitFlow); deeper carve-out can follow if real demand surfaces.
- **Flutter starter coverage** — *Deferred:* treat as Not Applicable for this Stage 2 plan. Flutter has no native preview-URL concept; revisit only if a concrete use case appears.

---

## Decisions Going Into Stage 2

Captured here so the spec-writer inherits a clean input:

1. **Placement** — Option 2 + Option 3 combined. Update `docs/guides/stage-4-ship.md` with a "Choosing a release strategy" section, AND add release-strategy profiles to `docs/guides/tool-reference.md`.
2. **Profile count** — two profiles: *Simplified (GitHub Flow)* and *Multi-environment (GitFlow)*. Compliance / CAB contexts steer to the latter.
3. **Profile location** — inside existing `tool-reference.md`, not a new subdirectory.
4. **Feature flags** — described as a role, not a provider. No vendor endorsement.
5. **Template** — `docs/templates/release-strategy.md` is deferred to a separate PR on a `templates/*` or `docs/*` branch.
6. **Starters** — no changes this PR. Next.js starter already implements GitHub Flow; Flutter is N/A.
7. **Sentinel OS** — not cited as a named example in the guide. Referenced only as the source of the motivating experience.

---

*Template from [agentic-blueprint](https://github.com/parkjadev/agentic-blueprint)*
