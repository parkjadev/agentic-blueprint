# Hard Rules — long form

Detailed explanation of each rule, the spirit behind it, and how to fix a violation. Loaded on demand by the `hard-rules-check` skill when a specific rule fails.

## Rule 1 — Australian spelling throughout

**Spirit:** consistent voice across docs, specs, comments, and error messages. Avoids the accidental mix of US and British English that looks unprofessional and creates search friction.

**Fix:** run the `australian-spelling` skill's script against the offending file, then apply the suggested swaps. Keep brand names and code identifiers as-is.

## Rule 2 — No domain-specific business logic in starters

**Spirit:** starters are reference implementations for *any* product. Anything that ties them to a specific brand, vertical, or customer defeats the purpose.

**Fix:** replace brand-specific strings, logos, or business logic with generic placeholders and a `TODO:` marker. Examples: `"Acme Corp"` → `"TODO: your-company"`; `billing/insurance-claim.ts` → deleted or genericised.

## Rule 3 — All starters must boot clean

**Spirit:** the clean-boot guarantee is what makes a starter trustable. A starter that doesn't pass its own check suite is actively misleading.

**Fix:**
- Next.js: `cd starters/nextjs && pnpm install && pnpm type-check && pnpm lint && pnpm test:ci`
- Flutter: `cd starters/flutter && flutter analyze && flutter test`

Address any failure at the root — don't silence warnings with `@ts-ignore` or `// ignore:` comments.

## Rule 4 — Optional services

**Spirit:** not every project needs Stripe, Inngest, or Resend. Forcing every user to provide every env var before the app boots is hostile. Only Supabase (auth + DB) is required.

**Fix:** in `starters/nextjs/src/env.ts`, wrap non-essential vars in `.optional()` via Zod, and gate the corresponding service initialisation on the presence of the var.

## Rule 5 — Spec-driven

**Spirit:** "just start coding" is how you ship the wrong thing fast. The spec is the shared contract between human and agent.

**Fix:** stop coding, run `/plan <slug>`, produce the spec. Resume `/build` once the spec exists.

**Exemptions** (script-level): `main`, `release/*`, `chore/*`. The `chore/*` exemption is trust-based — use it for memory-sync, dep bumps, and small fixes. Do not hide feature work behind a `chore/` prefix.

## Rule 6 — Plan-before-code

**Spirit:** Auto Mode produces speed, not quality. Every non-trivial change gets a plan file so the reviewer (human or agent) can assess intent before diff.

**Fix:** create `docs/plans/<slug>.md`. Reference the specs. Describe the implementation sequence. Then resume.

**Exemptions** (script-level): `main`, `release/*`, `chore/*`. Same trust caveat as Rule 5.

## Rule 7 — Templates are sacred

**Spirit:** `docs/templates/` is the IP. If a template section loses a header, every downstream spec silently loses that section too. Edit for clarity; never remove structure.

**Fix:** revert the template change. If a template genuinely needs a new section, raise it as its own PR with a `docs:` label — not bundled into a feature PR.

## Rule 8 — Tool-agnostic framing in guides

**Spirit:** guides recommend; they don't require. Vendor lock-in by documentation is still lock-in.

**Fix:** reword "you must use X" → "one common choice is X; alternatives include Y and Z". Keep the advice, drop the mandate.

## Rule 9 — Platform profiles descriptive

**Spirit:** profiles show *how* a toolchain maps to the five roles. They don't endorse vendors or declare winners.

**Fix:** remove language that frames a profile as "the right way" or a vendor as "recommended". Profiles read like observations, not prescriptions.
