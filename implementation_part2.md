# Nextflow Implementation Tutorial: Building a Genomic Analysis Pipeline - Part 2

**Previous:** [implementation_part1.md](implementation_part1.md) - Scripts 06-08

This part covers Scripts 09-10, troubleshooting, and advanced topics to complete your Nextflow pipeline knowledge.

---

## Script 09: Collecting Multiple Files - ReadLenDist Analysis

**Learning Goals:**
- Learn the `.collect()` operator for aggregating channel items
- Understand when to use collection vs. individual processing
- Work with processes that need all files at once
- Learn about custom scripts in Nextflow

<details>
<summary>Click to see the complete script</summary>

**File:** `pipelines/09_implementation_readLenDist.nf`

```nextflow
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
        // .flatMap { it }
        // .view()

    ReadLenDist(illumina_reads)
}
```

</details>

### Understanding Collection

<details>
<summary>Why use .collect()?</summary>

**The Problem:**
Some tools need **all files at once** rather than processing them individually.

**Example:** A script that calculates read length distribution across **all samples** to create a single combined report.

**Without `.collect()`:**
```
Channel emits:
  03_trimmed/bio_sample_01_1.trimmed.fastq.gz  → Process runs
  03_trimmed/bio_sample_01_2.trimmed.fastq.gz  → Process runs
  03_trimmed/bio_sample_02_1.trimmed.fastq.gz  → Process runs
  ... (10 separate process executions)
```
Result: Process runs 10 times, once per file

**With `.collect()`:**
```
Channel emits:
  [03_trimmed/bio_sample_01_1.trimmed.fastq.gz,
   03_trimmed/bio_sample_01_2.trimmed.fastq.gz,
   03_trimmed/bio_sample_02_1.trimmed.fastq.gz,
   ... all 10 files]
```
Result: Process runs **once** with all files

</details>

<details>
<summary>The .collect() Operator</summary>

```nextflow
Channel
    .fromPath(params.reads)
    .collect()
    .set { illumina_reads }
```

**How it works:**

1. **`fromPath(params.reads)`**: Creates a channel with individual files
   ```
   bio_sample_01_1.trimmed.fastq.gz
   bio_sample_01_2.trimmed.fastq.gz
   bio_sample_02_1.trimmed.fastq.gz
   ... (10 files total)
   ```

2. **`.collect()`**: Waits for all items, then emits them as a single list
   ```
   [bio_sample_01_1.trimmed.fastq.gz, bio_sample_01_2.trimmed.fastq.gz, 
    bio_sample_02_1.trimmed.fastq.gz, ... all 10 files]
   ```

3. **`.set { illumina_reads }`**: Assigns to variable

**Important:** `.collect()` is a **blocking operation** - it waits for all upstream processes to complete!

</details>

<details>
<summary>The ReadLenDist Process</summary>

```nextflow
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
```

**Key Concepts:**

- **`input: path reads`**: Receives a **list** of file paths (from `.collect()`)
- **`$reads`**: In the script, this expands to all files separated by spaces:
  ```bash
  read_length_dist.py sample_read_len_dist.tsv \
    bio_sample_01_1.trimmed.fastq.gz \
    bio_sample_01_2.trimmed.fastq.gz \
    ... (all 10 files)
  ```
- **Custom script**: `read_length_dist.py` is a Python script that:
  - Takes an output filename as first argument
  - Takes multiple FASTQ files as remaining arguments
  - Analyzes read lengths across all files
  - Outputs a single TSV file with combined statistics

</details>

<details>
<summary>Commented Debug Lines</summary>

```nextflow
// .flatMap { it }
// .view()
```

These are commented-out debugging operators:

- **`.flatMap { it }`**: Would "uncollect" the list back to individual items
- **`.view()`**: Would print channel contents

**Useful for debugging!** Uncomment to see what the channel contains:
```nextflow
Channel
    .fromPath(params.reads)
    .collect()
    .view()  // Shows: [file1, file2, file3, ... file10]
    .set { illumina_reads }
```

</details>

### When to Use .collect()

<details>
<summary>Collection vs. Individual Processing</summary>

**Use `.collect()` when:**
- Tool needs all files simultaneously
- Creating a combined report/summary
- Comparing across all samples
- Merging results

