# spy

Monitor active [Claude Code](https://docs.anthropic.com/en/docs/claude-code) and [Codex](https://openai.com/index/introducing-codex/) conversations from the terminal.

`spy` finds sessions for the current working directory and displays parsed message text (no raw JSON, no tool calls, no system messages).

## Install

```
brew install adamavenir/tap/spy
```

Or clone and add to your PATH:

```
git clone https://github.com/adamavenir/spy.git
ln -s "$(pwd)/spy/spy" /usr/local/bin/spy
```

## Usage

```
spy                Show the most recent session (accordion view)
spy <n>            Show session #n
spy watch          Follow the most recent session live
spy <n> watch      Follow session #n live
spy tail -30       Last 30 lines from most recent session
spy head -5        First 5 lines from most recent session
spy <n> tail -N    Last N lines from session #n
spy <n> head -N    First N lines from session #n
spy ls             List active + 5 most recent sessions
```

## Default view

When you run `spy` with no arguments, it shows an **accordion** of the most recent conversation: the first 3 lines of text, `...`, and the last 10 lines.

```
$ spy
run `tk show m-1138`

we need a strategy for debugging this issue
...
Commit: `f3346af5b` ("Handle EPIPE on command stdin")

Next steps:
1) Re-run the J2BD command that previously hit EPIPE
2) Run `MLLD_DEBUG_EXEC_IO=1` to verify the new logging path.

  2h ago [codex] (119 lines)
```

If multiple sessions are active (updated within the last 60 seconds), it shows the list view instead.

## List view

```
$ spy ls
=== Active ===

[1] "Please refactor the auth module..."
... "Done. All tests pass."
    12s ago [claude]

[2] "run `tk show m-1138`..."
... "Commit: `f3346af5b`"
    45s ago [codex]

=== Recent ===

[1] "Fix the build errors..."
... "All 47 tests pass."
    5m ago [claude]
```

## Requirements

- `jq`
- `bash` 4+

## Supported agents

| Agent | Session location |
|---|---|
| Claude Code | `~/.claude/projects/<encoded-path>/*.jsonl` |
| Codex CLI | `~/.codex/sessions/YYYY/MM/DD/*.jsonl` |

## License

MIT
