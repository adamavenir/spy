# spy

A bash CLI that monitors active Claude Code and Codex conversations for the current working directory.

## Architecture

Single file (`spy`) with no dependencies beyond `jq` and `bash`.

### Session discovery

spy finds conversations by matching the current working directory to session storage locations for each agent:

**Claude Code** stores sessions at `~/.claude/projects/<encoded-path>/<session-id>.jsonl`. The encoded path replaces `/` with `-` and prepends `-` (e.g., `/Users/adam/dev/fray` becomes `-Users-adam-dev-fray`). Each session is a JSONL file with entries like:
- `type: "user"` / `type: "assistant"` — messages with `.message.content` (string for text, array for tool use)
- `type: "summary"` — context summaries (ignored)
- `type: "system"` — system prompts (ignored)

**Codex CLI** stores sessions at `~/.codex/sessions/YYYY/MM/DD/rollout-<uuid>.jsonl`. The first line contains `session_meta` with a `payload.cwd` field used to match the current directory. Messages use `type: "response_item"` with `payload.role` and `payload.content[0].text`. Tool calls use `payload.type: "function_call"`.

### Session ordering

Sessions are sorted by file modification time (most recent first). Uses `find | xargs stat | sort` to handle projects with thousands of session files (avoids shell argument list limits with glob expansion).

### Text extraction

spy extracts readable content from each message:
- **User text** — displayed with grey background
- **Assistant text** — displayed plain
- **Tool usage** — displayed dim+italic with a brief summary (e.g., `Bash: git status`, `Edit /path/to/file`, `Grep pattern`)

Filtered out:
- Tool results (the output returned to the model)
- System/developer messages
- Codex preambles (AGENTS.md, permissions, environment_context, turn_aborted)
- Empty messages

### Commands

| Command | Description |
|---------|-------------|
| `spy` | Accordion (3 head + 10 tail) of most recent session, or list if multiple active |
| `spy <n>` | Accordion of session #n (1 = most recent) |
| `spy <uuid>` | Accordion of session by UUID (prefix match supported) |
| `spy watch` | Poll-based live follow (checks every 1s) |
| `spy tail -N` | Last N lines of parsed text |
| `spy head -N` | First N lines of parsed text |
| `spy ls` | Active sessions + 5 most recent |
| `spy --no-color` | XML tags (`<user>`, `<agent>`, `<tool>`) instead of ANSI |

### Watch mode

Both Claude Code and Codex write to their JSONL files in batches (complete turns, not streaming lines). Traditional `tail -f` misses updates due to inconsistent kqueue events on macOS. Instead, watch mode polls the file every second and processes only new lines.

### UUID lookup

Sessions can be accessed by UUID (the session ID in the filename). Partial prefix matching is supported — `spy 0c99` will match `0c99f1f1-670e-4427-...`. UUID lookup searches:
1. Claude: `~/.claude/projects/<encoded-cwd>/<uuid>*.jsonl`
2. Codex: `~/.codex/sessions/**/*<uuid>*.jsonl` (with cwd verification)

### Output modes

**Color mode** (default):
- User messages: grey background (`\033[48;5;237m`)
- Assistant messages: plain
- Tool usage: dim italic (`\033[2;3m`)
- Metadata: dim (`\033[2m`)

**No-color mode** (`--no-color` or `NO_COLOR` env):
- Wraps runs of same-role lines in XML tags: `<user>`, `<agent>`, `<tool>`
- Respects [no-color.org](https://no-color.org) convention

### Caveats

- Codex session matching requires `cwd` in `session_meta` to exactly match `pwd` (no symlink resolution)
- The 50-session limit means very old sessions in active projects won't appear in listings (but can be accessed by UUID)
- Watch mode has 1-second latency since it polls rather than using filesystem events
