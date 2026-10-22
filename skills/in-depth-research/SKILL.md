---
name: in-depth-research
description: >
  Conduct exhaustive multi-source investigation with documented methodology,
  source evaluation, iterative depth, and explicit halt criteria. Use when a
  question needs structured deep research rather than a quick lookup, when claims
  must be triangulated across independent sources, or when the user asks for
  methodology, confidence, caveats, and gaps with the answer. Prefer `anysearch`
  for a quick search or URL extraction, and `synthesize` when the user already
  provides the documents to combine.
metadata:
  version: "1.1.1"
  openclaw: '{"emoji":"🔬"}'
  related-skills: '{"anysearch":"Quick web or vertical search and URL extraction instead of a full investigation.","synthesize":"Combine user-provided documents instead of sourcing the outside world."}'
---

## Core Role

Deep research means investigate thoroughly until the question is answered: systematic exploration with a documented methodology, not surface search.

Primary outcome: a direct answer plus confidence, key findings with sources, caveats, gaps, and a short methodology note.

## Protocol

```
Scope → Search → Evaluate → Deepen → Synthesize → Document → Deliver
```

### 1. Scope

Before searching, clarify:

- What exactly needs answering?
- What depth is required? (Quick / Standard / Thorough / Exhaustive)
- What decision does this enable?
- Time and effort budget?

Reframe vague questions into specific, answerable queries. Confirm depth before spending the budget.

### 2. Search

Multi-vector approach (see `references/methodology.md`):

- Start broad, then narrow
- Use multiple search engines and source types
- Follow citation trails
- Check primary sources when secondary sources cite them
- Look for contradicting viewpoints

Track every source. Leave nothing unattributed.

### 3. Evaluate

For each source (see `references/sources.md`):

- Authority: who wrote this, and with what credentials?
- Recency: when was it published, and is it still valid?
- Evidence: are claims backed by data or method?
- Bias: agenda, funding, or conflict of interest?
- Corroboration: do independent sources confirm it?

Flag low-credibility sources and weight findings accordingly. Prefer Tier 1–2 evidence for load-bearing claims.

### 4. Deepen

Research is iterative:

- Initial findings reveal new questions
- Follow promising threads
- Fill identified gaps
- Halt when the answer is clear enough for the decision, returns diminish, or the budget is exhausted

Document the decision to halt and why. “More research is possible” is always true — note what further work would buy.

### 5. Synthesize

Merge findings (hand off to `synthesize` patterns when reconciling many documents):

- Reconcile contradictions explicitly
- Weight by source quality and independence
- Note confidence levels
- Identify remaining unknowns

### 6. Document

Keep a research trail:

- Sources consulted (with links)
- Search queries used
- Why certain sources were weighted higher
- What was missing or omitted (gaps)

### 7. Deliver

Format per user needs (see `references/output-formats.md`):

- Executive: BLUF + key findings + confidence
- Academic: full methodology + citations
- Working doc: all findings for further work
- Quick answer: only when depth is not required

## Output Format (Default)

```
🔬 DEEP RESEARCH: [Topic]

⚡ ANSWER
[Direct answer to the question — 2-3 sentences]

📊 CONFIDENCE: [High/Medium/Low] — [why]

🔍 KEY FINDINGS
• [Finding 1] — [source]
• [Finding 2] — [source]
• [Finding 3] — [source]

⚠️ CAVEATS
• [Important limitation or uncertainty]

🕳️ GAPS
• [What could not be determined]

📚 SOURCES ([count])
[Numbered list with credibility notes]

🔎 METHODOLOGY
[Brief: what was searched, how sources were evaluated, why research halted]
```

## Depth Levels

| Level | Effort | Sources | When |
|-------|--------|---------|------|
| Quick | 5-10 min | 3-5 | Simple factual questions |
| Standard | 30-60 min | 8-15 | Most research requests |
| Thorough | 2-4 hours | 20-30 | Important decisions |
| Exhaustive | Days | 50+ | Critical, high-stakes |

Confirm depth before starting. Adjust if findings warrant a different level.

## Hard Constraints

- Do not present a single uncorroborated secondary source as settled fact for a load-bearing claim.
- Do not hide contradictions; surface them under caveats or a dedicated contradictions section.
- Do not invent URLs, quotes, dates, statistics, or study results. If evidence is missing, say so under Gaps.
- Prefer primary or expert-tier sources for medical, legal, financial, and safety-critical claims; mark news-only coverage as provisional.

---

*References: `references/methodology.md`, `references/sources.md`, `references/output-formats.md`*
