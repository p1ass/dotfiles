# Source Prezto.
if [[ -s "${ZDOTDIR:-$HOME}/.zprezto/init.zsh" ]]; then
  source "${ZDOTDIR:-$HOME}/.zprezto/init.zsh"
fi

# Import other file
source $HOME/.bash_profile
source $HOME/.zshrc.kube

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

# Environment variables
export EDITOR="vim"

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

# Prompt
PS1="🤔.oO( "
source "/usr/local/opt/kube-ps1/share/kube-ps1.sh"
PS1='$(kube_ps1)'$PS1
kubeoff

#fuck
eval $(thefuck --alias)

# The next line updates PATH for the Google Cloud SDK.
export CLOUDSDK_PYTHON=$(which python)
if [ -f '/Users/plus/google-cloud-sdk/path.zsh.inc' ]; then . '/Users/plus/google-cloud-sdk/path.zsh.inc'; fi

# The next line enables shell command completion for gcloud.
if [ -f '/Users/plus/google-cloud-sdk/completion.zsh.inc' ]; then . '/Users/plus/google-cloud-sdk/completion.zsh.inc'; fi
