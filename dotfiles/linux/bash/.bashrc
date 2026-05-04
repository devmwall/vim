alias ll="eza -la --group-directories-first"
alias cat="batcat"
alias vim="nvim"

if command -v zoxide >/dev/null 2>&1; then
  eval "$(zoxide init bash)"
fi

if command -v fzf >/dev/null 2>&1; then
  eval "$(fzf --bash)"
fi

parse_git_branch() {
  git branch --show-current 2>/dev/null
}

set_bash_prompt() {
  local reset="\[\e[0m\]"
  local user_host="\[\e[1;36m\]\\u@\\h${reset}"
  local cwd="\[\e[1;34m\]\\w${reset}"
  local branch
  branch="$(parse_git_branch)"

  if [ -n "$branch" ]; then
    PS1="${user_host}:${cwd} \[\e[1;32m\](${branch})${reset}\\$ "
  else
    PS1="${user_host}:${cwd}\\$ "
  fi
}

PROMPT_COMMAND=set_bash_prompt
