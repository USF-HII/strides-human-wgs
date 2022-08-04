#!/usr/bin/env bash

BASE=$(readlink -f $(dirname $0))

PATH=${BASE}/tmp/mamba/bin:${PATH}

S3_PREFIX="usf-hii-niddk-teddy/output/run/human-wgs"

export PATH=$PATH:~/mamba/bin

c_snake() {
  snakemake \
    --jobs=100 \
    --kubernetes \
    --default-remote-provider=S3 \
    --default-remote-prefix="${S3_PREFIX}" \
    --use-conda \
    "$@"
}

c_rm() {
  aws s3 rm --recursive "s3://${S3_PREFIX}/work"
}

c_ls() {
  aws s3 ls --recursive "s3://${S3_PREFIX}/work"
}

#c_log() {
#  aws s3 cp s3://${S3_PREFIX}/logs/MICH518074222120_188_PDO-15661.log tmp/log.txt
#  cat tmp/log.txt
#}

if [[ $# -lt 1 ]]; then
  set | grep '^c_' | sed 's/^c_//' | cut -d' ' -f1
else
  cmd=$1; shift
  c_${cmd} "$@"
fi
