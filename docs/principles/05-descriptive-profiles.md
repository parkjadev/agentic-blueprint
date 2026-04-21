# 5. Descriptive profiles, not prescriptive

> Hard Rule. Enforced by a grep pass on `docs/guides/` for prescriptive / endorsement phrasing.

## The rule

Guides and platform profiles recommend tools; they never require a specific vendor. The discipline — spec-driven, gates-enforced, beat-aware — is the product. The toolchain is interchangeable.

v4 collapses the old Rules 8 (tool-agnostic framing) and 9 (platform profiles descriptive) into one principle because both say the same thing at different scopes. One rule, cleaner enforcement.

v4 ships two profiles — Claude-native and OutSystems ODC — with identical Spec and Signal artefacts; only Ship mechanics diverge. Additional profiles can be added at any time if they cover all three beats without picking a winner.

## Why

Vendor lock-in by documentation is still lock-in. A guide that says "you must use Vercel" becomes obsolete the moment a team standardises on a different host — even though the underlying practice (preview deploy → smoke test → promote) has nothing to do with Vercel specifically.

Tool-agnostic guides survive vendor churn. They also force us to articulate the *principle* the tool embodies, which is where the teaching value lives.

## In practice

- Phrasing: "one common choice is X; alternatives include Y and Z" instead of "you must use X".
- When a specific vendor is worth naming, name multiple and explain the trade-off in terms of the role the tool fills.
- Platform profiles read as observations: "Profile A uses tool X for Ship via <mechanism>". No "the only correct choice", no "recommended vendor".
- A profile notes trade-offs: where the toolchain shines, where it strains, when another profile would be cleaner.
- Adding a profile requires coverage of all three beats (Spec, Ship, Signal). Incomplete profiles live as TODOs, not as half-documents.

## When it fails

- The gate greps `docs/guides/` for "you must use", "required to use", "only works with", "recommended vendor", "the only correct choice".
- Fix: reword to "one common choice is …" or move the vendor-specific detail to a starter or footnote.

## Related

- `docs/guides/tool-reference.md` — the two-profile × three-beat matrix.
- `docs/guides/README.md` — guides catalogue.
