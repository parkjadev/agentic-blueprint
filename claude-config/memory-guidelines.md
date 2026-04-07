# Memory Guidelines

How to use Claude Code's memory system effectively for your project.

---

## When to Save Memories

Claude Code has four memory types. Each serves a different purpose.

### User Memories

Save when you learn about the developer's role, expertise, or preferences.

**Good examples:**
- "Senior full-stack dev, deep Next.js experience, new to Flutter"
- "Prefers terse responses, no trailing summaries"
- "Solo founder — context-switching between multiple ventures"

**Don't save:**
- Generic facts ("user is a developer")
- Anything that could be read as a negative judgement

### Feedback Memories

Save when the developer corrects your approach or confirms something non-obvious worked.

**Good examples:**
- "Don't mock the database in integration tests — use Neon preview branches"
- "Single bundled PR is preferred for refactors in this area"
- "Always run `pnpm check:all` before committing, not just `pnpm test`"

**Don't save:**
- One-off corrections that won't recur
- Feedback that's already captured in CLAUDE.md rules

### Project Memories

Save when you learn about ongoing work, deadlines, or decisions not in the code.

**Good examples:**
- "Merge freeze begins 2026-03-05 for mobile release"
- "Auth rewrite driven by legal/compliance, not tech debt"
- "Waiting on Clerk webhook fix before deploying user sync changes"

**Don't save:**
- Things derivable from git log or the code itself
- Ephemeral task details that only matter for the current session

### Reference Memories

Save when you learn where external information lives.

**Good examples:**
- "Pipeline bugs tracked in Linear project INGEST"
- "Oncall latency dashboard at grafana.internal/d/api-latency"
- "Design assets in Figma project linked from the README"

---

## How to Keep CLAUDE.md Current

CLAUDE.md is the most important file in the repo for Claude Code. It must stay accurate.

### When to Update CLAUDE.md

| Trigger | What to Update |
|---|---|
| New table added to schema | Data Model section |
| New service integrated | Stack table |
| New environment created | Environments table |
| New critical file identified | Do NOT Touch section |
| New pattern established | Key Patterns section |
| Hard rule added or changed | Hard Rules list |

### When NOT to Update CLAUDE.md

- Don't add temporary information (current sprint, in-progress work)
- Don't duplicate what's in the code (function signatures, import paths)
- Don't add information that changes frequently (dependency versions)
- Don't add meeting notes or discussion summaries

### The Update Process

1. Make the code change first
2. Check if CLAUDE.md needs updating
3. Update CLAUDE.md in the same commit or a follow-up commit
4. If using scheduled tasks, the doc sync task will catch missed updates

---

## Anti-Patterns

### Don't Save Code in Memory

Code patterns belong in CLAUDE.md, not in memory. Memory is for context that helps Claude understand *how* to work with you, not *what* the code looks like.

### Don't Save Everything

Memory has diminishing returns. A few high-quality memories are better than dozens of low-quality ones. If you're saving more than 2–3 memories per session, you're probably saving too much.

### Don't Use Memory as a Task List

Memory persists across sessions. Tasks are for the current session. Don't save "need to fix the auth bug" as a memory — create a GitHub issue instead.

### Don't Duplicate CLAUDE.md in Memory

If something belongs in CLAUDE.md (patterns, rules, architecture), put it there. CLAUDE.md is always loaded. Memory is loaded when relevant. CLAUDE.md is the authoritative source.

### Don't Save Stale Information

Memory records can become outdated. Before acting on a memory, verify it against the current code. If a memory conflicts with what you see in the code, trust the code and update or remove the memory.

---

## Memory + CLAUDE.md Decision Tree

```
Is this information useful across sessions?
├─ No → Don't save it anywhere (it's ephemeral)
└─ Yes
   ├─ Is it about the code, patterns, or architecture?
   │  └─ Put it in CLAUDE.md
   ├─ Is it about the developer's preferences or working style?
   │  └─ Save as a user or feedback memory
   ├─ Is it about an ongoing project decision or deadline?
   │  └─ Save as a project memory
   └─ Is it about where to find external information?
      └─ Save as a reference memory
```
