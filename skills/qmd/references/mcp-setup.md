# QMD MCP Server Setup

## Install and prepare collections

Perform installation, indexing, or server startup only when the user requests
setup. Node.js >=24.21.0 is required. BM25 and document reads need no model settings:

```bash
pnpm add -g @wei840222/qmd
qmd collection add ~/path/to/markdown --name myknowledge
qmd search "keyword phrases" -c myknowledge
```

For semantic search, first configure remote models as described in
[SKILL.md](../SKILL.md#models--remote-endpoint-configuration). Embedding builds
send document content, expansion sends queries/context, and reranking sends
candidate passages to the chosen providers. Run `qmd embed` only after that use
is authorized. Old local-model indexes remain readable lexically; conversion to
remote vectors requires an explicitly requested `qmd embed --force`, which clears
and rebuilds vectors. No local model, GPU setup, download, or `qmd pull` is needed.

## Configure MCP Client

Add QMD to your MCP client configuration (e.g. Cursor, Claude Desktop, Zed, OpenClaw, or other MCP-compatible clients):

```json
{
  "mcpServers": {
    "qmd": {
      "command": "qmd",
      "args": ["mcp"]
    }
  }
}
```

The MCP process must read the intended QMD configuration and inherit the required
embedding credentials (`OPENAI_API_KEY` or `VOYAGE_API_KEY`, depending on provider).
Use private client configuration or the launch environment; never commit keys.
Authenticated expansion and reranking use their own private QMD configuration
fields, `models.generate_api_key` and `models.rerank_api_key`.

## Protocol

QMD speaks MCP **2026-07-28** (SDK 2.x) and dual-speaks 2025-era stdio clients.

- **stdio** (`qmd mcp`): hosts still launch this as a subprocess. Opening
  `initialize` (2025) or a `_meta`-enveloped request / `server/discover`
  (2026) pins the connection's era.
- **HTTP** (`qmd mcp --http`): sessionless Streamable HTTP. No
  `Mcp-Session-Id`, no handshake. Each POST is independent. 2026 clients
  MUST send `MCP-Protocol-Version`, `Mcp-Method`, and (for `tools/call`)
  `Mcp-Name`. Version/caps travel in `_meta`. Call `server/discover` to
  learn supported versions and capabilities. `tools/list` is cacheable
  (`ttlMs` / `cacheScope`) and returns tools in a stable order.

## HTTP Mode

```bash
qmd mcp --http              # Port 8181
qmd mcp --http --daemon     # Background
qmd mcp stop                # Stop daemon
```

`POST /mcp` is the MCP endpoint (JSON). `GET /health` is a liveness check.
There is no session GET stream and no idle-session TTL.

## Tools

### query

Use either a plain `query` with an expansion policy, or caller-authored
`searches`. Do not supply both. For model-free lexical retrieval:

```json
{
  "searches": [{ "type": "lex", "query": "keyword phrases" }],
  "collections": ["myknowledge"],
  "limit": 10,
  "rerank": false
}
```

With remote embedding and reranking configured and a compatible vector index:

```json
{
  "searches": [
    { "type": "lex", "query": "keyword phrases" },
    { "type": "vec", "query": "natural language question" },
    { "type": "hyde", "query": "hypothetical answer passage..." }
  ],
  "limit": 10,
  "collections": ["myknowledge"],
  "minScore": 0.0
}
```

| Type | Method | Input |
|------|--------|-------|
| `lex` | BM25 | Keywords (2-5 terms) |
| `vec` | Vector | Question |
| `hyde` | Vector | Answer passage (50-100 words) |

Reranking defaults to enabled, including for typed lexical searches. Set
`rerank: false` to disable that remote stage. `expansion: "skip"` only skips
expansion; a plain query may still embed against an existing vector index.

### get

Retrieve document by path or `#docid`.

| Param | Type | Description |
|-------|------|-------------|
| `file` | string | Path or `#docid`; supports `:from:count` suffixes |
| `fromLine` | number? | First line, 1-indexed; overrides suffix start |
| `maxLines` | number? | Maximum lines; overrides suffix count |
| `lineNumbers` | bool? | Add line numbers (default true) |

### multi_get

Retrieve multiple documents.

| Param | Type | Description |
|-------|------|-------------|
| `pattern` | string | Glob or comma-separated list |
| `maxLines` | number? | Maximum lines per file |
| `maxBytes` | number? | Skip large files (default 64KB) |
| `lineNumbers` | bool? | Add line numbers (default true) |

### status

Index health and collections. No params.

## Troubleshooting

- **Not starting**: Check `command -v qmd`, Node version, and the MCP process's
  environment/config access. Start `qmd mcp` manually only as part of requested setup.
- **No lexical results**: Check `qmd collection list`, collection filters, and query
  terms. An embedding build does not repair missing lexical documents.
- **Remote model/configuration error**: Run `qmd doctor`. Missing credentials,
  endpoints, or matching vectors require explicit configuration or maintenance;
  use a lexical-only request rather than downloading models or silently rebuilding.
- **Slow search**: Compare a lexical-only request with the model-backed request.
  Inspect remote provider latency and index diagnostics; this build never loads
  a multi-GB local inference model.
