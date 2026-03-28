alias ll="eza -la --group-directories-first"
alias cat="batcat"
alias vim="nvim"

if command -v zoxide >/dev/null 2>&1; then
  eval "$(zoxide init bash)"
fi

if command -v fzf >/dev/null 2>&1; then
  eval "$(fzf --bash)"
fi
