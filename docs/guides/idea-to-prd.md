# Idea → PRD

How to take a raw idea and turn it into a structured Product Requirements Document using Claude Desktop Chat.

**Primary surface:** Claude Desktop Chat
**Handoff to:** `prd-to-specs.md` (Chat → Code)
**Template:** `docs/templates/PRD.md`

---

## Prerequisites

- Claude Desktop app (or claude.ai web)
- A Claude Project for your venture (persistent context across conversations)
- The PRD template (`docs/templates/PRD.md`) open or memorised

---

## Step-by-Step

### 1. Set Up Your Project Context

**Surface:** Claude Desktop Chat — Projects

If this is a new venture, create a dedicated Claude Project:

1. Open Claude Desktop → Projects → New Project
2. Name it after the venture (e.g., "Sentinel", "AccessFit247")
3. Add persistent context in the project instructions:
   - What the product does (one paragraph)
   - Who the target users are
   - Key technical constraints (stack, integrations, compliance)
   - Current state (greenfield, MVP, scaling)

This context persists across all conversations in the project — you won't need to repeat it.

### 2. Brainstorm the Problem

**Surface:** Claude Desktop Chat

Start a new conversation in your venture's project. Don't jump to solutions — focus on the problem:

> "I'm thinking about [rough idea]. Help me explore the problem space. Who has this problem? Why does it matter? What happens if we don't solve it?"

Let the conversation run. Push back on Claude's assumptions. Ask "why" and "who else" repeatedly. You're looking for:

- A clear problem statement
- Evidence the problem exists (even anecdotal)
- The specific users who feel the pain

### 3. Map the User Journeys

**Surface:** Claude Desktop Chat

Once the problem is clear, map how users would experience the solution:

> "Let's map the key user journeys. For each user segment, walk me through: what triggers them to start, what steps they take, and what outcome they achieve."

Focus on the happy path first. Edge cases come later in the technical spec. You want 2–4 journeys that cover the core experience.

### 4. Define the Feature Matrix

**Surface:** Claude Desktop Chat

Now prioritise what needs to be built:

> "Based on these journeys, what features do we need? Prioritise as P0 (must have for launch), P1 (should have), and P2 (nice to have). Be ruthless — I want a tight P0."

Challenge anything that feels like scope creep. A good P0 is the smallest set of features that makes the product useful.

### 5. Stress-Test the Plan

**Surface:** Claude Desktop Chat

Before you commit to writing it up, poke holes:

> "Play devil's advocate. What are the biggest risks with this plan? What might we be wrong about? What's the hardest technical challenge?"

This is where Chat excels — it can reason about trade-offs without the pressure to produce code. Let it challenge your assumptions.

### 6. Structure into PRD Template

**Surface:** Claude Desktop Chat

Now formalise everything into the template:

> "Let's write this up as a PRD. Use this structure: Problem Statement, Target Users, User Journeys, Feature Matrix (with priorities), Non-Functional Requirements, Success Metrics, Out of Scope, Open Questions."

If you have the PRD template, paste it into the conversation and ask Claude to fill it in based on your discussion.

### 7. Review and Iterate

**Surface:** Claude Desktop Chat

Read the draft critically. Ask Claude to:

- Tighten vague language ("improve UX" → "reduce onboarding steps from 5 to 2")
- Add measurable success metrics
- Ensure the out-of-scope section is explicit
- Flag any open questions that could block development

### 8. Finalise and Export

**Surface:** Claude Desktop Chat → Copy to local file

Once you're satisfied:

1. Copy the final PRD markdown from Chat
2. Save it to your repo: `docs/prd/[feature-name].md`
3. Commit via Claude Code (see next step)

### 9. Commit the PRD

**Surface:** Claude Code (Terminal)

```
# In Claude Code
> Commit docs/prd/[feature-name].md with message "docs: add [feature] PRD"
```

The PRD is now in the repo, version-controlled, and ready for the next phase.

---

## Handoff

The PRD is complete. Next: **decompose it into technical specs**.

→ Continue with `docs/guides/prd-to-specs.md`

---

## Tips

- **Use Projects for persistent context.** Don't re-explain your product every conversation. Set it up once in the project instructions.
- **Don't shortcut the problem step.** It's tempting to jump to features. Resist. A well-defined problem makes everything downstream faster.
- **Chat is for thinking, not building.** If you find yourself asking Chat to write code or create files, switch to Claude Code.
- **Export early, iterate in Code.** Once the PRD is 80% right, commit it and refine in Code where it's version-controlled. Don't chase perfection in Chat.

---

*See `docs/guides/claude-surfaces.md` for the full surface decision tree.*
