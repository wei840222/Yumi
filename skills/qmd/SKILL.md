---
name: qmd
description: Search local markdown knowledge bases, notes, docs, and wikis with QMD. Use when users ask to find notes, retrieve documents, inspect a wiki, answer from indexed markdown, or set up QMD access.
license: MIT
compatibility: Requires Node.js >=24.21.0 and qmd CLI or MCP server. Model-backed operations require explicitly configured remote APIs.
metadata:
  author: wei840222
  version: "2026.10.19"
allowed-tools: Bash(qmd:*), mcp__qmd__*
---

# QMD - Query Markdown Documents

## How search works

QMD searches local markdown collections: notes, docs, wikis, transcripts, and
project knowledge bases. Use it before web search when the answer may already be
in indexed local files.

BM25, Chinese segmentation, AST chunking, document reads, collections, and
maintenance run locally without model settings. Local inference, model downloads,
GPU setup, and fine-tuning tools are retired. `qmd pull` exits nonzero and never
downloads models.

Start with `qmd search` when model configuration or permission to use a remote
provider is unknown. Semantic retrieval needs remote embeddings and a compatible
vector index; automatic expansion and enabled reranking need their own remote
settings. Expansion sends queries/context, embedding builds send document
content, and reranking sends candidate passages to the configured providers.
Do not enable providers or rebuild vectors merely to answer a search request.

The workflow is always:

1. Search for candidate documents.
2. Retrieve the full source with `qmd get` or `qmd multi-get`.
3. Answer from retrieved text, citing paths or docids.

Do not answer from snippets alone when the user needs facts, decisions, quotes,
or nuance. Snippets are only leads.

Typical loop:

```bash
qmd search "merchant reality support interviews" -n 5
# leads: #abc123 concepts/customer-proximity.md; #def432 sources/merchant-call.md
qmd multi-get "#abc123,#def432" --format md
```

