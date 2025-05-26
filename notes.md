# Complete Usage Guide


---

## 1. Project Anatomy & Purpose

| Path                           | What it is                                                                                                                                                       | Why it matters                                                       |
| ------------------------------ | ---------------------------------------------------------------------------------------------------------------------------------------------------------------- | -------------------------------------------------------------------- |
| `Dockerfile`      | Two‑stage build that compiles the UCSC **faSize** binary in an Ubuntu builder, then copies the static executable into a 2 MB BusyBox runtime image.              | Final image is ≈ 5 MB – fast to pull even on quota‑limited clusters. |
| `.github/workflows/ci.yml` | GitHub Actions workflow that builds, tags, and pushes the image to **GitHub Container Registry (GHCR)** on every push to `main` and every Sunday via a cron job. | Keeps the container patched automatically.                           |
| `slurm/hello-genome.slurm`     | Minimal SLURM batch script that runs the container via **Apptainer/Singularity**.                                                                                | Shows exactly how to integrate the tool on HPC.                      |
| `README.md`                    | Quick‑start commands and explanation of output metrics.                                                                                                          | Good docs reduce onboarding time.                                    |

---

## 2. Key File Walk‑through

### 2.1 Dockerfile Highlights

```dockerfile
FROM ubuntu:22.04 AS builder            # full toolchain for static build
...
RUN make -C src/utils/faSize             # compile only faSize

FROM busybox:uclibc                      # ultra‑small runtime
COPY --from=builder /kent/bin/faSize /usr/local/bin/faSize
ENTRYPOINT ["faSize"]                   # so users can `docker run`
```

### 2.2 GitHub Actions Snippet

```yaml
- uses: docker/login-action@v3
  with:
    registry: ghcr.io
    username: ${{ github.actor }}          # user or bot triggering the workflow
    password: ${{ secrets.GITHUB_TOKEN }}
```

* `github.actor` – account that triggered the run.
* `${{ secrets.GITHUB_TOKEN }}` – repository secret.

### 2.3 SLURM Batch Script

```bash
#!/bin/bash
#SBATCH --job-name=hello-genome
#SBATCH --partition=cpu
#SBATCH --cpus-per-task=4      # faSize is single‑threaded; 4 is head‑room
#SBATCH --mem=4G
#SBATCH --time=00:10:00
#SBATCH --output=logs/%x-%j.out
#SBATCH --error=logs/%x-%j.err

set -euo pipefail
module load apptainer

apptainer exec hello-genome.sif \
  faSize /scratch/$USER/genomes/grch38.fa > grch38.qc
```

Mounting large FASTA files from `$SCRATCH` avoids stressing `$HOME`.

---


## 3. End‑to‑End Deployment Pipeline (CI to HPC)

1. **Fork or clone** the repo.
2. **Push** – GitHub Actions builds and publishes `ghcr.io/nesirli/hello-genome:latest`.
3. **On the HPC login node**:

   ```bash
   module load apptainer
   apptainer pull hello-genome.sif \
       docker://ghcr.io/nesirli/hello-genome:latest
   ```
5. **Submit** the SLURM script.
6. **Reuse** the cached `.sif` until a new tag is published.

---

## 4. Sizing Guidelines & Job Arrays

| Genome             | Typical wall time | Peak RAM  |
| ------------------ | ----------------- | --------- |
| Bacterial (\~5 Mb) | < 1 s             | \~ 20 MB  |
| Human GRCh38       | 30–45 s           | \~ 200 MB |

*Rule of thumb*: request **4 CPU, 4 GB, 10 min** per sample.

### Array Example

```bash
#SBATCH --array=1-500
FASTA=$(sed -n "${SLURM_ARRAY_TASK_ID}p" fastalist.txt)
apptainer exec hello-genome.sif faSize "$FASTA" > "${FASTA%.fa}.qc"
```

---

## 5. HPC Transfer & Execution Steps

### 5.1 Prerequisites

* Git 2.30 or newer – clone repository.
* `rsync` or `scp` – transfer files.
* SSH key configured on cluster.
* Apptainer/Singularity 1.1 or newer.
* SLURM 20.x or newer.

### 5.2 Clone Locally

```bash
git clone https://github.com/nesirli/hello-genome.git
cd hello-genome
```

### 5.3 Sync to Cluster

```bash
export CLUSTER=login.hpc.example.edu
export SCRATCH=/scratch/$USER/hello-genome
ssh "$CLUSTER" "mkdir -p $SCRATCH"
rsync -avP . "$CLUSTER:$SCRATCH"
```

### 5.4 Prepare Container on Cluster

```bash
ssh $CLUSTER
module load apptainer
cd $SCRATCH
apptainer pull hello-genome.sif \
    docker://ghcr.io/nesirli/hello-genome:latest
```

### 5.5 Dry‑Run (Optional)

```bash
wget -qO mini.fa https://hgdownload.soe.ucsc.edu/goldenPath/hg38/chromosomes/chrM.fa.gz
gunzip mini.fa.gz
apptainer exec hello-genome.sif faSize -detailed mini.fa
```

### 5.6 Submit Job

```bash
sbatch slurm/hello-genome.slurm
squeue -u $USER
```

### 5.7 Update to New Image Tag

```bash
apptainer pull --force hello-genome.sif \
    docker://ghcr.io/nesirli/hello-genome:$(date +%Y%m%d)
```

### 5.8 Cleanup

```bash
find $SCRATCH/logs -type f -mtime +14 -delete
rm -rf ~/.apptainer/cache  # free space if needed
```

---

## 6. Troubleshooting Quick‑Ref

| Symptom                    | Likely Fix                                                              |
| -------------------------- | ----------------------------------------------------------------------- |
| `FATAL: kernel too old`    | Use the cluster-provided Apptainer module.                              |
| Job killed `OUT OF MEMORY` | Increase `#SBATCH --mem=`.                                              |
| Cannot push to GHCR        | Confirm secret `HELLO_GENOME_PASS` exists and PAT has `write:packages`. |
| `image not found`          | Verify exact tag and case: `ghcr.io/<ORG>/hello-genome:<tag>`.          |


