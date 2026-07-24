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
export CHROME_EXECUTABLE="/Applications/Google Chrome.app/Contents/MacOS/Brave Browser"

#Optional
export PATH=$PATH:$ANDROID_HOME/tools
export PATH=$PATH:$ANDROID_HOME/tools/bin
export PATH=$PATH:$ANDROID_HOME/platform-tools
export PATH=$PATH:$ANDROID_HOME/cmdline-tools/latest/bin
export PATH=$PATH:/$ANDROID_HOME/emulator

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

# claude alias

alias cldw='CLAUDE_CONFIG_DIR="$HOME/.claude-work" claude'

export PATH="$HOME/.local/bin:$PATH"
