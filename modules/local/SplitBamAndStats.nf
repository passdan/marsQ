process SplitBamAndStats_slow {
    tag "$meta.id"
    label 'process_high'

    conda "${moduleDir}/environment.yml"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/samtools:1.17--h00cdaf9_0' :
        'biocontainers/samtools:1.17--h00cdaf9_0' }"
    
    input:
        tuple val(meta), path(bam)
        path(reference_genomes)

    output:
        path "${meta.id}_${genome_base}.bam"
        path "${meta.id}_${genome_base}_coverage_stats.txt"

    script:
        """
        samtools view -@$task.cpus -ho ${meta.id}.sam ${bam}
        
        mkdir ${meta.id}_mapped_genomes
        mkdir ${meta.id}_mapped_genomes_stats
        
        for genome in ${reference_genomes}/*.fna; do
            genome_base=\$(basename \$genome .fna | cut -d'_' -f1,2)
            head -n1 ${meta.id}.sam > ${meta.id}_mapped_genomes/${meta.id}_\${genome_base}.sam
            ## grep  "^@PG" ${meta.id}.sam >> ${meta.id}_mapped_genomes/${meta.id}_\${genome_base}.sam
            grep -F \${genome_base}_%_ ${meta.id}.sam >> ${meta.id}_mapped_genomes/${meta.id}_\${genome_base}.sam

            samtools coverage ${meta.id}_mapped_genomes/${meta.id}_\${genome_base}.sam > ${meta.id}_mapped_genomes_stats/${meta.id}_\${genome_base}_coverage_stats.txt
            samtools coverage -m ${meta.id}_mapped_genomes/${meta.id}_\${genome_base}.sam > ${meta.id}_mapped_genomes_stats/${meta.id}_\${genome_base}_coverage_stats_graphic.txt

            ##samtools view -@${task.cpus} -bo ${meta.id}_\${genome_base}.bam ${meta.id}_\${genome_base}.sam
            ##rm ${meta.id}_\${genome_base}.sam
        done
        """
}

process SplitBamAndStats {
    tag "$meta.id"
    label 'process_high'

    conda "${moduleDir}/environment.yml"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/samtools:1.17--h00cdaf9_0' :
        'biocontainers/samtools:1.17--h00cdaf9_0' }"
    
    input:
        tuple val(meta), path(bam)
        path(reference_genomes)

    output:
        path("${meta.id}_mapped_genomes_stats/*_coverage_stats.txt"), emit: cov_stats
        path("${meta.id}_mapped_genomes_stats/*_coverage_stats_graphic.txt"), emit: cov_graphics

    script:
        """
        samtools view -@$task.cpus -F 4 -o ${meta.id}.sam ${bam}
        samtools view -H -o ${meta.id}_header.sam ${bam}
        
        mkdir ${meta.id}_mapped_genomes
        mkdir ${meta.id}_mapped_genomes_stats
        
        for genome in ${reference_genomes}/*.fna; do
            genome_base=\$(basename \$genome .fna | cut -d'_' -f1,2)
            head -n1 ${meta.id}_header.sam > ${meta.id}_mapped_genomes/${meta.id}_\${genome_base}.sam
            grep "^@SQ.*\${genome_base}" ${meta.id}_header.sam >> ${meta.id}_mapped_genomes/${meta.id}_\${genome_base}.sam
            grep "^@PG" ${meta.id}_header.sam >> ${meta.id}_mapped_genomes/${meta.id}_\${genome_base}.sam
        done

        awk -F'\t' -v meta_id="${meta.id}" '{
            split(\$3, arr, "_%_");
            genome_filename = meta_id "_mapped_genomes/" meta_id "_" arr[1] ".sam";
            print >> genome_filename
        }' "${meta.id}.sam"

        for genome in ${reference_genomes}/*.fna; do
            genome_base=\$(basename \$genome .fna | cut -d'_' -f1,2)
            samtools coverage ${meta.id}_mapped_genomes/${meta.id}_\${genome_base}.sam > ${meta.id}_mapped_genomes_stats/${meta.id}_\${genome_base}_coverage_stats.txt
            samtools coverage -m ${meta.id}_mapped_genomes/${meta.id}_\${genome_base}.sam > ${meta.id}_mapped_genomes_stats/${meta.id}_\${genome_base}_coverage_stats_graphic.txt
        done

        ##samtools view -@${task.cpus} -bo ${meta.id}_\${genome_base}.bam ${meta.id}_\${genome_base}.sam
        ##rm ${meta.id}_\${genome_base}.sam
        """
}

process SplitBam {
    tag "$meta.id"
    label 'process_high'

    conda "${moduleDir}/environment.yml"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/samtools:1.17--h00cdaf9_0' :
        'biocontainers/samtools:1.17--h00cdaf9_0' }"
    
    input:
        tuple val(meta), path(bam)
        path(reference_genomes)

    output:
        tuple val(meta), path("split_genomes/*"), emit: split_genomes

    script:
        """       
        mkdir ${meta.id}_split_genomes

        for ref in \$(samtools idxstats ${bam} | cut -f1 | grep -v '*'); do
            genome_base=\$(basename \$ref | cut -d'_' -f1,2)
            contig_base=\$(basename \$ref | cut -d' ' -f1)
            
            if [ ! -d "\$genome_base" ]; then 
                mkdir ${meta.id}_split_genomes/\${genome_base}
            fi

            samtools view -@${task.cpus} -b ${bam} | grep > ${meta.id}_split_genomes/\${genome_base}/${meta.id}_\${ref}.bam
        done
        """
}

process BamStats {
    tag "$meta.id"
    label 'process_high'

    conda "${moduleDir}/environment.yml"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/samtools:1.17--h00cdaf9_0' :
        'biocontainers/samtools:1.17--h00cdaf9_0' }"
    
    input:
        tuple val(meta), path(split_genomes)

    output:
        path "${meta.id}_${genome_base}_coverage_stats.txt"

    script:
        """
        for genome in $split_genomes; do
            echo "${meta.id}    \$genome"
            #samtools cat $split_genomes\${genome}/*.bam | samtools sort -@$task.cpus -o ${meta.id}_\${genome}.bam
            #samtools coverage -@$task.cpus ${meta.id}_\${genome}.bam > ${meta.id}_\${genome_base}_coverage_stats.txt
        done

        """
}