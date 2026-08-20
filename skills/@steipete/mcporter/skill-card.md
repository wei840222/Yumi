## Description: <br>

Use the mcporter CLI to list, configure, auth, and call MCP servers/tools directly (HTTP or stdio), including ad-hoc servers, config edits, and CLI/type generation. <br>

This skill is ready for commercial/non-commercial use. <br>

## Publisher: <br>

[steipete](https://clawhub.ai/user/steipete) <br>

### License/Terms of Use: <br>

## Use Case: <br>

Developers and agent operators use this skill to inspect MCP servers, authenticate and configure mcporter, call MCP tools over HTTP or stdio, manage the mcporter daemon, and generate CLI or TypeScript integrations. <br>

### Deployment Geography for Use: <br>

Global <br>

## Known Risks and Mitigations: <br>

Risk: mcporter can call MCP tools over HTTP or stdio, including commands that contact servers or execute local scripts. <br>
Mitigation: Use trusted MCP servers and commands, and review local scripts before stdio execution. <br>
Risk: OAuth, configuration edits, daemon commands, and tool calls can affect credentials, local configuration, or long-running processes. <br>
Mitigation: Review proposed commands before execution and avoid production credentials unless the action is intentional. <br>

## Reference(s): <br>

- [mcporter homepage](http://mcporter.dev) <br>
- [ClawHub skill page](https://clawhub.ai/steipete/skills/mcporter) <br>

## Skill Output: <br>

**Output Type(s):** [Shell commands, Configuration, Code, Guidance] <br>
**Output Format:** [Markdown with inline shell commands and JSON examples] <br>
**Output Parameters:** [1D] <br>
**Other Properties Related to Output:** [May recommend machine-readable mcporter output with --output json.] <br>

## Skill Version(s): <br>

1.0.0 (source: server release metadata) <br>

## Ethical Considerations: <br>

Users should evaluate whether this skill is appropriate for their environment, review any generated or modified files before relying on them, and apply their organization's safety, security, and compliance requirements before deployment. <br>
