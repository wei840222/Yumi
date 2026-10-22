# Comparison Protocol

## 1. Criteria

- Load domain defaults (`references/domains.md`)
- Overlay user preferences from `<state_root>/preferences.md` when present
- If unknown after context signals: ask "What matters most here?"
- Output: ranked criteria with weights that sum to 100%
- Document any weight changes and why

## 2. Research Parity (Critical)

**Research each option to equivalent depth before scoring.**

Track a parity table:

```text
| Criterion | Option A sources | Option B sources | Balance |
|-----------|------------------|------------------|---------|
```

Rules:

- 5 reviews for A but 1 for B → research B first
- Do not score unbalanced rows
- Prefer primary or high-quality secondary sources over anonymous marketing copy
- Record source titles and full URLs in working notes (not necessarily in the user card)

## 3. Confidence Check

Before presenting, verify:

- Each option researched equally
- Each criterion researched equally
- Source quality comparable
- Data recency comparable

Fail any check → research more **or** caveat explicitly in the output.

## 4. Score

- Criterion scores: whole numbers 0–10
- `Final = Σ(criterion_score × weight)` with weights as fractions of 1.0 (or percent ÷ 100)
- Show the weighted math for the winner and runner-up
- Reject false precision (7.2 vs 7.3 is noise)

## 5. Present

```text
🆚 [A] vs [B]
📊 CRITERIA: [ranked by weight]
📈 SCORES: [table + confidence per row]
🎯 RESULT: [Winner] by [margin]
⚠️ CAVEATS: [imbalances / Low confidence rows]
💡 IF [X] MATTERS MORE: [alt winner]
```

Lead with caveats when any row is Low or Caveat. Offer the next research step when confidence blocks a safe decision.

## 6. After

- Note which criteria the user actually cared about
- With consent, update `<state_root>/preferences.md` by category using `assets/preferences-template.md` format
- Do not invent preference history

## Research notes (Gate 6)

Weighted multi-criteria scoring follows standard multi-attribute decision practice: define criteria and weights first, gather comparable evidence, then aggregate. Prefer whole-number criterion scores to avoid false precision. Research parity before scoring is the skill-specific control that keeps uneven source depth from silently deciding the winner.
