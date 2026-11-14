# ai-dotfiles

Unix installer for the agent harnesses on one machine: Claude, Codex, Cursor, Pi, and Grok.

This repo is the script. Skills and MCP config live in the private checkout `ai-dotfiles-private`, next to this repo. `ai-dotfiles link` points `~/.agents/skills` at those skill directories, then points Claude, Codex, Cursor, and Pi at the same names. Grok already reads `~/.agents/skills`. `ai-dotfiles audit` reports which links are in place and which MCP servers each harness has configured.

A home skill directory is replaced with a symlink only when its files match the private checkout. A directory that differs, or a symlink that already points somewhere else, is left alone and named in the output.

## Use

```sh
./ai-dotfiles audit
./ai-dotfiles link --dry-run
./ai-dotfiles link
```

Clone the private repo as `../ai-dotfiles-private`, or set `AI_DOTFILES_PRIVATE` to its path. Removing that checkout breaks the symlinks.

## What it does not change

- `~/.claude.json` and `~/.claude/settings.json`
- `~/.codex/config.toml`
- `~/.cursor/mcp.json` and `~/.cursor/cli-config.json`
- `~/.grok/config.toml`
- `~/.pi/agent/settings.json`

MCP entries and settings stay where each harness wrote them. The audit prints server names and on/off state. It does not print URLs, tokens, or environment values.

Windows is out of scope. The script is POSIX `sh` plus `python3` for reading JSON and TOML during `audit`. `link` does not need Python.
