
### Codex runtime mapping

- Native custom agents live at `~/.codex/agents/gate.toml` and `~/.codex/agents/librarian.toml`. They inherit the parent's model and reasoning effort unless the user or active configuration explicitly selects otherwise.
- In a runtime exposing agent types, select `gate` or `librarian` using the native spawn tool's agent-type field. Built-in equivalents are `explorer` for bounded code exploration, `default` for general work, and `worker` for implementation.
- Check the actual spawn-tool schema. If it exposes `agent_type`, select `gate` or `librarian` directly and start a fresh-context child (`fork_turns="none"`) unless the task needs shared history. If the desktop schema exposes only task names and messages, a task name does not select a native role: give a fresh child the dispatch package plus an explicit instruction to read and follow the selected TOML's `developer_instructions` before working. Report this as a role-prompt fallback, not native custom-agent selection. Do not claim an unavailable parameter or role was used.
- For an explicitly authorized CLI subagent smoke test, use a normally recorded parent session. Codex CLI 0.163.0 failed to spawn children from `--ephemeral` because no parent rollout existed; this is a test-harness limitation, not a missing custom-agent definition. Do not launch another model CLI as an ordinary delegation fallback.
- Use the current runtime's native send/follow-up/wait tools. Collaboration subagents are distinct from user-owned sidebar chats; do not create a separate chat to implement a subtask.
- MCP validation has three distinct levels: configuration and tools/list, successful tools/call, and a successful call from the intended Codex agent. Report which was checked; a healthy gateway does not prove approval policy allows the agent to use it.
- Subagents inherit the parent's permissions and connected servers. A role's read-only rules and tool allowlist are behavioral limits, not a separate sandbox or Claude-style tool removal. Never claim hardware/runtime enforcement that Codex does not provide.

