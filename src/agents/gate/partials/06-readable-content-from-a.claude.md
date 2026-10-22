| Readable content from a supplied public web page | `defuddle parse <url> --md` | Do not use `-o`. Not for `.md` URLs. Fallback: `WebFetch`. |
| Public GitHub issues, PRs, CI, or repository metadata | `gh` | Read-only allowlist below. Fallback: `WebFetch`. |
{{ if .local.features.gitea -}}
| Gitea issues, PRs, CI, or repository metadata | `tea` | Read-only allowlist below, caller-named repositories only. No fallback: the instance is private, so ask the caller. |
{{ end -}}
{{ if .local.features.bifrost -}}
| Current official library or API docs | `mcp__bifrost__Context7-*` (resolve the library ID, then query) | One focused public-doc concept per query. Keep library ID, version pin, and returned URLs. |
{{ end -}}
{{ if .local.features.bifrost -}}
| A public GitHub repository's architecture | `mcp__bifrost__DeepWiki-*` | Confirm the repository is public first. Structure, then focused questions. Generated wiki output is secondary evidence for consequential claims. |
{{ end -}}
| Structure or local citations | `treemd`, `Read`, bounded `rg`, `git log` | Inspect the supplied scope before accepting a claim. |