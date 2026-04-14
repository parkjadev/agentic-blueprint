# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What This Repo Is

A framework for building products with AI collaborators, covering the full lifecycle from research through operations. Includes document templates, workflow guides, and optional code starters.

The master plan is the five-stage lifecycle: **Research & Think → Plan → Build → Ship → Run**.

## Architecture

```
agentic-blueprint/
├── docs/templates/       # 10 spec-driven development templates (the IP)
├── docs/guides/          # 5 stage guides + 1 tool reference
├── docs/research/        # Research briefs
├── starters/nextjs/      # Optional: Full-stack Next.js starter (Supabase, Drizzle, Inngest)
├── starters/flutter/     # Optional: Mobile companion starter (Riverpod, GoRouter, Supabase)
└── claude-config/        # CLAUDE.md template, settings, memory guidelines, hooks
```

- **docs/templates/**: Spec-driven development templates. Each has section headers, explanatory comments, and examples. These are the core IP.
- **docs/guides/**: Five stage guides covering the full lifecycle, plus a tool reference appendix mapping roles to recommended tools.
- **docs/research/**: Research briefs produced during Stage 1.
- **starters/**: Optional reference implementations. The Next.js starter is the primary deliverable; Flutter is the mobile companion.
- **claude-config/**: Configuration files users copy into their own projects. Includes a CLAUDE.md template, permissions baseline, and hook patterns.

## Hard Rules

1. **Australian spelling throughout** — favour, colour, organisation, behaviour, licence (noun), etc. Applies to all prose, comments, and string literals in every file in this repo.
2. **No domain-specific business logic in starters** — starters contain only generic infrastructure patterns. Anything that ties a starter to a specific product, brand, or vertical must be replaced with a generic example and a `TODO:` marker before merging.
3. **All starters must boot clean** — `starters/nextjs/` must pass `pnpm install && pnpm type-check && pnpm lint && pnpm test:ci` with zero errors. `starters/flutter/` must pass `flutter analyze && flutter test` with zero errors. Never merge code that breaks a starter's clean boot.
4. **Optional services** — in starters, use optional Zod schemas in `env.ts` so services gracefully skip when env vars are missing. Only Supabase is required; everything else (Stripe, Inngest, Resend) must be opt-in.
5. **Spec-driven** — every feature starts as a spec document before any code is written.
6. **Plan-before-code** — review the plan before any code generation. No Auto Mode.
7. **Templates are sacred** — the templates in `docs/templates/` are the core IP. Edit for clarity, never remove sections.
8. **Tool-agnostic framing** — guides recommend tools but never require a specific vendor. The discipline is the product, not the toolchain.
9. **Platform profiles are descriptive, not prescriptive** — profiles show how tools map to roles. They do not endorse or require any specific vendor. New profiles can be added for any toolchain that covers the five roles.
