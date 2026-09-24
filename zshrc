export PATH="/opt/homebrew/bin:$PATH"

# Path to your Oh My Zsh installation.
export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="robbyrussell"

plugins=(
    git
    zsh-autosuggestions
    zsh-syntax-highlighting
)

source $ZSH/oh-my-zsh.sh

# User configuration

# .env

#Essential
export ANDROID_HOME=$HOME/dev/.android/android-sdk
export ANDROID_SDK_ROOT=$ANDROID_HOME
export JAVA_HOME=/opt/homebrew/opt/openjdk@21/libexec/openjdk.jdk/Contents/Home
#export CHROME_EXECUTABLE="/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
#export CHROME_EXECUTABLE="/Applications/Brave Browser.app/Contents/MacOS/Brave Browser"
export CHROME_EXECUTABLE="/Applications/Helium.app/Contents/MacOS/Helium"

#Optional
export PATH=$PATH:$ANDROID_HOME/tools
export PATH=$PATH:$ANDROID_HOME/tools/bin
export PATH=$PATH:$ANDROID_HOME/platform-tools
export PATH=$PATH:$ANDROID_HOME/cmdline-tools/latest/bin
export PATH=$PATH:$ANDROID_HOME/emulator

# asdf
export PATH="${ASDF_DATA_DIR:-$HOME/.asdf}/shims:$PATH"

# append completions to fpath
fpath=(${ASDF_DATA_DIR:-$HOME/.asdf}/completions $fpath)
# initialise completions with ZSH's compinit
autoload -Uz compinit && compinit

export FLUTTER_ROOT="$(asdf where flutter)"

alias docker='podman'
alias docker-compose='podman-compose'


# Added by Antigravity
export PATH="/Users/ekakshjanweja/.antigravity/antigravity/bin:$PATH"

export PATH="/Users/ekakshjanweja/.bun/bin:$PATH"

# bun completions
[ -s "/Users/ekakshjanweja/.bun/_bun" ] && source "/Users/ekakshjanweja/.bun/_bun"

# claude aliases (isolated profiles via CLAUDE_CONFIG_DIR)

alias cldw='CLAUDE_CONFIG_DIR="$HOME/.claude-work" claude'
alias cldp='CLAUDE_CONFIG_DIR="$HOME/.claude-personal" claude'

export PATH="$HOME/.local/bin:$PATH"

# work codex
# uses ~/.codex-work for an isolated work account
codexw() {
  CODEX_HOME="$HOME/.codex-work" command codex "$@"
}



# Added by Antigravity IDE
export PATH="/Users/ekakshjanweja/.antigravity-ide/antigravity-ide/bin:$PATH"

# Keep-awake toggles: `awake` disables lid-close sleep, `sleep` (no args) restores it.
# `sleep <args>` still runs the normal /bin/sleep (e.g. `sleep 5`).
# `sleepstatus` shows the current state.
awake() {
  sudo pmset -a disablesleep 1 sleep 0 womp 1 tcpkeepalive 1 && caffeinate -dimsu & echo "awake: lid-close sleep disabled, caffeinate running"
}
sleep() {
  if [ $# -gt 0 ]; then
    command sleep "$@"
  else
    sudo pmset -a disablesleep 0; pkill caffeinate 2>/dev/null; echo "sleep: lid-close sleep restored"
  fi
}
sleepstatus() {
  local sd sl
  sd=$(pmset -g | awk '/SleepDisabled/ {print $2}')
  sl=$(pmset -g | awk '/^ sleep/ {print $2}')
  if [ "$sd" = "1" ]; then
    echo "awake: lid-close sleep DISABLED (SleepDisabled=$sd, sleep=$sl)"
  else
    echo "sleep: lid-close sleep enabled (SleepDisabled=${sd:-?}, sleep=${sl:-?})"
  fi
  if pgrep -x caffeinate >/dev/null 2>&1; then
    echo "caffeinate: running (pid $(pgrep -x caffeinate | tr '\n' ' '))"
  else
    echo "caffeinate: not running"
  fi
}
