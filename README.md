# ChIP-seq Analysis Pipeline (Containerized)

A comprehensive, production-ready Snakemake workflow for ChIP-seq data analysis, fully containerized with Docker and deployable on HPC systems using Singularity.

![Docker Pulls](https://img.shields.io/docker/pulls/gynecoloji/chipseq_pipeline)
![Docker Image Size](https://img.shields.io/docker/image-size/gynecoloji/chipseq_pipeline/v1.0)
![GitHub Stars](https://img.shields.io/github/stars/gynecoloji/Snakemake_ChIP_seq_containerization?style=social)
![License](https://img.shields.io/github/license/gynecoloji/Snakemake_ChIP_seq_containerization)

## 📋 Table of Contents

- [Overview](#overview)
- [Features](#features)
- [Pipeline Workflow](#pipeline-workflow)
- [Requirements](#requirements)
- [Installation](#installation)
  - [Building with Docker](#building-with-docker)
  - [Converting to Singularity](#converting-to-singularity)
- [Usage](#usage)
  - [Docker Usage](#docker-usage)
  - [Singularity Usage on HPC](#singularity-usage-on-hpc)
  - [SLURM Job Submission](#slurm-job-submission)
- [Input Requirements](#input-requirements)
- [Configuration](#configuration)
- [Output Structure](#output-structure)
- [Advanced Options](#advanced-options)
- [Troubleshooting](#troubleshooting)
- [Citation](#citation)
- [Contact](#contact)

---

## 🔍 Overview

This pipeline performs comprehensive ChIP-seq analysis from raw FASTQ files to peak calling and visualization. It is designed for reproducibility and portability through containerization, making it ideal for both local analysis and HPC cluster environments.

**Key Technologies:**
- **Snakemake**: Workflow management
- **Docker**: Local containerization
- **Singularity**: HPC deployment
- **Conda**: Environment management within containers

---

## ✨ Features

- **Complete ChIP-seq workflow**: FastQC → Trimming → Alignment → Filtering → Peak calling
- **Simple Quality Control**: Simple QC at multiple steps (FastQC, Fastp, alignment metrics)
- **Flexible peak calling**: Supports both narrow (transcription factors) and broad (histone marks) peak modes
- **Input control support**: Optional input normalization for accurate peak calling
- **Blacklist filtering**: Removes reads from problematic genomic regions
- **Duplicate removal**: Picard-based PCR duplicate removal
- **Visualization**: BigWig file generation for genome browser visualization
- **Normalized tracks**: Input-normalized BigWig files when controls are available
- **Containerized**: Fully reproducible across different systems
- **HPC-ready**: Optimized for SLURM-based clusters via Singularity

**Tools included:**
- FastQC (v0.12.1)
- Fastp (v0.24.1)
- HISAT2 (v2.2.1)
- Samtools (v1.21)
- Picard (v3.1.1)
- BEDTools (v2.31.1)
- MACS2 (v2.2.7.1)
- deepTools (v3.5.6)
- MultiQC (v1.28)

---

## 🔄 Pipeline Workflow
```
Raw FASTQ files
    ↓
FastQC (Quality Control)
    ↓
Fastp (Trimming & Filtering)
    ↓
HISAT2 (Alignment)
    ↓
Samtools (Filtering & Sorting)
    ↓
Picard (Duplicate Removal)
    ↓
BEDTools (Blacklist Filtering)
    ↓
MACS2 (Peak Calling)
    ↓
deepTools (BigWig Generation)
    ↓
Results & simple QC Reports
```

---

## 📦 Requirements

### For Building (Docker)
- Docker (version 20.10+)
- 8GB+ RAM
- 50GB+ disk space

### For Running (Singularity on HPC)
- Singularity (version 3.0+)
- SLURM workload manager (or compatible job scheduler)
- 16GB+ RAM per job
- 8+ CPU cores recommended

### Input Data Requirements
- Paired-end FASTQ files (gzipped)
- Reference genome HISAT2 index
- Blacklist BED file for your genome
- Sample metadata CSV file

---

## 🛠️ Installation

### Building with Docker

**Step 1: Clone the repository**
```bash
git clone https://github.com/gynecoloji/Snakemake_ChIP_seq_containerization.git
cd Snakemake_ChIP_seq_containerization
```

**Step 2: Ensure you have all required files**

```bash
# Required structure for docker build:
# ├── Dockerfile
# ├── envs/
# │   ├── snakemake.yaml
# │   ├── macs2.yaml
# │   ├── bedtools.yaml
# │   ├── deeptools.yaml
# │   └── idr.yaml
# ├── ref/
# │   ├── picard.jar
# │   ├── blacklist-stats-script.py
# │   └── config.yaml
# ├── snakefile_tolerant_ChIPseq
# └── README.md
```

```bash
# Required structure for whole analysis:
# ├── Dockerfile
# ├── data/
# ├── results/
# ├── logs/
# ├── envs/
# │   ├── snakemake.yaml
# │   ├── macs2.yaml
# │   ├── bedtools.yaml
# │   ├── deeptools.yaml
# │   └── idr.yaml
# ├── ref/
# │   ├── ENSEMBL (hisat2 index files)
# │   ├── picard.jar
# │   ├── samples.csv
# │   ├── gencode.v36.annotation.gtf
# │   ├── hg38_blacklist_regions.bed
# │   ├── blacklist-stats-script.py
# │   └── config.yaml
# ├── snakefile_tolerant_ChIPseq
# └── README.md
```


**Step 3: Build the Docker image**
```bash
# Build locally
docker build -t chipseq-pipeline:v1.0 .

# Verify the build
docker images | grep chipseq-pipeline
```

**Step 4: Push to Docker Hub (for HPC access)**
```bash
# Login to Docker Hub
docker login

# Tag with your username
docker tag chipseq-pipeline:v1.0 gynecoloji/chipseq_pipeline:v1.0
docker tag chipseq-pipeline:v1.0 gynecoloji/chipseq_pipeline:latest

# Push to Docker Hub
docker push gynecoloji/chipseq_pipeline:v1.0
docker push gynecoloji/chipseq_pipeline:latest
```

### Converting to Singularity

**Method A: Pull directly from Docker Hub on HPC (RECOMMENDED)**
```bash
# On HPC cluster
module load singularity  # if needed

# Pull and convert in one step
singularity pull chipseq_pipeline.sif docker://gynecoloji/chipseq-pipeline:v1.0
```

**Method B: Convert from local Docker daemon**
```bash
# If Docker and Singularity are on the same machine
singularity build chipseq_pipeline.sif docker-daemon://chipseq-pipeline:v1.0
```

**Method C: Save Docker image and transfer**
```bash
# On local machine with Docker
docker save chipseq-pipeline:v1.0 -o chipseq_pipeline.tar

# Transfer to HPC
scp chipseq_pipeline.tar username@hpc.edu:/path/to/destination/

# On HPC, convert to Singularity
singularity build chipseq_pipeline.sif docker-archive://chipseq_pipeline.tar
```

---

## 🚀 Usage

### Docker Usage

**Basic usage (show help)**
```bash
docker run --rm chipseq-pipeline:v1.0
```

**Dry run (see what will be executed)**
```bash
docker run --rm \
    -v $(pwd)/data:/pipeline/data:ro \
    -v $(pwd)/ref:/pipeline/ref:ro \
    -v $(pwd)/results:/pipeline/results \
    -v $(pwd)/logs:/pipeline/logs \
    chipseq-pipeline:v1.0 \
    --cores 8 --use-conda -n -s /pipeline/snakefile_tolerant_ChIPseq -p
```

**Run full pipeline**
```bash
docker run --rm \
    -v $(pwd)/data:/pipeline/data:ro \
    -v $(pwd)/ref:/pipeline/ref:ro \
    -v $(pwd)/results:/pipeline/results \
    -v $(pwd)/logs:/pipeline/logs \
    chipseq-pipeline:v1.0 \
    --cores 8 --use-conda -s /pipeline/snakefile_tolerant_ChIPseq -p
```

### Singularity Usage on HPC

**Basic usage (show help)**
```bash
singularity pull chipseq_pipeline.sif docker://gynecoloji/chipseq_pipeline:v1.0

singularity run chipseq_pipeline.sif
```

**Dry run**
```bash
singularity run \
    --bind $(pwd)/data:/pipeline/data \
    --bind $(pwd)/ref:/pipeline/ref \
    --bind $(pwd)/results:/pipeline/results \
    --bind $(pwd)/logs:/pipeline/logs \
    chipseq_pipeline.sif \
    --cores 8 -n --use-conda -s /pipeline/snakefile_tolerant_ChIPseq -p
```

**Run full pipeline**
```bash
singularity run \
    --bind $(pwd)/data:/pipeline/data \
    --bind $(pwd)/ref:/pipeline/ref \
    --bind $(pwd)/results:/pipeline/results \
    --bind $(pwd)/logs:/pipeline/logs \
    chipseq_pipeline.sif \
    --cores 8 --use-conda -s /pipeline/snakefile_tolerant_ChIPseq -p
```

**Interactive mode (for testing/debugging)**
```bash
singularity shell \
    --bind $(pwd)/data:/pipeline/data \
    --bind $(pwd)/ref:/pipeline/ref \
    chipseq_pipeline.sif

# Inside the container
Singularity> conda activate snakemake
Singularity> snakemake --cores 8 --use-conda -s /pipeline/snakefile_tolerant_ChIPseq -p -n
```

### SLURM Job Submission

Create a SLURM submission script:
```bash
#!/bin/bash
#SBATCH --job-name=chipseq_pipeline
#SBATCH --output=logs/chipseq_%j.out
#SBATCH --error=logs/chipseq_%j.err
#SBATCH --time=24:00:00
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=20
#SBATCH --mem=64G
#SBATCH --partition=general

# Load Singularity module (if required)
module load singularity

# Set paths
DATA_DIR="/path/to/your/data"
REF_DIR="/path/to/your/ref"
RESULTS_DIR="/path/to/your/results"
LOGS_DIR="/path/to/your/logs"
SIF_FILE="/path/to/chipseq_pipeline.sif"

# Create output directories
mkdir -p ${RESULTS_DIR} ${LOGS_DIR}

# Run the pipeline
singularity run \
    --bind ${DATA_DIR}:/pipeline/data \
    --bind ${REF_DIR}:/pipeline/ref \
    --bind ${RESULTS_DIR}:/pipeline/results \
    --bind ${LOGS_DIR}:/pipeline/logs \
    ${SIF_FILE} \
    --cores ${SLURM_CPUS_PER_TASK} \
    --use-conda -s /pipeline/snakefile_tolerant_ChIPseq -p

echo "Pipeline completed successfully!"
```

Submit the job:
```bash
sbatch submit_chipseq.sh
```

---

## 📂 Input Requirements

### 1. FASTQ Files

Place paired-end FASTQ files in the `data/` directory with this naming convention:
```
data/
├── sample1_R1_001.fastq.gz
├── sample1_R2_001.fastq.gz
├── sample2_R1_001.fastq.gz
├── sample2_R2_001.fastq.gz
├── input1_R1_001.fastq.gz
└── input1_R2_001.fastq.gz
```

### 2. Sample Metadata (samples.csv)

Create a CSV file with the following structure:
```csv
sample_id,condition,replicate,input_control,peak_mode,notes
sample1,treatment,1,input1,narrow,H3K4me3 ChIP
sample2,treatment,2,input1,narrow,H3K4me3 ChIP
sample3,control,1,input2,broad,H3K27me3 ChIP
input1,input,1,,narrow,Input control for samples 1-2
input2,input,1,,broad,Input control for sample 3
```

**Column descriptions:**
- `sample_id`: Unique identifier matching FASTQ filename prefix
- `condition`: Experimental condition
- `replicate`: Biological replicate number
- `input_control`: Sample ID of the input control (leave empty for input samples)
- `peak_mode`: `narrow` for TFs/narrow peaks, `broad` for histone marks
- `notes`: Additional information (optional)

### 3. Reference Files (ref/config.yaml)

Create a configuration file:
```yaml
# ref/config.yaml

# Path to HISAT2 index (basename, without .1.ht2 extension)
hisat2_index: "/path/to/genome/index/hg38"

# Blacklist regions BED file
blacklist: "/path/to/hg38-blacklist.v2.bed"

# Effective genome size for BigWig normalization
# Human (hg38): 2913022398
# Mouse (mm10): 2652783500
effective_genome_size: 2913022398

# Sample metadata table
samples_table: "/path/to/samples.csv"
```

### 4. Required Reference Files

Ensure you have:
- **HISAT2 index**: Pre-built genome index files (`.ht2` files)
- **Blacklist file**: Download from [ENCODE](https://github.com/Boyle-Lab/Blacklist/tree/master/lists)
- **Picard JAR**: Should be in `ref/picard.jar`

---

## 📊 Output Structure
```
results/
├── fastqc/                          # Raw read QC reports
│   ├── sample1_R1_001_fastqc.html
│   └── sample1_R2_001_fastqc.html
├── fastp/                           # Trimmed reads and QC
│   ├── sample1_R1.trimmed.fastq.gz
│   ├── sample1_R2.trimmed.fastq.gz
│   ├── sample1.html
│   └── sample1.json
├── aligned/                         # Alignment files
│   ├── sample1.sam
│   └── sample1.sam.summary
├── filtered/                        # Filtered BAM files
│   ├── sample1.sorted.filtered.bam
│   └── sample1_summary.txt
├── dedup/                          # Deduplicated BAMs
│   ├── sample1.dedup.bam
│   └── sample1.dedup.metrics.txt
├── blacklist_filtered/             # Final filtered BAMs
│   ├── sample1.nobl.bam
│   ├── sample1.nobl.bam.bai
│   └── sample1.blacklisted.bam
├── peaks/                          # Peak calling results
│   ├── sample1_peaks.narrowPeak
│   ├── sample1_peaks.xls
│   └── sample1_summits.bed
├── bigwig/                         # Coverage tracks
│   └── sample1.bw
├── normalized_bigwig/              # Input-normalized tracks
│   └── sample1.normalized.bw
└── qc/                            # QC summary reports
    └── blacklist_filtering_stats.txt

logs/                               # All log files
├── fastqc/
├── fastp/
├── hisat2/
├── samtools/
├── dedup/
├── macs2/
└── blacklist_filter/
```

---

## ⚙️ Advanced Options

### Custom Snakemake Options
```bash
# Run specific rules only
singularity run --bind ... chipseq_pipeline.sif \
    --cores 8 -R fastp hisat2_align

# Force re-run of specific samples
singularity run --bind ... chipseq_pipeline.sif \
    --cores 8 --forcerun call_narrow_peaks

# Generate workflow diagram
singularity exec chipseq_pipeline.sif \
    snakemake -s /pipeline/snakefile_tolerant_ChIPseq --dag | dot -Tpng > workflow.png

# Run until a specific rule
singularity run --bind ... chipseq_pipeline.sif \
    --cores 8 --until remove_duplicates
```

### Modifying HISAT2 Alignment Parameters

The pipeline uses "tolerant mode" alignment parameters:
- `--score-min L,0,-0.6`
- `--mp 4,2`
- `--rdg 5,3 --rfg 5,3`

To modify these, edit the Snakefile before building the container.

### Adjusting MACS2 Peak Calling

Default parameters:
- Q-value cutoff: 0.05
- Genome: hs (human)
- Format: BAMPE (paired-end)

Modify in the Snakefile if needed before containerization.

---

## 🔧 Troubleshooting

### Issue: "Permission denied" errors

**Solution:** Ensure proper directory permissions and use `--bind` correctly:
```bash
chmod -R 755 /path/to/results
singularity run --bind /path/to/data:/pipeline/data:ro ...
```

### Issue: "Out of memory" errors

**Solution:** Increase memory allocation:
```bash
# In SLURM script
#SBATCH --mem=128G

# Or reduce thread count
singularity run ... --cores 4
```

### Issue: Conda environment activation fails

**Solution:** Ensure `--use-conda` flag is used:
```bash
singularity run ... chipseq_pipeline.sif --cores 8 --use-conda
```


### Issue: Singularity bind mount errors on HPC

**Solution:** Some HPC systems auto-bind certain paths. Check your system:
```bash
singularity exec chipseq_pipeline.sif env | grep SINGULARITY
```

### Getting Help

View detailed error logs:
```bash
# Check specific log files
cat logs/hisat2/sample1.log
cat logs/macs2/sample1_narrow.log
```

Run in debug mode:
```bash
singularity run --bind ... chipseq_pipeline.sif --cores 8 --verbose
```

---

## 📖 Pipeline Details

### Quality Control Steps

1. **FastQC**: Assess raw read quality
2. **Fastp**: 
   - Adapter trimming
   - Quality filtering (Q30+)
   - PolyG tail trimming
   - Minimum length 30bp
3. **Alignment metrics**: Via HISAT2 summary and Samtools flagstat
4. **Duplication rate**: Via Picard metrics
5. **Blacklist filtering**: Quantified in QC report

### Filtering Strategy

- **Properly paired reads**: Only concordant pairs kept
- **Primary alignments**: Secondary/supplementary alignments removed
- **Unique mapping**: Only uniquely mapped reads (NH:i:1 tag)
- **PCR duplicates**: Removed with Picard MarkDuplicates
- **Blacklist regions**: Fragments overlapping ENCODE blacklist removed

### Peak Calling Modes

**Narrow Peak Mode** (for transcription factors):
- Default settings for sharp peaks
- Includes summit calling
- Q-value cutoff: 0.05

**Broad Peak Mode** (for histone marks):
- Optimized for diffuse enrichment
- No summit calling
- Q-value cutoff: 0.05

---

## 📚 Citation

If you use this pipeline, please cite:

**Pipeline:**
```
GitHub: https://github.com/gynecoloji/SnakeMake_ChIP_seq_containerization
```

**Tools:**
- **Snakemake**: Mölder et al. (2021). F1000Research
- **FastQC**: Andrews S. (2010). Babraham Bioinformatics
- **Fastp**: Chen et al. (2018). Bioinformatics
- **HISAT2**: Kim et al. (2019). Nature Methods
- **Samtools**: Li et al. (2009). Bioinformatics
- **Picard**: Broad Institute
- **MACS2**: Zhang et al. (2008). Genome Biology
- **BEDTools**: Quinlan & Hall (2010). Bioinformatics
- **deepTools**: Ramírez et al. (2016). Nucleic Acids Research

---

## 📧 Contact

For questions, issues, or contributions:

- **GitHub Issues**: https://github.com/gynecoloji/SnakeMake_ChIPseq/issues
- **Email**: gynecoloji@gmail.com

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## 🙏 Acknowledgments

- ENCODE Consortium for blacklist regions
- Bioconda community for tool packaging
- Snakemake development team

---

**Last Updated:** January 2026  
**Version:** 1.0  
**Created by:** gynecoloji