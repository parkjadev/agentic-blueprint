# Contracts — stack-agnostic reference library

This directory defines the small set of interface contracts that projects using the agentic-blueprint share regardless of language, runtime, or framework. Each contract is a Markdown file with prose + JSON Schema (draft 2020-12 where applicable) + two short examples.

## What this directory is for

- **Canonical shape** for cross-cutting interfaces: API responses, error codes, auth tokens, telemetry events.
- **Load-bearing IP** from the retired v4 starters (Next.js + Flutter). Previously inline in starter code; now first-class reference artefacts.
- **Not a library.** Nothing in here is executable. Projects that consume these contracts translate them into whatever their stack supports (Zod, Pydantic, protobuf, etc.).

## Index

| Contract | File | Summary |
|---|---|---|
| API response envelope | [`api-response.md`](./api-response.md) | `{ success, data }` / `{ success, error }` — the shape every API endpoint returns |
| Error taxonomy | [`error-taxonomy.md`](./error-taxonomy.md) | Canonical error codes + when to use each |
| Auth token | [`auth-token.md`](./auth-token.md) | Access + refresh token shape, minimum claims, rotation |
| Telemetry | [`telemetry.md`](./telemetry.md) | Structured log + event-telemetry envelope |

## How to consume a contract

1. **Read the contract file end-to-end** before implementing. The "Behaviour" section often carries rules that aren't obvious from the shape alone.
2. **Copy the shape into your stack's idiom.** TypeScript project → Zod schema or discriminated union. Python → Pydantic model. Dart/Flutter → freezed class. Don't re-derive; translate.
3. **Reference the contract by filename + anchor** in your project's API spec or architecture doc. Example: `Per contracts/api-response.md § Shape, all responses return ApiResponse<T>.`
4. **Flag contract-level change needs via a PR on the blueprint**, not by diverging in your project. The contract is the single source of truth.

## Editing contracts

`docs/contracts/` is Rule-4 protected, same as `docs/templates/`. Edits require either:

- A branch named `contracts/*`, `docs/*`, or `templates/*`, OR
- A commit subject prefixed with `[release]`, OR
- The environment variable `AGENTIC_BLUEPRINT_RELEASE=1` set for the commit.

Rationale: contracts drift silently if anyone can edit them in a feature PR. The gate forces a deliberate release cadence and pulls reviewer attention to contract changes.

To retire a contract, move it to `_archive/` (always allowed) with a note explaining why and what replaces it.

## Format

Every contract file follows this structure:

```
# Contract — <Name>

**Status:** Stable | Draft
**Last revised:** YYYY-MM-DD

## Purpose
<what the contract defines and why it exists>

## Shape
<prose description + JSON Schema or pseudo-type signature>

## Behaviour
<rules that can't be expressed in the shape: ordering, error handling, retry semantics, etc.>

## Examples
<two short examples: the canonical success case and one non-trivial variant>

## References
<links to related contracts, principles, and external standards>
```

Deviation from the format requires a `[release]` commit and should be justified in the commit body.