**Examples:**
- MultiQC (aggregates QC reports)
- Read length distribution across all samples
- Genome assembly (needs all reads)

**Don't use `.collect()` when:**
- Tool processes files independently
- Want parallel execution per file/sample
- Each file produces separate output

**Examples:**
- FastQC (independent per file)
- Fastp (independent per sample)
- Alignment (independent per sample)

</details>

### Running Script 09

```bash
nextflow run pipelines/09_implementation_readLenDist.nf
```

**Expected Output:**
- `04_read_len_dist/sample_read_len_dist.tsv`: Single TSV file with read length statistics for all samples combined

**Note:** This script assumes trimmed files exist in `03_trimmed/` (from running Script 07 or 08 first)

## Script 10: The Full Pipeline - Channel Transformations

**Learning Goals:**
- Combine all processes into a complete workflow
- Learn the `.map()` operator for channel transformation
- Understand chaining collect after map
- See how data flows through a multi-step pipeline

<details>
<summary>Click to see the complete script</summary>

**File:** `pipelines/10_implementation_full.nf`

```nextflow
#!/usr/bin/env nextflow

//-- Configurable params
params.reads = '01_data/*_{R1,R2}.fastq.gz'
params.output_qc = '02_illuminaQC'
params.output_trim = '03_trimmed'
params.trimmed_reads = '03_trimmed/*fastq.gz'
params.output_rld = '04_read_len_dist'

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
      path("${sample_id}_R1.trimmed.fastq.gz"),
      path("${sample_id}_R2.trimmed.fastq.gz")

  script:
  """
  module load fastp

  fastp -i ${read1} \\
        -I ${read2} \\
        -o ${sample_id}_R1.trimmed.fastq.gz \\
        -O ${sample_id}_R2.trimmed.fastq.gz
  """
}

process ReadLenDist {
    publishDir params.output_rld, mode: 'copy'

    input:
    path reads

    output:
    path '*.tsv'

    script:
    """
    read_length_dist.py samples_read_len_dist.tsv $reads
    """
}

workflow {
    fastqc_ch = Channel.fromPath(params.reads)
    // fastqc_ch.view()
    trim_ch = Channel.fromFilePairs(params.reads, flat:true)
    // trim_ch.view()

    fastqc_ch | FastQC
    trimmed_output_ch = trim_ch | Fastp 

    trimmed_output_ch
        .map { sample_id, r1, r2 -> [r1, r2] }
        // .flatten()
        .collect()
        // .view()
        | ReadLenDist
}
```

</details>

### Understanding the Complete Workflow

<details>
<summary>Workflow Overview</summary>

**Data Flow:**

```
Raw Reads (01_data/)
    │
    ├───────────────────────────────────────────┐
    │                                               │
    ▼ (fromPath)                                   ▼ (fromFilePairs)
  FastQC                                          Fastp
    │                                               │
    ▼                                               ▼
  QC Reports                                  Trimmed Reads
  (02_illuminaQC/)                                │
                                                  ▼ (.map + .collect)
                                              ReadLenDist
                                                  │
                                                  ▼
                                            Length Distribution
                                            (04_read_len_dist/)
```

</details>

<details>
<summary>The .map() Operator</summary>

```nextflow
trimmed_output_ch
    .map { sample_id, r1, r2 -> [r1, r2] }
    .collect()
    | ReadLenDist
```

**What is `.map()`?**

The `.map()` operator transforms each item in a channel using a closure (function).

**Input to map** (from Fastp output):
```
[bio_sample_01, bio_sample_01_R1.trimmed.fastq.gz, bio_sample_01_R2.trimmed.fastq.gz]
[bio_sample_02, bio_sample_02_R1.trimmed.fastq.gz, bio_sample_02_R2.trimmed.fastq.gz]
[bio_sample_03, bio_sample_03_R1.trimmed.fastq.gz, bio_sample_03_R2.trimmed.fastq.gz]
... (5 tuples total)
```

**The transformation:**
```nextflow
.map { sample_id, r1, r2 -> [r1, r2] }
```
- **Input**: Tuple with 3 elements `(sample_id, r1, r2)`
- **Output**: List with 2 elements `[r1, r2]`
- **Effect**: Removes the sample_id, keeps only the file paths

