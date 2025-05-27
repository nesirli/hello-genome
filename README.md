# Hello Genome

[![Build & Push](https://github.com/nesirli/hello-genome/actions/workflows/ci.yml/badge.svg)](https://github.com/nesirli/hello-genome/actions/workflows/ci.yml)

**Tiny, portable `faSize` in a \~5 MB container.**

`hello-genome` packages the UCSC **faSize** utility so you can run a quick health check on FASTA files—locally or on an HPC cluster—*without* pulling in the full 800 MB Kent source tree.

---

## Purpose

Genome analysis pipelines can burn hours of compute time; a corrupted or mislabeled FASTA file wastes it all. `hello-genome` provides a lightning‑fast pre‑flight check that reports metrics such as sequence count, total length, longest/shortest record, and N-content.

---

## Installation & Build

You can either pull the published image from GitHub Container Registry or build it yourself.

### Pull from GHCR

```bash
docker pull ghcr.io/nesirli/hello-genome:latest
```

### Build Locally

```bash
git clone https://github.com/nesirli/hello-genome.git
cd hello-genome
docker build -t hello-genome .
```

---

## Usage

```bash
# Show help / view flags
docker run --rm hello-genome --help

# Basic size check
docker run --rm -v "$PWD":/data hello-genome /data/your_sequences.fasta
```

### faSize Flags

* `-detailed`     Output name and size for each record only.
* `-tab`          Emit tab-separated summary.
* `-veryDetailed` Show name, size, #Ns, #real, #upper, #lower per record.

**Example: Detailed record sizes**

```bash
docker run --rm -v "$PWD":/data hello-genome \
  -detailed \
  /data/your_sequences.fasta
```

---

## HPC Integration (Singularity / Apptainer + Slurm)

`hello-genome` also runs seamlessly on multi‑user clusters via Singularity (Apptainer).

### Prepare your FASTA

```bash
# Transfer and uncompress on the cluster
scp file.fasta.gz user@cluster:~/test/
cd ~/test
gunzip -c file.fasta.gz > file.fasta
```

### Pull & convert container

```bash
# On the login node (no Docker required)
apptainer pull hello-genome.sif \
    docker://ghcr.io/nesirli/hello-genome:latest
```

### Run interactively

```bash
apptainer run --bind $PWD:/data hello-genome.sif /data/file.fasta
```

### Slurm batch example

Save as `slurm/hello-genome.slurm`:

```bash
#!/bin/bash
#SBATCH --job-name=fasize
#SBATCH --output=fasize_%j.out
#SBATCH --mem=1G
#SBATCH --time=00:05:00

# Bind current dir into container
apptainer run --bind $PWD:/data $HOME/hello-genome.sif \
    /data/SRR30970561.fasta
```

Submit with:

```bash
sbatch slurm/hello-genome.slurm
```

---

## Continuous Integration

This repository includes a GitHub Actions workflow (`.github/workflows/ci.yml`) that builds and pushes multi‑arch images nightly and on every `main` update, then runs a smoke test against the published container.

---

## Repository Contents

```text
├── Dockerfile                 # Direct-download image for faSize
├── slurm/hello-genome.slurm   # Example Slurm script
├── .github/workflows/ci.yml   # CI pipeline for build & push
├── LICENSE                    # MIT License for this repo; faSize under UCSC license
└── README.md                  # This document
```

---

## License

`hello-genome` is released under the MIT License (see `LICENSE`).
`faSize` itself remains under the original UCSC Kent source license.
