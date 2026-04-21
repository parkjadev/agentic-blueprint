# Incident Runbook — [Incident Class or Service]

**Author:** [Name]
**Date:** [YYYY-MM-DD]
**Status:** Draft | In Review | Approved
**Scope:** product | epic | feature
**Severity tiers covered:** SEV1 | SEV2 | SEV3

> **Purpose.** A runbook is the page you open when something is on fire. It must be readable in two minutes, executable without context, and updated after every incident it covers. One runbook per incident class — not one mega-runbook.

---

## 1. Trigger

<!-- Exactly what signals this runbook applies. If the signal is ambiguous,
     write the decision rule a sleepy on-call would use at 2am. -->

TODO: Which alert, error signature, user report pattern, or metric breach says "open this runbook"?

## 2. Severity & Initial Assessment

| Sev | Definition | Example |
|---|---|---|
| SEV1 | Production down / data loss imminent / security breach | Full outage, cascading failure, confirmed data exfiltration |
| SEV2 | Major feature broken / significant user impact | Checkout failing for 10%+ users, auth broken for a provider |
| SEV3 | Degraded experience / isolated user impact | Slow endpoint, non-critical feature error |

**First 5 minutes:**
- [ ] Confirm the trigger (not a false alarm)
- [ ] Assign a severity from the table above
- [ ] Open an incident channel / thread with a timestamped header
- [ ] Notify stakeholders per severity (SEV1: all-hands; SEV2: team + leads; SEV3: team)

## 3. Detection Signals

<!-- Specific, verifiable signals that confirm the incident is happening.
     Use these to rule in or rule out; do not diagnose from a single signal. -->

| Signal | Where to look | Confirming value |
|---|---|---|
| TODO: Health check failure | TODO: monitoring URL | TODO: non-200 status |
| TODO: Error spike | TODO: APM dashboard | TODO: error rate > X% |
| TODO: User reports | TODO: support channel | TODO: N+ reports in Y minutes |

## 4. Mitigation — First Action

<!-- The fastest, safest action to stop the bleed. Not the fix — the circuit
     breaker. This section is read aloud during incidents; write it as a
     numbered list with exact commands. -->

1. TODO: Specific command or UI step
2. TODO: Specific command or UI step
3. TODO: Confirm mitigation effective (which signal returns to green?)

Expected outcome: TODO (e.g. "error rate drops below 1% within 3 minutes").

If the first action doesn't work after N minutes, escalate to Section 5.

## 5. Rollback Ladder

Use the rollback levers from `docs/templates/delivery.md` § 8. For this incident class, the default ladder is:

| Order | Lever | Trigger | Owner |
|---|---|---|---|
| 1 | TODO: Feature flag disable | TODO | TODO |
| 2 | TODO: Platform promote | TODO | TODO |
| 3 | TODO: Revert commit | TODO | TODO |
| 4 | TODO: Database restore | TODO (rare) | TODO |

> Escalate only when the previous lever has been tried or ruled out. Do not skip to database restore unless clearly data-integrity driven.

## 6. Communication

- **During incident:** timestamped updates in the incident channel every N minutes. Say what you know, what you don't, what you're trying next.
- **External:** status page update within 10 min of SEV1 confirmation; 30 min for SEV2.
- **Customers:** for SEV1 with data impact, legal and CS approve customer notice before it goes out.

Template lines:

```
[HH:MM UTC] Investigating reports of <symptom>. Impact: <scope>. Next update in 15 min.
[HH:MM UTC] Mitigation applied: <lever>. Monitoring recovery.
[HH:MM UTC] Resolved. Root cause TBD. Post-mortem link to follow within 48h.
```

## 7. Post-Mortem

<!-- Every SEV1 and SEV2 gets a post-mortem within 48 hours. Blameless,
     structured, public to the team. SEV3 may skip unless pattern emerges. -->

Post-mortem template (link or embed):

- **What happened** (user-visible symptom)
- **Timeline** (detection → mitigation → resolution, UTC timestamps)
- **Root cause** (five whys; stop when you hit a system-level cause, not a person)
- **Why our detection missed / lagged**
- **What prevented faster mitigation**
- **Action items** (owner + due date for each; filed as issues immediately)

## 8. CHANGELOG Entry

After resolution, append an entry to `CHANGELOG.md` under `[Unreleased]`:

```
### Fixed
- TODO: user-facing description of what was broken and what was fixed.
```

Use the `changelog-entry` skill or `signal-sync` skill (whichever is present in v4) to append via script.

## 9. Learnings

<!-- Surface the single most important lesson from this incident. Add it to
     docs/signal/learnings.md so future /spec idea and /spec feature runs
     can read it without re-summarising. -->

TODO: One-paragraph durable insight.

## 10. Runbook Maintenance

- **Last exercised (drill):** YYYY-MM-DD
- **Last updated after real incident:** YYYY-MM-DD
- **Owner:** TODO

> A runbook that hasn't been exercised or updated in 6 months is presumed stale. Schedule a drill.

---

*Template from [agentic-blueprint](https://github.com/parkjadev/agentic-blueprint)*
