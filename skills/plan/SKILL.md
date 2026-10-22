---
name: plan
description: Plan tasks with sizing, structuring steps, estimates, and risk rollbacks.
  Load when work spans multiple sessions, involves irreversible actions, lacks clear
  success criteria, or when resuming an existing plan. Does not handle personal productivity
  or calendar time blocking.
metadata:
  openclaw: '{"emoji": "🗺️", "requires": {"config": ["<state_root>/", "~/plan/", "~/clawic/plan/"]}}'
  version: 1.0.3
  related-skills: '{"decide": "Choose between options inside a plan step.", "escalate":
    "Ask-vs-act boundaries beyond planning scope.", "memory": "Long-term context and
    user continuity beyond planning records.", "productivity": "Personal productivity
    systems, time blocking, and reviews; plan covers executing a single task.", "self-improving":
    "General execution lessons; plan keeps only planning lessons."}'
---



## State location

Plan state may exist in `<workspace>/plan/`, `<workspace>/memory/plan/`, or `~/plan/`.
Before reading or writing state, resolve `<state_root>` as follows:

1. Use an explicitly configured path when one exists.
2. Otherwise use the first existing directory in this order:
   `<workspace>/plan/`, `<workspace>/memory/plan/`, `~/plan/`.
3. If none exists and state must be created, default to `<workspace>/plan/`.

Use the selected `<state_root>` for every state operation in this skill.



User preferences, the outcome log, and active plans live in `<state_root>/` (see `references/setup.md` on first use). If you have data at an old location (`~/plan/` or `~/clawic/plan/`), move it to `<state_root>/`, and say in one line that you moved it and from where.

## When To Use

- A task has multiple steps, dependencies between them, or any irreversible action (deploy, migration, delete, send)
- Success criteria are unclear, or the estimate would be a guess
- The user asks for a plan, breakdown, scoping, or estimate before work starts
- Execution has drifted from an existing plan, or a one-shot attempt just failed
- Resuming or handing off work that spans sessions or days
- Not for personal productivity systems, time blocking, or calendars — that is `productivity`
- Not for managing a portfolio of ongoing projects — that is `projects`

Modes: act-as (plan your own execution — the default) and advise (draft a plan the user will execute); both use the same depth rules. Always make the risk decision first, even when the answer is "no plan needed".

## Quick Reference

| Situation | Do this |
|-----------|---------|
| Done before successfully, fully reversible | Execute directly (L0) |
| Single deliverable, ≤30 min (`quick_task_minutes`), reversible | Think through steps, no doc (L1) |
| Multi-step, >30 min, or any irreversible step | Bullet plan, share with human (L2) |
| Dependencies across components, or spans >1 day | Milestone plan with validations (L3) → `references/long-horizon.md` |
| High stakes AND novel task type | Full plan, human validation before step 1 (L4) → `references/approval.md` |
| Estimate high/low ratio >3x | Spike first → `references/estimation.md`, `references/strategies.md` |
| A step has no attachable done-check | Convert to decision doc or spike → `references/decomposition.md` |
| Execution drifting from the plan | 2-consecutive-deviation trigger → `references/replanning.md` |
| Step blocked, or scope added mid-flight | Block and bolt-on protocols → `references/replanning.md` |
| Human approves instantly, or "just do it" | → `references/approval.md` |
| Resuming yesterday's (or last week's) plan | Resume protocol → `references/long-horizon.md` |
| Anything else / unsure | Plan at L2 — the cost is asymmetric (Core Rule 8) |

Depth on demand: `references/decomposition.md` steps, altitude, done-checks · `references/estimation.md` ranges, spikes, calibration · `references/risk.md` irreversibility, rollback, blast radius · `references/strategies.md` sequential, parallel, iterative, spike, validation · `references/replanning.md` deviations, blocks, abandonment · `references/approval.md` validation, validations, scope changes · `references/long-horizon.md` multi-day, resume, handoff · `references/outcomes.md` logging and learning · `references/setup.md` first use.

## Core Rules

1. **A plan's value is the risk decision, not the step list.** Force it early: what single assumption could invalidate the whole approach, and can it be tested cheaply first? A to-do list with no risk ordering adds ceremony, not safety (`references/risk.md`).
2. **Depth = the highest level any single signal triggers, is the exact measure.** A 20-minute task with one irreversible step is L2, not L1 — the short duration retains the irreversibility.
3. **Irreversibility dominates.** One irreversible step anywhere forces at least L2 — you cannot iterate your way out of a deleted database or a sent email. Classification and blast radius in `references/risk.md`.
4. **Every step carries an observable done-check.** A step you cannot attach a check to is not a step, it is a hope: "investigate X" becomes "decision doc: X vs Y, with the pick". Check catalog in `references/decomposition.md`.
5. **Order by information, not convenience.** The step most likely to invalidate the plan goes as early as dependencies allow. Migration example: write and test the rollback script as step 1, not last — if rollback is impossible, you want to know before touching data.
6. **Estimates are ranges; ratio >3x means spike first.** If the high/low ratio exceeds 3x, that is not an estimate, it is an unknown. 2-8h (4x) → spike; 3-6h (2x) → plan. Building and calibrating ranges in `references/estimation.md`.
7. **Detail decays past the first unknown.** Steps written beyond it are speculation you will rewrite. Plan in steps to the first validation; milestones beyond (`references/long-horizon.md`).
8. **When uncertain, plan — the cost is asymmetric.** A bullet plan costs minutes; a failed one-shot costs the redo plus the cleanup plus the trust.

