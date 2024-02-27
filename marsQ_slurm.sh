#!/bin/bash
#SBATCH --partition=epyc_ssd       # the requested queue
#SBATCH --nodes=1              # number of nodes to use
#SBATCH --tasks-per-node=1
#SBATCH --cpus-per-task=2      #
#SBATCH --mem=4000	     # in megabytes, unless unit explicitly stated
#SBATCH --error=logs/%J.err         # redirect stderr to this file
#SBATCH --output=logs/%J.out        # redirect stdout to this file
##SBATCH --mail-user=passD1@Cardiff.ac.uk  # email address used for event notification
##SBATCH --mail-type=end                                   # email on job end
##SBATCH --mail-type=fail                                  # email on job failure
 
 
echo "Some Usable Environment Variables:"
echo "================================="
echo "hostname=$(hostname)"
echo \$SLURM_JOB_ID=${SLURM_JOB_ID}
echo \$SLURM_NTASKS=${SLURM_NTASKS}
echo \$SLURM_NTASKS_PER_NODE=${SLURM_NTASKS_PER_NODE}
echo \$SLURM_CPUS_PER_TASK=${SLURM_CPUS_PER_TASK}
echo \$SLURM_JOB_CPUS_PER_NODE=${SLURM_JOB_CPUS_PER_NODE}
echo \$SLURM_MEM_PER_NODE=${SLURM_MEM_PER_NODE}

module purge
module load nextflow
module load singularity

export NXF_SINGULARITY_CACHEDIR="/mnt/scratch2/GROUP-smbpk/singularity_cache"

workdir="/tmp/wrex_marsq"

nextflow run main.nf \
	-w "${workdir}/work" \
	-profile singularity_slurm \
	-with-trace "logs/${SLURM_JOB_ID}.trace.txt" \
	--pipeline map_only \
	--reads "${workdir}/fastq/*{R1,R2}.fastq.gz" \
	--outdir "${workdir}/results" \
	--ref_genomes_folder "${workdir}/refs" \
	-resume



#	--ref_genomes_folder "${workdir}/refs" \
#	--ref_genomes_index "${workdir}/ref_index/ref/" \

