# claude-config/ — copy-ready bundle

Everything in this directory is meant to be copied into a downstream
repository. Start here when scaffolding a new project from the
agentic-blueprint.

## Contents

| Path | Purpose |
|---|---|
| `.claude/` | Full Claude Code harness — commands, subagents, skills, hooks, settings. Mirrors the blueprint's root `.claude/`. |
| `CLAUDE.md.template` | Tight primitive map (≤ 100 lines). Fill in the TODO blocks. |
| `settings.local.json.template` | Per-developer permission overrides. Commits should not include `.local` files. |
| `memory-guidelines.md` | How to use Claude memory effectively in a downstream repo. |
| `hooks/` | Hook *documentation* (how to write your own). The runnable hooks live in `.claude/hooks/`. |
| `github/` | GitHub project metadata — issue templates, PR template, workflows. Copy into your repo's `.github/`. |
| `scripts/` | Bootstrap and operational scripts. |

## Bootstrapping a fresh repo

After "Use this template" on GitHub:

```bash
# 1. Copy the harness and the templates
cp -r claude-config/.claude .
cp claude-config/CLAUDE.md.template CLAUDE.md
cp -R claude-config/github/. .github/

# 2. Create labels and lock down main
./claude-config/scripts/setup-labels.sh
./claude-config/scripts/setup-branch-protection.sh

# 3. File the bootstrap issue (Hard Rule 5 applies from commit 1)
gh issue create \
  --title "chore: initial scaffold" \
  --label "type:chore" \
  --body "Bootstrapping a new project from agentic-blueprint."

# 4. Fill in CLAUDE.md's TODO blocks (stack, environments,
#    project-specific Hard Rules)

# 5. Verify the Hard Rules gate runs
bash .claude/skills/hard-rules-check/scripts/check-all.sh
```

## Back-filling issues on an existing project

If you're adopting agentic-blueprint on a repo that already has commit
history, use `gh-backfill-issues.sh` with a manifest:

```bash
# manifest.txt — one issue per line
#   <type>|<scope>|<title>|<commit-sha>|<body-file or ->
cat > manifest.txt <<'EOF'
feature|workflow|feat: add label taxonomy bootstrap script|abc1234|-
chore|workflow|chore: scrub hardcoded brand references|def5678|-
docs|workflow|docs: rewrite deployment template|9012abc|-
EOF

DRY_RUN=1 ./claude-config/scripts/gh-backfill-issues.sh manifest.txt  # preview
./claude-config/scripts/gh-backfill-issues.sh manifest.txt            # apply
```

Idempotent — re-running skips issues whose titles already exist.

## Keeping the harness in sync

The harness under `claude-config/.claude/` mirrors the blueprint's own
`.claude/`. When either changes, the other should change in the same
PR. The `docs-inspector` subagent flags drift during `/run health-check`.
