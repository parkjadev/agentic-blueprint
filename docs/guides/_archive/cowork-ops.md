# Cowork Operations

Non-code operational playbook for using Claude Desktop Cowork to handle file processing, document generation, research compilation, and venture administration.

**Primary surface:** Claude Desktop — Cowork
**Secondary surface:** Claude Desktop Chat (for strategic thinking before Cowork execution)
**Related:** `claude-surfaces.md` (when to use Cowork vs other surfaces)

---

## Overview

Cowork is Claude's agentic file automation surface. It reads and writes local files, processes PDFs and images, and works autonomously on folder-based tasks. Use it for everything that isn't code — invoices, contracts, research, templates, and admin.

### When to Use Cowork

- Processing batches of files (receipts, documents, data exports)
- Generating documents from templates
- Reviewing and summarising contracts or legal documents
- Compiling research from multiple sources
- Organising files into structured folders

### When NOT to Use Cowork

- Writing or modifying code (use Claude Code)
- Git operations (use Claude Code)
- Strategic thinking or brainstorming (use Claude Desktop Chat)
- Anything requiring CLI tools or APIs (use Claude Code)

---

## Directory Layout

Organise your Cowork workspace to separate concerns. Cowork works best when pointed at a specific folder with a clear task.

```
~/Documents/Claude/                # Cowork root
├── operations/
│   ├── invoices/                  # Receipt photos, invoice PDFs
│   ├── contracts/                 # Legal docs, equity deeds, agreements
│   ├── research/                  # Market research, competitor analysis inputs
│   └── templates/                 # Document templates for Cowork
├── ventures/
│   ├── [venture-name]/            # Venture-specific non-code files
│   │   ├── meeting-notes/
│   │   ├── partner-comms/
│   │   └── timelines/
│   └── [another-venture]/
└── SKILL.md                       # Cowork skill file — persistent context
```

### Key Principles

- **One folder per concern.** Don't mix invoices with contracts.
- **Venture folders for venture-specific work.** Keep cross-venture operations in `operations/`.
- **Drop files, then ask.** Place raw materials in the folder first, then tell Cowork what to do with them.

---

## SKILL.md — Persistent Context

Create a `SKILL.md` in the root of your Cowork folder. This file persists across sessions and defines how Cowork operates. It's the equivalent of CLAUDE.md for non-code work.

### Example SKILL.md

```markdown
# Cowork Skills

## Brand Voice

- Professional but approachable
- Australian English (favour, colour, organisation)
- No jargon unless writing for a technical audience
- Short sentences, active voice

## Invoice Processing

When processing invoices or receipts in operations/invoices/:
1. Extract: date, vendor name, amount (AUD), GST amount, category
2. Categories: Software, Infrastructure, Professional Services, Office, Travel, Marketing
3. Append to operations/invoices/expenses.csv
4. CSV columns: Date, Vendor, Description, Amount, GST, Category, File
5. Move processed files to operations/invoices/processed/
6. Flag any invoice over $1,000 for manual review

## Contract Review

When reviewing documents in operations/contracts/:
1. Extract: parties, effective date, term, key obligations, termination clauses
2. Check against this red flag list:
   - Automatic renewal without notice period
   - Non-compete clauses broader than 12 months or the specific industry
   - Unlimited liability
   - IP assignment without fair consideration
   - Governing law outside Australia
3. Produce a summary in operations/contracts/reviews/[filename]-review.md
4. Rate risk: Low / Medium / High with justification

## Research Compilation

When compiling research from operations/research/:
1. For each source, extract: title, source URL/name, date, key findings
2. Score relevance: High / Medium / Low
3. Organise findings by theme (not by source)
4. Produce a summary brief in operations/research/briefs/[topic]-brief.md
5. Include a "So What?" section — what this means for the venture
```

### Tips for SKILL.md

- **Be prescriptive about output format.** Cowork follows instructions better when the expected output is specific.
- **Include processing rules.** "Flag any invoice over $1,000" is actionable. "Review invoices carefully" is not.
- **Update as patterns emerge.** If you keep correcting Cowork on the same thing, add a rule to SKILL.md.

---

