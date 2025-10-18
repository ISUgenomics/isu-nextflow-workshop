#!/usr/bin/env python3
"""
read_length_dist.py
Usage: read_length_dist.py output.tsv input1.fastq.gz [input2.fastq.gz ...]

Counts the number of reads of each length in one or more FASTQ files.
Outputs: TSV with columns  length  count  file
"""

import sys, gzip
from collections import Counter

def count_lengths(fname):    
    counts = Counter()
    with gzip.open(fname, 'rt') as f:
        for i, line in enumerate(f):
            if i % 4 == 1:  # sequence line
                counts[len(line.strip())] += 1
    return counts

if len(sys.argv) < 3:
    print(__doc__)
    sys.exit()

out_tsv = sys.argv[1]
infiles = sys.argv[2:]

with open(out_tsv, 'w') as out:
    out.write("length\tcount\tfile\n")
    for f in infiles:
        counts = count_lengths(f)
        for length, count in sorted(counts.items()):
            out.write(f"{length}\t{count}\t{f}\n")
