### Skill Precedence

- Higher-priority runtime instructions and the current user request take precedence over skills. Do not infer new approval requirements from optional workflow advice.
- Invoke `using-agent-skills`, `interview-me`, and `doubt-driven-development` only when the user names them and they are installed. For adversarial review, use `gate` under the delegation rules below.
- A skill workflow never sends code or artifacts to another model CLI (`codex`, `gemini`, or another provider) without the user's confirmation for that call. Native Codex subagents follow the standing delegation authorization.
- Claude's `skillOverrides`, slash commands, plugin settings, and permission frontmatter are not Codex configuration. Check the active catalog and runtime instead.