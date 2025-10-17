#!/usr/bin/env nextflow

process hello {
    publishDir 'output', mode: 'copy'

    input:
    val welcome

    output:
    path 'result.txt'

    script:
    """
    echo "$welcome" > result.txt
    """
}

params.welcome = "Hello, welcome to the world of Nextflow!"

workflow {
    hello(params.welcome)
}