**Output from map:**
```
[bio_sample_01_R1.trimmed.fastq.gz, bio_sample_01_R2.trimmed.fastq.gz]
[bio_sample_02_R1.trimmed.fastq.gz, bio_sample_02_R2.trimmed.fastq.gz]
[bio_sample_03_R1.trimmed.fastq.gz, bio_sample_03_R2.trimmed.fastq.gz]
... (5 lists)
```

**Why remove sample_id?**
Because ReadLenDist doesn't need sample names - it just needs all the files!

</details>

<details>
<summary>Chaining map() and collect()</summary>

```nextflow
trimmed_output_ch
    .map { sample_id, r1, r2 -> [r1, r2] }
    .collect()
    | ReadLenDist
```

**Step-by-step transformation:**

1. **After Fastp** (`trimmed_output_ch`):
   ```
   [bio_sample_01, bio_sample_01_R1.trimmed.fastq.gz, bio_sample_01_R2.trimmed.fastq.gz]
   [bio_sample_02, bio_sample_02_R1.trimmed.fastq.gz, bio_sample_02_R2.trimmed.fastq.gz]
   ... (5 tuples)
   ```

2. **After `.map()`**:
   ```
   [bio_sample_01_R1.trimmed.fastq.gz, bio_sample_01_R2.trimmed.fastq.gz]
   [bio_sample_02_R1.trimmed.fastq.gz, bio_sample_02_R2.trimmed.fastq.gz]
   ... (5 lists of 2 files each)
   ```

3. **After `.collect()`**:
   ```
   [[bio_sample_01_R1.trimmed.fastq.gz, bio_sample_01_R2.trimmed.fastq.gz],
    [bio_sample_02_R1.trimmed.fastq.gz, bio_sample_02_R2.trimmed.fastq.gz],
    ... (nested list with all 10 files)]
   ```

**Wait, that's a nested list!** The commented `.flatten()` could be used to flatten it:

4. **After `.flatten()` (if uncommented)**:
   ```
   [bio_sample_01_R1.trimmed.fastq.gz,
    bio_sample_01_R2.trimmed.fastq.gz,
    bio_sample_02_R1.trimmed.fastq.gz,
    ... (flat list with all 10 files)]
   ```

But Nextflow is smart - when you pass a nested list to a process expecting `path reads`, it automatically flattens it!

</details>

<details>
<summary>Alternative: Using flatten before collect</summary>

You could also write it as:

```nextflow
trimmed_output_ch
    .map { sample_id, r1, r2 -> [r1, r2] }
    .flatten()
    .collect()
    | ReadLenDist
```

This explicitly flattens before collecting:

1. After `.map()`: `[[r1, r2], [r1, r2], ...]` (5 lists)
2. After `.flatten()`: `[r1, r2, r1, r2, ...]` (10 individual files)
3. After `.collect()`: `[r1, r2, r1, r2, ...]` (all 10 files in one list)

Both approaches work!

</details>

<details>
<summary>Commented Debug Lines</summary>

```nextflow
// fastqc_ch.view()
// trim_ch.view()
// .flatten()
// .view()
```

These are debugging aids. Uncomment them to see channel contents at each step:

```nextflow
trimmed_output_ch
    .map { sample_id, r1, r2 -> [r1, r2] }
    .view()  // See output after map
    .collect()
    .view()  // See output after collect
    | ReadLenDist
```

**Pro tip:** Use `.view()` liberally when developing to understand data flow!

</details>

### Complete Workflow Execution

<details>
<summary>How the full pipeline executes</summary>

**Execution Timeline:**

```
Phase 1: Parallel QC and Trimming
  ├─ FastQC(bio_sample_01_R1) ───────────────────────────────────┐
  ├─ FastQC(bio_sample_01_R2) ───────────────────────────────────┤
  ├─ FastQC(bio_sample_02_R1) ───────────────────────────────────┤
  ├─ ... (10 FastQC jobs total)                     ┼─ FastQC complete
  │                                                  ┘
  ├─ Fastp(bio_sample_01) ─────────────────────────────────────────┐
  ├─ Fastp(bio_sample_02) ─────────────────────────────────────────┤
  └─ ... (5 Fastp jobs total)                        ┴─ Fastp complete
                                                            │
                                                            ▼
Phase 2: Collect and Analyze                      .map() + .collect()
                                                            │
                                                            ▼
  └─ ReadLenDist(all 10 trimmed files) ────────────────────────── Analysis complete
```

