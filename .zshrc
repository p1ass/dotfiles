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
eval "$(goenv init -)"
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"
export PATH="$GOROOT/bin:$PATH"
export PATH="$GOPATH/bin:$PATH"
export PATH="$HOME/bin:$PATH"
eval "$(rbenv init -)"

# flutter
export PATH="$PATH:$HOME/ghq/github.com/flutter/flutter/bin"

# Environment variables
export EDITOR="vim"
export COMPOSE_HTTP_TIMEOUT=300

# Alias
alias ..="cd .."
alias ...="cd ../.."
alias gcm="git commit -m"
alias gbrm="git branch --merged|egrep -v '\*|develop|master'|xargs git branch -d"
alias k='kubectl'
alias g='cd $(ghq root)/$(ghq list | peco)'
alias goland='/usr/local/bin/goland .'
alias h='hub browse'
alias vsc='code -n .'
alias lc='git ls-files | xargs -n1 git --no-pager blame -w | wc -l'
alias mdtopdf='docker run -it --rm -v `pwd`:/workdir plass/mdtopdf mdtopdf'
alias w-mdtopdf='docker run -it --rm -v `pwd`:/workdir  plass/mdtopdf w-mdtopdf'
alias linecnt='git ls-files | xargs -n1 git --no-pager blame -w | wc -l'

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
# Prompt
PS1="🤔.oO( "

#fuck
eval $(thefuck --alias)


# The next line enables shell command completion for gcloud.
export PATH="$PATH:$HOME/google-cloud-sdk/bin"
if [ -f '/Users/plus/google-cloud-sdk/completion.zsh.inc' ]; then . '/Users/plus/google-cloud-sdk/completion.zsh.inc'; fi
