#!/usr/bin/env nextflow

/*
* Create an output directory where the output will be saved
*/

process hello {
  publishDir 'output', mode: 'copy'

  output:
  path 'result.txt'

  script:
  """
  echo "Hello Nextflow World!" > result.txt
  """
}

workflow {
  // Run the hello process
  hello()
}
