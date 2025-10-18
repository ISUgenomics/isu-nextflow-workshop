#!/usr/bin/env nextflow

//-- Configurable params
params.reads = '01_data/*_{R1,R2}.fastq.gz'
params.output_qc = '02_IlluminaQC'
params.output_trim = '03_Trimmed'

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
    fastqc -t 2 ${sample_id}
    """
}

process Fastp {
  tag "${sample_id}"

  publishDir params.output_trim, mode: 'copy'

  input:
  tuple val(sample_id), path(read1), path(read2)

  output:
  tuple val(sample_id), 
      path("${sample_id}_1.trimmed.fastq.gz"),
      path("${sample_id}_2.trimmed.fastq.gz")

  script:
  """
  module load fastp

  fastp \
    -i ${read1} \
    -I ${read2} \
    -o ${sample_id}_1.trimmed.fastq.gz \
    -O ${sample_id}_2.trimmed.fastq.gz
   """
}

workflow {
    fastqc_ch = Channel.fromPath(params.reads)
    fastqc_ch.view()
    trim_ch = Channel.fromFilePairs(params.reads, flat:true)
    trim_ch.view()

    fastqc_ch | FastQC
    trimmed_reads_ch = trim_ch | Fastp 
    trimmed_reads_ch.view()
}
