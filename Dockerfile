############################
# Stage "kent": pull pre-built UCSC Genome Browser image
############################
FROM icebert/ucsc_genome_browser:latest AS kent

############################
# Stage "runtime": minimal image with just faSize
############################
FROM ubuntu:22.04 AS runtime

ARG DEBIAN_FRONTEND=noninteractive

# Install only what we need at runtime
RUN apt-get update -qq \
 && apt-get install -y --no-install-recommends \
      zlib1g \
      wget \
 && rm -rf /var/lib/apt/lists/*

# Fetch the standalone faSize binary directly from UCSC mirror
# (avoids COPY errors when its location inside the ICEBERT image changes)
RUN for i in 1 2 3; do \
      wget -qO /usr/local/bin/faSize \
           https://hgdownload.soe.ucsc.edu/admin/exe/linux.x86_64/faSize \
   && chmod +x /usr/local/bin/faSize \
   && break; \
   sleep 5; \
   done

ENTRYPOINT ["faSize"]