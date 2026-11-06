# Set up PATH before NVM so Homebrew cannot override the selected Node later.
typeset -U path PATH

if [[ -x /opt/homebrew/bin/brew ]]; then
  export HOMEBREW_PREFIX=/opt/homebrew
elif [[ -x /usr/local/bin/brew ]]; then
  export HOMEBREW_PREFIX=/usr/local
fi

export PNPM_HOME="$HOME/Library/pnpm"

if [[ -n "$HOMEBREW_PREFIX" ]]; then
  path=(
    "$HOMEBREW_PREFIX/opt/postgresql@17/bin"
    "$HOMEBREW_PREFIX/opt/openjdk@21/bin"
    "$HOMEBREW_PREFIX/bin"
    "$HOMEBREW_PREFIX/sbin"
    $path
  )

  if [[ -d "$HOMEBREW_PREFIX/opt/openjdk@21/libexec/openjdk.jdk/Contents/Home" ]]; then
    export JAVA_HOME="$HOMEBREW_PREFIX/opt/openjdk@21/libexec/openjdk.jdk/Contents/Home"
  fi
fi

# uv's default Python must take precedence over Homebrew's incidental Python.
path=(
  "$HOME/.local/bin"
  "$PNPM_HOME/bin"
  "$PNPM_HOME"
  "$HOME/go/bin"
  "$HOME/Library/Android/sdk/platform-tools"
  "/Applications/WezTerm.app/Contents/MacOS"
  $path
)

export EDITOR=nvim
export VISUAL=nvim
export ZSH="$HOME/.oh-my-zsh"
export NVM_DIR="$HOME/.nvm"

ZSH_THEME="miloshadzic"
zstyle ':omz:update' mode disabled

# Oh My Zsh provides these lazy wrappers; do not source nvm.sh a second time.
# Neovim must load Node too, because its language servers run as subprocesses.
zstyle ':omz:plugins:nvm' lazy yes
zstyle ':omz:plugins:nvm' lazy-cmd nvim eas

# Load syntax highlighting last so it sees all the other widgets.
plugins=(git copypath zsh-autosuggestions nvm fast-syntax-highlighting)

if [[ -r "$ZSH/oh-my-zsh.sh" ]]; then
  source "$ZSH/oh-my-zsh.sh"
else
  print -u2 'Oh My Zsh is not installed yet. Follow the dotfiles README.'
fi

alias vim="nvim"
alias vimrc='nvim "$HOME/.config/nvim"'
alias zshrc='nvim "$HOME/.zshrc"'
alias wezrc='nvim "$HOME/.wezterm.lua"'
alias dadbod='nvim "$HOME/.local/share/db_ui"'
alias grind="nvim leetcode.nvim"
alias lsplog='nvim "$HOME/.local/state/nvim/lsp.log"'

alias exti="exit"
alias eixt="exit"
alias localip="ipconfig getifaddr en0"

# Optional secrets and machine-specific settings, never tracked in Git.
if [[ -r "$HOME/.zshrc.local" ]]; then
  source "$HOME/.zshrc.local"
fi
