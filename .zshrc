# zmodload zsh/zprof
# Personal Zsh configuration file. It is strongly recommended to keep all
# shell customization and configuration (including exported environment
# variables such as PATH) in this file or in files sourced from it.
#
# Documentation: https://github.com/romkatv/zsh4humans/blob/v5/README.md.

# Periodic auto-update on Zsh startup: 'ask' or 'no'.
# You can manually run `z4h update` to update everything.
zstyle ':z4h:' auto-update      'no'
# Ask whether to auto-update this often; has no effect if auto-update is 'no'.
zstyle ':z4h:' auto-update-days '28'

# Keyboard type: 'mac' or 'pc'.
zstyle ':z4h:bindkey' keyboard  'mac'

# Don't start tmux.
zstyle ':z4h:' start-tmux       no

# Mark up shell's output with semantic information.
zstyle ':z4h:' term-shell-integration 'yes'

# Right-arrow key accepts one character ('partial-accept') from
# command autosuggestions or the whole thing ('accept')?
zstyle ':z4h:autosuggestions' forward-char 'accept'

# Recursively traverse directories when TAB-completing files.
zstyle ':z4h:fzf-complete' recurse-dirs 'no'

# Enable direnv to automatically source .envrc files.
zstyle ':z4h:direnv'         enable 'no'
# Show "loading" and "unloading" notifications from direnv.
# zstyle ':z4h:direnv:success' notify 'yes'

# Enable ('yes') or disable ('no') automatic teleportation of z4h over
# SSH when connecting to these hosts.
# zstyle ':z4h:ssh:example-hostname1'   enable 'yes'
# zstyle ':z4h:ssh:*.example-hostname2' enable 'no'
# The default value if none of the overrides above match the hostname.
zstyle ':z4h:ssh:*'                   enable 'no'

# Send these files over to the remote host when connecting over SSH to the
# enabled hosts.
zstyle ':z4h:ssh:*' send-extra-files '~/.nanorc' '~/.env.zsh'
zstyle ':z4h:*' fzf-flags --color=hl:5,hl+:5,bg:-1,bg+:-1,border:7,info:3,prompt:2,pointer:4 --no-border

# Clone additional Git repositories from GitHub.
#
# This doesn't do anything apart from cloning the repository and keeping it
# up-to-date. Cloned files can be used after `z4h init`. This is just an
# example. If you don't plan to use Oh My Zsh, delete this line.
# z4h install ohmyzsh/ohmyzsh || return

# Install or update core components (fzf, zsh-autosuggestions, etc.) and
# initialize Zsh. After this point console I/O is unavailable until Zsh
# is fully initialized. Everything that requires user interaction or can
# perform network I/O must be done above. Everything else is best done below.
z4h init || return

# All overrides below use ANSI names — they resolve via ghostty's current
# theme palette, so swapping ghostty's `theme = ...` does not require edits here.

# History substring search highlight (Up/Down arrow with typed prefix).
# Default is bg=magenta,fg=white which is unreadable on most dark themes.
HISTORY_SUBSTRING_SEARCH_HIGHLIGHT_FOUND='fg=black,bg=cyan,bold'
HISTORY_SUBSTRING_SEARCH_HIGHLIGHT_NOT_FOUND='fg=white,bg=red,bold'

# Faded text for comments + autosuggestions.
# Pinned to catppuccin's `overlay0` because Catppuccin Mocha's bright-black
# (#585b70) renders too bright on this display — same class of issue we had
# under tokyonight. ANSI names work fine for most themes but specifically
# break for these two.
typeset -gA ZSH_HIGHLIGHT_STYLES
ZSH_HIGHLIGHT_STYLES[comment]='fg=#6c7086'
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=#6c7086'
# Previous attempts (uncomment to switch back):
# ZSH_HIGHLIGHT_STYLES[comment]='fg=bright-black'         # ANSI, theme-portable — too bright on catppuccin mocha
# ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=bright-black'
# ZSH_HIGHLIGHT_STYLES[comment]='fg=#565f89'              # tokyonight's comment hex
# ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=#565f89'

