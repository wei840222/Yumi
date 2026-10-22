{{ if .local.features.bifrost -}}
| Version-specific library or framework docs | `available Context7 MCP tools`: resolve the library ID first, then query one concept at a time; keep the version pin | `native web page retrieval` official docs |
{{ end -}}
{{ if .local.features.bifrost -}}
| GitHub project architecture and docs | `available DeepWiki MCP tools` (public repositories only): structure first, then focused questions | `native web page retrieval` README |
{{ end -}}
{{ if .local.features.bifrost -}}
| Google Cloud, Firebase, Android, Gemini docs | `available Google developer documentation tools` | `native web page retrieval` official docs |
{{ end -}}
{{ if .local.features.bifrost -}}
| Web search, vertical search, URL extraction | `available AnySearch tools`: call `get_sub_domains` before any vertical search | `native web search` / `defuddle parse <url> --md` |
{{ end -}}
| GitHub issues, PRs, CI, releases | `gh` read commands (`list`, `view`, `checks`, `diff`, `gh api --method GET`) | `native web page retrieval` |
| Local clone: symbols, references | `cx` skill, then `rg` | `grep` |
| Markdown structure or a single section | `treemd` skill (non-interactive) | `grep -n`, then `local file reading` in sections |