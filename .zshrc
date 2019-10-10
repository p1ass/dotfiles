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

# Environment variables
export EDITOR="vim"

# Alias
alias ..="cd .."
alias ...="cd ../.."
alias gcm="git commit -m"
alias gbrm="git branch --merged|egrep -v '\*|develop|master'|xargs git branch -d"
alias k='kubectl'
alias g='cd $(ghq root)/$(ghq list | peco)'
alias gh='hub browse $(ghq list | peco | cut -d "/" -f 2,3)'

# Prompt
PS1="🤔.oO( "
source "/usr/local/opt/kube-ps1/share/kube-ps1.sh"
PS1='$(kube_ps1)'$PS1


# The next line updates PATH for the Google Cloud SDK.
if [ -f '/Users/plus/google-cloud-sdk/path.zsh.inc' ]; then . '/Users/plus/google-cloud-sdk/path.zsh.inc'; fi

# The next line enables shell command completion for gcloud.
if [ -f '/Users/plus/google-cloud-sdk/completion.zsh.inc' ]; then . '/Users/plus/google-cloud-sdk/completion.zsh.inc'; fi
