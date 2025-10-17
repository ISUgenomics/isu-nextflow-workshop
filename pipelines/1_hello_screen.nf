#!/usr/bin/env nextflow

/*
 * Use echo to print a message to the screen
 */

process hello {

    output:
    stdout

    script:
    """
    echo "Welcome to the world of Nextflow!"
    """
}

workflow {
    // Run the hello process
    hello().view()
}
