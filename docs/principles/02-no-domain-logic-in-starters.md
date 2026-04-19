# 2. No domain-specific business logic in starters

> Hard Rule. Enforced by `.claude/skills/hard-rules-check/scripts/check-all.sh`.

## The rule

Starters under `starters/` contain only generic infrastructure patterns.
Anything tied to a specific product, brand, vertical, or customer gets
replaced with a generic example and a `TODO:` marker before merging.

## Why

A starter's job is to let *any* team clone it and have a working
foundation on day one. The moment a starter references `AcmeCorp` or
`insurance-claim.ts`, its usefulness is capped at one company. The
framework is the product; the starters are the proof it works for the
generic case.

## In practice

- Brand names become `TODO: your-company-name`.
- Vertical-specific routes become `/api/examples/` with generic payloads.
- Seed data refers to `Widget` or `Example`, never to real products.
- Copy in UI uses placeholder strings with a `TODO:` comment pointing
  to where downstream teams replace them.

## When it fails

The rule-check script greps for known brand tokens inside `starters/`.
If it fires, the fix is usually a find/replace:

```
grep -rn "ACME\|MyCompany\|ClientName" starters/
```

Replace each hit with a generic term and a `TODO:` breadcrumb.

## Related

- Rule 3 — if you strip domain logic but leave a broken build, you've
  traded one violation for another.
- `claude-config/scripts/bootstrap-smoke-test.sh` — catches the case
  where domain-specific routes were the only thing keeping a starter
  compiling.
