# Incident response

The playbook for responding to a production incident. Triggered by
`/run incident <slug>`.

> This is a framework document. Specific products should copy this
> into their own `docs/operations/` and fill in the team-specific
> bits (on-call rotation, paging tool, status page URL, stakeholder
> contacts).

## Severity ladder

| Sev | Definition | Response expectation |
|---|---|---|
| Sev 1 | Service fully unavailable for all users | Page within 5 min, all-hands |
| Sev 2 | Significant degradation or partial outage | Page within 15 min, primary on-call |
| Sev 3 | Minor degradation, single-tenant impact | Next business hour |
| Sev 4 | Cosmetic or low-impact | Ticket, no page |

## The first 15 minutes (primary on-call)

1. **Acknowledge the page** — stops the escalation timer.
2. **Declare severity.** If unsure, declare higher; demote later.
3. **Open an incident channel** (or whatever your team's coordination
   surface is). Pin the current understanding at the top; keep it
   updated every 10 minutes.
4. **Establish a timeline.** Capture timestamps for: first alert,
   first customer report, first action taken. Timeline is the #1
   postmortem artefact; reconstructing it later is brutal.
5. **Stop the bleeding before finding the cause.** Roll back, feature-
   flag off, scale up — whatever reduces impact fastest. Root cause
   is a later concern.
6. **Update status page / customers** once the scope is known.

## Roles (for Sev 1 / Sev 2)

- **Incident commander (IC)** — coordinates, does not fix. Maintains
  the timeline and runs the comms cadence.
- **Tech lead** — makes the technical calls. Often the person who
  knows the affected system best.
- **Comms lead** — talks to customers, execs, support. Insulates IC
  and tech lead from interrupt traffic.

Small team? One person can wear two hats, but never all three —
the IC/tech-lead split is the one that matters most.

## Comms templates

### Internal update (every 10 minutes during active incident)

> **Incident update — <time>**
> Status: <Investigating | Mitigated | Resolved>
> Impact: <who is affected, how>
> Current action: <what's being done right now>
> Next update: <time>

### Customer-facing (status page / email)

> We're currently investigating an issue affecting <feature>. Users
> may experience <symptom>. We'll update this page every <interval>
> until resolved.

## Postmortem

Once the incident is mitigated (not necessarily fully resolved),
schedule a postmortem within 5 business days. Use
`docs/templates/postmortem.md` when that template lands; until then,
follow this outline:

- **Timeline** — every timestamp, every action.
- **Impact** — who was affected, for how long, what did they
  experience.
- **Root cause(s)** — prefer plural; the "5 whys" rarely bottoms out
  in one thing.
- **What went well** — named explicitly, not skipped.
- **What went poorly** — without blame. Focus on systems, not people.
- **Action items** — each with an owner and a deadline.

## Links and hand-offs

- Alerting rules: `<your alerting tool URL>`
- On-call rotation: `<your scheduling tool URL>`
- Status page: `<your status page URL>`
- Paging docs: `<your paging doc URL>`

Fill these in during adoption. The framework ships with blanks so
teams don't inherit someone else's runbook.
