## Description: <br>
Use when a complex problem needs a structured expert team rather than a single general answer. Runs a Single-CEO Expert Council with a Nuwa-style decision lens, Agency-style specialist selection, NEXUS handoffs, evidence-backed expert reports, and a verification layer before final synthesis. <br>

This skill is ready for commercial/non-commercial use. <br>

## Publisher: <br>
[wei840222](https://clawhub.ai/user/wei840222) <br>

### License/Terms of Use: <br>
MIT-0 <br>


## Use Case: <br>
Developers, product teams, and operators use this skill to break complex decisions into a small expert-council workflow with scoped specialists, evidence requirements, verification, and final synthesis. <br>

### Deployment Geography for Use: <br>
Global <br>

## Known Risks and Mitigations: <br>
Risk: Council runs write full local artifacts to /tmp, which may include sensitive prompt context or proprietary details. <br>
Mitigation: Avoid sending confidential data unless local artifact persistence is acceptable, and remove run directories when they are no longer needed. <br>
Risk: Optional source-asset initialization can clone public repositories and mutate the local filesystem. <br>
Mitigation: Run source-asset initialization only after explicit user approval and only when those external sources are needed. <br>
Risk: Expert reports and final synthesis can still contain unsupported or partially verified claims. <br>
Mitigation: Use the skill's verification verdicts and evidence requirements, and downgrade or remove claims that do not pass verification. <br>


## Reference(s): <br>
- [Ai Expert Team ClawHub Page](https://clawhub.ai/wei840222/skills/ai-expert-team) <br>
- [Source Research Snapshot](references/source-research-snapshot.md) <br>
- [Specialist Selection](references/specialist-selection.md) <br>
- [Validation Case Library](references/validation-case-library.md) <br>
- [Expert Handoff Template](templates/expert-handoff.md) <br>
- [Final Synthesis Template](templates/final-synthesis.md) <br>


## Skill Output: <br>
**Output Type(s):** [Text, Markdown, Shell commands, Configuration, Guidance] <br>
**Output Format:** [Markdown reports, handoffs, verification notes, final synthesis, and optional shell commands] <br>
**Output Parameters:** [1D] <br>
**Other Properties Related to Output:** [Runs are expected to persist traceable artifacts under /tmp/ai-expert-team/runs/<run_id>/.] <br>

## Skill Version(s): <br>
0.1.4 (source: server release metadata) <br>

## Ethical Considerations: <br>
Users should evaluate whether this skill is appropriate for their environment, review any generated or modified files before relying on them, and apply their organization's safety, security, and compliance requirements before deployment. <br>
