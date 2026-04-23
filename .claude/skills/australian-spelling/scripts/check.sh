#!/usr/bin/env bash
# Flag US-English variants against the Australian-English wordlist.
# Usage: check.sh <file-or-dir> [...]
# Exit 0 = clean, 1 = matches, 2 = usage error.
#
# Skips:
#   - inline-backticked code spans
#   - fenced code blocks (``` ... ```)
#   - the scanner's own wordlist.md (self-scan would match its US→AU pairs)
#   - any line with a `spell-ignore` marker — `# spell-ignore`,
#     `// spell-ignore`, or `<!-- spell-ignore -->` — for legitimate cases
#     like third-party CLI flag names — e.g. the gh-label flag itself   # spell-ignore
#   - tokens listed in the wordlist's "Ignore list" section

set -euo pipefail

SKILL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
WORDLIST="$SKILL_DIR/references/wordlist.md"

if [[ $# -lt 1 ]]; then
  echo "usage: check.sh <path> [<path> ...]" >&2
  exit 2
fi

if [[ ! -f "$WORDLIST" ]]; then
  echo "wordlist not found: $WORDLIST" >&2
  exit 2
fi

python3 - "$WORDLIST" "$@" <<'PY'
import os, re, sys, pathlib

wordlist_path = sys.argv[1]
targets = sys.argv[2:]

# Parse wordlist: collect us → au pairs and the ignore list.
pairs = []
with open(wordlist_path, encoding="utf-8") as f:
    for line in f:
        m = re.match(r"^([a-zA-Z]+) → ([a-zA-Z]+)", line)
        if m:
            pairs.append((m.group(1), m.group(2)))

if not pairs:
    print(f"no patterns in {wordlist_path}", file=sys.stderr)
    sys.exit(2)

us_words = sorted({p[0] for p in pairs}, key=len, reverse=True)
us_re = re.compile(r"\b(" + "|".join(map(re.escape, us_words)) + r")\b", re.IGNORECASE)
# Any line carrying `spell-ignore` (in `# …`, `// …`, or `<!-- … -->`) is skipped.
ignore_marker_re = re.compile(r"spell-ignore")

VALID_EXT = {".md", ".mdx", ".txt", ".yml", ".yaml", ".json", ".ts", ".tsx", ".js", ".jsx", ".dart", ".sh"}

# The scanner's own wordlist lists US→AU pairs; scanning it would always match.
# Skip any file whose basename is wordlist.md (catches live + adopter-bundle copies).
def is_self_wordlist(path: str) -> bool:
    return os.path.basename(path).lower() == "wordlist.md"

def gather_files(roots):
    for root in roots:
        if not os.path.exists(root):
            print(f"skip (not found): {root}", file=sys.stderr)
            continue
        if os.path.isfile(root):
            if not is_self_wordlist(root):
                yield root
            continue
        for dirpath, dirnames, filenames in os.walk(root):
            # Skip noise.
            dirnames[:] = [d for d in dirnames if d not in {".git", "node_modules", ".next", "build", "dist", ".dart_tool"}]
            for fn in filenames:
                full = os.path.join(dirpath, fn)
                if is_self_wordlist(full):
                    continue
                if os.path.splitext(fn)[1].lower() in VALID_EXT:
                    yield full

def strip_inline_code(line: str) -> str:
    return re.sub(r"`+[^`\n]*`+", "", line)

hits = []
for path in gather_files(targets):
    try:
        text = pathlib.Path(path).read_text(encoding="utf-8", errors="replace")
    except Exception:
        continue
    in_fence = False
    is_md = path.lower().endswith((".md", ".mdx"))
    for i, line in enumerate(text.splitlines(), start=1):
        if is_md and re.match(r"^\s*```", line):
            in_fence = not in_fence
            continue
        if in_fence:
            continue
        if ignore_marker_re.search(line):
            continue
        candidate = strip_inline_code(line) if is_md else line
        if us_re.search(candidate):
            hits.append((path, i, line))

for path, lineno, line in hits:
    print(f"{path}:{lineno}:{line}")

if hits:
    print()
    print(f"{len(hits)} match(es) found. Replace US-English variants with Australian-English equivalents (see references/wordlist.md).")
    sys.exit(1)

sys.exit(0)
PY
