# Pre-Commit Hook Patterns

Claude Code hooks that run automatically before commits. These ensure code quality without manual intervention.

---

## Overview

Claude Code hooks are configured in `.claude/settings.local.json` under the `hooks` key. Pre-commit hooks run before every `git commit` and can block the commit if checks fail.

---

## Pattern 1: Full Check Suite

Run the complete check suite before every commit. This is the recommended default.

### Configuration

```json
{
  "hooks": {
    "pre-commit": [
      {
        "command": "pnpm check:all",
        "description": "Run type-check, lint, and tests before commit",
        "blocking": true
      }
    ]
  }
}
```

### Behaviour

- **Blocking:** The commit is prevented if any check fails
- **Runs:** `pnpm type-check && pnpm lint && pnpm test:ci`
- **Duration:** Typically 10–30 seconds depending on test suite size

### When to Use

- Default for all projects
- Ensures no broken code is committed
- Catches type errors, lint violations, and test failures early

---

## Pattern 2: Fast Lint Only

For rapid iteration where the full test suite is too slow for every commit. Run tests separately before PRs.

### Configuration

```json
{
  "hooks": {
    "pre-commit": [
      {
        "command": "pnpm type-check && pnpm lint",
        "description": "Type-check and lint before commit (tests run in CI)",
        "blocking": true
      }
    ]
  }
}
```

### Behaviour

- **Blocking:** Commit prevented on type errors or lint violations
- **Skips:** Unit tests (rely on CI to catch test failures)
- **Duration:** Typically 5–15 seconds

### When to Use

- Large test suites where running all tests on every commit is impractical
- When paired with CI that runs the full suite on every push

---

## Pattern 3: Staged Files Only

Only check files that are being committed, not the entire codebase.

### Configuration

```json
{
  "hooks": {
    "pre-commit": [
      {
        "command": "pnpm lint --cache && pnpm type-check",
        "description": "Lint changed files and type-check before commit",
        "blocking": true
      }
    ]
  }
}
```

### Behaviour

- **Lint:** Uses ESLint cache to only re-lint changed files
- **Type-check:** Still checks the full project (TypeScript needs full context)
- **Duration:** Typically 3–10 seconds

---

## Pattern 4: Auto-Format on Commit

Automatically format code before committing. Non-blocking — fixes issues rather than blocking.

### Configuration

```json
{
  "hooks": {
    "pre-commit": [
      {
        "command": "pnpm prettier --write --cache .",
        "description": "Auto-format code before commit",
        "blocking": false
      },
      {
        "command": "pnpm type-check && pnpm lint",
        "description": "Type-check and lint after formatting",
        "blocking": true
      }
    ]
  }
}
```

### Behaviour

- **Step 1:** Format all files (non-blocking — always succeeds)
- **Step 2:** Type-check and lint (blocking — commit fails if issues remain)
- Requires `prettier` as a dev dependency

---

## Tips

- **Start with Pattern 1** (full check suite). Only switch to a lighter pattern if commit speed becomes a problem.
- **Blocking hooks prevent bad commits.** Non-blocking hooks run but don't stop the commit. Use blocking for checks, non-blocking for formatting.
- **Hooks run in order.** If you have multiple hooks, they execute sequentially. A blocking failure in an earlier hook stops later hooks from running.
- **Don't duplicate CI.** Hooks catch issues locally. CI catches issues on the server. They're complementary, not redundant.
- **Test your hooks.** After configuring a hook, make a deliberate error (e.g., add a `console.log`) and verify the hook blocks the commit.
