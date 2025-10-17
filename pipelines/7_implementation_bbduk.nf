#!/usr/bin/env nextflow

//-- Configurable params
params.reads = '01_Data/*_{1,2}.fastq'
params.adapters = "${projectDir}/resources/adapters.fa"
params.trim_quality = 20
params.min_length = 25
params.output_trim = '03_Trimmed'

process BBDuk {
  tag "${sample_id}"

  publishDir params.output_trim, mode: 'copy'

  input:
  tuple val(sample_id), path(read1), path(read2)

  output:
  tuple val(sample_id), 
      path("${sample_id}_1.trimmed.fastq"),
      path("${sample_id}_2.trimmed.fastq")

  script:
  """
  module load bbmap

  bbduk.sh \
    in1=${read1} in2=${read2} \
    out1=${sample_id}_1.trimmed.fastq \
    out2=${sample_id}_2.trimmed.fastq \
    ref=${params.adapters} \
    ktrim=4 k=23 mink=11 hdist=1 \
    qtrim=rl trimq=${params.trim_quality} \
    minlen=${params.min_length}
    """
}

workflow {
  Channel
    .fromFilePairs(params.reads, flat: true)
    .set { read_pairs }

    BBDuk(read_pairs)
}