## Task Patterns

### Expense Processing

**Setup:** Drop receipt photos or invoice PDFs into `operations/invoices/`.

**Prompt:**

> Process all new files in operations/invoices/. For each receipt or invoice, extract the data per the invoice processing rules in SKILL.md. Append to expenses.csv. Move processed files to the processed/ subfolder. Summarise what was processed when done.

**Expected Output:**
- `expenses.csv` updated with new rows
- Processed files moved to `processed/`
- Summary of what was added

**Review:** Open `expenses.csv` and spot-check the extracted data against the original documents. Fix any errors and note patterns for improving SKILL.md.

---

### Contract Review

**Setup:** Drop the contract PDF or document into `operations/contracts/`.

**Prompt:**

> Review the new document in operations/contracts/. Follow the contract review checklist in SKILL.md. Produce a review summary in operations/contracts/reviews/. Flag any red flags prominently at the top of the review.

**Expected Output:**
- Review document at `operations/contracts/reviews/[filename]-review.md`
- Key terms extracted
- Red flags listed with specific clause references
- Risk rating with justification

**Review:** Read the review alongside the original contract. Cowork catches structural risks well but may miss domain-specific nuance — always read the flagged clauses yourself.

---

### Research Compilation

**Setup:** Drop articles, PDFs, screenshots, or links into `operations/research/`.

**Prompt:**

> Compile research from all files in operations/research/ on the topic of [topic]. Follow the research compilation format in SKILL.md. Group findings by theme. Produce a brief at operations/research/briefs/[topic]-brief.md.

**Two-surface pattern:** For best results, think through the research strategy in Claude Desktop Chat first:

> (In Chat) "I'm researching [topic] for [venture]. What are the key themes I should organise findings around? What's the 'So What?' I should be looking for?"

Then use the themes from Chat to guide Cowork's compilation.

**Expected Output:**
- Research brief at `operations/research/briefs/[topic]-brief.md`
- Findings organised by theme with relevance scores
- "So What?" section connecting research to venture decisions

---

### Venture Administration

**Setup:** Each venture has its own folder under `ventures/[name]/`.

#### Meeting Notes

**Prompt:**

> Organise the meeting notes in ventures/[name]/meeting-notes/. For each note, extract: date, attendees, key decisions, action items with owners and due dates. Produce a running action tracker at ventures/[name]/action-tracker.md.

#### Follow-Up Emails

**Prompt:**

> Based on the latest meeting notes in ventures/[name]/meeting-notes/, draft follow-up emails for each action item owner. Use a professional but friendly tone per SKILL.md brand voice. Save drafts to ventures/[name]/partner-comms/drafts/.

#### Timeline Updates

**Prompt:**

> Read the current timeline at ventures/[name]/timelines/roadmap.md. Based on the latest meeting notes and any completed action items, update the timeline. Mark completed items, adjust dates where needed, and flag any items that are overdue.

---

### Document Generation

**Setup:** Place templates in `operations/templates/` and source data wherever appropriate.

**Prompt:**

> Using the template at operations/templates/[template-name].md and the data in [source-location], generate [output description]. Save to [output-location].

**Common use cases:**
- Weekly status reports from meeting notes and action trackers
- Investor updates from venture milestones and metrics
- Proposal documents from research briefs and templates

---

## Tips

- **Drop then ask.** Always place files in the right folder before starting a Cowork session. Don't describe files — let Cowork read them.
- **One task per session.** Cowork works best with a clear, single objective. "Process invoices" is better than "process invoices and also review that contract and compile research."
- **Think in Chat, compile in Cowork.** Strategic framing belongs in Claude Desktop Chat. File processing belongs in Cowork. Don't conflate them.
- **Review everything.** Cowork is good at extraction and organisation. It's less reliable at judgement calls (risk ratings, relevance scores). Always review its output.
- **Iterate SKILL.md.** Your SKILL.md will improve over time. After every session, note what Cowork got wrong and add a rule to prevent it next time.

---

*See `docs/guides/claude-surfaces.md` for the full surface decision tree.*
*See `docs/guides/agentic-workflow.md` for how Cowork fits into the lifecycle.*
