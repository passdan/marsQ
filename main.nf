#!/usr/bin/env nextflow
/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    nf-core/marsq
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    Github : https://github.com/nf-core/marsq
    Website: https://nf-co.re/marsq
    Slack  : https://nfcore.slack.com/channels/marsq
----------------------------------------------------------------------------------------
*/

nextflow.enable.dsl = 2

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    PRINT PARAMETER SUMMARY
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

log.info """\
 MARSQ   N F   P I P E L I N E
 ===================================
 reads        : ${params.reads}
 output       : ${params.outdir}
 ref genomes  : ${params.ref_genomes_folder}
 pipeline     : ${params.pipeline}
 """

// Raw reads
Channel
    .fromFilePairs( params.reads )
    .ifEmpty { error "Cannot find any reads matching: ${params.reads}" }
    .map { id, files ->
        def modified_baseName = id.split('\\.')[0]
        def meta = [ 'id': modified_baseName ]  // Create a meta map
        tuple(meta, files)
    }
    .set {fastq_files}


/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    NAMED WORKFLOWS FOR PIPELINE
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~S~~~~~~~~~~~~~~~~~~~
*/

include { MARSQ_FULL; MARSQ_MAP_ONLY } from './workflows/marsq'

//
// WORKFLOW: Run main nf-core/marsq analysis pipeline
//
workflow {
    if (params.pipeline == null || params.pipeline == "help") {
        println helpMessage
    }
    else if ( params.pipeline == "full_workflow" ) {
        MARSQ_FULL( fastq_files )
    }
    else if ( params.pipeline == "full_bbplit" ) {
        MARSQ_BBSPLIT( fastq_files )
    }
    else if ( params.pipeline == "map_only" ) {
        MARSQ_MAP_ONLY ( fastq_files )
    }
    else {
        println "ERROR ################################################################"
        println "Must select a pipeline"
        println ""
        println "To test the pipeline, use the \"demo\" pipeline or omit the pipeline flag:"
        println ""
        println "ERROR ################################################################"
        println "Exiting ..."
        System.exit(0)
    }
}

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    THE END
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/
