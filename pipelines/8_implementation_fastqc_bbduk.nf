#!/usr/bin/env nextflow

//-- Configurable params
params.reads = '01_Data/*_{1,2}.fastq'
params.adapters = "${projectDir}/resources/adapters.fa"
params.trim_quality = 20
params.min_length = 25
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
    fastqc_ch = Channel.fromPath(params.reads)
    fastqc_ch.view()
    trim_ch = Channel.fromFilePairs(params.reads, flat:true)
    trim_ch.view()

    fastqc_ch | FastQC
    trimmed_reads_ch = trim_ch | BBDuk 
}