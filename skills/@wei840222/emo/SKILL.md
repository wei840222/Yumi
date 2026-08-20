---
name: emo
description: Analyze emoji usage, overall sentiment scores (-1.0 to +1.0), sentiment intensity, polarization index, emotional volatility, and progression arc using the `emo` CLI tool. Use this skill whenever you need to evaluate the emotional tone, emoji density, or multi-file sentiment benchmark for user input, chat logs, or text files.
---

# `emo` Emoji Sentiment Analyzer

`emo` is a zero-dependency, high-performance Rust CLI tool that analyzes text and text files for emoji usage, weighted sentiment scores, non-neutral intensity, emotional polarization, and timeline progression based on the research-backed *Emoji Sentiment Ranking 1.0* dataset.

## Installation

```bash
cargo install emoji-sentiment
```

## When to Use

Use the `emo` CLI when you need to:
1. **Analyze Text Sentiment**: Calculate quantitative weighted sentiment scores (`-1.0` to `+1.0`) and non-neutral intensity (`0.0` to `1.0`) for any text or file.
2. **Detect Emotional Polarization**: Evaluate whether text contains conflicting positive and negative emotions (`Polarization Index`: `0.0` to `1.0`).
3. **Track Sentiment Shift over Time/Paragraphs**: Track emotional trends (`Warming Up 📈`, `Cooling Down 📉`, `Fluctuating 🌊`) across 4-quarter timeline, paragraphs (`--by-paragraph`), or lines (`--by-line`).
4. **Multi-File Benchmark**: Compare sentiment metrics across multiple text files side-by-side.
5. **Extract Structured Data**: Produce formatted JSON (`--json`) for automated pipelines, agent decisions, or database storage.

---

## Command Usage Examples

### 1. Basic Text Sentiment Analysis (via stdin)

```bash
echo "Rust is awesome! 🎉🚀 But debugging can be tricky 😭" | emo
```

### 2. File or Directory Analysis

```bash
# Analyze a single file
emo path/to/document.txt

# Analyze an entire directory (recursively scans all text files and generates benchmark)
emo path/to/logs_directory/
```

### 3. Multi-File Benchmark Comparison

When given multiple files, `emo` automatically outputs a side-by-side comparative table before the aggregated summary:

```bash
emo log1.txt log2.txt log3.txt
```

### 4. Segmented Analysis (Paragraphs or Lines)

```bash
# Analyze sentiment arc paragraph by paragraph (\n\n)
emo --by-paragraph article.md

# Analyze sentiment arc line by line (\n)
emo --by-line chat_log.txt
```

### 5. Programmatic JSON Output (for Agents & Pipelines)

```bash
emo --json feedback.txt
```

### 6. Concise One-Line Summary Output

```bash
emo --summary comment.txt
```

---

## JSON Output Schema & Key Metrics

When running `emo --json`, the resulting JSON object contains the following key fields:

