# syntax=docker/dockerfile:1.7
FROM ubuntu:22.04

# ARM & x86_64 packages are both in the main archive
RUN apt-get update -qq && \
    DEBIAN_FRONTEND=noninteractive \
    apt-get install -y --no-install-recommends ucsc-fasize && \
    rm -rf /var/lib/apt/lists/*

ENTRYPOINT ["faSize"]
CMD ["--help"]