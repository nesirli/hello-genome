# Hello Genome

[![Build & Push](https://github.com/nesirli/hello-genome/actions/workflows/ci.yml/badge.svg)](https://github.com/nesirli/hello-genome/actions/workflows/ci.yml)

**Tiny, portable `faSize` in a \~5 MB container.**

`hello-genome` packages the UCSC **faSize** utility so you can run a quick health check on FASTA files—locally or on an HPC cluster—*without* pulling in the full 800 MB Kent source tree.

---

## Purpose

Genome analysis pipelines can burn hours of compute time; a corrupted or mislabeled FASTA file wastes it all. `hello-genome` provides a lightning‑fast pre‑flight check that reports metrics such as sequence count, total length, longest/shortest record, and GC content.

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

> **Note**: The included `Makefile` is a placeholder and not required for `faSize` itself.

---

## Usage

```bash
# Show help / view flags
docker run --rm hello-genome --help

# Basic size check
docker run --rm -v "$PWD":/data hello-genome /data/your_sequences.fasta
```

### faSize Flags

* `-detailed`           Output name and size for each record only. ([hgdownload.soe.ucsc.edu](https://hgdownload.soe.ucsc.edu/admin/exe/macOSX.x86_64/?utm_source=chatgpt.com))
* `-tab`                Emit tab-separated statistics. ([hgdownload.soe.ucsc.edu](https://hgdownload.soe.ucsc.edu/admin/exe/macOSX.x86_64/?utm_source=chatgpt.com))
* `-veryDetailed`       Show name, size, #Ns, #real, #upper, #lower per record. ([hgdownload.soe.ucsc.edu](https://hgdownload.soe.ucsc.edu/admin/exe/macOSX.x86_64/?utm_source=chatgpt.com))

**Example: Detailed record sizes**

```bash
docker run --rm -v "$PWD":/data hello-genome \
  -detailed \
  /data/your_sequences.fasta
```

---

## HPC Integration (Slurm)

An example Slurm batch script is provided at `slurm/hello-genome.slurm`:

```bash
sbatch slurm/hello-genome.slurm
```

---

## Continuous Integration

This repository includes a GitHub Actions workflow (`.github/workflows/ci.yml`) that builds and pushes the image nightly and on every `main` branch update, then runs a smoke test:

* Builds for `linux/amd64` and `linux/arm64`
* Pushes to GHCR
* Pulls the image and runs `faSize --help` to verify

---

## Repository Contents

```text
├── Dockerfile                 # Two‑stage build (UCSC image → Ubuntu runtime)
├── slurm/hello-genome.slurm   # Example Slurm script
├── .github/workflows/ci.yml   # CI pipeline for build & push
├── LICENSE                    # MIT License for this repo; faSize under UCSC license
├── README.md                  # This document
└── notes.md                   # Extended usage & troubleshooting notes
```

---

## License

`hello-genome` is released under the MIT License (see `LICENSE`).
`faSize` itself remains under the original UCSC Kent source license.
