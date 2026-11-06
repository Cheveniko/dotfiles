#!/bin/bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage: bash scripts/install.sh [--dry-run] [--backup]

Link Zsh, WezTerm, Neovim, OpenCode, Claude Code, IdeaVim and Git to this checkout.
Only selected configuration files are linked for the AI tools; their data
directories stay untouched. No packages are installed.
Existing files are never overwritten. Use --backup to move conflicts into
~/.local/state/dotfiles/backups/ before linking, or --dry-run to only preview.
EOF
}

dry_run=false
backup=false
for arg in "$@"; do
  case "$arg" in
    --dry-run) dry_run=true ;;
    --backup) backup=true ;;
    --help|-h) usage; exit 0 ;;
    *) printf 'Unknown option: %s\n' "$arg" >&2; usage >&2; exit 1 ;;
  esac
done

repo_root="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd -P)"
sources=(
  "$repo_root/zsh/.zshrc"
  "$repo_root/wezterm/.wezterm.lua"
  "$repo_root/nvim/.config/nvim"
  "$repo_root/opencode/.config/opencode/opencode.json"
  "$repo_root/opencode/.config/opencode/cli.json"
  "$repo_root/opencode/.config/opencode/AGENTS.md"
  "$repo_root/claude/.claude/settings.json"
  "$repo_root/claude/.claude/CLAUDE.md"
  "$repo_root/ideavim/.ideavimrc"
  "$repo_root/git/.gitconfig"
  "$repo_root/git/.config/git/ignore"
)
relative_targets=(
  ".zshrc"
  ".wezterm.lua"
  ".config/nvim"
  ".config/opencode/opencode.json"
  ".config/opencode/cli.json"
  ".config/opencode/AGENTS.md"
  ".claude/settings.json"
  ".claude/CLAUDE.md"
  ".ideavimrc"
  ".gitconfig"
  ".config/git/ignore"
)
backup_root="${XDG_STATE_HOME:-$HOME/.local/state}/dotfiles/backups/$(date -u +%Y%m%dT%H%M%SZ)-$$"

is_linked() {
  [[ -L "$1" && "$(readlink "$1")" == "$2" ]]
}

# Check all targets before changing any of them.
for i in "${!sources[@]}"; do
  source_path="${sources[$i]}"
  target="$HOME/${relative_targets[$i]}"
  if [[ ! -e "$source_path" ]]; then
    printf 'Missing source: %s\n' "$source_path" >&2
    exit 1
  fi
  if is_linked "$target" "$source_path"; then
    continue
  fi
  if [[ -e "$target" || -L "$target" ]]; then
    if ! "$backup"; then
      printf 'Conflict: %s. Re-run with --backup to preserve it before linking.\n' "$target" >&2
      exit 1
    fi
    printf 'Back up: %s -> %s/%s\n' "$target" "$backup_root" "${relative_targets[$i]}"
  fi
  printf 'Link: %s -> %s\n' "$target" "$source_path"
done

if "$dry_run"; then
  exit 0
fi

for i in "${!sources[@]}"; do
  source_path="${sources[$i]}"
  target="$HOME/${relative_targets[$i]}"
  if is_linked "$target" "$source_path"; then
    continue
  fi
  if [[ -e "$target" || -L "$target" ]]; then
    backup_path="$backup_root/${relative_targets[$i]}"
    mkdir -p -- "$(dirname -- "$backup_path")"
    mv -- "$target" "$backup_path"
  fi
  mkdir -p -- "$(dirname -- "$target")"
  ln -s -- "$source_path" "$target"
done

printf 'Dotfiles linked. Open a new shell to load the Zsh configuration.\n'