**Key Points:**
1. FastQC and Fastp run in parallel (independent)
2. ReadLenDist waits for all Fastp processes to complete (`.collect()` blocks)
3. ReadLenDist runs once with all 10 trimmed files

</details>

### Running Script 10

```bash
nextflow run pipelines/10_implementation_full.nf
```

**Expected Output:**
- `02_illuminaQC/`: FastQC HTML and ZIP reports for all raw reads (10 files)
- `03_trimmed/`: Trimmed FASTQ files from Fastp (10 files)
- `04_read_len_dist/samples_read_len_dist.tsv`: Combined read length distribution

### Key Takeaways

**You've learned:**
- Basic process structure (Script 06)
- Paired-end file handling (Script 07)
- Parallel workflows (Script 08)
- Channel collection (Script 09)
- Channel transformation with `.map()` (Script 10)
- Building complete multi-step pipelines (Script 10)

## Troubleshooting Common Issues

<details>
<summary>Click for troubleshooting tips</summary>

### Input Files Not Found

If your pipeline can't find input files, check:
- File paths are correct
- Glob patterns match your file naming scheme
- You have read permissions for the files

### Process Fails to Execute

If a process fails:
- Check the work directory for error logs (`work/xx/xxxxxx/.command.err`)
- Ensure required modules are available on your system
- Verify input/output specifications match what processes expect

### Channel Type Mismatches

A common error is mismatched channel types:
- Use `.view()` to debug channel contents
- Ensure process inputs match the structure of incoming channels
- For paired reads, use `fromFilePairs` with the correct glob pattern

### Memory or Resource Issues

If processes fail due to resource constraints:
- Split large tasks into smaller chunks
- Add resource directives to processes (see Advanced Topics)

</details>

## Advanced Topics

<details>
<summary>Click to explore advanced Nextflow features</summary>

### Configuration Files

Separate pipeline logic from execution parameters using a `nextflow.config` file:

```nextflow
// nextflow.config
params {
    read_pairs = "01_Data/AT_Illumina_paired_{1,2}.fastq"
    output_qc = "03_IlluminaQC"
    // other parameters...
}

process {
    executor = 'slurm'
    cpus = 4
    memory = '8 GB'
}
```

### Process Directives

Fine-tune process behavior with directives:

```nextflow
process ResourceIntensiveTask {
    cpus 8
    memory '16 GB'
    time '2h'
    
    // process definition...
}
```

### Conditional Execution

Use `when` directive to conditionally execute processes:

```nextflow
process OptionalStep {
    when:
    params.run_optional
    
    script:
    """
    # This only runs if --run_optional is true
    """
}
```

### Error Handling

Add error strategies to handle failures:

```nextflow
process RobustProcess {
    errorStrategy 'retry'
    maxRetries 3
    
    script:
    """
    # Will retry up to 3 times if it fails
    """
}
```

</details>

## Conclusion

**Congratulations!** You've now learned how to build a complete Nextflow pipeline for genomic data analysis. This pipeline demonstrates key Nextflow concepts including:

- Process definitions and workflow orchestration
- Channel operations (fromPath, fromFilePairs, map, collect)
- Parallel and sequential execution
- File handling and publishing outputs
- Debugging with .view()
- Building multi-step pipelines

### Next Steps

You can extend this pipeline by:
- Adding more quality control steps
- Implementing alignment processes
- Adding variant calling
- Creating summary reports with MultiQC
- Optimizing for HPC or cloud execution

### Additional Resources

For more information, refer to:
- [Nextflow Documentation](https://www.nextflow.io/docs/latest/index.html)
- [nf-core Pipelines](https://nf-co.re/) - Community-curated pipelines
- [Nextflow Patterns](https://nextflow-io.github.io/patterns/) - Common workflow patterns

**Happy pipelining!**
