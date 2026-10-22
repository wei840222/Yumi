---
name: "codegraph"
description: "Analyze any source-code project through its pre-built local code graph: index it, then answer graph-first codebase questions — symbol source + call paths, callers/callees, change impact, affected tests, file inventory. Use when asked how a codebase works, who calls a symbol, what a change would break, or which tests cover a change."
metadata:
  openclaw:
    emoji: "🕸️"
---

# CodeGraph — Graph-First Codebase Analysis

Answer codebase questions from a pre-built local code graph instead of a grep+read crawl. CodeGraph parses a project with tree-sitter, stores symbols/edges/files in SQLite with FTS5, and returns the verbatim source an agent needs in one call.

## Graph-first doctrine

Start with `explore`: when it finds the relevant symbols, it returns their verbatim, line-numbered source plus call paths — a completed Read, not a search result.

- Treat `explore` output as the read source itself: it is byte-for-byte the on-disk file, identical to a Read call. Using it directly is the point of the tool.
- For flow questions, name the symbols spanning the flow: `codegraph explore 'mutateElement renderScene'` surfaces the call path among them, riding dynamic-dispatch hops grep cannot follow.
- After edits, if a response opens with a `⚠️ Some files referenced below were edited since the last index sync` banner, Read only the listed files; everything unlisted is fresh.

## Indexing

CodeGraph is per-project and index-driven. The graph lives in `<repo>/.codegraph/`.

- Before querying, confirm the project is indexed with `codegraph status`.
- An unindexed project: stop calling codegraph for it this session and fall back to built-in Read/Grep. Indexing is the caller's decision — mention `codegraph init` exists, run it only when authorized.
- `codegraph init` in the project root builds `.codegraph/` and the graph in one step. It respects `.gitignore` and default-excluded dirs (`node_modules`, `dist`, `vendor`, ...); files over 1 MB are skipped.

### 🔴 STOP — index-changing commands

`init`, `index`, `sync`, `uninit`, and `unlock` modify `.codegraph/` or remove its lock. Do not run them without explicit authorization. `uninit` is destructive; never use it merely to recover from a query failure. If the graph is missing, stale, locked, or unhealthy and authorization is absent, fall back to built-in Read/Grep and state the limit.

## Workflow

### Step 1 — Confirm codegraph

```
codegraph --version
```

If codegraph is absent and installing it is authorized, follow the install section in `references/cli-reference.md` (standalone bundle or npm; Node >=20 <25; new shell needed after bundle install).

**Done when:** a version string prints.

### Step 2 — Check the index

```
codegraph status <repo>
```

`status` takes a positional path, not `--path` (only `explore`/`query`/`node`/`files`/`callers`/`callees`/`impact`/`affected` use `-p/--path`). Running it inside the repo also works.

**Done when:** you know whether the project is indexed and the backend is healthy.

### Step 3 — Establish the graph

🔴 **STOP:** If the index is absent, request authorization before `codegraph init <repo>`, then re-run status. Without authorization, fall back to built-in tools and state the limit.

**Done when:** `codegraph status` reports the graph initialized with sane counts — or you have a fallback in hand.

### Step 4 — One-shot explore

```
codegraph explore --path <repo> '<question or symbol bag>'
```

Ask the whole question first. A bag of symbol names works better for flows than broad natural language.

**Done when:** you have the relevant source and call paths for the question — or an explicit unindexed/empty signal telling you to fall back or narrow.

### If `explore` misses

Treat an empty result, mostly unrelated symbols, or a result that omits the requested path/symbol as a miss. Do not repeat the same broad natural-language query.

1. Locate the target with `codegraph query --path <repo> --kind function <symbol>`. Record its `filePath`, `startLine`, and `endLine`.
2. Read the exact source with `codegraph node --path <repo> --file <filePath> --offset <startLine> --limit <lineCount>`, where `lineCount = endLine - startLine + 1`.
3. Trace relationships with `callers`, `callees`, or `impact` for the selected symbol.
4. If a precise query is still empty, fall back to built-in Read/Grep and say that the graph could not establish the answer.

### Step 5 — Narrow

Only when explore left ground uncovered: `query` for symbol lookup (kind/path/name fields), `node` to read one symbol or file, `callers`/`callees` for one-hop relationships, `impact` for change radius, `affected` for a complete test-file backstop, `files` for tree inventory. Prefer `--json` for scriptable output.

For focused test selection, begin with `callers` and symbol-level `impact`; use `affected` last to catch omissions. `affected` is file-level and unranked, so do not choose a focused test run from it alone.

**Done when:** every symbol, call path, and affected test the question needs is accounted for.

### Step 6 — Answer from the graph

Answer directly from what codegraph returned, citing path anchors. Results come from a full AST parse — the graph outranks recall.

**Done when:** every material claim in the answer traces to returned source with a path anchor.

## Reference

Full flag table, query syntax, env vars, ignore rules, language support, install, and performance caveats: `references/cli-reference.md`.

## Do not

- Do not install, initialize, rebuild, sync, unlock, or remove an index without explicit authorization.
- Do not treat a successful but unrelated `explore` result as evidence for the question.
- Do not claim test-case-level coverage from `affected`; it reports affected files, not individual tests.
