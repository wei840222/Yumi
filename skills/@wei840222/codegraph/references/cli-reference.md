# CodeGraph CLI Reference

## Command surface (`codegraph --help`, 1.4.1)

```bash
codegraph init [options] [path]          # Create .codegraph/ + build initial index (one step)
codegraph uninit [options] [path]        # Remove .codegraph/ (deletes the dir; --force skips prompt)
codegraph index [options] [path]         # Full rebuild from scratch (same result as fresh init; --force)
codegraph sync [options] [path]          # Incremental update since last index (safe; --quiet)
codegraph status [options] [path]        # Index status + statistics (--json)
codegraph query [options] <search>       # Symbol search across the codebase
codegraph explore [options] <query...>   # Relevant symbols' source + call paths in one shot
codegraph node [options] [name]          # One symbol's source + caller/callee trail, or read a file
codegraph files [options]                # Project file structure from the index
codegraph daemon|daemons                 # Manage background daemons (pick one to stop)
codegraph unlock [path]                  # Remove a stale lock file blocking indexing
codegraph callers [options] <symbol>     # All functions/methods that call a symbol
codegraph callees [options] <symbol>     # All functions/methods a symbol calls
codegraph impact [options] <symbol>      # What is affected by changing a symbol
codegraph affected [options] [files...]  # Test files affected by changed source files
codegraph install [options]              # Wire MCP server into agents (Claude Code, Cursor, Codex, opencode, Hermes)
codegraph uninstall [options]            # Remove agent wiring (+ CLI unless --keep-cli)
codegraph telemetry [status|on|off]      # Anonymous usage telemetry
codegraph upgrade [options] [version]    # Update to latest (or pinned) release
codegraph version                        # Print version (-v, --version)
```

## Flags per command (verified 1.4.1 `codegraph <cmd> --help`)

| Command | Flags |
|---|---|
| `init` | `-f, --force`, `-v, --verbose` |
| `uninit` | `-f, --force` |
| `index` | `-f, --force`, `-q, --quiet`, `-v, --verbose` |
| `sync` | `-q, --quiet` |
| `status` | `-j, --json` |
| `query` | `-p, --path <path>`, `-l, --limit <number>` (default 10), `-k, --kind <kind>`, `-j, --json` |
| `explore` | `-p, --path <path>`, `--max-files <number>` |
| `node` | `-p, --path <path>`, `-f, --file <file>`, `--offset <number>`, `--limit <number>`, `--symbols-only` |
| `files` | `-p, --path <path>`, `--filter <dir>`, `--pattern <glob>`, `--format <tree\|flat\|grouped>` (default tree), `--max-depth <number>`, `--no-metadata`, `-j, --json` |
| `callers` | `-p, --path <path>`, `-l, --limit <number>` (default 20), `-j, --json` |
| `callees` | `-p, --path <path>`, `-l, --limit <number>` (default 20), `-j, --json` |
| `impact` | `-p, --path <path>`, `-d, --depth <number>` (default 2), `-j, --json` |
| `affected` | `-p, --path <path>`, `--stdin`, `-d, --depth <number>` (default 5), `-f, --filter <glob>`, `-j, --json`, `-q, --quiet` |

All `--json` outputs are scriptable. `explore` and `node` accept multiple `<query...>` tokens — name the symbols spanning a flow and codegraph surfaces the call path between them.

## Query syntax

Field-qualified, case-insensitive, composable with free text (free text goes to FTS5):

```
kind:function name:auth path:src/api authenticate
```

Fields: `kind:` (NodeKind), `lang:`/`language:` (alias), `path:` (case-insensitive substring of file_path), `name:` (case-insensitive substring of node name). Quoted values allowed (`path:"my dir/file"`); unknown prefixes pass through to FTS. Parsing is forgiving, never throws.

NodeKind values: `file, module, class, struct, interface, trait, protocol, function, method, property, field, variable, constant, enum, enum_member, type_alias, namespace, parameter, import, export, route, component, union`.

## Environment variables

| Var | Effect |
|---|---|
| `CODEGRAPH_MCP_TOOLS` | Surface MCP tools (default is `explore` alone) |
| `CODEGRAPH_WATCH_DEBOUNCE_MS` | Auto-sync debounce, clamped [100ms, 60s], default 2000ms |
| `CODEGRAPH_NO_DAEMON` | Disable shared background server (WSL2 fix) |
| `CODEGRAPH_DIR` | Index dir name override (e.g. `.codegraph-win`) |
| `CODEGRAPH_ALLOW_UNSAFE_NODE` | Allow Node 25 (not recommended — crashes tree-sitter) |
| `CODEGRAPH_EXPLORE_DEDUP` | Cross-call dedup off switch |
| `CODEGRAPH_NO_REBIND` | Opt out of sync rebinding |
| `CODEGRAPH_TELEMETRY=0` / `DO_NOT_TRACK=1` | Telemetry off |

## Ignore rules (expectation-setting)

- Default-excluded dirs: `node_modules`, `dist`, `build`, `out`, `vendor`, `target`, `__pycache__`, `.venv`, `.next`, `.nuxt`, `.svelte-kit`, `.gradle`, `Pods`, `obj`, `coverage`, `.cache`, etc. Only a `.gitignore` negation opts back in.
- `MAX_FILE_SIZE = 1 MB` — larger files skipped.
- Android `res/` resource trees excluded by default.
- `codegraph.json` (per-project) can override: `extensions`, `includeIgnored`, `exclude`, `include` (gitignore-style).

## Language support

~36 languages via `EXTENSION_MAP` (`src/extraction/grammars.ts`). 20 run through a native Rust kernel; the rest use a portable engine; per-file fallback on unsupported platforms/parse errors. Objective-C is Partial (`.mm` may parse incompletely). Framework-aware routes: Django, Flask, FastAPI, Express, NestJS, Laravel, Drupal, Rails, Spring, Gin, Axum, ASP.NET, Vapor, React Router, SvelteKit, Vue/Nuxt, Cargo workspaces.

## Install

```bash
# Standalone bundle — no Node, no toolchain (recommended)
curl -fsSL https://raw.githubusercontent.com/colbymchenry/codegraph/main/install.sh | sh
# npm (requires Node >=20 <25)
npm i -g @colbymchenry/codegraph
```

Node 25 is hard-blocked (`CODEGRAPH_ALLOW_UNSAFE_NODE=1` overrides, not recommended). After bundle install, a new shell is needed for `codegraph` to be on PATH. Upgrades: `codegraph upgrade` (detect + update), `codegraph upgrade --check`.

## Performance caveats

- Fresh index of a 27k-file repo: ~100s (maintainer self-report, unverified).
- A one-file edit re-syncs in ~4s; saved file updates "in well under a second".
- `explore` output is dense and stays in context: maintainer measures ~80% more retrieval context resident than file-reading agents (67k vs 18k tokens on VS Code). Budget for long sessions in small windows.
