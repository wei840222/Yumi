## Description:

Analyze any source-code project through its pre-built local code graph: index it, then answer graph-first codebase questions — symbol source + call paths, callers/callees, change impact, affected tests, file inventory.

This skill is ready for commercial/non-commercial use.

## Publisher:

[wei840222](https://clawhub.ai/user/wei840222)

### License/Terms of Use:

MIT-0

## Use Case:

Developers and engineers use this skill to answer codebase questions from a local CodeGraph index, including symbol source, call paths, callers and callees, change impact, affected tests, and file inventory. It helps an agent prefer graph-backed evidence when a project is indexed and fall back to normal code-reading tools when it is not.

### Deployment Geography for Use:

Global

## Known Risks and Mitigations:

Risk: Install instructions may lead users to run a remote shell installer without verification.

Mitigation: Prefer a package-manager or verified download flow before installing CodeGraph.

Risk: Creating or updating a CodeGraph index persists local source-code metadata and snippets in the repository.

Mitigation: Confirm authorization before creating or updating .codegraph indexes, especially in private repositories.

## Reference(s):

- [CodeGraph CLI Reference](references/cli-reference.md)
- [ClawHub skill page](https://clawhub.ai/wei840222/skills/codegraph)

## Skill Output:

**Output Type(s):** [text, markdown, shell commands, guidance]

**Output Format:** [Markdown with path references and inline shell commands]

**Output Parameters:** [1D]

**Other Properties Related to Output:** [May include graph-derived source excerpts, call paths, file inventories, impact summaries, affected-test guidance, and fallback limits.]

## Skill Version(s):

1.0.1 (source: server release evidence)

## Ethical Considerations:

Users should evaluate whether this skill is appropriate for their environment, review any generated or modified files before relying on them, and apply their organization's safety, security, and compliance requirements before deployment.
