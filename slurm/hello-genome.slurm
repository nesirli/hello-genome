#!/bin/bash
#SBATCH --job-name=faSize
#SBATCH --partition=compute
#SBATCH --cpus-per-task=4
#SBATCH --mem=4G
#SBATCH --time=00:10:00
#SBATCH --output=logs/faSize_%j.out

module load apptainer   # or singularity

# Convert or pull image once (outside the job) — see README
apptainer exec --bind $SCRATCH/genomes:/data hello-genome.sif \
  faSize /data/grch38.fa