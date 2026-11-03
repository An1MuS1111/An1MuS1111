# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

setopt histignorealldups sharehistory

# Use emacs keybindings even if our EDITOR is set to vi
bindkey -e

# Keep 1000 lines of history within the shell and save it to ~/.zsh_history:
HISTSIZE=1000
SAVEHIST=1000
HISTFILE=~/.zsh_history

# Use modern completion system
autoload -Uz compinit
compinit

zstyle ':completion:*' auto-description 'specify: %d'
zstyle ':completion:*' completer _expand _complete _correct _approximate
zstyle ':completion:*' format 'Completing %d'
zstyle ':completion:*' group-name ''
zstyle ':completion:*' menu select=2
eval "$(dircolors -b)"
zstyle ':completion:*:default' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*' list-colors ''
zstyle ':completion:*' list-prompt %SAt %p: Hit TAB for more, or the character to insert%s
zstyle ':completion:*' matcher-list '' 'm:{a-z}={A-Z}' 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=* l:|=*'
zstyle ':completion:*' menu select=long
zstyle ':completion:*' select-prompt %SScrolling active: current selection at %p%s
zstyle ':completion:*' use-compctl false
zstyle ':completion:*' verbose true

zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#)*=0=01;31'
zstyle ':completion:*:kill:*' command 'ps -u $USER -o pid,%cpu,tty,cputime,cmd'

# Export path variables from bash (remove if causes any issue)
export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:$PATH"

# init homebrew
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

# activate powerlevel10k
source /home/linuxbrew/.linuxbrew/share/powerlevel10k/powerlevel10k.zsh-theme

# rustup installation if not added already
export PATH=/home/linuxbrew/.linuxbrew/opt/rustup/bin:$PATH

# cargo init
export PATH="$HOME/.cargo/bin:$PATH"

# config for mise
eval "$(mise activate zsh)"

# config for clang-format
export PATH=/home/linuxbrew/.linuxbrew/opt/clang-format/bin:$PATH


# zoxide — smarter cd (`z proj`, `zi` interactive). Pairs with yazi.
if command -v zoxide >/dev/null 2>&1; then
  eval "$(zoxide init zsh)"
fi


# fzf — Ctrl-R history, Ctrl-T files, Alt-C directories
# brew install fzf && $(brew --prefix)/opt/fzf/install --key-bindings --completion --no-update-rc
if command -v fzf >/dev/null 2>&1; then
  source <(fzf --zsh)
  export FZF_DEFAULT_OPTS='--height 40% --layout=reverse --border'
  if command -v fd >/dev/null 2>&1; then
    export FZF_DEFAULT_COMMAND='fd --hidden --follow --exclude .git'
    export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
    export FZF_ALT_C_COMMAND='fd --type d --hidden --follow --exclude .git'
  fi
fi

# Initialize Starship Prompt (Replaces adam1)
# if command -v starship >/dev/null 2>&1; then
#   eval "$(starship init zsh)"
# fi

# init eza
alias ls='eza --icons --git'
alias ll='eza -l --header --icons --git'
alias la='eza -la --header --icons --git'
alias tree='eza --tree'
alias lt='eza -lT --level=2 --icons --git'

# Custom aliases for eazy access
alias proj='cd ~/proj/'
alias rust='cd ~/proj/rust/'

# Editors / rust
alias nv='nvim'
alias crun='cargo run'
alias cchk='cargo check'
alias cfmt='cargo fmt'
alias clippy='cargo clippy'

# environment variables
export EXPLABS_API_KEY="xpl_428901343a2f0c7a27472eb9cb4122c4dabffb49"

export EDITOR=nvim
export VISUAL=nvim
export PAGER=less
export LESS='-R'

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# installation for vcpkg
export VCPKG_ROOT="$HOME/dev/vcpkg"
export PATH="$VCPKG_ROOT:$PATH"
export CMAKE_TOOLCHAIN_FILE="$VCPKG_ROOT/scripts/buildsystems/vcpkg.cmake"
export PATH="$HOME/.local/bin:$PATH"

# cuda-13.3 installation
export PATH=/usr/local/cuda-13.3/bin${PATH:+:${PATH}}
export LD_LIBRARY_PATH=/usr/local/cuda-13.3/lib64${LD_LIBRARY_PATH:+:${LD_LIBRARY_PATH}}

# installation for ffmpeg-full
export PATH=/home/linuxbrew/.linuxbrew/opt/ffmpeg-full/bin:$PATH
# For compilers to find ffmpeg-full you may need to set:
export LDFLAGS=-L/home/linuxbrew/.linuxbrew/opt/ffmpeg-full/lib
export CPPFLAGS=-I/home/linuxbrew/.linuxbrew/opt/ffmpeg-full/include
# For pkgconf to find ffmpeg-full you may need to set:
export PKG_CONFIG_PATH=/home/linuxbrew/.linuxbrew/opt/ffmpeg-full/lib/pkgconfig

# Initialize vcpkg config
export VCPKG_ROOT="$HOME/vcpkg"
export PATH="$VCPKG_ROOT:$PATH"
