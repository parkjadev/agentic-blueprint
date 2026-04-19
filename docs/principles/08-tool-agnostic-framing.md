# 8. Tool-agnostic framing

> Hard Rule. Enforced by a grep pass on `docs/guides/` for prescriptive
> phrasing.

## The rule

Guides recommend tools; they never require a specific vendor. The
discipline — spec-driven, plan-before-code, clean boots — is the
product. The toolchain is interchangeable.

## Why

Vendor lock-in by documentation is still lock-in. A guide that says
"you must use Vercel" becomes obsolete the moment a team standardises
on a different host — even though the underlying practice (CI → deploy
preview → promote) has nothing to do with Vercel specifically.

Tool-agnostic guides survive vendor churn. They also force us to
articulate the *principle* the tool embodies, which is where the
teaching value lives.

## In practice

- Phrasing: "one common choice is X; alternatives include Y and Z"
  instead of "you must use X".
- When a specific vendor is worth naming, name multiple, and explain
  the trade-off in terms of the role the tool fills (not the brand).
- Platform profiles (`docs/guides/profiles/` when they land) show
  *how* to map a toolchain to the five roles; they don't declare a
  winner.
- Code snippets in guides favour generic examples; vendor-specific
  integration belongs in `starters/` where the `TODO:` markers make
  the commitment explicit.

## When it fails

- The rule-check script greps for "you must use", "required to use",
  "only works with" in `docs/guides/`.
- Fix: reword to "one common choice is …" or move the vendor-specific
  detail to a starter or a footnote.

## Related

- Rule 9 — platform profiles are descriptive, not prescriptive.
- `docs/guides/README.md` — the guides catalogue.
