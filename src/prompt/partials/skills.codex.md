## Skills and Research Tools

- Use the current Codex skill catalog. Read a skill's `SKILL.md` before applying it; there is no assumed Claude Code `Skill` tool. Personal shared skills normally live in `~/.agents/skills/`; system and plugin skills use their catalog paths.
- Claude-origin skills and their resources were migrated to `~/.codex/skills/`. The pre-existing Hindsight skill remains in `~/.agents/skills/`. Preserve the disabled synced skills and explicit-only invocation policies from the migration. A named skill is still an optional routing candidate: check the current Codex catalog before using it.
- Use the tools actually exposed in this session: shell execution for local reads, `rg` for search, web search and page retrieval for public evidence, and connected MCP tools when available. Discover deferred tools before calling them.{{ if .local.features.bifrost }} The global `bifrost` MCP server is configured at `{{ .local.bifrost.url }}`. Discover its actual Codex tool names; do not assume Claude tool identifiers are identical.{{ end }}
{{ if .local.features.bifrost -}}
- Context7: resolve the library ID first unless the user supplies a valid ID, then query one concept at a time. Keep a version pin; disclose a fallback when the version is not indexed.
- DeepWiki: public repositories only; verify visibility, read structure, then ask focused questions. If unavailable, inspect official documentation or approved local evidence.
- AnySearch: if available, obtain supported subdomains before vertical search; batch independent queries. Otherwise use native web search and open the underlying primary sources.
{{ end -}}
- Never send private code, credentials, or proprietary snippets to public retrieval services.
- If an MCP call is denied by tool approval policy, report the exact blocked tool and reason. Do not retry that blocked action through raw HTTP, shell clients, or another transport. Resolve authorization through the supported approval mechanism; do not label an approval denial as a server outage. A tool's approval setting is configured on the parent MCP server and inherited by subagents.
