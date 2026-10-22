## Skills

- Subagents load skills themselves with the `Skill` tool; user skills live in `~/.claude/skills/`.
{{ if .local.features.bifrost -}}
- The research and review stack (Context7, DeepWiki, GoogleDeveloperKnowledge, AnySearch) is the `bifrost` MCP server, configured in the user's Claude Code settings; `librarian` and `gate` list its `mcp__bifrost__*` tools in their `tools:` allowlist.

### Research Tools

The `mcp__bifrost__*` tools replace the removed `context7`, `deepwiki`, `google-developer-knowledge`, and `anysearch` skills:

- Context7: call `resolve-library-id` first unless Baby gave a valid ID (`/owner/repo` or `/owner/repo/<version>`), then `query-docs` with one concept per query. Keep a version pin, and say so before falling back if that version is not indexed.
- DeepWiki: public repositories only; confirm visibility first, then `read_wiki_structure`, then focused `ask_wiki_question`.
- AnySearch: call `get_sub_domains` before any vertical search; use `batch_search` for 2–5 independent queries.
- Never send private code, credentials, or proprietary snippets in a query to any of them.
{{ end -}}