## The Planning Decision

Before executing, scan for signals:

| Signal | One-shot OK | Plan needed |
|--------|-------------|-------------|
| Task done before successfully | ✅ | |
| Clear single deliverable | ✅ | |
| Reversible if wrong | ✅ | |
| Multiple components | | ✅ |
| Dependencies between steps | | ✅ |
| Any irreversible step | | ✅ |
| Touches production data or external users | | ✅ |
| Ambiguous success criteria | | ✅ |
| Estimated > `quick_task_minutes` of work | | ✅ |

**Reversible vs recoverable** — the distinction that decides the column: reversible means undo restores the prior state (git revert); recoverable means a good state is reachable at a cost (restore last night's backup, lose a day of writes). Recoverable-at-cost counts as "plan needed", not "reversible" — full taxonomy and recovery-window decay in `references/risk.md`.

## Plan Depth Levels

| Level | Trigger | Format |
|-------|---------|--------|
| L0 | Done before successfully, fully reversible | Execute directly |
| L1 | Single deliverable, ≤ `quick_task_minutes`, reversible | Think through steps; no doc |
| L2 | Multi-step, or > `quick_task_minutes`, or any irreversible step | Bullet plan shared with the human |
| L3 | Dependencies between components, or spans >1 day | Milestone plan with validations; persisted (`references/long-horizon.md`) |
| L4 | High stakes AND novel (this task type previously undone) | Full plan; human validation before step 1 (`references/approval.md`) |

Depth = highest single signal (Core Rule 2). Per-type learned defaults override this table once the outcome log has evidence (`references/outcomes.md`, Current Defaults).

## Plan Format (L2-L4)

```
📋 Plan: [goal]

Why planned: [the signal that triggered planning — one line]

Steps:
1. [step] — [observable output that proves it is done]
2. [step] — [observable output]
3. [step] — [observable output]

Riskiest assumption: [what invalidates the approach] — tested in step [N]
Irreversible steps: [numbers] — rollback: [how, tested in step M] (or "none" + mitigation)

Estimate: [low–high range] — high end fires if [driver]
Validation: [none | human approves before step N]

[The specific question, not "Ready to start?" — references/approval.md]
```

Rules that make the format work:

- **3-7 steps.** More than 7 means wrong altitude: group into milestones and plan only the first milestone in step detail (`references/decomposition.md`).
- Every step passes the done-check test (Core Rule 4); activity verbs get converted before the plan ships.
- The rollback is itself a step with a check, placed before the irreversible step (`references/risk.md`, Rollback Design).
- Scan the hidden-steps checklist — rollback, backup+restore-verify, post-change verification, comms, cleanup, monitoring (`references/decomposition.md`, The Steps Nobody Writes).

## Executing Against The Plan

- Approval covers what is written. At L3+, a materially different execution needs re-approval, not a retroactive mention — what counts as material is defined in `references/approval.md`.
- **Replan trigger:** when 2 consecutive steps deviate from plan (skipped, reordered, or output differs from stated), halt execution and replan instead of patching step-by-step. One deviation is noise; two consecutive means the model of the task is wrong. Deviation taxonomy, blocked steps, scope changes, and the replan procedure: `references/replanning.md`.
- Record every deviation in the outcome log — deviations are the raw material for next time's plan (`references/outcomes.md`).

## Learning Loop

Learning rates are asymmetric because evidence costs are asymmetric:

- **Promote depth after ONE failure** attributable to plan depth — and name what the deeper level would have caught. If you cannot name it, it was not a planning failure and no promotion happens.
- **Demote depth after 3 consecutive successes** where the extra depth went unused. Observable signal: plan sections unused during execution.
- **Auto-execute after 5 consecutive successful validated runs** of a plan type: ask "Should I auto-start [type] plans without validation?" One failure resets the streak and restores validation. The bar is higher than demotion because this removes a human safety net, not just ceremony. Types in `always_validate` always require validation.

Per-type state lives in the Current Defaults block of `<state_root>/references/outcomes.md`:

```
### Auto-Execute (validation waived by human)
- refactor/small: L2 [streak: 7]

### Validate First
- migration/data: L4 [always — in always_validate]

### Learning
- api/integration: L2, streak 3/5 toward auto-execute proposal
```

Logging: append a record after every L2+ task; L0/L1 only when they failed (a failed "trivial" task is evidence the type needs promotion). Strategy verdicts need a why — "Parallel → merge conflicts" teaches; "Parallel → didn't work" does not. Record format, last-5 analysis, and review cadence: `references/outcomes.md`.

## Output Gates

Before sharing a plan (L2+), verify:

- Riskiest assumption named, with the step number that tests it?
- Every step has an observable output — no bare activity verbs?
- Irreversible steps listed with a tested rollback, or "none" plus a mitigation?
- Estimate is a range with ratio ≤3x — otherwise did I propose a spike instead?
- Depth equals the highest signal triggered, and `always_validate` types have validation on?
- The closing question is specific enough that its answer proves the plan was read (L3+)?

## Configuration

User-dependent variables. Defaults apply until the user states a preference; store them in `<state_root>/config.yaml`.

| Variable | Type | Default | Effect |
|---|---|---|---|
| quick_task_minutes | number (minutes) | 30 | Sets the L1/L2 boundary in the depth table and the "estimated >" signal in The Planning Decision |
| plan_artifact | chat \| file | chat | Where L2 plans live; `file` writes them to `<state_root>/active/` like L3+ (`references/long-horizon.md`) |
| always_validate | list of task types | migration/*, external-send/* | Types where human validation always demands validation, regardless of streaks |
| stale_after_days | number (days) | 7 | Resuming a plan idle longer than this re-validates the riskiest assumption first; 4x this forces a full replan (`references/long-horizon.md`) |

Preference areas to record as the user reveals them:

- **thresholds** — replan sensitivity, promotion/demotion streak lengths, review cadence — affects Learning Loop and `references/outcomes.md` triggers
- **format** — estimate units, plan verbosity, language of plan docs — affects Plan Format output
- **approval** — task types the user wants to see planned regardless of size, preferred validation question style — affects `references/approval.md` conduct
- **scope** — domains where the user prefers one-shot execution (bias one level down, irreversibility floor stays) — affects per-type depth defaults

## Traps

| Trap | Why it fails | Do instead |
|------|--------------|------------|
| Planning as procrastination: detailing steps past the first unknown | That detail is speculation; you will rewrite it after the unknown resolves | Steps to the first validation, milestones beyond |
| Steps written as activities ("investigate X") | No observable output means no done-check; plans drift silently | Every step names the artifact or check that proves completion (`references/decomposition.md`) |
| Uniform depth for every task | L4 on trivial work trains the human to skim-approve; L1 on novel work ships failures | Depth table + learned per-type defaults |
| Sticking to a plan reality has contradicted | A plan is a forecast, not a commitment; adherence becomes sunk cost | 2-consecutive-deviation replan trigger (`references/replanning.md`) |
| Point estimates | Read as commitments and hide uncertainty | Range with a named high-end driver; ratio >3x → spike first |
| Per-step buffers | Silently consumed; they hide the true range | One plan-level range — the low-high gap IS the buffer (`references/estimation.md`) |
| Skipping the unwritten steps: rollback, restore-verify, post-change verification, comms | Plans fail disproportionately on steps that were omitted | Hidden-steps checklist at plan time (`references/decomposition.md`) |
| Executing beyond approved scope without saying so | Approval covers the written plan only; burned trust raises validation on everything after | Announce deviations at the deviation; re-approve at L3+ (`references/approval.md`) |
| Treating silence as approval | An unread validation request protects nobody | Reversible prep only; halt before an irreversible boundary on silence (`references/approval.md`) |
| Resuming a stale plan blindly | The world moved: dependencies, backups, assumptions | Resume protocol; re-validate past `stale_after_days` (`references/long-horizon.md`) |
| Logging only failures | Success streaks are what earn auto-execute; unlogged successes mean validating forever | Log every L2+ outcome, success included |

## Where Experts Disagree

- **The plan document vs the planning act.** "Plans are worthless, planning is everything" (Eisenhower) is half right: the act is always worth it; the artifact pays only at boundaries — human validation, multi-session resume, handoff. Solo reversible work → think and execute directly; anything crossing a boundary → write.
- **Estimate in time vs relative size.** Relative sizing (points) pays only with a stable velocity to convert it — a team asset. An agent's equivalent is the per-type calibration multiplier from its own outcome log; with that log, time ranges are strictly more informative.
- **Upfront depth vs iterate-and-see.** Iterate when feedback is cheap and steps are reversible; plan upfront when feedback is expensive or steps are irreversible. The depth table IS that frontier — the disagreement dissolves once irreversibility is priced.
