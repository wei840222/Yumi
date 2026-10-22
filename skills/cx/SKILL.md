---
name: cx
description: "Semantic code navigation with `cx` CLI. Use when you need to understand code structure before reading files, find symbol definitions, trace references before refactoring, or explore large codebases efficiently. Triggers: 'cx overview', 'cx symbols', 'cx definition', 'cx references', 'code structure', 'find function', 'where is X defined', 'who calls X', 'semantic navigation'."
---

# cx

Use `cx` for semantic code navigation before reading whole files. Start narrow and
only expand context when the task requires it.

## Core Workflow

Follow this escalation order:

1. `cx overview <path>` to understand a file or directory.
2. `cx symbols` to discover named symbols.
3. `cx definition` or `cx references` to inspect a symbol or its semantic usages.
4. Read a full file only when semantic navigation cannot answer the question.

Use `cx` before exploring code, editing a named symbol, refactoring, or resuming
work after context compression. For ambiguous names, find candidates with
`cx symbols --name "*partial*"`, then narrow `definition` with `--from`.

## Before Running cx

- Use supported source languages or Markdown; do not use cx for YAML, JSON, TOML,
  binary files, anonymous functions, dynamic dispatch, or non-symbol regions.
- Work inside a git repository, or provide `--root <path>`.
- Ensure the required language grammar is installed. Run `cx overview .` for a
  first-use probe; its missing-grammar output includes the install command.

cx is read-only. Use normal read and edit tools for changes or for full-file context.

## Optional References

Run `cx skill references` to list expanded guidance, then run
`cx skill references <name>` to print one reference on demand.
