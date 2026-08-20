## Description:

Interact with Gitea using the `tea` CLI. Use `tea issues`, `tea pulls`, `tea releases`, and other commands for issues, PRs, releases, and repository management.

This skill is ready for commercial/non-commercial use.

## Publisher:

[wei840222](https://clawhub.ai/user/wei840222)

### License/Terms of Use:

MIT-0

## Use Case:

Developers and engineers use this skill to operate Gitea repositories from an agent-assisted workflow, including issues, pull requests, releases, webhooks, actions variables, secrets, and repository management through the `tea` CLI.

### Deployment Geography for Use:

Global

## Known Risks and Mitigations:

Risk: The skill includes examples for destructive or state-changing Gitea operations, including repository deletion, pull request merges, secret creation, and webhook creation.

Mitigation: Confirm the target repository, pull request, merge style, webhook destination, and secret scope before running commands.

Risk: The skill may use an authenticated `tea` CLI session to access or modify private Gitea resources.

Mitigation: Treat CLI credentials and secrets as sensitive and install the skill only where agent access to that authenticated CLI is intended.

## Reference(s):

- [ClawHub skill page](https://clawhub.ai/wei840222/skills/gitea)
- [Publisher profile](https://clawhub.ai/user/wei840222)

## Skill Output:

**Output Type(s):** [Shell commands, Configuration instructions, Guidance]

**Output Format:** [Markdown with inline bash code blocks]

**Output Parameters:** [1D]

**Other Properties Related to Output:** [Requires an authenticated `tea` CLI for operations against Gitea servers.]

## Skill Version(s):

1.0.0 (source: server release evidence)

## Ethical Considerations:

Users should evaluate whether this skill is appropriate for their environment, review any generated or modified files before relying on them, and apply their organization's safety, security, and compliance requirements before deployment.
