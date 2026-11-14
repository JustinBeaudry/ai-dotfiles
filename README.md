# ai-dotfiles

One portable checkout for a small set of agent skills and MCP server examples. The `ai-dotfiles` script links the skills into Claude, Codex, Cursor, and Pi; Grok reads the shared `~/.agents/skills` directory directly. MCP examples are documentation and are never installed by the script.

## Skills

| Skill | Purpose |
| --- | --- |
| `task-graph` | Bounded work with graph, checks, and progress artifacts |
| `browser-routing` | Choose an available browser tool |
| `playwright-cli` | Interactive browser automation reference |
| `react-nextjs` | React 19 and Next.js implementation guidance |
| `use-spark` | Spark Desktop CLI reference; requires a working local `spark` command |

The copied skills are plain files under `skills/`. `task-graph` retains its source attribution. No private Git history is included.

## Install and audit

```sh
git clone https://github.com/JustinBeaudry/ai-dotfiles.git
cd ai-dotfiles
./ai-dotfiles audit
./ai-dotfiles link --dry-run
./ai-dotfiles link
```

`link` points `~/.agents/skills/<name>` at this checkout's `skills/<name>`, then links Claude, Codex, Cursor, and Pi to the shared names. It does not change MCP or harness settings. Existing nonmatching skill directories and links are kept. For a selected skill, a link to the former sibling `ai-dotfiles-private` checkout is migrated to this repo. Other skills in the old checkout are not migrated or removed.

Keep this checkout at a stable path: installed skills are symlinks to it. Use `AI_DOTFILES_HOME=/path/to/test-home` to target a different home directory. `AI_DOTFILES_PRIVATE` can point to the former private checkout if it was not next to this repo; it is used only to recognize old links during migration.

`audit` reports link status and MCP server **names** from local harness settings. It does not print server URLs, tokens, or environment values. Windows is outside the script's scope. The script uses POSIX `sh`; its MCP audit uses Python 3 for JSON and TOML parsing.

## MCP examples

The `mcp/` files show two servers:

- **Context7** uses its OAuth endpoint. Complete sign-in in the client when prompted.
- **Railway** launches `railway mcp`. Install and authenticate the Railway CLI separately.

Choose the matching file for your client and **merge** its server entries into your existing configuration. Do not replace a live config wholesale, and do not commit credentials or local settings:

| Client | Example | Live config to merge into |
| --- | --- | --- |
| Claude | `mcp/claude.json` | `~/.claude.json` (`mcpServers`) |
| Codex | `mcp/codex.toml` | `~/.codex/config.toml` (`mcp_servers`) |
| Cursor | `mcp/cursor.json` | `~/.cursor/mcp.json` (`mcpServers`) |

Project-specific servers and local application paths are intentionally absent. Pi does not load MCP servers. The script does not alter Grok's MCP imports or settings.

## Verify

```sh
./test.sh
./test-single-checkout.sh
```

Both tests use temporary home directories. `test-single-checkout.sh` covers migration of a selected skill's old symlink.
