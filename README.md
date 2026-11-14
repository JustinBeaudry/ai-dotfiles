# ai-dotfiles

A small Unix shell script for the agent harnesses on one machine: Claude, Codex, Cursor, Pi, and Grok.

Shared skills live in `~/.agents/skills`. `ai-dotfiles link` points the other harnesses at those directories. Grok already reads that path. `ai-dotfiles audit` reports which links are in place and which MCP servers each harness has configured.

There is no manifest, no adapter, and no rewrite of tool config. The git repo holds the script. It does not hold skills, MCP credentials, or settings.

## Use

```sh
./ai-dotfiles audit
./ai-dotfiles link --dry-run
./ai-dotfiles link
```

`link` creates a symlink when the skill name is missing. A real directory, or a symlink that already points somewhere else, is left alone and named in the output.

## What it does not change

- `~/.claude.json` and `~/.claude/settings.json`
- `~/.codex/config.toml`
- `~/.cursor/mcp.json` and `~/.cursor/cli-config.json`
- `~/.grok/config.toml`
- `~/.pi/agent/settings.json`

MCP entries and settings stay where each harness wrote them. The audit prints server names and on/off state. It does not print URLs, tokens, or environment values.

Windows is out of scope. The script is POSIX `sh` plus `python3` for reading JSON and TOML during `audit`. `link` does not need Python.
