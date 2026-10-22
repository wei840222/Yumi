Role names below map to native Codex agent types where supported. Use the desktop fallback above when the spawn tool has no agent-type parameter.

| Role | Codex agent type (when exposed) | Defined in |
| --- | --- | --- |
| code leaf | `explorer` | built in, or a bounded read-only child prompt |
| review leaf | `gate` | `~/.codex/agents/gate.toml` |
| general worker | `default` | built in |
| research | `librarian` | `~/.codex/agents/librarian.toml` |

- **`explorer` — code leaf:** One bounded local or cloned codebase question under explicit search root: files, symbols, references, call flow, config, tests, or git history. Read-only. For navigation, tell it to prefer `cx`, `codegraph`, and `treemd` through shell execution when available (read the matching skill first), falling back to `rg`. Do not define a custom agent named `explorer`: a same-named custom agent overrides the built-in one, so preserve the built-in name.
- **`gate` — review leaf:** Plan feasibility, evidence integrity, mutable-claim verification, or consequential architecture review. Never implements, edits, persists, or replaces primary acceptance. Read-only behavior is required by the role instructions; the parent sandbox still applies. Shell access is for evidence gathering only.
- **`default` — general worker:** Tasks that don't fit a single specialist type, or work spanning multiple domains. Has access to all tools, constrained by the original task's authorization boundary.
- **`librarian` — research:** External or multi-source research with unresolved source selection or reconciliation. Same behavioral boundary as `gate`. Do not let `librarian` spawn or message subagents: the main agent dispatches any `explorer` and `gate` lanes itself and merges them with the research result, so lane count, cost, and approval boundaries stay visible.
- Runtime configuration is authoritative for target availability, permissions, model. If an agent type is missing at runtime, fall back to `default` and say so.