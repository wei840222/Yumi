# Confidence Levels

Use when reporting scores in comparisons.

| Level | Definition | When to use |
|-------|------------|-------------|
| **High** | 3+ quality sources, consistent findings, recent data | Strong basis for scoring |
| **Medium** | 1–2 sources or minor inconsistencies | Reasonable but not definitive |
| **Low** | Single source, outdated, or conflicting data | Caveat the score |
| **Caveat** | Significant imbalance between options | State explicitly in output |

## Applying confidence

Show confidence per criterion:

```text
| Criterion | Item A | Item B | Confidence |
|-----------|--------|--------|------------|
| Price     | 8      | 6      | High       |
| Quality   | 7      | 8      | Medium     |
| Support   | 5      | 7      | Low ⚠️     |
```

When confidence is Low or Caveat:

- Lead with the issue in ⚠️ CAVEATS (do not bury it)
- State what additional research would raise confidence
- Offer to investigate further before the user decides
- Prefer a partial answer over a false-precision ranking
