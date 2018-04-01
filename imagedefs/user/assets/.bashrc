export PATH=~/bin:$PATH
export CLICOLOR=1

alias tree='tree -C'

GIT_PS1_SHOWCOLORHINTS=1
GIT_PS1_SHOWDIRTYSTATE=1

source /usr/share/bash-completion/completions/git
source /usr/local/sbin/git-prompt.sh

PS1='\[\033[01;33m\]\u\[\033[0m\]@\[\033[01;32m\]\h\[\033[0m\] \W\[\033[01;34m\]$(__git_ps1 " (%s)")\[\033[0m\]\[\033[01;36m\] λ\[\033[0m\] '

