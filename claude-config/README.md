# Claude Code Configuration

Reusable Claude Code configuration templates and GitHub project bootstrap files.

## Contents

- `CLAUDE.md.template` — Customisable project guide (Hard Rules, env matrix, labels)
- `settings.local.json.template` — Permissions baseline
- `memory-guidelines.md` — How to use Claude memory effectively
- `hooks/` — Claude Code hook patterns
  - `pre-commit.md` — Pre-commit automation patterns
  - `post-deploy.md` — Post-deploy verification patterns
- `github/` — GitHub project metadata (copy into a new repo's `.github/`)
  - `ISSUE_TEMPLATE/feature.yml` — Feature request template
  - `ISSUE_TEMPLATE/bug.yml` — Bug report template
  - `ISSUE_TEMPLATE/chore.yml` — Maintenance / refactor template
  - `ISSUE_TEMPLATE/docs.yml` — Documentation template
  - `ISSUE_TEMPLATE/config.yml` — Issue picker configuration (disables blank issues)
  - `pull_request_template.md` — Default PR template (linked issue, test plan, rollback)
- `scripts/` — One-shot bootstrap scripts for a fresh GitHub repo
  - `setup-branch-protection.sh` — Locks down `main` (squash-only, required CI, enforce_admins=true)
  - `setup-labels.sh` — Creates the `type:*` / `scope:*` / status label taxonomy

## Bootstrapping a fresh repo

After "Use this template" on GitHub:

```bash
# 1. Copy config into the new repo
cp claude-config/CLAUDE.md.template CLAUDE.md
cp -R claude-config/github/. .github/

# 2. Create labels and lock down main
./claude-config/scripts/setup-labels.sh
./claude-config/scripts/setup-branch-protection.sh

# 3. Customise CLAUDE.md (env URLs, region, project-specific rules)
```
