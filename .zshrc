# Source Prezto.
if [[ -s "${ZDOTDIR:-$HOME}/.zprezto/init.zsh" ]]; then
  source "${ZDOTDIR:-$HOME}/.zprezto/init.zsh"
fi

# go
export GOROOT=/usr/local/go
export GOENV_DISABLE_GOPATH=1
export PATH="/usr/local/go/bin:$PATH"
export PATH="$HOME/go/bin:$PATH"

# path
eval "$(direnv hook zsh)"
export PATH="$HOME/bin:$PATH"


# asdf
export ASDF_DATA_DIR="$HOME/.asdf"
export PATH="$ASDF_DATA_DIR/shims:$PATH"
. ~/.asdf/plugins/java/set-java-home.zsh


export PATH="$HOME/google-cloud-sdk/bin:$PATH"

#poetry
export PATH="$HOME/.poetry/bin:$PATH"

# uv
. "$HOME/.local/bin/env"
source "$HOME/.zshrc.uv"

# scipy
export LIBRARY_PATH=$LIBRARY_PATH:/usr/local/opt/openssl/lib/

# flutter
export PATH="$PATH:$HOME/ghq/github.com/flutter/flutter/bin"

# Environment variables
export EDITOR="vim"

# Docker
export COMPOSE_DOCKER_CLI_BUILD=1
export COMPOSE_HTTP_TIMEOUT=300
export DOCKER_BUILDKIT=1

# Terraform
export TF_CLI_ARGS_plan="--parallelism=30"
export TF_CLI_ARGS_apply="--parallelism=30"


# Deno
export PATH="$HOME/.deno/bin:$PATH"

# Bun
export PATH="$HOME/.bun/bin:$PATH"

# Node
export NODE_PATH=$NODE_PATH:"$(yarn global dir)/node_modules"

# dotfiles bin
export PATH="$PATH:$HOME/ghq/github.com/p1ass/dotfiles/bin"

# buildpack
# . $(pack completion)

# Alias
alias gbrm="git branch --merged|egrep -v '\*|main|develop|master'|xargs git branch -d"
alias g='cd $(ghq root)/$(ghq list | peco)'
alias goland='/usr/local/bin/goland .'
alias h='hub browse'
alias vsc='code -n .'
alias lc='git ls-files | xargs -n1 git --no-pager blame -w | wc -l'
alias mdtopdf='docker run -it --rm -v `pwd`:/workdir plass/mdtopdf mdtopdf'
alias w-mdtopdf='docker run -it --rm -v `pwd`:/workdir  plass/mdtopdf w-mdtopdf'
alias linecnt='git ls-files | xargs -n1 git --no-pager blame -w | wc -l'
alias rmcolor='sed -r "s/\x1B\[([0-9]{1,2}(;[0-9]{1,2})?)?[m|K]//g"'
alias tailjq='while read line; do echo ${line}| gsed -r "s/\x1B\[([0-9]{1,2}(;[0-9]{1,2})?)?[m|K]//g" | jq '.' ; done'
alias sed='gsed'
alias pr='gh pr create -a @me -w'
alias md2c='pandoc -f markdown -t textile <(pbpaste) | pbcopy' # コンフル形式に変換
alias cpu='sudo powermetrics --samplers smc |grep -i "CPU die temperature"'

# Alternative unix command
alias acat='bat'
alias als='eza'
alias adu='dust'
alias tree='br'
alias atree='br'
source $HOME/.config/broot/launcher/bash/br

function peco-history-selection() {
    BUFFER=`history -n 1 | tac  | awk '!a[$0]++' | peco`
    CURSOR=$#BUFFER
    zle reset-prompt
}

zle -N peco-history-selection
bindkey '^R' peco-history-selection

# 5秒以上かかったコマンドの終了を通知する
# https://morishin.hatenablog.com/entry/2016/10/01/223731
function preexec () {
   _prev_cmd_start_time=$SECONDS
   _cmd_is_running=true
}
function precmd() {
  if $_cmd_is_running ; then
    _prev_cmd_exec_time=$((SECONDS - _prev_cmd_start_time))
    if ((_prev_cmd_exec_time > 5)); then
      terminal-notifier -message "Command execution finished" -sound default
    fi
  fi
  _cmd_is_running=false
}

# Prompt
PS1="🤔.oO( "

# The next line updates PATH for the Google Cloud SDK.~
if [ -f "$HOME/google-cloud-sdk/path.zsh.inc" ]; then . "$HOME/google-cloud-sdk/path.zsh.inc"; fi

# The next line enables shell command completion for gcloud.
if [ -f '$HOME/google-cloud-sdk/completion.zsh.inc' ]; then . '$HOME/google-cloud-sdk/completion.zsh.inc'; fi


fpath+=~/.zfunc

autoload -U +X bashcompinit && bashcompinit
autoload -Uz compinit && compinit
complete -C '/usr/local/bin/aws_completer' aws

complete -o nospace -C /usr/local/bin/terraform terraform

test -e "${HOME}/.iterm2_shell_integration.zsh" && source "${HOME}/.iterm2_shell_integration.zsh" || true

# 1Password
eval "$(op completion zsh)"; compdef _op op

# tabtab source for packages
# uninstall by removing these lines
[[ -f ~/.config/tabtab/zsh/__tabtab.zsh ]] && . ~/.config/tabtab/zsh/__tabtab.zsh || true

# Import other file
if [[ -s "$HOME/.bash_profile" ]]; then
  source $HOME/.bash_profile
fi
if [[ -s "$HOME/.zshrc.local" ]]; then
  source $HOME/.zshrc.local
fi

source $HOME/.config/broot/launcher/bash/br

source $HOME/.config/broot/launcher/bash/br

# pnpm
export PNPM_HOME="$HOME/Library/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end

# bun completions
[ -s "$HOME/.bun/_bun" ] && source "$HOME/.bun/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"


