#!/usr/bin/env nextflow

/*
 * Hello redirect: write greeting to file
 */

process hello {
    output:
    path 'result.txt'

    script:
        """
        echo "Welcome to the world of Nextflow!" > result.txt
        """
}

workflow {
    hello()
}
