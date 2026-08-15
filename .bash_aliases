# Interactive shell preferences
alias ll='ls -alF'
alias gs='git status --short --branch'
alias gd='git diff'
alias gl='git log --oneline --decorate --graph -20'

# Obtain GitHub authentication from Coder only for each gh invocation.
gh() {
  local token

  if ! token="$(coder external-auth access-token treyturner-github)"; then
    printf '%s\n' "$token" >&2
    return 1
  fi

  GH_TOKEN="$token" command gh "$@"
}
