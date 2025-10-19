# Introduction to Nextflow: Building Reproducible Computational Pipelines - Part 2

**Previous:** [hello_part1.md](hello_part1.md) - Scripts 01-03

This part covers Scripts 04-05, advanced topics, and prepares you for the implementation tutorial.

---

## Script 04: Process Inputs - Passing Data to Processes

**Learning Goals:**
- Learn how to define process inputs
- Understand the `val` input qualifier
- See how to pass data from workflow to process
- Use variables in process scripts

**Building on Script 03:**

Scripts 01-03 had **hardcoded** messages. But real pipelines need to process **different data**! Script 04 introduces process inputs - the foundation for making processes reusable.

### The Problem with Hardcoded Values

**Script 03:**
```nextflow
process hello {
  script:
  """
  echo "Hello Nextflow World!" > result.txt  // Always the same!
  """
}
```

**Problems:**
- Can't change the message without editing the script
- Can't process different inputs
- Not reusable

**Solution:** Add an `input` block to accept data!

### Step 1: Examine the Script

```bash
cat pipelines/04_hello_input.nf
```

<details>
<summary>Click to see the complete script</summary>

**File:** `pipelines/04_hello_input.nf`

```nextflow
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

workflow {
    hello("Hello, welcome to the world of Nextflow!")
}
```

</details>

### What Changed from Script 03?

<details>
<summary>Adding the input block</summary>

**Script 03:**
```nextflow
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
  hello()  // No arguments
}
```

**Script 04:**
```nextflow
process hello {
    publishDir 'output', mode: 'copy'

    input:                    // NEW!
    val welcome              // NEW!

    output:
    path 'result.txt'

    script:
    """
    echo "$welcome" > result.txt    // Uses variable!
    """
}

workflow {
    hello("Hello, welcome to the world of Nextflow!")  // Pass data
}
```

**Key Changes:**
1. Added `input:` block with `val welcome`
2. Changed script to use `$welcome` variable
3. Workflow now passes a string to `hello()`

</details>

### Understanding Process Inputs

<details>
<summary>The input block</summary>

```nextflow
input:
val welcome
```

**What does this mean?**

- **`input:`**: Declares what data the process needs
- **`val`**: Input qualifier meaning "value" (string, number, etc.)
- **`welcome`**: Variable name to use in the script

