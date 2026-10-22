# Complete Usage Inventory

`cx references` reports semantic symbol references. It does not enumerate binary
entrypoints, manifests, documentation, tests, or plain-text path mentions.

When the request asks for all usages, entrypoints, or integration impact:

1. Run `cx references --name <name> --context` for semantic call sites.
2. Classify the target: library symbol, binary entrypoint, configuration value, or file path.
3. Search relevant non-symbol surfaces with `rg`, scoped to known files or directories and excluding generated output.
4. Report semantic references, runtime or manifest entrypoints, and documentation, test, or plain-text mentions separately.

Do not report a text match as a call site. If the repository has no relevant
manifest, documentation, or test paths, say so explicitly instead of broadening
the search to unrelated parent directories.

```bash
# Rust binary entrypoints and file-path mentions
rg -n --glob '!target/**' 'src/main\.rs|\[\[bin\]\]' Cargo.toml README.md docs tests

# Generic documentation and test mentions for a symbol
rg -n --glob '!node_modules/**' --glob '!vendor/**' '\bNAME\b' README.md docs tests
```