When remote search is configured and appropriate, use structured `qmd query`
with exact lexical anchors and semantic paraphrases. Add `intent:` when the
request is ambiguous; typed fields bypass automatic expansion. See
[Pick the right search mode](#pick-the-right-search-mode).

When reporting what you retrieved, a compact note is enough; do not paste whole
files unless needed:

```text
Retrieved:
- #abc123 concepts/customer-proximity.md
- #def432 sources/merchant-call.md
```

## Pick the right search mode

Use **BM25 lexical search** when you know exact words, titles, names, code
symbols, or rare phrases:

```bash
qmd search "cockpit OKR Goodhart" -n 10
qmd search '"AI Before Headcount"' -c concepts -n 5
```

Use **`qmd query` with structured fields** when the user describes an idea
indirectly, uses different wording than the source, or needs conceptual recall.
Use this after confirming the required remote models and index are available.
Combine exact anchors with semantic recall:

```bash
qmd query $'intent: Find the concept note about metrics as instruments without letting OKRs replace judgment.\nlex: cockpit instruments OKR Goodhart metrics judgment\nvec: data informed not metric driven product judgment\nhyde: A concept note says metrics are useful like cockpit instruments, but leaders should remain data-informed rather than metric-driven because OKRs and dashboards can Goodhart product judgment.'
```

Structured query fields:

- `intent:` optionally states what you are trying to find **and what to avoid**.
  It steers ranking away from nearby-but-wrong concepts.
- `lex:` exact terms, aliases, titles, code symbols, and rare words you expect
  in the source. This is your own keyword expansion.
- `vec:` paraphrases the idea in natural language, in source-like wording.
- `hyde:` describes the document or answer that would satisfy the request.

Use only the fields that help the request. A plain `qmd query "..."` follows the
expansion policy; it may call remote expansion, embedding, and reranking services.
Typed `vec:` and `hyde:` queries require remote embeddings; typed `lex:` does
not. Reranking is enabled by default even for a lexical structured query.

For a single rare token or a verbatim phrase, prefer `qmd search`. To inspect
structured ranking, use `--explain`; for model-free structured lexical search,
also disable reranking:

```bash
qmd query --format json --explain $'intent: ...\nlex: ...\nvec: ...'  # inspect ranking
qmd query --no-rerank 'lex: authentication'                       # lexical only
```

If a required remote provider is missing or fails, QMD reports an error rather
than using a local model or silently dropping that stage. Use `qmd search` with
better lexical terms as an explicit alternative and disclose the narrower search.

## Retrieve sources

Search results include docids like `#abc123` and `qmd://...` paths. Fetch them:

```bash
qmd get "#abc123"
qmd get qmd://concepts/ai-before-headcount.md
qmd multi-get "#abc123,#def432" --format md
qmd multi-get 'concepts/{ai-before-headcount.md,data-informed-not-metric-driven.md}' --format md
qmd multi-get 'sources/podcast-2025-*.md' -l 80
```

Use `multi-get` when comparing several hits or gathering context across pages.

### Output is line-numbered and carries the docid — cite both

`get` and `multi-get` are **line-numbered by default** and always print the
document's `#docid` and `qmd://` path. So `get` output looks like:

```text
qmd://concepts/note.md  #abc123
---

1: # Metrics as instruments
2:
3: Treat dashboards like cockpit instruments...
```

Cite the docid and exact line numbers in your answer, and use the numbers to ask
for the next slice. Pass `--no-line-numbers` only when you need raw content to
copy verbatim (e.g. reproducing a code block).

When you need to open or edit the underlying file (e.g. hand a path to `Read`,
`Edit`, or an editor), add `--full-path`. It replaces the `qmd://` URL + docid
header with the document's on-disk path, falling back to the canonical header if
the file no longer exists on disk:

```text
$ qmd get "#abc123" --full-path
/Users/you/notes/concepts/note.md
---

1: # Metrics as instruments
```

`--full-path` works the same way on `qmd search` and `qmd query`: result paths
become the file's on-disk path — `./`-prefixed relative path when the file is
inside `$PWD`, absolute realpath otherwise — and the per-result `#docid` is
dropped because the path is the identifier. The leading `./` is intentional so
the output is unambiguously a filesystem path and cannot be mistaken for a bare
collection-relative string. Default search/query output still uses `qmd://`
URIs; only opt into `--full-path` when you specifically need a path you can hand
to a non-QMD tool.

### Read line ranges with the `:from:count` suffix — never pipe through `sed`/`head`/`tail`

`qmd get` slices files itself. Use the suffix or flags; do **not** shell out to
`sed -n`, `head`, `tail`, or `awk` to pull a line range. Piping defeats docid
resolution, virtual-path lookups, line numbering, and the header, and it is
slower and more error-prone.

The most compact form is a `:from:count` suffix right on the path or docid —
prefer it:

```bash
qmd get "#abc123:120:40"                  # 40 lines starting at line 120
qmd get qmd://concepts/note.md:200:60     # lines 200–259
qmd get "#abc123:120"                      # from line 120 to end of file
qmd get "#abc123" --from 120 -l 40         # equivalent, using flags
```

Suffix and flags:

- `<path>:<from>:<count>` — start at line `<from>`, read `<count>` lines. **Best
  for reading around a search hit.**
- `<path>:<from>` — start at `<from>`, read to end of file.
- `--from <line>` / `-l <lines>` — flag equivalents. Explicit flags override the
  suffix, so `... :5:2 -l 1` reads 1 line.
- `--no-line-numbers` — drop the `N:` prefixes (line numbers are on by default).

Wrong: `qmd get "#abc123" | sed -n '120,160p'`
Right: `qmd get "#abc123:120:40"`

Search results include a `:line` anchor on each hit — feed it straight into
`qmd get path:line:<n>` to read a window around the match (line numbers in the
output will start at `line`).

## Discover what is indexed

Run `qmd status`, `qmd collection list`, or `qmd ls` to inspect collections and
document counts. Use `qmd doctor` for remote configuration and index diagnostics:

```bash
qmd status            # collection overview, document counts, configured models
qmd collection list   # list registered collection paths
qmd ls                # list collection virtual paths
qmd doctor            # diagnose without model requests
```

Use collection filters (`-c <name>`) when the relevant collection is known:

```bash
qmd search "headcount autonomous agents" -c concepts -n 10
qmd query "merchant support product reality" -c concepts -c sources -n 10
```

Collection filters narrow the search scope. Latency still depends on the index,
query, and remote services; do not promise a fixed response time.

## Filter by metadata

Documents can carry typed metadata in a `qmd.metadata` frontmatter block (strings, numbers, booleans, or flat arrays). `search`, `vsearch`, and `query` accept `--filter` with a recursive JSON AST; every returned result satisfies it:

```bash
qmd search "authentication" --filter '{"key":"status","operator":"eq","value":"published"}'
qmd query "dependency injection" --filter '{"operator":"and","operands":[{"key":"topics","operator":"all","value":["typescript"]},{"key":"status","operator":"nin","value":["draft","archived"]}]}'
```

Nodes are discriminated by `operator`: groups `and`/`or` take `operands`, `not` takes one `operand`, and conditions take `key` + `value` with operators `eq`/`ne`/`gt`/`gte`/`lt`/`lte` (comparison), `in`/`nin`/`all` (membership), or `exists` (presence). Matching is typed and exact; missing keys do not match `ne`/`nin` (add an `exists: false` branch in an `or` group to include them). The MCP `query` tool accepts the same AST as a `filter` object. JSON output includes each result's `metadata`.

## MCP Tool: `query`

When using the MCP server, prefer structured searches:

For offline BM25, send only `lex` searches and explicitly set `rerank: false`:

```json
{
  "searches": [{ "type": "lex", "query": "cockpit OKR Goodhart" }],
  "collections": ["concepts"],
  "limit": 10,
  "rerank": false
}
```

When remote embeddings and reranking are configured, combine query types:

```json
{
  "searches": [
    { "type": "lex", "query": "cockpit OKR Goodhart" },
    {
      "type": "vec",
      "query": "data informed not metric driven product judgment"
    },
    {
      "type": "hyde",
      "query": "A concept note explains that metrics are useful as instruments, but leaders should not let OKRs or dashboards replace judgment."
    }
  ],
  "intent": "Find the concept note about using metrics as instruments without becoming metric-driven.",
  "collections": ["concepts"],
  "limit": 10
}
```

Query types:

- `lex` — BM25 keyword search. Best for exact terms, names, titles, and code.
- `vec` — vector semantic search. Best for natural-language concepts.
- `hyde` — vector search using a hypothetical answer/document passage.

## Query craft

Good QMD searches mix three things:

1. **Title/alias anchors:** exact page titles, named entities, phrases.
2. **Semantic paraphrase:** how a human would describe the idea.
3. **Negative space:** enough intent to avoid nearby-but-wrong concepts.

Examples:

```bash
# Exact-ish title lookup
qmd search '"arm the rebels" merchants tools big companies' -c concepts

# Semantic concept lookup
qmd query $'intent: Find the customer proximity concept, not generic customer delight.\nlex: support pseudonymous merchant customer interviews\nvec: founder stays close to merchant reality through support and product use'

# Source lookup
qmd search "six-week cadence WhatsApp merchant relationships Shawn Ryan" -c sources -n 10
```

For the complete EBNF grammar, search operators, and JSON payload specifications, see [Query Syntax Reference](references/query-syntax.md).

## Setup and maintenance

Only mutate indexes when the user asked for setup or maintenance. Searching and
retrieving are safe; collection/index mutation is not a casual first step.

```bash
pnpm add -g @wei840222/qmd
qmd collection add ~/notes --name notes
qmd update
qmd search "authentication" -c notes
```

### Models & Remote Endpoint Configuration

Configure models and custom endpoints in `~/.config/qmd/index.yml` under the `models:` section:

```yaml
models:
  embed_api_url: https://api.example.com/v1 # Both embed_api_url and embed_api_model enable remote embeddings
  embed_api_model: text-embedding-3-small # or text-embedding-3-large
  embed_dimension: 1536 # Optional: expected vector dimension; validates remote output

  # Optional: Remote LLM Query Expansion (aliases: generate_url, generate_base_url, generate_api_url)
  generate_api_url: https://api.example.com/v1 # Base URL (appends /chat/completions) or full endpoint
  generate_api_model: your-expansion-model

  # Optional: Remote Reranking (supports rerank_url / rerank_base_url / rerank_api_url)
  rerank_api_url: https://your-reranker.example/v1/rerank
  rerank_api_model: your-reranker

# Optional: Custom User Dictionary for CJK segmentation
dictionary: ~/.config/qmd/dictionary.txt
```

Remote URLs support `_url`, `_base_url`, and `_api_url` aliases. A base URL gets
`/chat/completions` for expansion or `/rerank` for reranking. Use a dedicated
reranker model with `/rerank`, or a chat-capable model with an explicit
`/chat/completions` endpoint; do not interchange those model types.

Official OpenAI embeddings require `OPENAI_API_KEY`; official Voyage embeddings
require `VOYAGE_API_KEY`. For authenticated expansion/reranking, configure
`models.generate_api_key` / `models.rerank_api_key` in private configuration.
`OPENAI_API_KEY` does not automatically fill those two fields. Never commit keys
or assume that YAML interpolates environment variables. The MCP subprocess must
receive the required environment and be able to read the intended QMD config.

After the user authorizes sending indexed documents to the configured embedding
provider, run `qmd embed` for a compatible index. Existing local-model indexes
remain usable for lexical search and reads. Switching embedding identity requires
an explicitly requested `qmd embed --force`, which clears and rebuilds vectors
while retaining lexical content. Do not mix identities, delete the database,
change models automatically, or attempt local inference as recovery.

Health and diagnostics:

```bash
qmd doctor
qmd status
```

`qmd doctor` checks config, remote model settings, vector fingerprints, CJK channel readiness, and common environment overrides without issuing model requests. If a model-backed command fails, run it before changing configuration.

## MCP setup

See `references/mcp-setup.md` for Claude Code, Claude Desktop, OpenClaw, and HTTP
server configuration.

## Pitfalls

- **Do not stop at snippets.** Fetch documents before making claims.
- **Do not slice files with `sed`/`head`/`tail`.** Use the `path:from:count`
  suffix (e.g. `qmd get "#abc123:120:40"`) or `--from`/`-l`. Output is already
  line-numbered; piping breaks docid resolution, the header, and virtual paths.
- **Choose remote search deliberately.** Typed queries skip expansion, but
  `vec:`/`hyde:` still need remote embeddings and reranking defaults to enabled.
  Skipping expansion alone does not make a query model-free.
- **Do not overuse semantic search.** If you know exact titles or terms, BM25 is
  faster and often better.
- **Do not mutate indexes casually.** `qmd collection add`, `qmd update`, and
  `qmd embed` change local state and can be expensive.
- **Model-backed commands can be environment-sensitive.** If `qmd query`,
  `qmd vsearch`, or reranking fails because remote providers are unavailable,
  use `qmd search` and stronger lexical/structured terms.
- **Ambiguous user wording needs intent.** Add `intent:` rather than hoping query
  expansion guesses the right domain.
- **Collection names matter.** Search `concepts` for synthesized wiki pages,
  `sources` for transcripts/raw source pages, and docs collections for code or
  project documentation.

Local model inference and `qmd pull` are retired in remote-only builds. Existing
local-model databases remain available for lexical reads. Training datasets,
fine-tuning/conversion scripts, and GPU/Bun container smoke tools are also removed;
do not recommend them for setup or troubleshooting.
