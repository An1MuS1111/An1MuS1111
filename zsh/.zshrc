# path: ~/.zshrc
# Oh My Zsh + Powerlevel10k (instant prompt is inside — keep this first)
[[ -f "${XDG_CONFIG_HOME:-$HOME/.config}/zsh/oh-my-zsh.zsh" ]] && source "${XDG_CONFIG_HOME:-$HOME/.config}/zsh/oh-my-zsh.zsh"

# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:$HOME/.local/bin:/usr/local/bin:$PATH

# Export path variables from bash
export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:$PATH"

# Homebrew
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv zsh)"

# Cargo
export PATH="$HOME/.cargo/bin:$PATH"

# mise is loaded by the Oh My Zsh `mise` plugin (activate + completions).
# If you ever drop that plugin, uncomment:
eval "$(mise activate zsh)"

# For clang-format
export PATH="/home/linuxbrew/.linuxbrew/opt/clang-format/bin:$PATH"

# For golang path
if command -v go >/dev/null 2>&1; then
  export PATH="$PATH:$(go env GOPATH)/bin"
fi

# For vcpkg
export VCPKG_ROOT="$HOME/vcpkg"
export PATH="$VCPKG_ROOT:$PATH"
export CMAKE_TOOLCHAIN_FILE="$VCPKG_ROOT/scripts/buildsystems/vcpkg.cmake"

export PATH="$HOME/.local/bin:$PATH"

# -----------------------------------------------------------------------------
# History — better recall across tmux panes / Ghostty tabs
# -----------------------------------------------------------------------------
HISTFILE="${HISTFILE:-$HOME/.zsh_history}"
HISTSIZE=100000
SAVEHIST=100000
setopt SHARE_HISTORY
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_REDUCE_BLANKS
setopt HIST_VERIFY
setopt EXTENDED_HISTORY

# -----------------------------------------------------------------------------
# Completion quality
# -----------------------------------------------------------------------------
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' menu select
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"

# -----------------------------------------------------------------------------
# fzf — Ctrl-R history, Ctrl-T files, Alt-C directories
#   brew install fzf && $(brew --prefix)/opt/fzf/install --key-bindings --completion --no-update-rc
# -----------------------------------------------------------------------------
if command -v fzf >/dev/null 2>&1; then
  source <(fzf --zsh)
  export FZF_DEFAULT_OPTS='--height 40% --layout=reverse --border'
  if command -v fd >/dev/null 2>&1; then
    export FZF_DEFAULT_COMMAND='fd --hidden --follow --exclude .git'
    export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
    export FZF_ALT_C_COMMAND='fd --type d --hidden --follow --exclude .git'
  fi
fi

# -----------------------------------------------------------------------------
# zoxide — smarter cd (`z proj`, `zi` interactive). Pairs with yazi.
#   brew install zoxide
# -----------------------------------------------------------------------------
if command -v zoxide >/dev/null 2>&1; then
  eval "$(zoxide init zsh)"
fi

# -----------------------------------------------------------------------------
# eza
# -----------------------------------------------------------------------------
alias ls='eza --icons --git'
alias ll='eza -l --header --icons --git'
alias la='eza -la --header --icons --git'
alias tree='eza --tree'
alias lt='eza -lT --level=2 --icons --git'

# Editors / rust
alias nv='nvim'
alias crun='cargo run'
alias cchk='cargo check'
alias cfmt='cargo fmt'
alias clippy='cargo clippy'

export EDITOR=nvim
export VISUAL=nvim
export PAGER=less
export LESS='-R'

# Custom aliases for eazy access
alias proj='cd ~/proj/'
alias rust='cd ~/proj/rust/'
alias zshcfg="nvim ~/.zshrc"
alias omzcfg='nvim ${XDG_CONFIG_HOME:-$HOME/.config}/zsh/oh-my-zsh.zsh'
alias tmuxcfg='nvim ~/.tmux.conf'
alias termcfg='nvim ~/.config/alacritty/alacritty.toml'
alias nvimcfg='nvim ~/.config/nvim'
alias ghosttycfg='nvim ~/.config/ghostty/config.ghostty'

# Git extras on top of the omz git plugin (gst, gco, ggp, etc.)
alias lg='lazygit'
alias gs='git status -sb'
alias gd='git diff'
alias gds='git diff --staged'

# shell wrapper for yazi
function y() {
	local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
	command yazi "$@" --cwd-file="$tmp"
	IFS= read -r -d '' cwd < "$tmp"
	[ "$cwd" != "$PWD" ] && [ -d "$cwd" ] && builtin cd -- "$cwd"
	command rm -f -- "$tmp"
}

# Quick extract already covered by the `extract` plugin (`x file.tar.gz`)

# Added by Antigravity CLI installer
export PATH="/home/khalidrafi/.local/bin:$PATH"

# Added by LM Studio CLI tool (lms)
export PATH="$PATH:/home/khalidrafi/.lmstudio/bin"

# Added MANPATH for erlang
export MANPATH="/home/linuxbrew/.linuxbrew/opt/erlang/lib/erlang/man"

export WINIT_UNIX_BACKEND=x11

