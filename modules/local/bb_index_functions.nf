process BBSPLIT_INDEX {
    tag "index"
    label 'process_high'

    conda "bioconda::bbmap=39.01"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/bbmap:39.01--h5c4e2a8_0':
        'biocontainers/bbmap:39.01--h5c4e2a8_0' }"

    input:
    path(reference_folder)

    output:
    path("ref_index"), emit: index

    script:

    // Join all ref genomes in to comma sep string
    def cmd = """
    echo "Generating bbsplit index. Note: Once indexes have been created you should"
    echo "define the folder in the params.ref_genomes_index to avoid regenerating each run"
    
    references=\$(ls ${reference_folder}/*.fna | tr '\\n' ',' | sed 's/,\$//')

    mkdir ref_index
    bbsplit.sh build=1 ref=\$references threads=${task.cpus} path=ref_index/
    """
    cmd
}

process ConcatenateGenomes {
    input:
        path(ref_genomes)

    output:
        path("concatenated_reference.fasta"), emit: ref_genomes_fasta

    script:
        def cmd = """
        cat ${ref_genomes}/*.fna > concatenated_reference.fasta
        """
        cmd
}


