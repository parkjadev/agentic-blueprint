# Stage 1: Research & Think

> Validate the problem space with real research, then shape the idea into a structured PRD through deliberate conversation with a thinking partner.

## Why this stage exists

Most AI-assisted development fails not because the code is bad, but because the
wrong thing gets built. The root cause is almost always the same: teams jump
straight from a rough idea to generating code. Cursor and Replit both optimise
for speed-to-code — Cursor opens an editor, Replit spins up an environment —
neither provides a dedicated surface for *thinking*. When your only tool is a
code generator, every idea looks like a feature to ship.

Research is the antidote. Before you brainstorm solutions, you need to
understand the competitive landscape, existing user behaviour, and technical
constraints. Deep-research tools can synthesise dozens of sources in minutes,
surfacing risks and opportunities you would otherwise discover weeks into
implementation. Skipping this step means building on assumptions instead of
evidence.

The thinking phase that follows is equally critical. A persistent-context chat
lets you accumulate decisions across multiple conversations — your problem
statement, user segments, prioritisation rationale — without re-explaining
context every time. Tools that lack persistent project context force you to
start from scratch each session, which fragments your reasoning and leads to
inconsistent PRDs. The Blueprint makes research and structured thinking explicit
stages so that nothing downstream is built on shaky foundations.

## What you need

| Role | Recommended | Alternatives |
| --- | --- | --- |
| Research tool | Perplexity Deep Research | Claude web search, ChatGPT Deep Research, Gemini Deep Research |
| Thinking partner | Claude Desktop Chat (Projects) | Any LLM chat with persistent context |

## How it works

### 1. Define research questions

Before you touch any AI tool, write down 3–7 specific questions you need
answered. Good research questions are falsifiable and bounded:

- "Who are the top 5 competitors and what do they charge?"
- "What regulatory requirements apply in AU / US / EU?"
- "What open-source libraries exist for [capability]?"

Avoid vague questions like "Is this a good idea?" — they produce vague answers.

### 2. Run deep research

Feed your questions into a deep-research tool. Let it crawl, synthesise, and
cite sources. Review the output critically — check that citations are real and
that conclusions follow from the evidence. Flag anything that contradicts your
assumptions; those contradictions are the most valuable findings.

### 3. Save research brief

Structure your findings using the research-brief template. Save the file as
`[topic].md` locally or in your thinking partner's project context (e.g.,
Cowork). The repo does not exist yet — it will be bootstrapped in Stage 2,
where you will commit the research brief to `docs/research/`.

### 4. Set up project context (persistent chat)

Open your thinking partner. If this is a new venture, create a dedicated project
or workspace:

1. Create a new project named after the venture (e.g., "Acme Web")
2. Add persistent context in the project instructions:
   - What the product does (one paragraph)
   - Who the target users are
   - Key technical constraints (stack, integrations, compliance)
   - Current state (greenfield, MVP, scaling)

This context persists across all conversations in the project — you will not
need to repeat it.

### 5. Brainstorm with thinking partner

Start a new conversation in your venture's project. Focus on the problem, not
the solution:

> "I'm thinking about [rough idea]. Here's what research revealed: [key
> findings]. Help me explore the problem space. Who has this problem? Why does
> it matter? What happens if we don't solve it?"

Push back on assumptions. Ask "why" and "who else" repeatedly. You are looking
for a clear problem statement, evidence the problem exists, and the specific
users who feel the pain.

### 6. Map user journeys

Once the problem is clear, map how users would experience the solution:

> "Let's map the key user journeys. For each user segment, walk me through:
> what triggers them to start, what steps they take, and what outcome they
> achieve."

Focus on the happy path first. Edge cases come later in the technical spec. Aim
for 2–4 journeys that cover the core experience.

### 7. Build feature matrix (P0 / P1 / P2)

Prioritise what needs to be built:

> "Based on these journeys, what features do we need? Prioritise as P0 (must
> have for launch), P1 (should have), and P2 (nice to have). Be ruthless — I
> want a tight P0."

Challenge anything that feels like scope creep. A good P0 is the smallest set of
features that makes the product useful.

### 8. Stress-test assumptions

Before committing to a PRD, poke holes:

> "Play devil's advocate. What are the biggest risks with this plan? What might
> we be wrong about? What's the hardest technical challenge? Where does our
> research have gaps?"

This is where a thinking partner excels — it can reason about trade-offs without
the pressure to produce code. Let it challenge your assumptions.

### 9. Structure into PRD template

Formalise everything into the PRD template:

> "Let's write this up as a PRD. Use this structure: Problem Statement, Target
> Users, User Journeys, Feature Matrix (with priorities), Non-Functional
> Requirements, Success Metrics, Out of Scope, Open Questions."

Iterate until language is precise — replace "improve UX" with "reduce onboarding
steps from 5 to 2". Ensure success metrics are measurable, the out-of-scope
section is explicit, and open questions are flagged.

### 10. Save PRD

Export the final PRD and save it locally:

1. Copy the final PRD markdown from your chat
2. Save it as `[feature-name].md` locally or in your thinking partner's project
   context (e.g., Cowork)

The repo does not exist yet — it will be bootstrapped in Stage 2, where you
will commit the PRD to `docs/specs/<slug>/PRD.md`.

## Templates

- [Research Brief](../templates/research-brief.md) — structured findings from deep research including sources, key insights, and open questions
- [PRD](../templates/PRD.md) — problem statement, target users, user journeys, feature matrix, success metrics

## Exit criteria

- Research brief and PRD are finalised and saved locally. Both will be committed to the repo in Stage 2.
- All open questions either resolved or explicitly documented in the PRD
- P0 feature set is tight and justified by research evidence

## Platform notes

- **Claude-native:** Use Claude Desktop Projects for persistent venture context across conversations.
- **Cursor + Perplexity:** Perplexity Deep Research handles the research. For thinking, use Claude Desktop Chat or iterate in Perplexity follow-up threads (less depth than a dedicated thinking partner).
- **OutSystems ODC:** Same research and thinking workflow. ODC teams benefit from researching existing OutSystems Forge components and solution patterns before ideating.

## Anti-patterns

| Anti-pattern | Why it fails | Do this instead |
| --- | --- | --- |
| Skip research, jump to brainstorming | You build on assumptions that may be wrong; competitors or regulations surface too late | Run deep research first; commit findings before brainstorming |
| Use Chat for coding tasks | Chat is optimised for reasoning, not file operations; you lose version control and context | Think in Chat, write in Code — switch surfaces at the handoff |
| No persistent context | Every conversation starts from zero; decisions drift and contradict each other | Use a project or workspace so context accumulates across sessions |
| PRD too vague ("improve the experience") | Specs cannot be derived from vague requirements; implementation becomes guesswork | Quantify every claim; replace adjectives with measurable criteria |
| Skip stress-test | Risks surface during implementation when they are expensive to fix | Dedicate a full conversation turn to devil's-advocate review before finalising |

---

*Next stage: [Stage 2 — Plan](stage-2-plan.md)*
