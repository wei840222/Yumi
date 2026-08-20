## Description:

Manage and automate coding tasks with Jules, Google's autonomous AI coding agent CLI for delegating repository tasks, tracking remote sessions, reviewing or applying patches, and using teleport.

This skill is ready for commercial/non-commercial use.

## Publisher:

[wei840222](https://clawhub.ai/user/wei840222)

### License/Terms of Use:

MIT-0

## Use Case:

Developers and engineers use this skill to operate the Jules CLI for asynchronous repository work, including task delegation, remote session monitoring, patch review, patch application, and teleport workflows.

### Deployment Geography for Use:

Global

## Known Risks and Mitigations:

Risk: Direct patch application with `--apply` or `teleport` can change the local repository using remote agent-generated changes.

Mitigation: Inspect fetched patches first, confirm git status and target branch, and prefer a clean branch or disposable checkout before applying changes.

## Reference(s):

- [Jules CLI Reference](references/cli-reference.md)
- [ClawHub Skill Page](https://clawhub.ai/wei840222/skills/jules)

## Skill Output:

**Output Type(s):** [text, markdown, shell commands, guidance]

**Output Format:** [Markdown with inline bash code blocks and command tables]

**Output Parameters:** [1D]

**Other Properties Related to Output:** [Requires the `jules` CLI binary.]

## Skill Version(s):

1.0.0 (source: server release metadata)

## Ethical Considerations:

Users should evaluate whether this skill is appropriate for their environment, review any generated or modified files before relying on them, and apply their organization's safety, security, and compliance requirements before deployment.
