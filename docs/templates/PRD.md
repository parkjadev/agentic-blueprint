# Product Requirements Document — [Feature/Product Name]

**Author:** [Name]
**Date:** [YYYY-MM-DD]
**Status:** Draft | In Review | Approved
**Scope:** product | epic | feature
**Parent:** [slug of parent idea or epic; omit if this is a product-scope PRD]

> **Scope-aware sections.** Render the *Vision*, *Success Metrics*, *Non-Goals*, and *Feature Matrix* sections only when `Scope: product`. Render *Child features* only for `product` or `epic`. Render *Acceptance Criteria* for all scopes.

<!-- Budget: words ≤ 4500 · feature-matrix rows ≤ 30 · open questions ≤ 10.
     Long-output agents (spec-author) must chunk via Write + Edit — first Write ≤ 1500 words,
     each subsequent Edit ≤ 1500 words (see agent large-output protocol). -->

---

## Problem Statement

<!-- What problem are we solving? Who has this problem? Why does it matter now?
     Be specific — "users can't do X" is better than "we need to improve Y".
     Include evidence: support tickets, analytics, user interviews, market data. -->

TODO: Describe the problem

## Target Users

<!-- Who are the primary and secondary users? What are their characteristics?
     Include roles, technical proficiency, frequency of use, and context. -->

| User Segment | Description | Priority |
|---|---|---|
| TODO: Primary user | Description | Primary |
| TODO: Secondary user | Description | Secondary |

## User Journeys

<!-- Map out the key flows from the user's perspective. Focus on the happy path first,
     then edge cases. Each journey should have a clear trigger, steps, and outcome. -->

### Journey 1: [Name]

**Trigger:** [What causes the user to start this journey]

1. User does X
2. System responds with Y
3. User completes Z

**Outcome:** [What the user has achieved]

<!-- Example:
### Journey 1: New User Onboarding
**Trigger:** User clicks "Sign Up" from the marketing page
1. User enters email and password
2. System creates account via Supabase Auth, sends verification email
3. User verifies email, lands on post-auth routing
4. System checks role, redirects to dashboard
5. User sees empty state with guided setup prompts
**Outcome:** User has a verified account and understands how to start using the product
-->

## Feature Matrix

<!-- List every feature required to solve the problem. Group by priority.
     P0 = must have for launch. P1 = should have. P2 = nice to have. -->

| Feature | Description | Priority | Journey |
|---|---|---|---|
| TODO: Feature name | What it does | P0 | Journey 1 |

## Non-Functional Requirements

<!-- Performance, security, accessibility, scalability, compliance.
     Be specific with numbers: "page load < 2s on 3G", not "fast". -->

| Requirement | Target | Measurement |
|---|---|---|
| Page load time | < 2s (3G) | Lighthouse performance score |
| Availability | 99.9% uptime | Vercel status monitoring |
| Accessibility | WCAG 2.1 AA | Axe audit score |
| TODO: Add more | | |

## Success Metrics

<!-- How do we know this worked? Define metrics you can measure within 30 days of launch.
     Include both leading indicators (adoption) and lagging indicators (retention). -->

| Metric | Current | Target | Timeframe |
|---|---|---|---|
| TODO: Metric name | Baseline | Goal | 30 days |

## Out of Scope

<!-- Explicitly state what this PRD does NOT cover. Prevents scope creep. -->

- TODO: Thing we're not building

## Open Questions

<!-- Anything unresolved that could change the plan. Track owner and due date. -->

| # | Question | Owner | Due |
|---|---|---|---|
| 1 | TODO: Open question | Name | YYYY-MM-DD |

## Appendix

<!-- Supporting materials: wireframes, competitive analysis, research links, data exports. -->

---

*Template from [agentic-blueprint](https://github.com/parkjadev/agentic-blueprint)*
