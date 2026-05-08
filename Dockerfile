FROM quay.io/cilium/tetragon:v1.7.0
COPY --chmod=755 entrypoint.sh /entrypoint.sh
RUN mkdir -p /etc/tetragon/tetragon.tp.d
COPY tetragon.tp.d/* /etc/tetragon/tetragon.tp.d/
ENTRYPOINT ["/entrypoint.sh"]
CMD ["tetragon", "--server-address", "unix:///var/run/tetragon/tetragon.sock"]