```json
{
  "total_chars": 84,
  "total_words": 15,
  "total_emojis": 5,
  "unique_emojis": 5,
  "matched_emojis_count": 5,
  "unmatched_emojis_count": 0,
  "overall_score": 0.345,
  "overall_intensity": 0.742,
  "positive_count": 3,
  "neutral_count": 0,
  "negative_count": 2,
  "density_per_1000_chars": 59.52,
  "density_per_100_words": 33.33,
  "style_level": "Heavy Emoji / Social",
  "entropy": 2.322,
  "diversity_ratio": 1.0,
  "polarization_index": 0.96,
  "polarization_status": "Highly Polarized 🔥❄️",
  "volatility_std_dev": 0.412,
  "volatility_status": "High Volatility / Emotional Swing 🌊",
  "ambiguity_index": 0.0,
  "ambiguity_status": "Direct & Explicit 🎯",
  "position_bias": {
    "avg_position": 0.45,
    "front_pct": 40.0,
    "mid_pct": 40.0,
    "end_pct": 20.0,
    "bias_status": "Balanced Placement"
  },
  "slang_analysis": {
    "total_slang_count": 3,
    "slang_density_per_100_words": 20.0,
    "sarcasm_index": 85.0,
    "sarcasm_status": "High Sarcasm / Irony Alert 🎭",
    "elongation_count": 1,
    "hybrid_score": 0.525,
    "top_slang": [
      {
        "term": "笑死",
        "count": 1,
        "sentiment_score": 0.8,
        "sarcasm_weight": 0.2,
        "meaning": "extremely funny"
      }
    ]
  },
  "block_stats": [
    {
      "block_name": "Emoticons",
      "count": 2,
      "percentage": 40.0,
      "avg_score": 0.292
    }
  ],
  "progression": {
    "segments": [
      {
        "label": "Q1 (Beginning)",
        "score": 0.709,
        "intensity": 0.799,
        "emoji_count": 2
      }
    ],
    "trend_status": "Cooling Down 📉 (Positive → Negative)"
  },
  "top_used": [
    {
      "emoji": "🎉",
      "name": "PARTY POPPER",
      "count": 1,
      "score": 0.74,
      "intensity": 0.816,
      "in_dataset": true
    }
  ]
}
```

---

## Score Range & Interpretation Guide

| Metric | Range | Interpretation |
| :--- | :--- | :--- |
| **`overall_score`** | `+0.5` to `+1.0` | **Very Positive** 😃 (Strongly optimistic, celebratory) |
| | `+0.05` to `+0.5` | **Positive** 😊 (Friendly, supportive, satisfied) |
| | `-0.05` to `+0.05` | **Neutral** 😐 (Factual, objective, balanced) |
| | `-0.5` to `-0.05` | **Negative** 🙁 (Frustrated, disappointed, concerned) |
| | `-1.0` to `-0.5` | **Very Negative** 😭 (Angry, severely distressed) |
| **`overall_intensity`** | `0.0` to `1.0` | **Emotional Non-Neutrality**. Measures how emotionally charged the text is regardless of positive/negative polarity. |
| **`polarization_index`** | `0.0` to `0.1` | **Harmonious / Unified** (Consistent sentiment direction) |
| | `0.7` to `1.0` | **Highly Polarized** 🔥❄️ (Contains strongly opposing positive and negative emotions simultaneously) |
| **`volatility_std_dev`** | `< 0.2` | **Monotone / Consistent** (Emotional tone remains steady throughout) |
| | `≥ 0.4` | **High Volatility / Emotional Swing** 🌊 (Large sentiment shifts between sentences/sections) |
| **`style_level`** | Categorical | `Text Only`, `Formal / Minimal`, `Casual`, `Expressive`, or `Heavy Emoji / Social` based on emoji density per 100 words. |

---

## Dataset References & Community Standards

While `emo` relies on **Emoji Sentiment Ranking 1.0** for compiled zero-dependency runtime evaluation, the following datasets are standard references in the NLP research community:

- **Emoji Sentiment Ranking 1.0** *(Built-in)*: 751 annotated emojis with polarity scores (`-1.0` to `+1.0`). (Novak et al., 2015)
- **TweetEval / SemEval-2018 Task 2**: Contextual emoji prediction benchmark across 20 classes. (Barbieri et al., 2018)
- **DeepMoji**: 1.2B Twitter corpus across 64 emoji labels for transfer learning and sarcasm detection. (Felbo et al., EMNLP 2017)
- **EmojiNet**: Multi-sense emoji knowledge base linking 2,300+ emojis to BabelNet synsets. (Knoesis Institute)
- **Google GoEmotions**: 58k Reddit comments across 27 fine-grained emotions mapped 1-to-1 to emojis. (Google Research, 2020)
- **Social Media Slang & Emoji Corpus**: ~14k UGC texts with slang, elongated words, and explicit sarcasm labels. (Kaggle)

