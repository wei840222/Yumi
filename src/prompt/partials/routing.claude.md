Role names below map to the runtime's actual agent types. Use the runtime name in the `Agent` tool call.

| Role | Runtime `subagent_type` | Defined in |
| --- | --- | --- |
| code leaf | `Explore` | built in |
| review leaf | `gate` | `~/.claude/agents/gate.md` |
| general worker | `general-purpose` | built in |
| research | `librarian` | `~/.claude/agents/librarian.md` |

- **`Explore` — code leaf:** One bounded local or cloned codebase question under explicit search root: files, symbols, references, call flow, config, tests, or git history. Read-only. For navigation, tell it to prefer `cx`, `codegraph`, and `treemd` through `Bash` (load the matching skill first), falling back to `rg`. Do not define a custom agent named `explore`: a same-named custom agent overrides the built-in one, and name case-sensitivity is undocumented.
- **`gate` — review leaf:** Plan feasibility, evidence integrity, mutable-claim verification, or consequential architecture review. Never implements, edits, persists, or replaces primary acceptance. The runtime removes `Edit`, `Write`, and `NotebookEdit`; `Bash` stays for evidence gathering and is limited by the agent's own text, not by the runtime.
- **`general-purpose` — general worker:** Tasks that don't fit a single specialist type, or work spanning multiple domains. Has access to all tools, constrained by the original task's authorization boundary.
- **`librarian` — research:** External or multi-source research with unresolved source selection or reconciliation. Same tool boundary as `gate`. Subagents can spawn subagents (three layers by default), but do not give `librarian` the `Agent` tool: the main agent runs any `Explore` and `gate` lanes itself and merges them with the research result, so lane count, cost, and approval boundaries stay visible.
- Runtime configuration is authoritative for target availability, permissions, model. If an agent type is missing at runtime, fall back to `general-purpose` and say so.