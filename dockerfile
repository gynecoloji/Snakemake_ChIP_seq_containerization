FROM continuumio/miniconda3:latest

LABEL maintainer="gynecoloji@gmail.com"
LABEL description="ChIP-seq Analysis Pipeline with Snakemake"
LABEL version="1.0"

WORKDIR /Pipeline

# Install system dependencies
RUN apt-get update && apt-get install -y \
    wget \
    curl \
    git \
    build-essential \
    libz-dev \
    libbz2-dev \
    liblzma-dev \
    libcurl4-openssl-dev \
    libssl-dev \
    unzip \
    default-jre \
    procps \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Configure conda
RUN conda config --add channels defaults && \
    conda config --add channels bioconda && \
    conda config --add channels conda-forge && \
    conda config --set channel_priority flexible

# Copy environment files
COPY envs/ /pipeline/envs/

# Create conda environments
RUN conda env create -f /pipeline/envs/snakemake.yaml && \
    conda env create -f /pipeline/envs/macs2.yaml && \
    conda env create -f /pipeline/envs/bedtools.yaml && \
    conda env create -f /pipeline/envs/deeptools.yaml && \
    conda env create -f /pipeline/envs/idr.yaml && \
    conda clean -a -y

# Activate snakemake environment by default
RUN echo "source activate snakemake" > ~/.bashrc
ENV PATH /opt/conda/envs/snakemake/bin:$PATH

# Install additional tools in base/snakemake environment
# These are tools commonly used but might not be in the yaml files
RUN /opt/conda/envs/snakemake/bin/pip install --no-cache-dir \
    numpy \
    pandas

# Create directory structure
RUN mkdir -p /pipeline/ref \
    /pipeline/data \
    /pipeline/results \
    /pipeline/logs \
    /pipeline/envs

# Copy reference files (including your picard.jar)
COPY ref/ /pipeline/ref/

# Verify Picard installation
RUN java -jar /pipeline/ref/picard.jar --version || \
    echo "Picard installed but version check not available"

# Copy pipeline scripts and files
COPY snakefile_tolerant_ChIPseq /pipeline/

# Create entrypoint script
RUN echo '#!/bin/bash\n\
set -e\n\
\n\
# Activate snakemake environment\n\
source /opt/conda/etc/profile.d/conda.sh\n\
conda activate snakemake\n\
\n\
# If no arguments provided, show usage\n\
if [ $# -eq 0 ]; then\n\
    echo "ChIP-seq Analysis Pipeline"\n\
    echo "Usage:"\n\
    echo "  docker run [options] <image> [snakemake arguments]"\n\
    echo ""\n\
    echo "Examples:"\n\
    echo "  # Run full pipeline with 8 cores"\n\
    echo "  docker run -v /path/to/data:/pipeline/data -v /path/to/results:/pipeline/results <image> --cores 8"\n\
    echo ""\n\
    echo "  # Dry run to see what will be executed"\n\
    echo "  docker run -v /path/to/data:/pipeline/data <image> --cores 8 -n"\n\
    echo ""\n\
    echo "  # Run specific rule"\n\
    echo "  docker run -v /path/to/data:/pipeline/data <image> --cores 8 -R call_narrow_peaks"\n\
    echo ""\n\
    echo "  # Generate workflow diagram"\n\
    echo "  docker run <image> --dag | dot -Tpng > dag.png"\n\
    exit 0\n\
fi\n\
\n\
# Run snakemake with provided arguments\n\
exec snakemake -s /pipeline/snakefile_tolerant_ChIPseq --use-conda "$@"\n\
' > /pipeline/entrypoint.sh && chmod +x /pipeline/entrypoint.sh

# Set environment variables
ENV LANG=C.UTF-8 \
    LC_ALL=C.UTF-8 \
    PYTHONUNBUFFERED=1

# Set proper permissions
RUN chmod -R 755 /pipeline

# Set entrypoint
ENTRYPOINT ["/pipeline/entrypoint.sh"]

# Default command (empty - will show usage)
CMD []