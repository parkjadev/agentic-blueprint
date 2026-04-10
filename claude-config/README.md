# Claude Code Configuration

Reusable Claude Code configuration templates and GitHub project bootstrap files.

## Contents

- `CLAUDE.md.template` — Customisable project guide (Hard Rules, env matrix, labels)
- `settings.local.json.template` — Permissions baseline
- `memory-guidelines.md` — How to use Claude memory effectively
- `hooks/` — Claude Code hook patterns
  - `pre-commit.md` — Pre-commit automation patterns
  - `post-merge.md` — Post-merge automation (plan status markers, doc sweep prompt)
  - `post-deploy.md` — Post-deploy verification patterns
- `github/` — GitHub project metadata (copy into a new repo's `.github/`)
  - `ISSUE_TEMPLATE/feature.yml` — Feature request template
  - `ISSUE_TEMPLATE/bug.yml` — Bug report template
  - `ISSUE_TEMPLATE/chore.yml` — Maintenance / refactor template
  - `ISSUE_TEMPLATE/docs.yml` — Documentation template
  - `ISSUE_TEMPLATE/config.yml` — Issue picker configuration (disables blank issues)
  - `pull_request_template.md` — Default PR template (linked issue, test plan, rollback)
  - `workflows/auto-label.yml` — GitHub Action that auto-applies the `scope:*` label from the issue form dropdown on every issue open/edit
- `scripts/` — Bootstrap and operational scripts for a GitHub repo
  - `setup-branch-protection.sh` — Locks down `main` (squash-only, required CI, enforce_admins=true)
  - `unblock-protection.sh` — Sanctioned escape hatch — temporarily disables enforce_admins with auto-restore
  - `setup-labels.sh` — Creates the `type:*` / `scope:*` / status label taxonomy
  - `gh-backfill-issues.sh` — Retroactively create closed issues from a manifest (for repos that adopted issue-first discipline late)
  - `update-plan-status.sh` — Update inline status markers in plan files when a phase ships (invoked from `hooks/post-merge.md`)

## Bootstrapping a fresh repo

After "Use this template" on GitHub:

```bash
# 0. File the bootstrap issue BEFORE any branch — Hard Rule #2 ("issue
#    before branch") applies from the very first scaffold commit. The
#    --label flag will fail until step 2 below; either drop it for now
#    or run setup-labels.sh first.
gh issue create \
  --title "chore: initial scaffold" \
  --label "type:chore" \
  --body "Bootstrapping a new project from agentic-blueprint."

# 1. Copy config into the new repo
cp claude-config/CLAUDE.md.template CLAUDE.md
cp -R claude-config/github/. .github/

# 2. Create labels and lock down main
./claude-config/scripts/setup-labels.sh
./claude-config/scripts/setup-branch-protection.sh

# 3. Customise CLAUDE.md (env URLs, region, project-specific rules)
```

The bootstrap issue gives every subsequent commit something to reference and demonstrates the issue-first workflow from line 1. Without it, the first ten commits of any new project ship without an issue and the team learns the wrong lesson.

## Back-filling issues on an existing project

If you're adopting agentic-blueprint on a repo that already has commit history and you want to back-fill issues to satisfy Hard Rule #2 ("issue before branch"), use `gh-backfill-issues.sh` with a manifest:

```bash
# manifest.txt — one issue per line
#   <type>|<scope>|<title>|<commit-sha>|<body-file or ->
cat > manifest.txt <<'EOF'
feature|workflow|feat: add label taxonomy bootstrap script|abc1234|-
chore|workflow|chore: scrub hardcoded brand references|def5678|-
docs|workflow|docs: rewrite deployment template|9012abc|-
EOF

# Dry-run first to preview
DRY_RUN=1 ./claude-config/scripts/gh-backfill-issues.sh manifest.txt

# Run for real
./claude-config/scripts/gh-backfill-issues.sh manifest.txt
```

Idempotent — re-running with the same manifest skips issues whose titles already exist.
