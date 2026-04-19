# 9. Platform profiles are descriptive, not prescriptive

> Hard Rule. Enforced by a grep pass on `docs/guides/` for endorsement
> language.

## The rule

Platform profiles show *how* a given toolchain maps to the five
lifecycle roles. They do not endorse, recommend, or require any
specific vendor. New profiles can be added for any toolchain that
covers the five roles.

## Why

A profile is an observation: "here is a set of tools, here is how
they compose." It is not a vote. Once profiles start picking
winners, the blueprint becomes a marketing surface for whichever
vendor's profile ships first.

The value of a profile is in the mapping, not the choice. When a
reader sees how Profile A handles "Build" with tool X and Profile B
handles the same role with tool Y, they learn what the role
requires — which survives any vendor change.

## In practice

- Profile files (under `docs/guides/profiles/` when they land) follow
  a fixed template: Research role → Plan role → Build role → Ship
  role → Run role, with a tool named for each.
- Prose inside a profile reads like an observation, not a sales
  pitch. No "the only correct choice", no "recommended vendor".
- A profile can (and should) note trade-offs: where the toolchain
  shines, where it strains, when another profile would be cleaner.
- Adding a profile requires coverage of all five roles. Incomplete
  profiles live as TODOs, not as half-documents.

## When it fails

- The rule-check greps profiles for "recommended vendor" and "the
  only correct choice" (extendable — add patterns as new endorsement
  language appears).
- Fix: reframe endorsements as observations. "Tool X is recommended"
  → "Tool X covers this role via <mechanism>".

## Related

- Rule 8 — the broader tool-agnostic framing principle.
- `docs/guides/README.md` — profile catalogue when it lands.
