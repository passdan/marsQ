<<<<<<< HEAD
# marsQ
Metagenomes against Reference Sequences Quantification
=======
# ![nf-core/marsq](docs/images/nf-core-marsq_logo_light.png#gh-light-mode-only) ![nf-core/marsq](docs/images/nf-core-marsq_logo_dark.png#gh-dark-mode-only)

## Introduction

**In development**

**nf-core/marsq** is a bioinformatics pipeline that ...

<!-- TODO nf-core:
   Complete this sentence with a 2-3 sentence summary of what types of data the pipeline ingests, a brief overview of the
   major pipeline sections and the types of output it produces. You're giving an overview to someone new
   to nf-core here, in 15-20 seconds. For an example, see https://github.com/nf-core/rnaseq/blob/master/README.md#introduction
-->

<!-- TODO nf-core: Include a figure that guides the user through the major workflow steps. Many nf-core
     workflows use the "tube map" design for that. See https://nf-co.re/docs/contributing/design_guidelines#examples for examples.   -->
<!-- TODO nf-core: Fill in short bullet-pointed list of the default steps in the pipeline -->

1. Read QC ([`FastQC`](https://www.bioinformatics.babraham.ac.uk/projects/fastqc/))
2. Present QC for raw reads ([`MultiQC`](http://multiqc.info/))
3. Maps reads agains reference genomes
4. Quantifies

## Usage
Reccomended running in the ```marsQ_slurm.sh```

```
nextflow run main.nf \
        -w "${workdir}/work" \
        -profile singularity_slurm \
        -with-trace "logs/${SLURM_JOB_ID}.trace.txt" \
        --pipeline map_only \
        --reads "${workdir}/fastq/*{R1,R2}.fastq.gz" \
        --outdir "${workdir}/results" \
        --ref_genomes_folder "${workdir}/refs" \
        -resume
```
refs is a folder containing genomes to map against. One file per genome. A useful tool to download a range of sequences is [genome_updater](https://github.com/pirovc/genome_updater)
