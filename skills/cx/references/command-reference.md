# cx Command Reference

## Navigation Commands

```bash
cx overview PATH                    # File structure or directory summary
cx overview DIR --full              # Include kinds, ranges, and signatures
cx symbols [--kind K] [--name GLOB] [--file PATH]
cx symbols --kinds [--file PATH]   # Available symbol kinds with counts
cx definition --name NAME [--from PATH] [--kind K] [--max-lines N]
cx references --name NAME [--file PATH] [--context]
```

Short aliases: `cx o`, `cx s`, `cx d`, and `cx r`.

## Shared Options

```bash
--root PATH      # Project root; defaults to the git root
--json           # Emit JSON instead of TOON
--no-tests       # Exclude test files and symbols
--limit N        # Override the command result limit
--offset N       # Skip results for pagination
--all            # Bypass the default limit
```

Default limits are unlimited for `overview`, 3 for `definition`, 100 for
`symbols`, and 50 for `references`. Prefer narrowing with `--from`, `--file`,
or `--kind` before paging or using `--all`.

When limited, JSON output uses `{total, offset, limit, results}`. Otherwise it
returns a bare array. Default TOON output is compact and line-based; line numbers
are 1-indexed and paths are relative to the project root.

## Symbols, Grammars, and Cache

Symbol kinds include `fn`, `struct`, `enum`, `trait`, `type`, `const`, `class`,
`interface`, `module`, `event`, `field`, and `heading`. Methods are represented
as `fn`.

```bash
cx lang list
cx lang add rust typescript python go swift
cx cache path
cx cache clean
```

Set `CX_CACHE_DIR` to override the index and grammar cache location.
