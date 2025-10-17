#!/usr/bin/env nextflow

params.reads = "03_Trimmed/AT_Illumina_paired_*fastq"
params.output_jf = "04_GenomeScope"

process JellyfishCount {
    publishDir params.output_jf, mode: 'copy'

    input:
    path reads

    output:
    path "reads.jf"

    script:
    """
    module load jellyfish
    jellyfish count -m 21 -s 100M -t 20 -C ${reads} -o reads.jf
    """
}

workflow {
    Channel
        .fromPath(params.reads)
        .set { illumina_reads }

    JellyfishCount(illumina_reads)
}
