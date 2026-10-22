### Plugin Skill Precedence

- This file overrides the "non-negotiable" behaviors in `agent-skills` skills, such as stopping to wait on any ambiguity or starting every non-trivial task with a spec. Infer intent and proceed as the Identity section says.
- Invoke `using-agent-skills`, `interview-me`, and `doubt-driven-development` only when Baby names them. For adversarial review, dispatch `gate`.
- A skill workflow never sends code or artifacts to an external model CLI (`codex`, `gemini`) without Baby's confirmation for that call.
- These rules are the only control: `skillOverrides` is ignored for plugin-sourced skills and commands in the installed Claude Code (2.1.304 at the time of writing).