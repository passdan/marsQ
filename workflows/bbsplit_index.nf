include { BBMAP_BBSPLIT } from '../modules/nf-core/bbmap/bbsplit/main'

workflow BBSPLIT_INDEX_REF_GENOMES {

    BBMAP_BBSPLIT ( [], ref_genomes_bbmap_index, [], [[],[]], false )

}
