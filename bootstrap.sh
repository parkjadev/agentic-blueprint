#!/usr/bin/env bash
# bootstrap.sh — install the agentic-blueprint into the current directory.
#
# This is the non-circular entry point for first-time adopters. /beat install
# (the slash command) assumes the blueprint is already in your repo; this
# script puts it there.
#
# Safe to run via:
#   bash bootstrap.sh                                    # from a blueprint clone
#   bash <(curl -fsSL <URL>/bootstrap.sh)                # from anywhere
#   curl -fsSL <URL>/bootstrap.sh | bash                 # pipe form
#
# Behaviour:
#   - Detects whether the script is running from a local blueprint checkout
#   - If not, clones the blueprint (--depth 1) to a tmp dir that's cleaned on exit
#   - Delegates to claude-config/scripts/install.sh with the caller's CWD as target
#   - Same preconditions as install.sh (clean working tree; --force bypass)
#
# After bootstrap, /beat install and /beat update (the slash commands) work from
# inside Claude Code as documented.

set -euo pipefail

BLUEPRINT_URL="${AGENTIC_BLUEPRINT_URL:-https://github.com/parkjadev/agentic-blueprint.git}"
BLUEPRINT_REF="${AGENTIC_BLUEPRINT_REF:-main}"

INSTALL_ARGS=()
while [[ $# -gt 0 ]]; do
  case "$1" in
    --dry-run|--force)
      INSTALL_ARGS+=("$1")
      shift
      ;;
    --url)
      BLUEPRINT_URL="$2"
      shift 2
      ;;
    --ref)
      BLUEPRINT_REF="$2"
      shift 2
      ;;
    -h|--help)
      cat <<EOF
bootstrap.sh — install the agentic-blueprint into the current directory.

Usage:
  bash bootstrap.sh [--dry-run] [--force]
  bash <(curl -fsSL <URL>/bootstrap.sh) [--dry-run] [--force]

Options:
  --dry-run     Preview the install — print every file that would be created,
                merged, or skipped. No writes.
  --force       Bypass the dirty-working-tree refusal and command-file clash
                refusal. Use with care.
  --url <url>   Override the blueprint git URL
                (default: ${BLUEPRINT_URL}).
  --ref <ref>   Override the ref / branch / tag to clone
                (default: ${BLUEPRINT_REF}).

Environment variables:
  AGENTIC_BLUEPRINT_URL, AGENTIC_BLUEPRINT_REF — same as --url / --ref.

After running this script once in an adopter repo, the Claude Code slash
commands /beat install, /beat update, /beat status all work normally.
EOF
      exit 0
      ;;
    *)
      echo "bootstrap: unknown arg: $1" >&2
      echo "Run 'bash bootstrap.sh --help' for usage." >&2
      exit 2
      ;;
  esac
done

# Detect whether we're already inside a blueprint checkout. The heuristic:
# if claude-config/scripts/install.sh exists next to this script, use it;
# otherwise clone.
src_dir=""
if [[ "${BASH_SOURCE[0]:-}" != "" ]]; then
  candidate="$(cd "$(dirname "${BASH_SOURCE[0]}")" 2>/dev/null && pwd || true)"
  if [[ -n "$candidate" && -f "$candidate/claude-config/scripts/install.sh" ]]; then
    src_dir="$candidate"
  fi
fi

if [[ -n "$src_dir" ]]; then
  echo "agentic-blueprint bootstrap: using local checkout at $src_dir"
else
  # Remote path — clone to a tmp dir and clean up on exit.
  command -v git >/dev/null 2>&1 || {
    echo "bootstrap: git is required but not installed" >&2
    exit 1
  }
  tmp_dir="$(mktemp -d -t agentic-blueprint-XXXXXX)"
  trap 'rm -rf "$tmp_dir"' EXIT
  echo "agentic-blueprint bootstrap: cloning $BLUEPRINT_URL ($BLUEPRINT_REF) → $tmp_dir"
  git clone --quiet --depth 1 --branch "$BLUEPRINT_REF" "$BLUEPRINT_URL" "$tmp_dir"
  src_dir="$tmp_dir"
fi

if [[ ! -x "$src_dir/claude-config/scripts/install.sh" && ! -f "$src_dir/claude-config/scripts/install.sh" ]]; then
  echo "bootstrap: installer not found at $src_dir/claude-config/scripts/install.sh" >&2
  exit 1
fi

# Delegate. install.sh uses its own SRC_DIR derivation, so running it from
# its real on-disk path is all we need. install.sh operates on CWD as the
# target adopter directory — same contract as /beat install.
bash "$src_dir/claude-config/scripts/install.sh" ${INSTALL_ARGS[@]+"${INSTALL_ARGS[@]}"}
