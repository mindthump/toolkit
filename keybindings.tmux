# Put the prefix to C-b so it doesn't conflict with an "outer" tmux/byobu.

unbind-key -n C-b
set -g prefix ^B
bind b send-prefix
bind C-b last-window

bind s choose-tree
