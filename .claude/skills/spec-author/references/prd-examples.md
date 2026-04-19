# PRD — worked examples

Short excerpts showing how to fill `docs/templates/PRD.md` sections without re-deriving structure.

## Problem statement — good

> Users on the free tier can't see how close they are to their quota until they hit it. 38% of support tickets tagged `billing` in the last 90 days cite surprise at a limit they didn't know existed. Source: Zendesk export (2026-02-01 → 2026-04-30).

**Why it's good:** names the user, the surface, the specific friction, and backs the claim with measurable evidence.

## Problem statement — bad

> Billing UX is confusing.

**Why it's bad:** no user named, no surface named, no evidence.

---

## Success metric — good

> Primary: reduce `billing-surprise` tickets by 60% within 60 days of launch (baseline 38%, target 15%).
> Secondary: no regression in upgrade conversion (current 4.2%).

**Why it's good:** one primary, one guardrail; both measurable with existing instrumentation.

## Success metric — bad

> Users will be happier.

**Why it's bad:** not measurable, not bounded in time.

---

## Scope — good

**In scope**
- Free-tier dashboard shows current usage and remaining quota
- Warning email at 80% usage
- Docs update for the new quota indicator

**Out of scope (deferred)**
- Paid-tier dashboard updates — tracked in #<issue>
- Quota breach grace period — needs separate PRD

**Why it's good:** explicit in/out, deferred items linked to issues so they don't get lost.
