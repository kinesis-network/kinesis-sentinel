#!/bin/sh

# 1. Start a background process to fix permissions once the socket exists
(
    # Wait up to 30 seconds for the socket to appear
    for i in $(seq 1 30); do
        if [ -S /var/run/tetragon/tetragon.sock ]; then
            chmod 666 /var/run/tetragon/tetragon.sock
            echo "Successfully set socket permissions to 666"
            break
        fi
        sleep 1
    done
) &

# 2. Launch Tetragon normally
# Using 'exec' ensures signals are passed to Tetragon correctly
exec "$@"