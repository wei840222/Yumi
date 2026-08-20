## Description:

Use this skill when the user wants to run, configure, troubleshoot, or explain Google Antigravity CLI (`agy`), including one-shot prompts, interactive TUI sessions, conversation resume, artifact review, plugin management, slash commands, keybindings, sandbox/permissions, settings files, or migration from Gemini CLI.

This skill is ready for commercial/non-commercial use.

## Publisher:

[wei840222](https://clawhub.ai/user/wei840222)

### License/Terms of Use:

MIT-0

## Use Case:

Developers and engineers use this skill to run, configure, troubleshoot, and explain Google Antigravity CLI workflows, including one-shot prompts, TUI sessions, permissions, artifact review, plugins, settings, and migration from Gemini CLI.

### Deployment Geography for Use:

Global

## Known Risks and Mitigations:

Risk: Permission-bypass or always-proceed modes can let the CLI act without normal review prompts.

Mitigation: Keep sandboxing, review prompts, and TUI permission controls enabled for normal use; use bypass modes only in trusted, narrow workspaces.

Risk: Generated code or artifacts may be incorrect or unsafe if accepted without inspection.

Mitigation: Review artifacts and command summaries before approval, especially in unfamiliar repositories.

Risk: Installation or update commands can execute remote installer scripts.

Mitigation: Verify the Antigravity CLI install source before running installation commands.

## Reference(s):

- [ClawHub Skill Page](https://clawhub.ai/wei840222/skills/antigravity-cli)
- [CLI Usage](references/cli-usage.md)
- [Overview and Workflows](references/overview-workflows.md)
- [Interactive TUI](references/tui.md)
- [Artifact Review](references/artifacts.md)
- [Security and Permissions](references/security-permissions.md)
- [Configuration and Platform](references/config-platform.md)
- [Antigravity CLI Reference](https://antigravity.google/docs/cli-reference)
- [Antigravity CLI Features](https://antigravity.google/docs/cli-features)
- [Using AGY CLI](https://antigravity.google/docs/cli-using)
- [Prompting and Interaction](https://antigravity.google/docs/cli-prompting)
- [Gemini CLI Migration](https://antigravity.google/docs/gcli-migration)

## Skill Output:

**Output Type(s):** [Guidance, Shell commands, Configuration instructions, Markdown]

**Output Format:** [Markdown with inline shell commands and configuration snippets]

**Output Parameters:** [1D]

**Other Properties Related to Output:** [May reference local Antigravity CLI settings, permissions, plugins, skills, and artifact review workflows.]

## Skill Version(s):

1.0.1 (source: server release evidence)

## Ethical Considerations:

Users should evaluate whether this skill is appropriate for their environment, review any generated or modified files before relying on them, and apply their organization's safety, security, and compliance requirements before deployment.
