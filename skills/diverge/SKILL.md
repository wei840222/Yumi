---
name: diverge
description: Evaluate complex questions through multiple perspectives before reaching a reasoned synthesis. Use when the user requests competing viewpoints for product decisions, safety-critical evaluations, creative choices, or consequential trade-offs.
metadata:
  openclaw: '{"emoji":"🌿"}'
  version: "1.0.0"
---

## When to Diverge

Diverge when a single viewpoint isn't enough. For a parallel-thinking framing, load `references/parallel-thinking.md`:
- **Product decisions** — Different user types have conflicting needs
- **Safety-critical** — Need doctor, lawyer, security expert perspectives
- **Creative work** — Multiple aesthetic directions before choosing
- **Complex trade-offs** — No obvious "right" answer

Use direct analysis when the answer is clear, the request is speed-critical, or the available evidence already supports a high-confidence decision.

## How Many Perspectives

| Complexity | Perspectives | Examples |
|------------|--------------|----------|
| Low | 2-3 | Quick sanity check |
| Medium | 3-5 | Product feature review |
| High | 5-7 | Safety-critical, legal |

**Rule:** Enough to cover blind spots, not so many you can't synthesize.

### Dispatch Boundary

Before launching personas, confirm the host permits parallel work and that any required approval is already in scope. If dispatch is unavailable, present the selected perspectives as an explicit dry run and label the result accordingly.

## Choosing Perspectives

Match perspectives to the problem:

- **Product:** Power user, casual user, churned user, new user
- **Medical:** Doctor, patient, caregiver, insurance
- **Legal:** Lawyer, affected party, regulator
- **Technical:** Security, performance, maintainability
- **Content:** Target audience, critic, competitor

Load `references/personas.md` for common perspective templates.

## Synthesis

After collecting perspectives:
1. **Identify conflicts** — Where do perspectives disagree?
2. **Find common ground** — What do all perspectives agree on?
3. **Weigh by stakes** — Safety concerns > preferences
4. **Decide** — Make a call, document trade-offs

Load `references/synthesis.md` for conflict resolution patterns.

## Learning User Preferences

Track when divergence helped vs. was overkill. Adapt:
- User who values speed → diverge less, ask before spawning
- User who values thoroughness → diverge more proactively
