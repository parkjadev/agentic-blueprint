#!/usr/bin/env bash
# signal-sync: append a keepachangelog entry under ## [Unreleased] in CHANGELOG.md.
# Usage: append-changelog.sh --category <name> --message "..." --pr <n>

set -euo pipefail

category=""
message=""
pr=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --category) category="$2"; shift 2;;
    --message)  message="$2";  shift 2;;
    --pr)       pr="$2";       shift 2;;
    *) echo "unknown arg: $1" >&2; exit 2;;
  esac
done

if [[ -z "$category" || -z "$message" || -z "$pr" ]]; then
  echo "Usage: $0 --category <Added|Changed|Deprecated|Removed|Fixed|Security> --message \"...\" --pr <n>" >&2
  exit 2
fi

case "$category" in
  Added|Changed|Deprecated|Removed|Fixed|Security) ;;
  *) echo "invalid category: $category" >&2; exit 2;;
esac

REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
CHANGELOG="$REPO_ROOT/CHANGELOG.md"
if [[ ! -f "$CHANGELOG" ]]; then
  echo "CHANGELOG.md not found at repo root" >&2
  exit 2
fi

# Trim trailing period — we'll add it plus the PR link consistently.
message="${message%.}"
entry="- ${message}. (#${pr})"

python3 - "$CHANGELOG" "$category" "$entry" <<'PY'
import sys, pathlib, re

path, category, entry = sys.argv[1], sys.argv[2], sys.argv[3]
text = pathlib.Path(path).read_text()

unreleased = re.search(r"## \[Unreleased\]\s*\n", text)
if not unreleased:
    insert = "## [Unreleased]\n\n### " + category + "\n\n" + entry + "\n\n"
    text = re.sub(r"(# Changelog[^\n]*\n+)", r"\1" + insert, text, count=1)
    pathlib.Path(path).write_text(text)
    print("inserted new [Unreleased] block")
    sys.exit(0)

start = unreleased.end()
next_block = re.search(r"^## \[", text[start:], re.MULTILINE)
end = start + next_block.start() if next_block else len(text)
block = text[start:end]

sub_re = re.compile(r"^### " + re.escape(category) + r"\s*\n", re.MULTILINE)
m = sub_re.search(block)
if m:
    cat_start = m.end()
    next_cat = re.search(r"^### ", block[cat_start:], re.MULTILINE)
    cat_end = cat_start + next_cat.start() if next_cat else len(block)
    lines = block[cat_start:cat_end].rstrip("\n")
    new_block = block[:cat_start] + lines + "\n" + entry + "\n\n" + block[cat_end:]
else:
    new_block = block.rstrip("\n") + "\n\n### " + category + "\n\n" + entry + "\n\n"

text = text[:start] + new_block + text[end:]
pathlib.Path(path).write_text(text)
print("appended:", entry)
PY
