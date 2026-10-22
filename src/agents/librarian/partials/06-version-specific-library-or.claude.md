{{ if .local.features.bifrost -}}
| Version-specific library or framework docs | `mcp__bifrost__Context7-*`: resolve the library ID first, then query one concept at a time; keep the version pin | `WebFetch` official docs |
{{ end -}}
{{ if .local.features.bifrost -}}
| GitHub project architecture and docs | `mcp__bifrost__DeepWiki-*` (public repositories only): structure first, then focused questions | `WebFetch` README |
{{ end -}}
{{ if .local.features.bifrost -}}
| Google Cloud, Firebase, Android, Gemini docs | `mcp__bifrost__GoogleDeveloperKnowledge-*` | `WebFetch` official docs |
{{ end -}}
{{ if .local.features.bifrost -}}
| Web search, vertical search, URL extraction | `mcp__bifrost__AnySearch-*`: call `get_sub_domains` before any vertical search | `WebSearch` / `defuddle parse <url> --md` |
{{ end -}}
| GitHub issues, PRs, CI, releases | `gh` read commands (`list`, `view`, `checks`, `diff`, `gh api --method GET`) | `WebFetch` |
| Local clone: symbols, references | `cx` skill, then `rg` | `grep` |
| Markdown structure or a single section | `treemd` skill (non-interactive) | `grep -n`, then `Read` in sections |