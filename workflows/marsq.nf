/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    IMPORT NF-CORE MODULES/SUBWORKFLOWS
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

//
// MODULE: Installed directly from nf-core/modules
//
include { FASTQC        } from '../modules/nf-core/fastqc/main'
include { FASTP         } from '../modules/nf-core/fastp/main'
include { MULTIQC       } from '../modules/nf-core/multiqc/main'
include { BBMAP_INDEX   } from '../modules/nf-core/bbmap/index/main'
include { BBMAP_BBSPLIT } from '../modules/nf-core/bbmap/bbsplit/main'
include { BBMAP_ALIGN   } from '../modules/nf-core/bbmap/align/main'
include { SAMTOOLS_SORT   } from '../modules/nf-core/samtools/sort/main'
include { SAMTOOLS_INDEX   } from '../modules/nf-core/samtools/index/main'

include { ConcatenateGenomes   } from '../modules/local/bb_index_functions'
include { SplitBamAndStats; SplitBam; BamStats } from '../modules/local/SplitBamAndStats'


/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    RUN MAIN WORKFLOW
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

// Info required for completion email and summary
def multiqc_report = []



workflow MARSQ_FULL {
    take:
        read_pairs_ch
    
    main:
        //
        // MODULE: Run FastQC
        //
        FASTQC ( read_pairs_ch )

        //
        // MODULE: trim reads with fastp
        //

        FASTP ( read_pairs_ch, [], false, false )

        //
        // BBMAP ALIGN. Align the split FASTQ files back to their respective reference genomes.
        //
        BBMAP_ALIGN ( FASTP.out.reads, bbmap_index )
}


workflow MARSQ_BBSPLIT {
    take:
        read_pairs_ch
    
    main:
        // Reference genomes
        if (params.generate_DB) {
            // Generate BBmap index
            BBSPLIT_INDEX( params.ref_genomes_folder )
            bbsplit_index = BBSPLIT_INDEX.out.index_ch
        } 
        else {
            bbsplit_index = params.ref_genomes_index
        }
        //
        // MODULE: Run FastQC
        //
        FASTQC ( read_pairs_ch )

        //
        // MODULE: trim reads with fastp
        //

        FASTP ( read_pairs_ch, [], false, false )

        //
        // BBMAP SPLIT. Call BBMap with the index once per sample
        //
        BBMAP_BBSPLIT ( FASTP.out.reads, bbsplit_index, [], [[],[]], false )

}

workflow MARSQ_MAP_ONLY {
    take:
        read_pairs_ch

    main:    
        // Reference genomes
        if (params.generate_DB) {
            // Concatinate genomes
            ConcatenateGenomes( params.ref_genomes_folder )

            // Generate BBmap index
            BBMAP_INDEX( ConcatenateGenomes.out.ref_genomes_fasta )
            bbmap_index = BBMAP_INDEX.out.index
        } 
        else {
            bbmap_index = params.ref_genomes_index
        }

        //
        // BBMAP ALIGN. Align the split FASTQ files back to their respective reference genomes.
        //
        BBMAP_ALIGN ( read_pairs_ch, bbmap_index )
        SAMTOOLS_SORT( BBMAP_ALIGN.out.bam)
        SAMTOOLS_INDEX( SAMTOOLS_SORT.out.bam)

        //
        // Splits the mapped reads per genome
        //

        SplitBamAndStats( SAMTOOLS_SORT.out.bam, params.ref_genomes_folder )

        //BamStats( SplitBam.out.split_genomes)
        
}

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    THE END
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/
