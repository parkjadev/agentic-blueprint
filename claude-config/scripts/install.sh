#!/usr/bin/env bash
# Agentic Blueprint — /beat install (v5).
# Copies the blueprint bundle into an existing repo without touching source.
#
# Usage:
#   bash claude-config/scripts/install.sh [--dry-run] [--force]
#
# Behaviour:
#   - Refuses on a dirty working tree unless --force
#   - Fails fast if any source path is missing (pre-flight stat check)
#   - Merges existing CLAUDE.md via <!-- agentic-blueprint:begin/end --> fence
#   - Creates docs/ scaffolding (templates, contracts, specs, research, operations, signal)
#   - Copies the sacred templates + stack-agnostic reference contracts
#   - Installs .github/workflows/hard-rules.yml (GitHub repos only)
#   - Appends .env*, *.pem, *.key patterns to .gitignore
#   - Writes claude-config/VERSION to the adopter repo

set -euo pipefail

DRY_RUN=0
FORCE=0
while [[ $# -gt 0 ]]; do
  case "$1" in
    --dry-run) DRY_RUN=1; shift;;
    --force)   FORCE=1;   shift;;
    *) echo "unknown arg: $1" >&2; exit 2;;
  esac
done

# BUNDLE_DIR  = .../claude-config/ — self-contained adopter bundle
# BLUEPRINT_ROOT = parent of BUNDLE_DIR — where docs/ and .github/ live
BUNDLE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BLUEPRINT_ROOT="$(cd "$BUNDLE_DIR/.." && pwd)"

echo "agentic-blueprint install"
echo "  bundle:    $BUNDLE_DIR"
echo "  blueprint: $BLUEPRINT_ROOT"
echo "  dry-run:   $DRY_RUN · force: $FORCE"
echo

# 0. Pre-flight stat check — every source path must exist before any write.
required_sources=(
  "$BUNDLE_DIR/.claude/commands"
  "$BUNDLE_DIR/.claude/agents"
  "$BUNDLE_DIR/.claude/skills"
  "$BUNDLE_DIR/.claude/hooks"
  "$BUNDLE_DIR/.claude/settings.json"
  "$BUNDLE_DIR/CLAUDE.md.template"
  "$BUNDLE_DIR/VERSION"
  "$BUNDLE_DIR/scheduled-tasks.yaml"
  "$BLUEPRINT_ROOT/docs/templates"
  "$BLUEPRINT_ROOT/docs/contracts"
  "$BLUEPRINT_ROOT/.github/workflows/hard-rules-check.yml"
)
missing=()
for p in "${required_sources[@]}"; do
  [[ -e "$p" ]] || missing+=("$p")
