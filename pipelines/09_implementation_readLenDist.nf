#!/usr/bin/env nextflow

params.reads = "03_trimmed/*fastq.gz"
params.output_rld = "04_read_len_dist"

process ReadLenDist {
    publishDir params.output_rld, mode: 'copy'

    input:
    path reads

    output:
    path "*.tsv"

    script:
    """
    read_length_dist.py sample_read_len_dist.tsv $reads
    """
}

workflow {
    Channel
        .fromPath(params.reads)
        .collect()
        .set { illumina_reads }

    ReadLenDist(illumina_reads)
}
