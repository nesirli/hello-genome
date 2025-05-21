# hello-genome 🚀

**Tiny, portable `faSize` in a \~5 MB container.**

`hello-genome` packages the UCSC **faSize** utility so you can sanity‑check any FASTA file—on a laptop, in CI, or on an HPC cluster—*without* installing the 800 MB Kent source tree.

[![Build & Push](https://github.com/<USERNAME>/hello-genome/actions/workflows/docker.yml/badge.svg)](https://github.com/<USERNAME>/hello-genome/actions/workflows/docker.yml)

---

## 📌 Purpose

Genome pipelines burn hours of CPU; a corrupted or mislabeled FASTA wastes all of it.
`hello-genome` gives you a lightning‑fast pre‑flight check that reports:

| Metric             | Insight it provides                           |
| ------------------ | --------------------------------------------- |
| **Size**           | Detect truncated downloads or extra scaffolds |
| **GC %**           | Spot contamination (e.g. bacterial contigs)   |
| **N % / gaps**     | Gauge assembly completeness                   |
| **Sequence count** | Confirm expected chromosomes/contigs          |

Because the tool is wrapped in a minimal container (BusyBox + one binary) it **starts in milliseconds** and **pulls in seconds**, even on quota‑restricted HPC filesystems.

---

## 🚀 What this repo does

1. **Builds** a multistage Docker image (`Dockerfile.hello-genome`) that compiles `faSize` from source, then ships *only* the binary on a BusyBox base.
2. **Publishes** the image to **GitHub Container Registry (GHCR)** via a GitHub Actions workflow (`.github/workflows/docker.yml`) on every push *and* a weekly cron job.
3. **Distributes** HPC artefacts: a Singularity/Apptainer conversion recipe and an example Slurm script (`slurm/hello-genome.slurm`).
4. **Documents** usage (this `README.md`) so the image is copy‑pasta‑ready for pipelines, CI matrices, and teaching demos.

---

## 🏃 Quick start

```bash
# Build locally
git clone https://github.com/<USERNAME>/hello-genome.git
cd hello-genome
docker build -f Dockerfile.hello-genome -t hello-genome .

# Run a genome QC (mount your FASTA)
docker run --rm -v $PWD:/data hello-genome faSize /data/GRCh38.fa
```

Example truncated output:

```
#seq  name      size        N%   GC%  gap
1     chr1  248,387,328   3.4  41.0  638
…
total     3,094,753,649   3.2  40.9  9,421 gaps
```

---

## 🖥️ HPC usage (Singularity / Apptainer + Slurm)

```bash
# Convert once (workstation or login node)
apptainer pull hello-genome.sif docker://ghcr.io/<USERNAME>/hello-genome:latest

# Copy genome to shared storage, then submit
sbatch slurm/hello-genome.slurm
```

The provided Slurm script requests 4 CPUs for 10 minutes and saves output to `logs/faSize_<jobID>.out`. Tweak resources to match your cluster policy.

---

## 🤖 CI / CD

* **Push → Build:** every commit to `main` rebuilds and pushes `ghcr.io/<USERNAME>/hello-genome:latest`.
* **Weekly cron:** Sunday 02:00 UTC job refreshes against the latest UCSC source.
* **Badges:** green = image current; red = investigate.

---

## 🗂️ Repo layout

```
.
├── Dockerfile.hello-genome        # two‑stage build (Ubuntu → BusyBox)
├── slurm/
│   └── hello-genome.slurm         # example Slurm batch script
└── .github/workflows/
    └── docker.yml                 # CI + weekly rebuild
```

---

## 📝 License

`hello-genome` is released under the MIT License.
`faSize` retains its original UCSC Kent source license.