# Source Prezto.
if [[ -s "${ZDOTDIR:-$HOME}/.zprezto/init.zsh" ]]; then
  source "${ZDOTDIR:-$HOME}/.zprezto/init.zsh"
fi

# Import other file
source $HOME/.bash_profile
source $HOME/.zshrc.kube
source $HOME/.zshrc.local

# any env
eval "$(direnv hook zsh)"
export GOENV_ROOT="$HOME/.goenv"
export PATH="$GOENV_ROOT/bin:$PATH"
export GOENV_DISABLE_GOPATH=1
eval "$(goenv init -)"
export PATH="$GOROOT/bin:$PATH"
export PATH="$GOPATH/bin:$PATH"
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"
export PATH="$HOME/bin:$PATH"
eval "$(rbenv init -)"
export PATH="$HOME/.plenv/bin:$PATH"
eval "$(plenv init - zsh)"
export PATH="$HOME/.jenv/bin:$PATH"
eval "$(jenv init -)"

source ~/perl5/perlbrew/etc/bashrc
export PATH="$HOME/.jenv/bin:$PATH"
eval "$(jenv init -)"

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
alias pr='gh pr create -a p1ass -w'
alias md2c='pandoc -f markdown -t textile <(pbpaste) | pbcopy' # コンフル形式に変換
alias cpu='sudo powermetrics --samplers smc |grep -i "CPU die temperature"'

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

function peco-select-history() {
    local tac
    if which tac > /dev/null; then
        tac="tac"
    else
        tac="tail -r"
    fi
    BUFFER=$(history -n 1 | \
        eval $tac | \
        peco --query "$LBUFFER")
    CURSOR=$#BUFFER
    zle clear-screen
}
zle -N peco-select-history
bindkey '^h' peco-select-history

function fd() {
  local dir
  dir=$(find ${1:-.} -path '*/\.*' -prune \
                  -o -type d -print 2> /dev/null | fzf +m) &&
  cd "$dir"
}

# Prompt
PS1="🤔.oO( "


# The next line updates PATH for the Google Cloud SDK.~
if [ -f "$HOME/google-cloud-sdk/path.zsh.inc" ]; then . "$HOME/google-cloud-sdk/path.zsh.inc"; fi

# The next line enables shell command completion for gcloud.
if [ -f "$HOME/google-cloud-sdk/completion.zsh.inc" ]; then . "$HOME/google-cloud-sdk/completion.zsh.inc"; fi


fpath+=~/.zfunc

autoload -U compinit
compinit

# sumo
export SUMO_HOME="/usr/local/opt/sumo/share/sumo"
export PATH="/usr/local/opt/expat/bin:$PATH"


autoload -U +X bashcompinit && bashcompinit
complete -o nospace -C /usr/local/bin/terraform terraform
