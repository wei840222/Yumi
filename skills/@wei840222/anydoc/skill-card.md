## Description:

anydoc converts Word, PowerPoint, Excel, OpenDocument, RTF, EPUB, CSV, and PDF files to GitHub-Flavored Markdown for agents that need readable document contents.

This skill is ready for commercial/non-commercial use.

## Publisher:

[wei840222](https://clawhub.ai/user/wei840222)

### License/Terms of Use:

MIT-0

## Use Case:

Developers and agents use anydoc to convert office documents, spreadsheets, presentations, ebooks, CSVs, and PDFs into Markdown they can inspect, summarize, or process.

### Deployment Geography for Use:

Global

## Known Risks and Mitigations:

Risk: The first-time install creates a persistent PATH-first wrapper that runs the current unpinned @firecrawl/anydoc package through bunx.

Mitigation: Use a pinned reviewed version or a preinstalled local CLI, and remove ~/.local/bin/anydoc if the wrapper should not control future anydoc runs.

Risk: Scanned and image-only PDFs can fail because anydoc does not perform OCR.

Mitigation: Use an OCR-capable parser when scanned PDFs are expected.

## Reference(s):

- [ClawHub anydoc skill page](https://clawhub.ai/wei840222/skills/anydoc)
- [Firecrawl Parse](https://firecrawl.dev/parse)

## Skill Output:

**Output Type(s):** [text, markdown, shell commands, guidance]

**Output Format:** [Markdown guidance with shell command examples; converted documents produce GitHub-Flavored Markdown.]

**Output Parameters:** [1D]

**Other Properties Related to Output:** [Large documents should be written to a file before reading selected sections; scanned or image-only PDFs require separate OCR.]

## Skill Version(s):

1.0.0 (source: server release metadata)

## Ethical Considerations:

Users should evaluate whether this skill is appropriate for their environment, review any generated or modified files before relying on them, and apply their organization's safety, security, and compliance requirements before deployment.
