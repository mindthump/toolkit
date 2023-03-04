#!/bin/bash
# For things that happen when a container is created, not possible in an image
# It does not run if 'command:' and/or 'args:' are used in a pod spec
# or exec'ing into a running pod

# Arguments are run as a command, usually a shell (e.g., /bin/zsh)
exec "$@"
