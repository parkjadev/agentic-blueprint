---
description: Beat — where am I in the three-beat lifecycle? Plus install / update for adopters.
argument-hint: [status|install|update] [--json|--force]
allowed-tools: Bash, Read, Write, Edit, Glob, Grep
---

# /beat — Beat status, install, update (v4)

`/beat` replaces the v3 `/stage` command and adds `install` / `update` sub-verbs for adopt-in-place and version management.

## Sub-verbs

| Sub-verb | Purpose |
|---|---|
| `/beat` (no args) / `/beat status` | Report current beat + next-best command. First-time onboarding reads "follow the arrow" |
| `/beat install` | Adopt-in-place — copy the blueprint into an existing repo without touching source code. For a new project, run this in an empty repo then use `/spec idea <product>` — v5 has no bundled starter scaffold. |
| `/beat update` | Pull newer blueprint version into an adopter repo; respect customisations |

## Steps — `/beat status` (default)

1. Detect branch, open specs, open PRs, recent commits.
2. Classify current beat:
   - On `main` or mainline, clean tree → **Signal** (between features)
   - On feature branch, spec exists, code in flight → **Ship**
   - On feature branch, no spec yet → **Spec**
3. Warn if:
   - Any feature branch is >7 days old
   - More than 1 feature branch is open simultaneously
4. Print a compact report:

```
Beat: <Spec|Ship|Signal> — <short state description>
Branch: <branch>
Blockers: <list or "none">
Next: <one concrete command>
Warnings: <branch hygiene if applicable>
```

5. First-time users (no `docs/specs/`, no research briefs) see:

```
No spec yet. Run:
  /spec idea <your-product>   for a greenfield product
  /spec feature <your-feature> to plan a single feature
```

`--json` flag emits the same payload as JSON for external dashboards.

## Steps — `/beat install`

1. **Detect layout.** Monorepo vs single app; existing `CLAUDE.md`; existing `.claude/`; CI platform (GitHub Actions / GitLab / CircleCI / none).
2. **Dry-run report.** Print every file the install will create, merge, or skip. Abort if the user rejects.
3. **Precondition checks.**
   - Working tree must be clean. Refuse otherwise.
   - Existing `.claude/commands/X.md` that clashes with a blueprint command → abort unless `--force` is passed.
4. **Copy `.claude/` bundle.** Commands, agents, skills, hooks, settings. Preserve anything the adopter already had by backing it up to `.claude/_pre-v4-backup/`.
5. **Merge `CLAUDE.md`.** If none exists, write a fresh blueprint preamble. If one exists, prepend a fenced `<!-- agentic-blueprint:begin -->` … `<!-- agentic-blueprint:end -->` block at the top; preserve all user content below untouched.
6. **Create `docs/` scaffolding.** `docs/templates/`, `docs/specs/`, `docs/research/`, `docs/operations/`, `docs/signal/`. Copy the 9 v4 templates.
7. **Install the CI wrapper.** GitHub → `.github/workflows/hard-rules.yml`. Other platforms → print porting instructions.
8. **Append to `.gitignore`.** Ensure `.env*` (except `.env.example`), `*.pem`, `*.key` are present.
9. **Write `claude-config/VERSION`.** Semver string from the blueprint source.
10. **Print post-install report.** "Installed N commands, M agents, X skills, Y hooks; wrote Z templates; your `CLAUDE.md` was merged; next: `/beat status`."

## Steps — `/beat update`

1. Read local `claude-config/VERSION`; compare to the latest upstream tag.
2. **Dry-run diff.** Show which blueprint-owned files changed; which adopter-edited blueprint files would conflict.
3. **Update blueprint-owned files only.** Anything inside `<!-- agentic-blueprint:begin/end -->` fence in `CLAUDE.md` + all `.claude/` files that weren't locally modified.
4. **Skip-with-warning** any blueprint file the adopter has edited. User resolves by hand.
5. **Leave user extensions alone.** Custom commands/agents/skills/hooks outside the blueprint set are untouched.
6. Update `claude-config/VERSION` on success.
7. Report summary: files updated, files skipped (with reason), next steps.

## What this command does NOT do

- Modify source code in an adopter repo (install never does this)
- Overwrite user-customised primitives (update respects the customisation contract)
- Bypass Hard Rules — install honours local gates once the bundle is in place
