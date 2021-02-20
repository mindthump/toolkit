#!/bin/bash

# Startup commands, etc. go here

sudo pip install --no-cache-dir --disable-pip-version-check -r ./requirements.txt

# Run CMD, usually a shell (e.g., /bin/bash)
exec "$@"
