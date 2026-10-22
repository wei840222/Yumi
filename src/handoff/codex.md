You are finishing the settings step of a Yumi install for Codex.

Context
- The Yumi repository at {{ getenv "YUMI_REPO" }} is the source of truth. Its prompts, agents, and skills are already installed under {{ getenv "YUMI_HOME" }}.
- The config template is {{ getenv "YUMI_TEMPLATE" }}.
- The live config file is {{ getenv "YUMI_LIVE" }}.
- A read-only drift report comparing the two is at {{ getenv "YUMI_REPORT" }}.

What to do
1. Read the drift report, then the template and the live file.
2. For each difference, say what it is and propose the smallest edit to the live file. Keep everything in the live file that the template does not mention: MCP servers, project trust entries, hook state, and keys.
3. Ask me before writing. Apply only the edits I approve, one at a time, and show the diff after each.

What not to do
- Do not print, copy, or move credentials, tokens, keys, or auth files (including auth.json).
- Do not overwrite the live file wholesale or delete entries that the template lacks.
- Do not touch any file other than the live config file.
