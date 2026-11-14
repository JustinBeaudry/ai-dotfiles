#!/bin/sh
# Exercise link and audit against a fake home. Does not touch the real one.
set -eu

cd "$(dirname "$0")"
root=$(mktemp -d)
trap 'rm -rf "$root"' EXIT INT TERM

mkdir -p "$root/.agents/skills/kept"
printf '%s\n' '---' 'name: kept' '---' '# local' >"$root/.agents/skills/kept/SKILL.md"
mkdir -p "$root/.claude/skills/kept"
printf '%s\n' 'local' >"$root/.claude/skills/kept/SKILL.md"
mkdir -p "$root/.cursor/skills-cursor/vendor-skill"
printf '%s\n' '---' 'name: vendor-skill' '---' >"$root/.cursor/skills-cursor/vendor-skill/SKILL.md"
ln -s "$root/.cursor/skills-cursor/vendor-skill" "$root/.agents/skills/vendor-skill"
mkdir -p "$root/.codex/skills"
ln -s "$root/.agents/skills/missing-old" "$root/.codex/skills/task-graph"

export AI_DOTFILES_HOME="$root"

fresh="$root/fresh-home"
fresh_out=$(AI_DOTFILES_HOME="$fresh" ./ai-dotfiles link --dry-run)
printf '%s\n' "$fresh_out" | grep -q 'link    canon task-graph'
[ ! -e "$fresh/.agents/skills" ]

out=$(./ai-dotfiles link --dry-run)
printf '%s\n' "$out" | grep -q 'link    canon task-graph'
printf '%s\n' "$out" | grep -q 'link    claude task-graph'
printf '%s\n' "$out" | grep -q 'replace codex task-graph'
if printf '%s\n' "$out" | grep -q 'vendor-skill'; then exit 1; fi
if printf '%s\n' "$out" | grep -q ' kept'; then exit 1; fi

./ai-dotfiles link >/dev/null
./ai-dotfiles link >/dev/null

for tool in .claude/skills .codex/skills .cursor/skills .pi/agent/skills; do
  [ -L "$root/$tool/task-graph" ]
  [ "$(readlink "$root/$tool/task-graph")" = "$root/.agents/skills/task-graph" ]
  [ ! -e "$root/$tool/vendor-skill" ]
done
[ "$(readlink "$root/.agents/skills/task-graph")" = "$(pwd)/skills/task-graph" ]
[ -d "$root/.claude/skills/kept" ]
[ ! -L "$root/.claude/skills/kept" ]

audit=$(./ai-dotfiles audit)
printf '%s\n' "$audit" | grep -q 'real skill directories: 5'
printf '%s\n' "$audit" | grep -q 'Pi does not load MCP servers'
[ ! -e "$root/.claude.json" ]
[ ! -e "$root/.codex/config.toml" ]
[ ! -e "$root/.grok/config.toml" ]

echo "ok"
