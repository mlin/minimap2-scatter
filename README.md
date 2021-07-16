# minimap2-scatter

## WIP proof-of-concept

See also: https://github.com/mlin/minimap2/tree/distributed-mapping

How to:

```bash
git clone --recursive https://github.com/mlin/minimap2-scatter.git
cd minimap2-scatter

make  # builds Docker image locally

export MINIWDL__DOWNLOAD_CACHE__PUT=true
export MINIWDL__DOWNLOAD_CACHE__GET=true
export MINIWDL__DOWNLOAD_CACHE__DIR=/tmp/miniwdl_download_cache
miniwdl run _demo.wdl \
    db_fasta=s3://idseq-public-references/test/viral-alignment-indexes/viral_nt \
    fastq=https://github.com/chanzuckerberg/idseq-workflows/raw/main/short-read-mngs/test/norg_13__nacc_35__uniform_weight_per_organism__hiseq_reads__v10__R1.fastq.gz \
    fastq2=https://github.com/chanzuckerberg/idseq-workflows/raw/main/short-read-mngs/test/norg_13__nacc_35__uniform_weight_per_organism__hiseq_reads__v10__R2.fastq.gz \
    shards=4 --verbose
```
