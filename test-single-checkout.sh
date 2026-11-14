#!/bin/sh
# Exercise the single-checkout install and migration in an isolated home.
set -eu

cd "$(dirname "$0")"
root=$(mktemp -d)
trap 'rm -rf "$root"' EXIT INT TERM

repo="$root/ai-dotfiles"
old="$root/ai-dotfiles-private"
home="$root/home"
mkdir -p "$repo/skills/task-graph" "$old/skills/task-graph" "$old/skills/legacy-only" "$home/.agents/skills" "$home/.codex/skills"
cp ./ai-dotfiles "$repo/ai-dotfiles"
printf '%s\n' '---' 'name: task-graph' '---' '# current' >"$repo/skills/task-graph/SKILL.md"
printf '%s\n' '---' 'name: task-graph' '---' '# old' >"$old/skills/task-graph/SKILL.md"
ln -s "$old/skills/task-graph" "$home/.agents/skills/task-graph"
ln -s "$old/skills/legacy-only" "$home/.agents/skills/legacy-only"
ln -s "$home/.agents/skills/task-graph" "$home/.codex/skills/task-graph"

export AI_DOTFILES_HOME="$home"
out=$("$repo/ai-dotfiles" link --dry-run)
printf '%s\n' "$out" | grep -q 'migrate canon task-graph'
[ "$(readlink "$home/.agents/skills/task-graph")" = "$old/skills/task-graph" ]
[ "$(readlink "$home/.agents/skills/legacy-only")" = "$old/skills/legacy-only" ]

"$repo/ai-dotfiles" link >/dev/null
[ "$(readlink "$home/.agents/skills/task-graph")" = "$repo/skills/task-graph" ]
[ "$(readlink "$home/.codex/skills/task-graph")" = "$home/.agents/skills/task-graph" ]
[ "$(readlink "$home/.agents/skills/legacy-only")" = "$old/skills/legacy-only" ]
"$repo/ai-dotfiles" link >/dev/null

echo "ok"
