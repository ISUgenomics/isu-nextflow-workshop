#!/usr/bin/env nextflow

//-- Configurable params
params.reads = '01_data/*_{R1,R2}.fastq.gz'
params.output_trim = '03_Trimmed'

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
  Channel
    .fromFilePairs(params.reads, flat: true)
    .set { read_pairs }

  Fastp(read_pairs)
}
