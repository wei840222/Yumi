# cx Output Examples

Real output samples from cx commands. Use these only when exact output shape matters.

## cx overview (Directory Overview)

```
[3]{file,symbol_count,symbols}:
  src/main.rs,3,"Cli, Commands, main"
  src/index.rs,5,"Index, FileData, Symbol, SymbolKind, cache_path_for"
  src/query.rs,4,"dir_overview, symbols, definition, references"
```

## cx overview (Markdown Headings)

```
[3]{name,kind,range,signature}:
  "cx — Semantic Code Navigation",heading,L6-L34,"# cx — Semantic Code Navigation"
  "First-run checks",heading,L35-L59,"## First-run checks (once per session)"
  "Common Recipes & Extra Info",heading,L60-L73,"## Common Recipes & Extra Info"
```

## cx symbols --kinds

```
[4]{kind,count}:
  fn,42
  struct,15
  enum,3
  heading,12
```

## cx symbols --json (Paginated vs Unlimited)

Unlimited (`--all` or unpaginated):

```json
[
  {
    "file": "src/main.rs",
    "name": "main",
    "kind": "fn",
    "signature": "fn main()"
  }
]
```

Paginated (`--limit` active):

```json
{
  "total": 32,
  "offset": 0,
  "limit": 1,
  "results": [
    {
      "file": "src/main.rs",
      "name": "main",
      "kind": "fn",
      "signature": "fn main()"
    }
  ]
}
```

## cx definition

```
file: src/main.rs
line: 154
---
fn main() {
    let config = tree_sitter_language_pack::PackConfig { ... };
    // ... function body
```

## cx references (with --context)

```
[2]{file,line,kind,context}:
  src/main.rs,180,call,"let idx = index::Index::load_or_build(&root);"
  src/main.rs,190,call,"let idx = index::Index::load_or_build(&root);"
```

## Output Format Notes

- Default format is **TOON** (compact, line-based)
- Use `--json` for machine-parseable JSON output
- Line numbers are 1-indexed
- File paths are relative to project root (git root)