**Input qualifiers:**
- **`val`**: Simple values (strings, numbers, booleans)
- **`path`**: Files or directories (we'll use this in Scripts 06-10)
- **`tuple`**: Multiple values grouped together

</details>

<details>
<summary>Using inputs in scripts</summary>

```nextflow
script:
"""
echo "$welcome" > result.txt
"""
```

**Variable interpolation:**

- **`$welcome`**: Bash-style variable reference
- Nextflow replaces `$welcome` with the actual value before running
- Works like bash variables in the script block

**Example:** If `welcome = "Hello!"`, the script becomes:
```bash
echo "Hello!" > result.txt
```

</details>

<details>
<summary>Passing data in the workflow</summary>

```nextflow
workflow {
    hello("Hello, welcome to the world of Nextflow!")
}
```

**How it works:**

1. Workflow calls `hello()` with a string argument
2. The string is passed to the process's `input` block
3. The value is assigned to the `welcome` variable
4. The process script uses `$welcome`

**Data Flow:**
```
Workflow: "Hello, welcome..." → Process input: welcome → Script: $welcome
```

</details>

### Step 2: Run the Pipeline

```bash
nextflow run pipelines/04_hello_input.nf
```

**Expected Output:**
```
N E X T F L O W  ~  version 24.04.4

Launching `pipelines/04_hello_input.nf` [determined_hopper] DSL2 - revision: 5ff76c72d0

executor >  local (1)
[3c/a1b2c3] process > hello [100%] 1 of 1 ✔
```

### Step 3: Check the Output

```bash
cat output/result.txt
```

**Output:**
```
Hello, welcome to the world of Nextflow!
```

The message came from the workflow, not hardcoded in the process!

### Key Takeaways

**You've learned:**
- Processes can accept inputs using the `input:` block
- Use `val` for simple values (strings, numbers)
- Variables are accessed with `$variable_name` in scripts
- The workflow passes data to processes as arguments
- This makes processes reusable with different data

## Script 05: Parameters - Making Pipelines Configurable

**Learning Goals:**
- Learn to use `params` for configurable pipelines
- Understand default parameter values
- Learn to override parameters from the command line
- Make pipelines flexible and reusable

**Building on Script 04:**

Script 04 required editing the workflow to change the message. But what if you want users to customize the pipeline **without editing code**? Script 05 introduces parameters - the standard way to make Nextflow pipelines configurable!

### The Problem with Hardcoded Workflow Values

**Script 04:**
```nextflow
workflow {
    hello("Hello, welcome to the world of Nextflow!")  // Hardcoded!
}
```

**To change the message, you must:**
1. Open the script file
2. Edit the string
3. Save the file

**Not user-friendly!**

**Solution:** Use `params` to allow command-line configuration!

### Step 1: Examine the Script

```bash
cat pipelines/05_hello_default.nf
```

<details>
<summary>Click to see the complete script</summary>

**File:** `pipelines/05_hello_default.nf`

```nextflow
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
```

</details>

### What Changed from Script 04?

<details>
<summary>Adding parameters</summary>

**Script 04:**
```nextflow
workflow {
    hello("Hello, welcome to the world of Nextflow!")
}
```

**Script 05:**
```nextflow
params.welcome = "Hello, welcome to the world of Nextflow!"  // NEW!

workflow {
    hello(params.welcome)  // Uses parameter
}
```

**Key Changes:**
1. Added `params.welcome` with a default value
2. Workflow uses `params.welcome` instead of hardcoded string

</details>

### Understanding Parameters

<details>
<summary>What are params?</summary>

**Parameters** are Nextflow's way of making pipelines configurable.

```nextflow
params.welcome = "Hello, welcome to the world of Nextflow!"
```

**Key Concepts:**

- **`params`**: Special Nextflow object for parameters
- **`.welcome`**: Parameter name (you choose this)
- **`= "..."`**: Default value (used if not overridden)

**Naming convention:** Use lowercase with underscores
- Good: `params.input_file`, `params.output_dir`, `params.quality_threshold`
- Avoid: `params.InputFile`, `params.OUTDIR`

</details>

<details>
<summary>How parameters work</summary>

**Three ways to set parameters:**

1. **Default value in script** (lowest priority):
   ```nextflow
   params.welcome = "Default message"
   ```

2. **Command-line argument** (highest priority):
   ```bash
   nextflow run script.nf --welcome "Custom message"
   ```

3. **Config file** (medium priority - covered in advanced topics):
   ```nextflow
   params {
       welcome = "Config message"
   }
   ```

**Priority:** Command-line > Config file > Script default

</details>

### Step 2: Run with Default Parameters

```bash
nextflow run pipelines/05_hello_default.nf
```

**Expected Output:**
```
N E X T F L O W  ~  version 24.04.4

Launching `pipelines/05_hello_default.nf` [determined_hopper] DSL2 - revision: 5ff76c72d0

executor >  local (1)
[4d/b2c3d4] process > hello [100%] 1 of 1 ✔
```

**Check the output:**
```bash
cat output/result.txt
```

**Output:**
```
Hello, welcome to the world of Nextflow!
```

The default value was used!

### Step 3: Override Parameters

Now the magic - change the message **without editing the script**:

```bash
nextflow run pipelines/05_hello_default.nf --welcome "Greetings from the command line!"
```

**Check the output:**
```bash
cat output/result.txt
```

**Output:**
```
Greetings from the command line!
```

**It worked!** The command-line value overrode the default.

### Real-World Example

<details>
<summary>How this applies to real pipelines</summary>

**Typical bioinformatics pipeline parameters:**

```nextflow
// Input/Output
params.reads = "data/*_{R1,R2}.fastq.gz"
params.output_dir = "results"

// Quality control
params.min_quality = 20
params.min_length = 50

// Analysis
params.genome = "/path/to/reference.fa"
params.threads = 4
```

**Users can customize without editing:**
```bash
nextflow run pipeline.nf \
  --reads "my_data/*.fastq.gz" \
  --output_dir "my_results" \
  --min_quality 30 \
  --threads 8
```

**This is how Scripts 06-10 work!**

</details>

### Common Parameter Patterns

<details>
<summary>Best practices for parameters</summary>

**1. Provide sensible defaults:**
```nextflow
params.threads = 4          // Good default
params.output_dir = "results"  // Reasonable
```

**2. Document your parameters:**
```nextflow
// Input files (glob pattern)
params.reads = "data/*.fastq.gz"

// Quality threshold (Phred score)
params.min_quality = 20
```

**3. Group related parameters:**
```nextflow
// Input/Output
params.input_dir = "data"
params.output_dir = "results"

// Quality Control
params.min_quality = 20
params.min_length = 50
```

**4. Use descriptive names:**
- Good: `params.quality_threshold`, `params.input_fastq`
- Bad: `params.qt`, `params.in`

</details>

### Key Takeaways

**You've learned:**
- Use `params.name = value` to define parameters
- Parameters provide default values
- Override with `--param_name value` on command line
- Command-line values take priority over defaults
- Parameters make pipelines user-friendly and reusable
- This is the foundation for configurable bioinformatics pipelines

**Congratulations!** You've completed the foundational scripts (01-05). You now understand:
- Processes and workflows
- File outputs and publishDir
- Process inputs
- Parameters

You're ready for the implementation tutorial (Scripts 06-10) with real bioinformatics tools!

---

## Workshop Checkpoint: What You've Learned

### Core Concepts Mastered

**Script 01 - Hello World:**
- Basic Nextflow script structure
- Process definitions and workflow orchestration
- Using `.view()` for debugging

**Script 02 - File Outputs:**
- Creating file outputs with `path`
- Understanding the work directory
- Inspecting `.command.*` files for debugging

**Script 03 - Publishing:**
- Using `publishDir` to make outputs accessible
- Different publishing modes (copy, symlink, move)
- Separating work directory from final outputs

**Script 04 - Process Inputs:**
- Defining process inputs with `val`
- Variable interpolation in scripts
- Passing data from workflow to process

**Script 05 - Parameters:**
- Making pipelines configurable with `params`
- Setting default values and overriding from command line
- Best practices for parameter naming

---

## Next Steps: Implementation Tutorial

### What's Coming in Scripts 06-10

Now you'll apply these concepts to build a **real bioinformatics pipeline**:

**Script 06 - FastQC Quality Control:**
- Run a published tool (FastQC) on multiple files in parallel

**Script 07 - Paired-End Read Trimming:**
- Handle paired-end sequencing data with Fastp

**Script 08 - Parallel Workflows:**
- Run multiple processes simultaneously

**Script 09 - Collecting Results:**
- Use `.collect()` to aggregate files
- Run custom Python scripts

**Script 10 - Complete Pipeline:**
- Chain processes together with channel transformations

### Ready to Continue?

**Open the implementation tutorial:**

```bash
cat implementation_part1.md
```

**Or in your editor:**
```bash
code implementation_part1.md
```

---

## Understanding the Work Directory

### What is the work directory for?

Throughout Scripts 01-05, Nextflow created a `work/` directory with cryptic subdirectories. Let's understand why this exists and when to clean it up.

**The work directory serves two critical purposes:**

1. **Pipeline execution workspace**
   - Each process runs in its own isolated subdirectory
   - Contains all inputs, outputs, and execution logs
   - Enables debugging (you can inspect exactly what happened)

2. **Resume functionality**
   - Nextflow tracks which tasks completed successfully
   - Allows skipping already-completed work
   - Essential for long-running pipelines

### The -resume Feature

<details>
<summary>How resume works</summary>

Imagine you run a pipeline with 100 samples, and it fails on sample 95. Without `-resume`, you'd have to rerun all 100 samples!

**With `-resume`, Nextflow is smart:**

```bash
# First run (fails at sample 95)
nextflow run script.nf

# Fix the issue, then resume
nextflow run script.nf -resume
```

**What happens:**
- Nextflow checks the work directory
- Finds that samples 1-94 completed successfully
- **Skips** those tasks (uses cached results)
- **Only runs** sample 95 onwards

**How it knows:**
- Each task has a unique hash based on:
  - Process script
  - Input files
  - Parameters
- If hash matches and task succeeded, reuse the result!

</details>

<details>
<summary>When to use -resume</summary>

**Use `-resume` when:**
- Your pipeline failed and you fixed the issue
- You stopped the pipeline and want to continue
- You added more samples and want to process only the new ones
- You're iterating during development

**Example scenario:**
```bash
# Run pipeline on 10 samples
nextflow run script.nf --input "data/*.fastq"
# (Completes successfully)

# Add 5 more samples to data/
# Run again with -resume
nextflow run script.nf --input "data/*.fastq" -resume
# Only processes the 5 new samples!
```

</details>

### Should You Clean the Work Directory?

**During development (now):** **Keep it!**
- You'll experiment with scripts
- You'll use `-resume` frequently
- Disk space is minimal (Scripts 01-05 are tiny)

**After pipeline completion:** **Optional cleanup**
- Published outputs are in `output/` (safe to keep)
- Work directory can be deleted to save space
- Only matters when working with large files

### Cleaning Up (Optional)

If you want to clean up before moving to the implementation tutorial:

```bash
# Remove work directory (safe - outputs are published)
rm -rf work/

# Remove output directory (if you want a fresh start)
rm -rf output/
```

**Or keep everything:**
```bash
# Do nothing! The work directory from Scripts 01-05 is tiny.
# You'll learn more about cleanup strategies in the implementation
# tutorial when working with real sequencing data (GB of files).
```

### Advanced: Nextflow Clean Command

<details>
<summary>Using nextflow clean (optional)</summary>

Nextflow provides a `clean` command for more selective cleanup:

```bash
# See what would be deleted (dry run)
nextflow clean -n

# Delete all work files
nextflow clean -f

# Keep only successful runs, delete failed ones
nextflow clean -f -k

# Delete work files older than a certain run
nextflow clean -f -before <run_name>
```

**For now, simple `rm -rf work/` is fine.** You'll learn more about `nextflow clean` in the implementation tutorial.

</details>

---

## Quick Reference

### Essential Commands

```bash
# Run a pipeline
nextflow run script.nf

# Override parameters
nextflow run script.nf --param_name value

# Resume from checkpoint
nextflow run script.nf -resume
```

### Essential Syntax

```nextflow
// Parameters
params.input = "data/*.fastq"

// Process
process MyProcess {
    publishDir 'results', mode: 'copy'
    input:
    path input_file
    output:
    path 'output.txt'
    script:
    """
    my_tool $input_file > output.txt
    """
}

// Workflow
workflow {
    Channel.fromPath(params.input) | MyProcess
}
```

---

## Continue to Implementation Tutorial

**You've built a solid foundation. Now let's apply it to real-world analysis!**

**Next:** [Implementation Tutorial Part 1 (Scripts 06-08)](implementation_part1.md)

In the implementation tutorial, you'll process real sequencing data and build a complete analysis pipeline.
