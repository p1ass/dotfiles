# Source Prezto.
if [[ -s "${ZDOTDIR:-$HOME}/.zprezto/init.zsh" ]]; then
  source "${ZDOTDIR:-$HOME}/.zprezto/init.zsh"
fi

# Import other file
source $HOME/.bash_profile
# source $HOME/.zshrc.kube
source $HOME/.zshrc.local

# any env
export GOROOT=/usr/local/go
eval "$(direnv hook zsh)"
export GOENV_DISABLE_GOPATH=1
export PATH="/usr/local/go/bin:$PATH"
export PATH="$HOME/go/bin:$PATH"
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"
export PATH="$HOME/bin:$PATH"
eval "$(rbenv init -)"


# asdf
. /opt/homebrew/opt/asdf/libexec/asdf.sh
. ~/.asdf/plugins/java/set-java-home.zsh


source ~/perl5/perlbrew/etc/bashrc


# The next line enables shell command completion for gcloud.
export PATH="$HOME/google-cloud-sdk/bin:$PATH"

#poetry
export PATH="$HOME/.poetry/bin:$PATH"

# scipy
export LIBRARY_PATH=$LIBRARY_PATH:/usr/local/opt/openssl/lib/

# flutter
export PATH="$PATH:$HOME/ghq/github.com/flutter/flutter/bin"

# Environment variables
export EDITOR="vim"
export COMPOSE_HTTP_TIMEOUT=300

# Docker
export COMPOSE_DOCKER_CLI_BUILD=1
export DOCKER_BUILDKIT=1

# Deno
export PATH="$HOME/.deno/bin:$PATH"

# Node
export NODE_PATH=$NODE_PATH:"$(yarn global dir)/node_modules"

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
alias als='exa'
alias tree='br'
eval "$(mcfly init zsh)"

function gp () {
    local selected_pr_id=$(gh pr list | peco | awk '{ print $1 }')
    if [ -n "$selected_pr_id" ]; then
        BUFFER="gh pr checkout ${selected_pr_id}"
        zle accept-line
    fi
    zle clear-screen
}
zle -N gp
bindkey "^g^p" gp

function peco-history-selection() {
    BUFFER=`history -n 1 | tail -r  | awk '!a[$0]++' | peco`
    CURSOR=$#BUFFER
    zle reset-prompt
}

zle -N peco-history-selection
bindkey '^R' peco-history-selection

function fd() {
  local dir
  dir=$(find ${1:-.} -path '*/\.*' -prune \
                  -o -type d -print 2> /dev/null | fzf +m) &&
  cd "$dir"
}

function daily_start() {
    brew upgrade
    find $HOME/ghq -type d -maxdepth 3 -mindepth 3 | xargs -P 32 -IREPO_NAME zoekt-index -index $HOME/.zoekt -ignore_dirs=".git,.hg,.svn,node_modules" REPO_NAME
}

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
if [ -f "$HOME/google-cloud-sdk/completion.zsh.inc" ]; then . "$HOME/google-cloud-sdk/completion.zsh.inc"; fi


fpath+=~/.zfunc

autoload bashcompinit && bashcompinit
autoload -Uz compinit && compinit
complete -C '/usr/local/bin/aws_completer' aws

# sumo
export SUMO_HOME="/usr/local/opt/sumo/share/sumo"
export PATH="/usr/local/opt/expat/bin:$PATH"


autoload -U +X bashcompinit && bashcompinit
complete -o nospace -C /usr/local/bin/terraform terraform

test -e "${HOME}/.iterm2_shell_integration.zsh" && source "${HOME}/.iterm2_shell_integration.zsh" || true