# Verify shell colour overrides + terminal theme. Run: colour-check
colour-check() {
  print -P "%F{cyan}-- live overrides --%f"
  print "history-found:     $HISTORY_SUBSTRING_SEARCH_HIGHLIGHT_FOUND"
  print "history-not-found: $HISTORY_SUBSTRING_SEARCH_HIGHLIGHT_NOT_FOUND"
  print "autosuggest:       $ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE"
  print "comment:           $ZSH_HIGHLIGHT_STYLES[comment]"
  print
  print -P "%F{cyan}-- ANSI 0-15 swatch (slot 6=cyan, slot 8=bright-black) --%f"
  local i
  for i in {0..15}; do
    printf '\e[48;5;%dm %2d \e[0m' $i $i
    (( (i+1) % 8 == 0 )) && print
  done
  print
  print -P "%F{cyan}-- manual triggers --%f"
  print "  type 'cd Doc' + Up        (history match  -> bg=cyan)"
  print "  type 'xyzqqq' + Up        (no match       -> bg=red)"
  print "  type 'echo # comment'     (comment        -> #6c7086)"
  print "  type a known prefix       (autosuggest    -> #6c7086)"
}

# Extend PATH. typeset -U dedupes on re-source.
typeset -U path PATH
export KEPLER_SDK_PATH=$HOME/kepler/sdk/0.20.3719
path=(~/bin $path)
path=("$HOME/.volta/bin" $path)
path=("$HOME/.local/bin" $path)
path=("$HOME/.bun/bin" $path)
path=("$HOME/tizen-studio/tools/" $path)
path=("$HOME/tizen-studio/tools/ide/bin" $path)
# path=("/opt/android-platform-tools/" $path)
path=(~/Android/Sdk/platform-tools/ $path)
path=(~/Android/Sdk/cmdline-tools/latest/bin $path)
# path=(/opt/webOS_TV_SDK/CLI/bin(N/) $path)
# path=("/Users/ryan.nash/Library/Application Support/JetBrains/Toolbox/scripts" $path)
path=(/opt/homebrew/opt/openjdk@17/bin $path)
path=($KEPLER_SDK_PATH/bin $KEPLER_SDK_PATH/bin/tools $path)
path=(/Applications/Prisma\ Access\ Agent.app/Contents/Helpers $path)

# Export environment variables.
export GPG_TTY=$TTY
export VOLTA_HOME="$HOME/.volta"
export ANDROID_HOME=~/Android/Sdk
export BUN_INSTALL="$HOME/.bun"
# export LG_WEBOS_TV_SDK_HOME="/opt/webOS_TV_SDK"

# Secrets live in ~/.env.zsh (chmod 600, never commit).
z4h source ~/.env.zsh

# Use additional Git repositories pulled in with `z4h install`.
#
# This is just an example that you should delete. It does nothing useful.
# z4h source ohmyzsh/ohmyzsh/lib/diagnostics.zsh  # source an individual file
# z4h load   ohmyzsh/ohmyzsh/plugins/emoji-clock  # load a plugin

# Autosuggest accept/partial-accept/clear widgets (vi-mode aware).
ZSH_AUTOSUGGEST_ACCEPT_WIDGETS=(vi-forward-char end-of-line)
ZSH_AUTOSUGGEST_PARTIAL_ACCEPT_WIDGETS=(forward-word)
ZSH_AUTOSUGGEST_CLEAR_WIDGETS+=(vi-cmd-mode)

# Define key bindings.
z4h bindkey undo Ctrl+/   Shift+Tab  # undo the last command line change
z4h bindkey redo Option+/            # redo the last undone command line change

z4h bindkey z4h-cd-back    Shift+Left   # cd into the previous directory
z4h bindkey z4h-cd-forward Shift+Right  # cd into the next directory
z4h bindkey z4h-cd-up      Shift+Up     # cd into the parent directory
z4h bindkey z4h-cd-down    Shift+Down   # cd into a child directory

