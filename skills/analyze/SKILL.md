---
name: analyze
description: Analyze data, code, text, decisions, or visuals using structured frameworks. Use when the user wants to prioritize, question assumptions, or form conclusions.
metadata:
  version: "1.0.0"
  openclaw: '{"emoji":"🧩"}'
---

## 1. Setup

State what decision the analysis serves. Pick a framework. Record the first impression to challenge later.
Proceed once the purpose, framework, and unknowns are recorded.

- **Purpose in one line**: "This analysis helps decide ___"
- **What's missing**: 3+ unknowns that would change conclusions
- **First impression**: Write it — then seek counter-evidence

## Failure Recovery

- If the selected framework does not yield clear priorities, switch to an alternative framework (for example, from MECE to Pre-mortem).
- If key data sources cannot be verified, mark the analysis as low confidence and identify the data validation needed before acting.

## 2. Execution

- **Prioritize always**: 🔴 Critical (1-2 max) · 🟡 Important (2-3) · ⚪ Minor
- **Mark sources**: Every claim gets `[from input]` or `[inferred]`
- **Seek disconfirmation**: Dedicate space to "why I might be wrong"
- **Distinguish**: Facts vs opinions. Correlation vs causation.

## 3. Synthesis

- **One-line summary**: Force analysis into one sentence
- **So what?**: End with action, not summary
- **Obviousness test**: Would someone say this without reading? → Deeper

## Quality Controls

- **Depth**: Produce deep analysis rather than simple paraphrasing.
- **Prioritization**: Ensure clear distinction between critical and minor items.
- **Objectivity**: Challenge the first impression to ensure it does not become the conclusion.
- **Context**: Provide complete denominators (for example, "500 cancellations out of 50,000 total").
- **Verification**: Verify and cite sources for all data.

## By Domain

| Domain | Focus | Watch |
|--------|-------|-------|
| Data | Grain, missing, outliers | Centinels, mixed types |
| Code | Production breaks, dead code | Style ≠ bugs |
| Text | Thesis, evidence strength | Unsourced claims |
| Decisions | Unlisted options, reversibility | Status quo bias |
| Visual | Dominance, consistency | Platform conventions |

## Frameworks

Pick one before starting:

- **MECE**: Mutually exclusive, collectively exhaustive. Ensure all categories are disjoint and cover the entire possible scope of the problem.
- **Pros/Cons+**: Add reversibility + cost of inaction
- **Pre-mortem**: Assume the project or strategy has already failed spectacularly in the near future, then work backward to determine what led to this failure. Helps counter overconfidence and groupthink.
- **Steel man**: Address the strongest form of an opponent's argument (or the strongest counter-argument to a thesis), even if it was not presented, by applying the principle of charity. Doing so tests the true robustness of the position.

## Output

```
🎯 PURPOSE: Decide [X]
🔴 CRITICAL: [Finding + source]
🟡 IMPORTANT: [Findings]
⚠️ COUNTER: [Contradictions]
➡️ ACTION: [Recommendation]
```
