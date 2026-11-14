#!/bin/sh
# Exercise link and audit against a fake home. Does not touch the real one.
set -eu

cd "$(dirname "$0")"
root=$(mktemp -d)
trap 'rm -rf "$root"' EXIT INT TERM

mkdir -p "$root/.agents/skills/demo"
printf '%s\n' '---' 'name: demo' '---' '# demo' >"$root/.agents/skills/demo/SKILL.md"

mkdir -p "$root/.agents/skills/gstack/nested"
printf '%s\n' '---' 'name: nested' '---' >"$root/.agents/skills/gstack/nested/SKILL.md"

mkdir -p "$root/.cursor/skills-cursor/vendor-skill"
printf '%s\n' '---' 'name: vendor-skill' '---' >"$root/.cursor/skills-cursor/vendor-skill/SKILL.md"
ln -s "$root/.cursor/skills-cursor/vendor-skill" "$root/.agents/skills/vendor-skill"

mkdir -p "$root/.agents/skills/synced/old"
printf '%s\n' '---' 'name: old' '---' >"$root/.agents/skills/synced/old/SKILL.md"

mkdir -p "$root/.claude/skills/kept"
printf '%s\n' 'local' >"$root/.claude/skills/kept/SKILL.md"
mkdir -p "$root/.agents/skills/kept"
printf '%s\n' '---' 'name: kept' '---' >"$root/.agents/skills/kept/SKILL.md"

mkdir -p "$root/.codex/skills"
ln -s "$root/.agents/skills/missing-old" "$root/.codex/skills/demo"

export AI_DOTFILES_HOME="$root"

out=$(./ai-dotfiles link --dry-run)
printf '%s\n' "$out" | grep -q 'link    claude demo'
printf '%s\n' "$out" | grep -q 'replace codex demo'
printf '%s\n' "$out" | grep -q 'skip    claude kept'
printf '%s\n' "$out" | grep -q 'link    claude gstack'
! printf '%s\n' "$out" | grep -q 'vendor-skill'
! printf '%s\n' "$out" | grep -q ' synced'

./ai-dotfiles link >/dev/null
./ai-dotfiles link >/dev/null

for tool in .claude/skills .codex/skills .cursor/skills .pi/agent/skills; do
  [ -L "$root/$tool/demo" ]
  [ "$(readlink "$root/$tool/demo")" = "$root/.agents/skills/demo" ]
  [ -L "$root/$tool/gstack" ]
  [ ! -e "$root/$tool/vendor-skill" ]
  [ ! -e "$root/$tool/synced" ]
done
[ -d "$root/.claude/skills/kept" ]
[ ! -L "$root/.claude/skills/kept" ]

audit=$(./ai-dotfiles audit)
printf '%s\n' "$audit" | grep -q 'real skill directories: 3'
printf '%s\n' "$audit" | grep -q 'kept    kept'
printf '%s\n' "$audit" | grep -q 'Pi does not load MCP servers'
[ ! -e "$root/.claude.json" ]
[ ! -e "$root/.codex/config.toml" ]
[ ! -e "$root/.grok/config.toml" ]

echo "ok"