# vi mode
bindkey -v
bindkey "^H" backward-delete-char
bindkey "^?" backward-delete-char
bindkey -M vicmd '^[[A' history-substring-search-up
bindkey -M vicmd '^[[B' history-substring-search-down
bindkey -M viins '^[[A' history-substring-search-up
bindkey -M viins '^[[B' history-substring-search-down
bindkey -M viins '^I' z4h-fzf-complete
bindkey -M viins '^R' z4h-fzf-history

# Autoload functions.
autoload -Uz zmv

# Define functions and completions.
function md() { [[ $# == 1 ]] && mkdir -p -- "$1" && cd -- "$1" }
compdef _directories md

# My funcs 
function getIp () {
  internal_ip=$(ipconfig getifaddr en0)
  external_ip=$(curl -s -4 --max-time 3 ifconfig.me || echo "(unavailable)")
  printf "%s\n%s\n" " $internal_ip" "󰖟 $external_ip"
}
cw() {
  local name="$1"
  local base="${2:-$(git symbolic-ref --short refs/remotes/origin/HEAD 2>/dev/null | sed 's@^origin/@@' || echo main)}"
  local repo_root
  repo_root="$(git worktree list --porcelain | awk '/^worktree /{print $2; exit}')" || return 1
  local wt_dir="$repo_root/.claude/worktrees/$name"

  git fetch origin "$base"
  git worktree add "$wt_dir" -b "$name" "origin/$base"

  # Locally-trusted HTTPS certs per worktree: Next's `--experimental-https` reads
  # apps/<app>/certificates/ relative to its cwd and only auto-generates a
  # localhost-only cert. Pre-seed each such app with a cert covering the dev domain
  # so https://local.dev.streaming.channel4.com:3000 is trusted with no warning.
  if command -v mkcert >/dev/null 2>&1; then
    local cert_domain="local.dev.streaming.channel4.com"
    local app_pkg app_dir
    for app_pkg in "$wt_dir"/apps/*/package.json(N); do
      grep -q -- '--experimental-https' "$app_pkg" || continue
      app_dir="${app_pkg%/package.json}"
      mkdir -p "$app_dir/certificates"
      mkcert -cert-file "$app_dir/certificates/localhost.pem" \
             -key-file "$app_dir/certificates/localhost-key.pem" \
             localhost "$cert_domain" 127.0.0.1 ::1 >/dev/null 2>&1 \
        && echo "  ✓ certs: ${app_dir:t} (localhost + $cert_domain)"
    done
  fi

  (cd "$wt_dir" && claude)
}

# Define named directories: ~w <=> Windows home directory on WSL.
[[ -z $z4h_win_home ]] || hash -d w=$z4h_win_home

# Define aliases.
alias tree='tree -a -I .git'
alias dotfiles="/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME"

alias ls='eza -A --color=auto'
alias vi="nvim"
alias vim="nvim"
alias prisma="pacli connect --best"
alias prismaDisconnect="pacli disconnect"

chromeDebug() {
  "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome" \
    --no-first-run \
    --activate-on-launch \
    --no-default-browser-check \
    --allow-file-access-from-files \
    --disable-web-security \
    --disable-translate \
    --proxy-auto-detect \
    --enable-blink-features=ShadowDOMV0 \
    --enable-blink-features=CustomElementsV0 \
    "$@" \
    &> /dev/null &
}

# Set shell options: http://zsh.sourceforge.net/Doc/Release/Options.html.
setopt glob_dots     # no special treatment for file names with a leading dot
setopt no_auto_menu  # require an extra TAB press to open the completion menu
# zprof

# zoxide: smart cd — `z <prefix>` jumps to most-frecent dir.
eval "$(zoxide init zsh)"

# bun completions
[ -s "/Users/ryan.nash/.bun/_bun" ] && source "/Users/ryan.nash/.bun/_bun"

# bun

