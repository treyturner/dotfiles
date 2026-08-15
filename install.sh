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

link_github_cli_wrapper() {
  local source_path="$repo_dir/.local/bin/gh"
  local target_path="$HOME/.local/libexec/treyturner-dotfiles/gh"
  local obsolete_target="$HOME/.local/bin/gh"

  mkdir -p -- "$(dirname -- "$target_path")"

  if [[ -L "$obsolete_target" ]] &&
     [[ "$(readlink -f -- "$obsolete_target")" == "$(readlink -f -- "$source_path")" ]]; then
    rm -- "$obsolete_target"
    printf 'Removed obsolete wrapper link %s\n' "$obsolete_target"
  fi

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

prefer_github_cli_wrapper() {
  local shell_config="$1"
  local marker="# treyturner/dotfiles: prefer GitHub authentication wrapper"

  if [[ -f "$shell_config" ]] && grep -Fqx -- "$marker" "$shell_config"; then
    return
  fi

  printf '\n%s\n%s\n' \
    "$marker" \
    'export PATH="$HOME/.local/libexec/treyturner-dotfiles:$PATH"' >> "$shell_config"
  printf 'Updated PATH precedence in %s\n' "$shell_config"
}

link_file ".bash_aliases"
link_file ".gitconfig"
link_github_cli_wrapper

prefer_github_cli_wrapper "$HOME/.bashrc"

if [[ -e "$HOME/.bash_profile" ]]; then
  prefer_github_cli_wrapper "$HOME/.bash_profile"
elif [[ -e "$HOME/.bash_login" ]]; then
  prefer_github_cli_wrapper "$HOME/.bash_login"
else
  prefer_github_cli_wrapper "$HOME/.profile"
fi
