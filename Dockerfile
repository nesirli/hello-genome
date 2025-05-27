############################
# Stage "kent": full UCSC toolbox
############################
FROM icebert/ucsc_genome_browser:latest AS kent

############################
# Stage "runtime": minimal image
############################
FROM ubuntu:22.04 AS runtime
ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get update -qq && apt-get install -y --no-install-recommends zlib1g \
    && rm -rf /var/lib/apt/lists/*

# grab the proven-working binary from the first stage
COPY --from=kent /usr/local/bin/faSize /usr/local/bin/
RUN /usr/local/bin/faSize -h >/dev/null     # build-time smoke test

ENTRYPOINT ["faSize"]