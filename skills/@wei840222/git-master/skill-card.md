## Description:

Guides agents through git operations including atomic commits, rebases, squashes, and history searches with repository style detection and safety checks.

This skill is ready for commercial/non-commercial use.

## Publisher:

[wei840222](https://clawhub.ai/user/wei840222)

### License/Terms of Use:

MIT-0

## Use Case:

Developers and engineering agents use this skill to plan and execute git workflows such as atomic commits, rebases, squashes, and change-history investigations. It emphasizes context gathering, repository commit-style matching, and explicit safety checks before history-changing commands.

### Deployment Geography for Use:

Global

## Known Risks and Mitigations:

Risk: Git operations can change repository state, including staged files, commits, branch history, and remote synchronization.

Mitigation: Review the agent's plan before staging, committing, rebasing, fetching, resetting, or pushing.

Risk: History rewriting and recovery commands can make work difficult to restore if used without preparation.

Mitigation: Keep backups or stashes before destructive recovery commands and supervise any force-with-lease push recommendations.

## Reference(s):

- [ClawHub skill page](https://clawhub.ai/wei840222/skills/git-master)
- [ClawHub publisher profile](https://clawhub.ai/user/wei840222)

## Skill Output:

**Output Type(s):** [text, markdown, shell commands, guidance]

**Output Format:** [Markdown with inline shell commands]

**Output Parameters:** [1D]

**Other Properties Related to Output:** [May include commit plans, rebase plans, history-search summaries, and safety warnings for repository-changing commands.]

## Skill Version(s):

1.0.0 (source: server release evidence)

## Ethical Considerations:

Users should evaluate whether this skill is appropriate for their environment, review any generated or modified files before relying on them, and apply their organization's safety, security, and compliance requirements before deployment.
