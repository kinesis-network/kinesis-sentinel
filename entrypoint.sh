#!/bin/sh
# Tetragon creates its gRPC socket root:root 0660, which only root can use.
# The consumer (dynamo) runs unprivileged, so once the socket exists it is
# handed to the consumer's group: SOCKET_GID names the group and the mode
# becomes 0660. The API has no auth of its own -- AddTracingPolicy accepts
# enforcer policies that kill processes, and DeleteTracingPolicy switches
# detection off -- so it must not be opened wider than that. Without
# SOCKET_GID (a hand-started container) the socket is made world-accessible
# as before, with a warning.
SOCK=/var/run/tetragon/tetragon.sock

# Wait for the socket with no deadline: loading the base sensor can take
# well over the old 30s on a slow box, and giving up left the socket unusable
# until the container restarted. The subshell dies with the container, since
# exec below replaces this shell with tetragon.
(
  while [ ! -S "$SOCK" ]; do
    sleep 1
  done
  if [ -n "$SOCKET_GID" ]; then
    chown "root:$SOCKET_GID" "$SOCK" && chmod 660 "$SOCK" \
      && echo "Socket $SOCK owned by root:$SOCKET_GID, mode 660" \
      || echo "WARN: could not set socket ownership/mode on $SOCK"
  else
    chmod 666 "$SOCK" \
      && echo "WARN: SOCKET_GID not set; socket $SOCK made world-accessible (666)" \
      || echo "WARN: could not chmod $SOCK"
  fi
) &

# Launch Tetragon normally
exec "$@"
