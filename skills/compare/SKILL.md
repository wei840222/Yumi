---
name: compare
description: >
  Run rigorous multi-option comparisons with weighted criteria, research-parity
  checks, confidence levels, and preference memory. Use when the user asks which
  option is better, wants a side-by-side score, trade-off analysis, or a
  decision between products, software, services, locations, people, investments,
  or content. Decline when research cannot be balanced or priorities stay unknown.
metadata:
  version: "1.0.1"
  openclaw: '{"emoji":"⚖️"}'
  related-skills: '{"decide":"Log decision outcomes and patterns after a comparison leads to a choice.","memory":"Stores durable user facts that may inform comparison preferences beyond compare-local state."}'
compatibility: '*'
---

## State location

Compare preference state may exist in `<workspace>/compare/`, `<workspace>/memory/compare/`, or `~/compare/`.
Resolve `<state_root>` before the first preference read or write:

1. Use an explicit user/host-configured path if supplied; resolve it to an actual absolute directory.
2. Otherwise select the first existing directory in this order:
   `<workspace>/compare/`, `<workspace>/memory/compare/`, `~/compare/`.
3. If multiple candidates exist, use only the highest-precedence directory, report the conflict, and leave the others unchanged.
4. If none exists and the user authorizes preference persistence, create `<workspace>/compare/` by default.
5. `<workspace>` comes from the host/runtime, not the shell current directory. If it is unavailable, an existing `~/compare/` may be read; otherwise request an explicit root before creation.
6. Keep the selected root fixed for this invocation. Preference state belongs outside the skill package and version-controlled paths.

Use `<state_root>/preferences.md` for learned criterion priorities. Create that file only after the first authorized preference write. Load `assets/preferences-template.md` when initializing the file. Do not treat the literal string `<state_root>` as a filesystem path.

## Ordered workflow

Execute these steps in order for every comparison:

1. **Classify the request** — multi-option "which is better / trade-off / scorecard" → continue here; after a choice is made and should be remembered as a decision pattern → hand off logging to `decide`; durable free-form facts about the user → `memory`.
2. **Capture options and constraints** — name the options, decision deadline, hard constraints (budget, platform, must-haves), and any explicit "X matters more" signals.
3. **Resolve state** — bind `<state_root>`; load `<state_root>/preferences.md` when it exists; report conflicts.
4. **Build criteria** — load `references/domains.md` defaults for the matching domain; overlay preferences and explicit user weights; ask "What matters most here?" only when priorities are still unknown. Emit ranked criteria whose weights sum to 100%.
5. **Research with parity** — research each option to equivalent depth **before** scoring. Track `| Criterion | Option A sources | Option B sources | … |`. If one side has deeper coverage, research the lagging side first. Load `references/protocol.md` for the full procedure and `references/confidence.md` for confidence labels.
6. **Confidence gate** — verify equal research depth, equal criterion coverage, comparable source quality, and comparable data recency. On any failure: research more **or** caveat explicitly. Do not present a clean winner over unbalanced data.
7. **Score** — use whole-number criterion scores (0–10). Compute `Final = Σ(criterion_score × weight)`. Show the math. Prefer whole numbers; treat 7.2 vs 7.3 as noise rather than signal.
8. **Present** — use the card format in `references/protocol.md` (criteria, scores with confidence, winner + margin, caveats, "if X matters more" alternate). Lead with uncertainty when confidence is Low/Caveat.
9. **Update preferences (authorized)** — after the user confirms useful criteria, append or revise the matching category line in `<state_root>/preferences.md`. Skip writes without consent or when no durable signal appeared.
10. **Decline path** — if research parity is impossible, priorities stay unclear, or time is insufficient, return a partial comparison with explicit gaps rather than a misleading ranking. Load `references/traps.md` when checking for anchoring, unequal effort, halo effect, or buried caveats.

## Failure branches

| Condition | Action |
|-----------|--------|
| Priorities unknown after one clarifying question | Stop ranking; ask only for the top 1–2 must-haves |
| One option lacks comparable sources | Research more or mark that criterion Low/Caveat; never invent data |
| Hard constraint eliminates all but one option | Report constraint win; skip fake multi-criteria drama |
| User wants absolute certainty on sparse data | State confidence limit; offer deeper research scope before deciding |
| Preference file missing or unreadable | Continue with domain defaults; create template only after write consent |
| Multiple state roots detected | Use highest-precedence only; report siblings; do not merge |

## Core principle

A comparison is only as reliable as its weakest-researched dimension. Uneven confidence invalidates the ranking. Keep always-on guidance here; load references only for the active step.

## Resources

| Path | Load when |
|------|-----------|
| `references/protocol.md` | Running the full criteria → parity → score → present loop |
| `references/domains.md` | Selecting default weights by domain |
| `references/confidence.md` | Labeling High/Medium/Low/Caveat per criterion |
| `references/traps.md` | Self-checking research, scoring, and presentation mistakes |
| `assets/preferences-template.md` | Initializing `<state_root>/preferences.md` |
