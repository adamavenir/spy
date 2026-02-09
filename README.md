# spy

Monitor active [Claude Code](https://docs.anthropic.com/en/docs/claude-code) and [Codex](https://openai.com/index/introducing-codex/) conversations from the terminal.

`spy` finds sessions for the current working directory and displays parsed message text with visual differentiation between user messages (grey background), assistant responses, and tool usage (dim italic).

## Install

```
brew install adamavenir/tap/spy
```

Or clone and install:

```
git clone https://github.com/adamavenir/spy.git
cd spy
make install
```

## Usage

```
spy                Show the most recent session (accordion view)
spy <n>            Show session #n (1 = most recent)
spy <uuid>         Show session by UUID (partial match supported)
spy watch          Follow the most recent session live
spy <n> watch      Follow session #n live
spy tail -30       Last 30 lines from most recent session
spy head -5        First 5 lines from most recent session
spy <n> tail -N    Last N lines from session #n
spy ls             List active + 5 most recent sessions
spy --no-color     Disable ANSI colors, use XML tags instead
```

## Default view

When you run `spy` with no arguments, it shows an **accordion** of the most recent conversation: the first 3 lines, `...`, and the last 10 lines.

```
$ spy
 run `tk show m-1138`                        # grey background = user
 we need a strategy for debugging this issue
Bash: tk show m-1138                         # dim italic = tool

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

## UUID access

You can access any session by its UUID (from the session filename):

```
spy 0c99f1f1                    # partial UUID (prefix match)
spy 0c99f1f1-670e-4427-98c3-12007c8f7bc5   # full UUID
spy 0c99f1f1 watch              # watch by UUID
spy 0c99f1f1 tail -20           # tail by UUID
```

## No-color mode

For piping or accessibility, `--no-color` (or `NO_COLOR` env var) outputs XML tags instead of ANSI:

```
$ spy --no-color tail -10
<user>
run `tk show m-1138`
</user>
<tool>
Bash: tk show m-1138
</tool>
<agent>
The issue has been fixed.
</agent>
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
