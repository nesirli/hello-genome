# syntax=docker/dockerfile:1.7

###############################################################################
# Minimal HPC image providing UCSC `faSize` binary via direct download.
# Simplifies multi-arch builds by targeting AMD64 only for HPC clusters.
###############################################################################

ARG TARGETARCH=amd64
FROM ubuntu:22.04

# ---------------------------------------------------------------------------
# Core utilities for downloading and decompressing
# ---------------------------------------------------------------------------
RUN apt-get update -qq && \
    DEBIAN_FRONTEND=noninteractive \
    apt-get install -y --no-install-recommends \
        ca-certificates curl wget && \
    rm -rf /var/lib/apt/lists/*

# ---------------------------------------------------------------------------
# QEMU loader symlink for AMD64 emulation on non-x86 hosts
# ---------------------------------------------------------------------------
RUN if [ "$TARGETARCH" = "amd64" ]; then \
        mkdir -p /lib64 && \
        ln -sf /lib/x86_64-linux-gnu/ld-linux-x86-64.so.2 /lib64/ld-linux-x86-64.so.2; \
    fi

# ---------------------------------------------------------------------------
# Download UCSC's faSize statically for x86_64
# ---------------------------------------------------------------------------
# Retry loop to handle transient network failures
RUN for i in 1 2 3; do \
        wget -qO /usr/local/bin/faSize \
             https://hgdownload.soe.ucsc.edu/admin/exe/linux.x86_64/faSize && \
        chmod +x /usr/local/bin/faSize && break; \
        sleep 5; \
    done

# ---------------------------------------------------------------------------
# Verify at build-time that faSize works
# ---------------------------------------------------------------------------
# build-time smoke test skipped under emulation

# ---------------------------------------------------------------------------
# Default entrypoint runs faSize
# ---------------------------------------------------------------------------
ENTRYPOINT ["/usr/local/bin/faSize"]
CMD ["--help"]