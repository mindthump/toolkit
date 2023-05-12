## Setup some environment variables.
umask 002
export HISTSIZE=1000
export HISTIGNORE="&:[bf]g:exit"
export PS1="[\e[32m\u@\h\e[0m \w]\\$ "

alias la='ls -al --color'
export LESS='--raw'
