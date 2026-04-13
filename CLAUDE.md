# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What This Repo Is

A GitHub template repository for bootstrapping new projects. Use "Use this template" to create a new repo, then customise the starters and configuration for your project.

The master plan is **Agentic-Blueprint-v2.0.md** — all work must align with it.

## Architecture

```
agentic-blueprint/
├── docs/templates/       # Reusable document templates (PRD, specs, architecture)
├── docs/guides/          # Full lifecycle workflow guides mapped to Claude surfaces
├── starters/nextjs/      # Full-stack Next.js starter (Supabase, Drizzle, Inngest)
├── starters/flutter/     # Mobile companion starter (Riverpod, GoRouter, Supabase)
└── claude-config/        # CLAUDE.md template, settings, memory guidelines, hooks
```

- **docs/templates/**: Spec-driven development templates. Each has section headers, explanatory comments, and examples.
- **docs/guides/**: Workflow guides covering the full lifecycle (ideation → deploy → maintain). Each guide maps to specific Claude surfaces (Desktop Chat, Code CLI, VS Code, Scheduled Tasks, Cowork, Dispatch).
- **starters/**: Boilerplate projects meant to be copied into new repos. The Next.js starter is the primary deliverable; Flutter is the mobile companion.
- **claude-config/**: Configuration files users copy into their own projects. Includes a CLAUDE.md template, permissions baseline, and hook patterns.

## Hard Rules

1. **Australian spelling throughout** — favour, colour, organisation, behaviour, licence (noun), etc. Applies to all prose, comments, and string literals in every file in this repo.
2. **No domain-specific business logic in starters** — starters contain only generic infrastructure patterns. Anything that ties a starter to a specific product, brand, or vertical must be replaced with a generic example and a `TODO:` marker before merging.
3. **All starters must boot clean** — `starters/nextjs/` must pass `pnpm install && pnpm type-check && pnpm lint && pnpm test:ci` with zero errors. `starters/flutter/` must pass `flutter analyze && flutter test` with zero errors. Never merge code that breaks a starter's clean boot.
4. **Optional services** — in starters, use optional Zod schemas in `env.ts` so services gracefully skip when env vars are missing. Only Supabase is required; everything else (Stripe, Inngest, Resend) must be opt-in.
5. **Spec-driven** — every feature starts as a spec document before any code is written.
6. **Plan-before-code** — use Claude Code's plan → approve → execute pattern. No Auto Mode.

## Execution Phases

Built in phases per `Agentic-Blueprint-v2.0.md` § Execution Order:

1. Repo structure + README (done)
2. Claude surfaces guide
3. Document templates
4. Workflow guides (existing + new)
5. Next.js starter (infra → config → schema → app shell → scripts/tests)
6. Claude config templates + hooks
7. Flutter starter
8. Scheduled tasks & Cowork playbooks
9. Final README + validation

Phases 2–5 and 6–10 can run in parallel. Always check which phase is current before starting work.
