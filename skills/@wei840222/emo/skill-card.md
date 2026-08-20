## Description:

Analyze emoji usage, overall sentiment scores (-1.0 to +1.0), sentiment intensity, polarization index, emotional volatility, and progression arc using the `emo` CLI tool.

This skill is ready for commercial/non-commercial use.

## Publisher:

[wei840222](https://clawhub.ai/user/wei840222)

### License/Terms of Use:

MIT-0

## Use Case:

Developers, analysts, and agents use this skill to evaluate emoji usage and sentiment in user input, chat logs, and text files, including multi-file comparisons and segmented progression analysis.

### Deployment Geography for Use:

Global

## Known Risks and Mitigations:

Risk: The skill directs agents to install and use an external Rust CLI from Cargo.

Mitigation: Install only when the package source and execution environment are approved for the intended use.

Risk: Directory mode can recursively process local text content.

Mitigation: Run the CLI only on files or directories that are intended for sentiment and emoji analysis.

## Reference(s):

- [ClawHub skill page](https://clawhub.ai/wei840222/skills/emo)

## Skill Output:

**Output Type(s):** [Guidance, Shell commands, Text, JSON]

**Output Format:** [Markdown guidance with inline shell commands; CLI output may be text summaries, comparison tables, or JSON.]

**Output Parameters:** [1D]

**Other Properties Related to Output:** [Can analyze stdin, individual files, directories, multiple files, paragraphs, or lines depending on the emo CLI command used.]

## Skill Version(s):

0.1.2 (source: server release metadata)

## Ethical Considerations:

Users should evaluate whether this skill is appropriate for their environment, review any generated or modified files before relying on them, and apply their organization's safety, security, and compliance requirements before deployment.
