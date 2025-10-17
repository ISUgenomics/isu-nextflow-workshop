#!/usr/bin/env nextflow

params.reads = "01_Data/AT_Illumina_paired_*fastq"
params.output_qc = "02_IlluminaQC"

process FastQC {
    tag "${sample_id}"

    publishDir params.output_qc, mode: 'copy'

    input:
    path sample_id

    output:
    path "*.html"
    path "*.zip"

    script:
    """
    module load fastqc
    fastqc -o . -t 2 ${sample_id}
    """
}

workflow {
    Channel
    .fromPath(params.reads)
    .set { illumina_reads }

    FastQC(illumina_reads)
}
