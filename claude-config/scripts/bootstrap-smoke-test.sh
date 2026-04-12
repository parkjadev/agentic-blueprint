#!/usr/bin/env bash
#
# bootstrap-smoke-test.sh
#
# The dogfooding harness for agentic-blueprint itself.
#
# Hard Rule #3 says "all starters must boot clean". But there's no test that
# the *bootstrap flow* — the steps a user follows after clicking "Use this
# template" — actually produces a working project. Each starter passes its own
# checks in isolation, but the end-to-end "fresh tmpdir → copy template →
# install → check:all" loop was untested until this script.
#
# What it does:
#   1. Creates a fresh tmpdir
#   2. Copies starters/nextjs/* to tmpdir root (the README quickstart pattern)
#   3. Copies starters/flutter/ to tmpdir/mobile/ (same pattern)
#   4. Copies claude-config/CLAUDE.md.template to tmpdir/CLAUDE.md
#   5. Copies claude-config/github/ to tmpdir/.github/
#   6. Runs `pnpm install --frozen-lockfile && pnpm check:all` in tmpdir
#   7. Runs `flutter analyze && flutter test` in tmpdir/mobile/ (skipped if
#      `flutter` CLI is not installed)
#   8. Reports pass/fail with a summary
#
# Usage:
#   ./claude-config/scripts/bootstrap-smoke-test.sh
#
# The script expects to be run from the agentic-blueprint repo root.
# Exit code: 0 if all checks pass, 1 if any check fails, 2 if setup fails.
#
# Requirements:
#   - pnpm
#   - node (for the Next.js starter)
#   - flutter (optional — skipped with a warning if not installed)

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
TMPDIR_BASE="$(mktemp -d)"
TMPDIR="${TMPDIR_BASE}/bootstrap-test"

cleanup() {
  echo
  echo "Cleaning up ${TMPDIR_BASE}..."
  rm -rf "${TMPDIR_BASE}"
}
trap cleanup EXIT

echo "=== Bootstrap Smoke Test ==="
echo "Repo root: ${REPO_ROOT}"
echo "Tmpdir:    ${TMPDIR}"
echo

# ── Step 1: scaffold the tmpdir ───────────────────────────────────────────────

mkdir -p "${TMPDIR}"

echo "→ Copying Next.js starter to tmpdir root..."
cp -R "${REPO_ROOT}/starters/nextjs/." "${TMPDIR}/"

echo "→ Copying Flutter starter to tmpdir/mobile/..."
cp -R "${REPO_ROOT}/starters/flutter" "${TMPDIR}/mobile"

echo "→ Copying CLAUDE.md.template..."
cp "${REPO_ROOT}/claude-config/CLAUDE.md.template" "${TMPDIR}/CLAUDE.md"

echo "→ Copying GitHub config..."
mkdir -p "${TMPDIR}/.github"
cp -R "${REPO_ROOT}/claude-config/github/." "${TMPDIR}/.github/"

echo

# ── Step 2: Next.js checks ───────────────────────────────────────────────────

echo "=== Next.js Starter ==="

if ! command -v pnpm >/dev/null 2>&1; then
  echo "ERROR: pnpm not found. Cannot run Next.js checks." >&2
  exit 2
fi

cd "${TMPDIR}"

# No --frozen-lockfile: the starter is a template and doesn't ship a
# pnpm-lock.yaml. The lockfile gets generated on first install — that's
# what we're simulating here. After the user commits the generated lockfile,
# their own CI should use --frozen-lockfile for reproducibility.
echo "→ pnpm install"
if ! pnpm install 2>&1; then
  echo "FAIL: pnpm install failed." >&2
  exit 1
fi

echo "→ pnpm type-check"
if ! pnpm type-check 2>&1; then
  echo "FAIL: pnpm type-check failed." >&2
  exit 1
fi

echo "→ pnpm lint"
if ! pnpm lint 2>&1; then
  echo "FAIL: pnpm lint failed." >&2
  exit 1
fi

# test:ci needs env vars (even dummy ones). Use SKIP_ENV_VALIDATION if
# @t3-oss/env-nextjs is in use; otherwise set dummy values.
echo "→ pnpm test:ci (with SKIP_ENV_VALIDATION=true)"
if ! SKIP_ENV_VALIDATION=true pnpm test:ci 2>&1; then
  echo "FAIL: pnpm test:ci failed." >&2
  exit 1
fi

echo
echo "Next.js: ALL CHECKS PASSED"
echo

# ── Step 3: Flutter checks (optional) ────────────────────────────────────────

echo "=== Flutter Starter ==="

if ! command -v flutter >/dev/null 2>&1; then
  echo "WARNING: flutter CLI not found. Skipping Flutter checks."
  echo "         Install Flutter to test the mobile starter."
  echo
else
  cd "${TMPDIR}/mobile"

  echo "→ flutter pub get"
  if ! flutter pub get 2>&1; then
    echo "FAIL: flutter pub get failed." >&2
    exit 1
  fi

  echo "→ flutter analyze"
  if ! flutter analyze 2>&1; then
    echo "FAIL: flutter analyze failed." >&2
    exit 1
  fi

  echo "→ flutter test"
  if ! flutter test 2>&1; then
    echo "FAIL: flutter test failed." >&2
    exit 1
  fi

  echo
  echo "Flutter: ALL CHECKS PASSED"
  echo
fi

# ── Summary ───────────────────────────────────────────────────────────────────

echo "=== BOOTSTRAP SMOKE TEST PASSED ==="
echo "The template produces a working project when copied to a fresh directory."