done
if (( ${#missing[@]} > 0 )); then
  echo "ERROR: required source paths missing from the blueprint checkout:" >&2
  for p in "${missing[@]}"; do echo "  - $p" >&2; done
  echo
  echo "If you invoked via bootstrap.sh, the tmp clone may have been partial." >&2
  echo "If you invoked from a local clone, ensure it is not shallow or partial." >&2
  exit 1
fi

# 1. Working tree cleanliness.
if [[ $FORCE -eq 0 ]]; then
  if ! git diff --quiet 2>/dev/null || ! git diff --cached --quiet 2>/dev/null; then
    echo "ERROR: working tree has uncommitted changes. Commit or stash first, or pass --force." >&2
    exit 1
  fi
fi

# 2. Detect clashes in .claude/commands/
clashes=""
for f in "$BUNDLE_DIR/.claude/commands"/*.md; do
  [[ -f "$f" ]] || continue
  base=$(basename "$f")
  if [[ -f ".claude/commands/$base" ]]; then
    clashes="$clashes $base"
  fi
done
if [[ -n "$clashes" ]]; then
  if [[ $FORCE -eq 0 ]]; then
    echo "ERROR: existing .claude/commands/ files clash:$clashes" >&2
    echo "Either rename your command or pass --force to overwrite." >&2
    exit 1
  fi
fi

run() { if [[ $DRY_RUN -eq 1 ]]; then echo "DRY: $*"; else eval "$*"; fi; }

# 3. Copy .claude/ bundle (backup any pre-existing locals).
#
# Portability note: `cp -R src dest` nests when dest exists — it creates
# dest/src/... instead of replacing dest. To avoid this class of bug on
# re-runs (especially with --force), we always remove the target directory
# first. A fresh backup captures any pre-existing content before removal.
if [[ -d .claude ]]; then
  run "rm -rf .claude/_pre-install-backup"
  run "mkdir -p .claude/_pre-install-backup"
  for sub in commands agents skills hooks; do
    if [[ -d ".claude/$sub" ]]; then
      run "cp -R \".claude/$sub\" \".claude/_pre-install-backup/$sub\""
    fi
  done
fi
run "mkdir -p .claude"
for sub in commands agents skills hooks; do
  run "rm -rf \".claude/$sub\""
  run "cp -R \"$BUNDLE_DIR/.claude/$sub\" \".claude/$sub\""
done
if [[ ! -f .claude/settings.json ]]; then
  run "cp \"$BUNDLE_DIR/.claude/settings.json\" .claude/settings.json"
fi

# 4. CLAUDE.md — merge or write fresh (source: CLAUDE.md.template).
BLUEPRINT_PREAMBLE_START='<!-- agentic-blueprint:begin -->'
BLUEPRINT_PREAMBLE_END='<!-- agentic-blueprint:end -->'

if [[ -f CLAUDE.md ]]; then
  if grep -q "$BLUEPRINT_PREAMBLE_START" CLAUDE.md 2>/dev/null; then
    echo "CLAUDE.md already has an agentic-blueprint fence — skipping merge (use /beat update to refresh)"
  else
    run "cp CLAUDE.md CLAUDE.md.pre-install.bak"
    if [[ $DRY_RUN -eq 0 ]]; then
      {
        echo "$BLUEPRINT_PREAMBLE_START"
        cat "$BUNDLE_DIR/CLAUDE.md.template"
        echo "$BLUEPRINT_PREAMBLE_END"
        echo
        cat CLAUDE.md
      } > CLAUDE.md.new
      mv CLAUDE.md.new CLAUDE.md
    else
      echo "DRY: merge CLAUDE.md with fenced block at top (source: $BUNDLE_DIR/CLAUDE.md.template)"
    fi
  fi
else
  run "cp \"$BUNDLE_DIR/CLAUDE.md.template\" CLAUDE.md"
fi

# 5. docs/ scaffolding.
for d in docs/templates docs/contracts docs/specs docs/research docs/operations docs/signal; do
  run "mkdir -p \"$d\""
done

# Copy the sacred templates if docs/templates/ is empty of them.
for t in "$BLUEPRINT_ROOT/docs/templates"/*.md; do
  [[ -f "$t" ]] || continue
  base=$(basename "$t")
  if [[ ! -f "docs/templates/$base" ]]; then
    run "cp \"$t\" \"docs/templates/$base\""
  fi
done

# Copy the stack-agnostic reference contracts (v5+).
for c in "$BLUEPRINT_ROOT/docs/contracts"/*.md; do
  [[ -f "$c" ]] || continue
  base=$(basename "$c")
  if [[ ! -f "docs/contracts/$base" ]]; then
    run "cp \"$c\" \"docs/contracts/$base\""
  fi
done

# Seed empty signal logs.
for log in learnings.md agent-log.md dependencies.md spend.md; do
  run "touch \"docs/signal/$log\""
done

# 6. GitHub Actions hard-rules workflow.
if [[ -d .git ]] && [[ ! -f .github/workflows/hard-rules.yml ]]; then
  run "mkdir -p .github/workflows"
  run "cp \"$BLUEPRINT_ROOT/.github/workflows/hard-rules-check.yml\" .github/workflows/hard-rules.yml"
else
  if [[ ! -d .git ]]; then
    echo "Non-git directory — skipping GitHub Actions install. Port check-all.sh to your CI manually."
  fi
fi

# 7. .gitignore — append .env* / *.pem / *.key if missing.
if [[ ! -f .gitignore ]]; then
  run "touch .gitignore"
fi
for pat in '.env' '.env.*' '!.env.example' '*.pem' '*.key'; do
  if ! grep -qxF "$pat" .gitignore 2>/dev/null; then
    if [[ $DRY_RUN -eq 1 ]]; then
      echo "DRY: append \"$pat\" to .gitignore"
    else
      echo "$pat" >> .gitignore
    fi
  fi
done

# 8. VERSION pin.
run "mkdir -p claude-config"
run "cp \"$BUNDLE_DIR/VERSION\" claude-config/VERSION"
run "cp \"$BUNDLE_DIR/scheduled-tasks.yaml\" claude-config/scheduled-tasks.yaml"

echo
echo "agentic-blueprint install complete."
VER=$(cat "$BUNDLE_DIR/VERSION" 2>/dev/null || echo "?")
echo "Version: $VER"
echo "Next: run /beat status in Claude Code"
