#!/usr/bin/env bash
set -Eeuo pipefail

repo_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

link_file() {
  local relative_path="$1"
  local source_path="$repo_dir/$relative_path"
  local target_path="$HOME/$relative_path"

  mkdir -p -- "$(dirname -- "$target_path")"

  if [[ -L "$target_path" ]] &&
     [[ "$(readlink -f -- "$target_path")" == "$(readlink -f -- "$source_path")" ]]; then
    return
  fi

  if [[ -e "$target_path" || -L "$target_path" ]]; then
    local backup="${target_path}.backup.$(date -u +%Y%m%dT%H%M%SZ)"
    mv -- "$target_path" "$backup"
    printf 'Backed up %s to %s\n' "$target_path" "$backup"
  fi

  ln -s -- "$source_path" "$target_path"
  printf 'Linked %s -> %s\n' "$target_path" "$source_path"
}

link_file ".bash_aliases"
link_file ".gitconfig"
