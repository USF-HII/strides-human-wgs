# STRIDES Human WGS Pilot

## Local Snakemake Setup

```bash
mamba_sh=https://github.com/conda-forge/miniforge/releases/latest/download/Mambaforge-Linux-x86_64.sh

mkdir -p ./tmp

curl -sSL ${mamba} > ./tmp/mamba.sh

bash tmp/mamba.sh -b -p ./tmp/mamba

/bin/env PATH=./tmp/mamba/bin:${PATH} \
  conda install \
    -c bioconda \
    -c conda-forge \
    snakemake-minimal \
    python-kubernetes \
    boto3
```

## Run

./run.sh snake
