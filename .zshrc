# Source Prezto.
if [[ -s "${ZDOTDIR:-$HOME}/.zprezto/init.zsh" ]]; then
  source "${ZDOTDIR:-$HOME}/.zprezto/init.zsh"
fi

# PATH & environment variables
source "$HOME/.zshrc.path"

# Terraform
export TF_CLI_ARGS_plan="--parallelism=50"
export TF_CLI_ARGS_apply="--parallelism=50"

# Environment variables
export EDITOR="vim"

# Alias
alias gbrm="git branch --merged|egrep -v '\*|main|develop|master'|xargs git branch -d"
alias g='cd $(ghq root)/$(ghq list | fzf)'
alias h='gh browse'
alias vsc='code -n .'
alias lc='git ls-files | xargs -n1 git --no-pager blame -w | wc -l'
alias rmcolor='sed -r "s/\x1B\[([0-9]{1,2}(;[0-9]{1,2})?)?[m|K]//g"'
alias tailjq='while read line; do echo ${line}| gsed -r "s/\x1B\[([0-9]{1,2}(;[0-9]{1,2})?)?[m|K]//g" | jq '.' ; done'
alias sed='gsed'
alias pr='gh pr create -a @me -w'
alias cpu='sudo powermetrics --samplers smc |grep -i "CPU die temperature"'

# Alternative unix command
alias acat='bat'
alias als='eza'
alias adu='dust'
alias tree='br'
alias atree='br'
[[ -f "$HOME/.config/broot/launcher/bash/br" ]] && source "$HOME/.config/broot/launcher/bash/br"

# share .zshhistory
setopt inc_append_history
setopt share_history

function fzf-history-selection() {
    BUFFER=$(history -n 1 | tail -r | awk '!a[$0]++' | fzf --query "$LBUFFER")
    CURSOR=$#BUFFER
    zle reset-prompt
}

zle -N fzf-history-selection
bindkey '^R' fzf-history-selection

_cmd_is_running=false
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

# Prompt (pure テーマ + PS1上書き)
PS1="🤔.oO( "

# Completions
source "$HOME/.zshrc.completion"

# Import other file
if [[ -s "$HOME/.bash_profile" ]]; then
  source $HOME/.bash_profile
fi
if [[ -s "$HOME/.zshrc.local" ]]; then
  source $HOME/.zshrc.local
fi
