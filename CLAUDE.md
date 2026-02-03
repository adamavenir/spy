# spy

A bash CLI that monitors active Claude Code and Codex conversations for the current working directory.

## Architecture

Single file (`spy`) with no dependencies beyond `jq` and `bash`.

### Session discovery

spy finds conversations by matching the current working directory to session storage locations for each agent:

**Claude Code** stores sessions at `~/.claude/projects/<encoded-path>/<session-id>.jsonl`. The encoded path replaces `/` with `-` and prepends `-` (e.g., `/Users/adam/dev/fray` becomes `-Users-adam-dev-fray`). Each session is a JSONL file with entries like:
- `type: "user"` / `type: "assistant"` — messages with `.message.content` (string for text, array for tool results)
- `type: "summary"` — context summaries (ignored by spy)
- `type: "system"` — system prompts (ignored by spy)

**Codex CLI** stores sessions at `~/.codex/sessions/YYYY/MM/DD/rollout-*.jsonl`. The first line contains `session_meta` with a `payload.cwd` field used to match the current directory. Messages use `type: "response_item"` with `payload.role` and `payload.content[0].text`.

### Text extraction

spy extracts only readable text — user and assistant message content. It filters out:
- Tool calls and tool results (array content blocks)
- System/developer messages
- Codex system preambles (AGENTS.md, permissions, environment_context, turn_aborted)

### Session ordering

Sessions are sorted by file modification time (most recent first). The `ls -t | head -50` approach for Claude avoids scanning thousands of files in projects with long histories.

### Commands

- **default** — Accordion view (3 head + 10 tail lines) of most recent session, or list view if multiple sessions are active (updated within 60s)
- **`<n>`** — Accordion of session #n (1 = most recent)
- **`watch`** — `tail -f` with jq parsing for live streaming
- **`tail -N`** / **`head -N`** — Extract all text, pipe through head/tail
- **`ls`** — Two-section list: active (within 60s) and recent (up to 5)

### Caveats

- Claude Code sessions with only tool-result messages (no string content) show as empty
- Codex session matching requires the `cwd` in `session_meta` to exactly match `pwd` (no symlink resolution)
- The 50-file limit on Claude session scanning means very old sessions in active projects may not appear
