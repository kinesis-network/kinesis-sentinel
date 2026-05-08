#!/bin/sh

# 1. Start a background process to fix permissions once the socket exists
(
  # Wait up to 30 seconds for the socket to appear
  for i in $(seq 1 30); do
    if [ -S /var/run/tetragon/tetragon.sock ]; then
      # Get current permissions in octal format (e.g., 660)
      # %a is the format for octal in most stat versions
      CURRENT_PERM=$(stat -c "%a" /var/run/tetragon/tetragon.sock)
      if [ "$CURRENT_PERM" != "666" ]; then
        chmod 666 /var/run/tetragon/tetragon.sock
        echo "Socket permissions were $CURRENT_PERM. Successfully updated to 666."
      else
        # Optional: log that it's already correct, or just stay silent
        echo "Socket permissions are already 666."
      fi
      break
    fi
    sleep 1
  done
) &
# 2. Launch Tetragon normally
exec "$@"
