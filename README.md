# kinesis-sentinel
Node hardening solution: Tetragon packaged with Kinesis tracing policies.

The container publishes Tetragon's gRPC socket at `/var/run/tetragon/tetragon.sock`.
Pass `SOCKET_GID=<gid>` to have the entrypoint chown the socket to `root:<gid>`
with mode 0660, so only that group (the dynamo service user's) can reach the
API. Without it the socket is made world-accessible, which is fine for a
throwaway local run but not for a node.
