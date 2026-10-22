# cx Decision Tree

Use this guide when choosing between cx, a text search, or reading a full file.

```
START: Need to understand code/docs?
│
├─ YES → Is it a supported language? (Rust/TS/Python/Go/C/ObjC/C++/Java/Ruby/Lua/Zig/Bash/Solidity/Dart/Elixir/Swift/Markdown)
│   │
│   ├─ NO → Use `read` tool directly (for .yaml, .json, .toml, binary files, etc.)
│   │
│   └─ YES → What is the goal?
│       │
│       ├─ Understand file or directory structure → `cx overview <path> [--full]`
│       │   └─ Need specific symbol/section? → `cx definition --name <X>`
│       │
│       ├─ Find symbol across project → `cx symbols [--kind K] [--name GLOB] [--kinds]`
│       │   └─ Found it? → `cx definition --name <X> --from <file>`
│       │
│       ├─ Before editing/refactoring → `cx references --name <X> [--context]`
│       │   └─ See impact? → Proceed with edit
│       │
│       └─ After context compression → `cx overview <path>` to re-orient
│
└─ NO → Is the target a text pattern, configuration value, or non-symbol region?
    │
    ├─ YES → Use `rg` for scoped text search, then read the needed file section
    │
    └─ NO → Read the required file context directly
```

## Quick Lookup Table

| Your Situation                 | First Command                               | Next Step                              |
| ------------------------------ | ------------------------------------------- | -------------------------------------- |
| "What's in this file or dir?"  | `cx overview file.rs` or `cx overview dir/` | `cx definition --name <X>`             |
| "Where is X defined?"          | `cx symbols --name "*X*"`                   | `cx definition --name X --from <file>` |
| "Who calls X?"                 | `cx references --name X --context`          | Read exact reference line context      |
| "How does this module work?"   | `cx symbols --file module.py`               | `cx definition` for key functions      |
| "What kinds of symbols exist?" | `cx symbols --kinds`                        | `cx symbols --kind <K>`                |
| "What's in this Markdown doc?" | `cx overview README.md`                     | `cx definition --name "Section Title"` |

## Common Pitfalls

| Avoid                             | Prefer                          | Reason                                |
| --------------------------------- | ------------------------------- | ------------------------------------- |
| `cx overview config.yaml`         | Read the config file            | cx does not parse YAML, JSON, or TOML |
| `cx definition --name main`       | Add `--from src/app.rs`         | Common names need disambiguation      |
| Reading before checking structure | `cx overview file.rs` first     | Avoids unnecessary full-file context  |
| Exact `cx symbols --name handler` | `cx symbols --name "*handler*"` | Discovery uses glob patterns          |
| Ignoring missing grammars         | `cx lang add <language>`        | cx cannot index without the grammar   |

## Workflow Examples

### Understand a New Codebase

```bash
cx overview .
cx symbols --kind fn
cx definition --name main --from src/main.rs
cx references --name main --context
```

### Refactor a Named Symbol

```bash
cx references --name old_function_name --context
cx definition --name old_function_name
```

Read or edit only after the definition and relevant call sites are understood.

### Navigate Markdown Documentation

```bash
cx overview README.md
cx definition --name "Installation" --from README.md
```

## Error Recovery Flow

```
cx command fails
│
├─ "unsupported file type" → File is .yaml/.json/.toml → Use `read`
│
├─ "database locked" → See `cx skill references setup-and-recovery`
│
├─ "file not in index" → File outside git root? → Pass `--root <path>` or use `read`
│
├─ "symbol not found" → Try glob: `cx symbols --name "*partial*"`
│
└─ "missing grammar" → See `cx skill references setup-and-recovery`
```
