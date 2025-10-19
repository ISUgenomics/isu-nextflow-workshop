# Introduction to Nextflow: Building Reproducible Computational Pipelines

Welcome to the Nextflow workshop! In this hands-on tutorial, you'll learn how to build scalable, reproducible computational pipelines using Nextflow.

## What is Nextflow?

**Nextflow** is a powerful workflow management system designed to make computational pipelines:
- **Portable**: Run the same pipeline on your laptop, HPC cluster, or cloud
- **Reproducible**: Track every step and ensure consistent results
- **Scalable**: Automatically parallelize tasks across available resources
- **Flexible**: Write once, run anywhere (local, SLURM, AWS, etc.)
- **Tool-agnostic**: Integrate any command-line program (Python, R, bash scripts, compiled binaries)

### Why Use Nextflow?

Traditional computational workflows often involve:
- Writing complex bash scripts with nested loops
- Manually tracking which files have been processed
- Struggling with parallelization and resource management
- Difficulty reproducing results months later
- Combining tools from different sources (published tools, lab scripts, your own code)

**Nextflow solves these problems** by:
- Automatically parallelizing independent tasks
- Managing data flow between processes
- Handling failures and resuming from checkpoints
- Providing clear, readable pipeline code
- Seamlessly integrating tools regardless of their origin

### Key Concepts

Before we start, here are the core concepts you'll learn:

1. **Processes**: Individual computational tasks (running any command-line tool or script)
2. **Channels**: Data streams that connect processes together
3. **Workflows**: The orchestration of processes and data flow
4. **Operators**: Methods to transform and manipulate channels (`.map()`, `.collect()`, etc.)

### About This Workshop

**Example Domain**: We use bioinformatics examples in this workshop, but the concepts apply to **any computational domain**:
- Image processing and computer vision
- Climate modeling and simulations
- Text analysis and natural language processing
- Machine learning pipelines
- Statistical analysis workflows
- Any field requiring batch processing of data

**Tools Used**: Throughout this workshop, you'll see how Nextflow integrates:
- **Published tools**: FastQC and Fastp (widely-used bioinformatics programs)
- **Custom scripts**: Python scripts written specifically for this analysis
- **Your own tools**: The same principles apply to any command-line program you use

The key insight: **Nextflow doesn't care what your tools do** - it just manages how data flows between them!

### What You'll Build Today

In this workshop, you'll progress through increasingly complex pipelines:

**Scripts 01-05** (This tutorial):
- Script 01: Hello World - Your first Nextflow process
- Script 02: Working with files - Reading and writing data
- Script 03: Using parameters - Making pipelines configurable
- Script 04: Multiple inputs - Processing several files
- Script 05: Channels - Understanding data flow

**Scripts 06-10** (Implementation tutorial):
- Script 06: Quality control with FastQC (published tool)
- Script 07: Data trimming with Fastp (published tool)
- Script 08: Parallel workflows (running multiple tools simultaneously)
- Script 09: Collecting results with ReadLenDist (custom Python script)
- Script 10: Complete multi-step pipeline (integrating everything)

### Learning Approach

This tutorial is designed to be:
- **Hands-on**: You'll run every script and see the results
- **Progressive**: Each script builds on concepts from the previous one
- **Practical**: Real tools and data from actual research workflows
- **Interactive**: Experiment, break things, and learn!
- **Transferable**: Apply these skills to your own research domain

Let's get started!

---

## Getting a compute node on Nova using OnDemand

Use the link: [Nova OnDemand](http://nova-ondemand.its.iastate.edu/)

Please login using your ISU credentials.

We will be using the VS Code Server on ISU HPC cluster for this tutorial. 

## Setting  up the environment

### Let us clone the tutorial repo

```bash
cd /work/short_term/<ISU_NetID>
git clone https://github.com/ISUgenomics/isu-nextflow-workshop.git
```

## Copying data required for the tutorial

```bash
cp -a /work/short_term/workshop2_bash/01_data .
```

## Script 01: Hello World - Your First Nextflow Process

**Learning Goals:**
- Understand the basic structure of a Nextflow script
- Learn what a process is and how it works
- See how the workflow block orchestrates processes
- Use the `.view()` operator to display output

### Before Nextflow: Manual Command

First, let's see what we're automating. Run this command directly in your terminal:

```bash
echo 'Welcome to the world of Nextflow!'
```

**Output:**
```
Welcome to the world of Nextflow!
```

This prints a greeting directly in the shell. Simple, right? But what if you need to:
- Run this on 100 different inputs?
- Track when it was run and with what parameters?
- Resume if it fails?
- Run it on different compute systems?

That's where Nextflow comes in!

### Step 1: Load Nextflow

```bash
module load nextflow
module list
```

This loads the Nextflow module on the HPC cluster.

### Step 2: Examine the Script

Let's look at the Nextflow version:

```bash
cat pipelines/01_hello_screen.nf
```

<details>
<summary>Click to see the complete script</summary>

**File:** `pipelines/01_hello_screen.nf`

```nextflow
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
```

</details>

### Understanding the Components

<details>
<summary>The Shebang Line</summary>

```nextflow
#!/usr/bin/env nextflow
```

- Declares this file as a Nextflow script
- Allows the script to be executed directly (like a bash script)
- Not strictly required, but good practice

</details>

<details>
<summary>The Process Block</summary>

```nextflow
process hello {
    output:
    stdout

    script:
    """
    echo "Welcome to the world of Nextflow!"
    """
}
```

**What is a Process?**

A process is a **basic computing unit** in Nextflow. Think of it as a wrapper around any command-line tool or script.

**Components:**

- **`process hello`**: Names the process "hello"
- **`output: stdout`**: Captures standard output (what the command prints)
  - This creates a **channel** containing the output
  - Channels are how data flows between processes
- **`script: """ ... """`**: Contains the actual command(s) to run
  - Triple quotes allow multi-line commands
  - Can contain any bash/shell commands
  - Variables can be interpolated with `${variable}`

**Key Insight:** The process doesn't run immediately - it's just a definition. The workflow block decides when to run it.

</details>

<details>
<summary>The Workflow Block</summary>

```nextflow
workflow {
    // Run the hello process
    hello().view()
}
```

**What is a Workflow?**

The workflow block is where you **orchestrate** your processes - deciding which to run, in what order, and with what data.

**Components:**

- **`hello()`**: Executes the hello process
  - Returns a channel containing the process output
  - In this case, the channel contains "Welcome to the world of Nextflow!"
- **`.view()`**: A channel operator that prints channel contents to the terminal
  - Useful for debugging and seeing what's in a channel
  - Without `.view()`, the output would be captured but not displayed

**Data Flow:**
```
hello process → stdout channel → .view() → terminal
```

</details>

### Step 3: Run the Pipeline

```bash
nextflow run pipelines/01_hello_screen.nf
```

**Expected Output:**

```
N E X T F L O W  ~  version 24.04.4

Launching `pipelines/01_hello_screen.nf` [maniac_albattani] DSL2 - revision: 91b2c7c409

executor >  local (1)
[9c/4c931d] process > hello [100%] 1 of 1 ✔
Welcome to the world of Nextflow!
```

### Understanding the Output

<details>
<summary>What does each line mean?</summary>

```
N E X T F L O W  ~  version 24.04.4
```
- Nextflow version being used

```
Launching `pipelines/01_hello_screen.nf` [maniac_albattani] DSL2 - revision: 91b2c7c409
```
- Script being run
- Random name assigned to this run ("maniac_albattani")
- DSL2: Nextflow's Domain Specific Language version 2
- Git revision (if in a git repository)

```
executor >  local (1)
```
- Executor: where the process runs (local machine, SLURM, AWS, etc.)
- (1): One process executed

```
[9c/4c931d] process > hello [100%] 1 of 1 ✔
```
- `[9c/4c931d]`: Unique hash for this process execution
  - Used to find the work directory: `work/9c/4c931d.../`
- `process > hello`: Name of the process
- `[100%] 1 of 1 ✔`: Progress indicator - 1 task completed successfully

```
Welcome to the world of Nextflow!
```
- The actual output from our process (displayed by `.view()`)

</details>

### Key Takeaways

**You've learned:**
- A Nextflow script has **processes** (what to do) and a **workflow** (when to do it)
- Processes capture output into **channels**
- The `.view()` operator displays channel contents
- Nextflow tracks every execution with a unique hash
- Each process runs in its own work directory

## Script 02: Writing to Files - Understanding File Outputs

**Learning Goals:**
- Learn how to create file outputs instead of stdout
- Understand the Nextflow work directory structure
- See where process outputs are stored
- Learn to inspect process execution artifacts

**Building on Script 01:**

In Script 01, we used `output: stdout` to print to the terminal. But real pipelines need to **save results to files**. Script 02 shows you how!

### Step 1: Examine the Script

```bash
cat pipelines/02_hello_redirect.nf
```

<details>
<summary>Click to see the complete script</summary>

**File:** `pipelines/02_hello_redirect.nf`

```nextflow
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
```

</details>

### What Changed from Script 01?

<details>
<summary>Comparing the two scripts</summary>

**Script 01:**
```nextflow
process hello {
    output:
    stdout              // Captures what's printed to terminal

    script:
    """
    echo "Welcome to the world of Nextflow!"
    """
}

workflow {
    hello().view()      // .view() displays the stdout
}
```

**Script 02:**
```nextflow
process hello {
    output:
    path 'result.txt'   // Captures a file

    script:
    """
    echo "Welcome to the world of Nextflow!" > result.txt
    """
}

workflow {
    hello()             // No .view() needed - output is a file
}
```

**Key Differences:**
1. **Output type**: `stdout` → `path 'result.txt'`
2. **Script command**: Direct echo → Redirect to file with `>`
3. **Workflow**: No `.view()` needed (file is automatically saved)

</details>

### Understanding File Outputs

<details>
<summary>The path output qualifier</summary>

```nextflow
output:
path 'result.txt'
```

**What does `path` mean?**

- `path` tells Nextflow: "This process creates a file"
- `'result.txt'` is the filename to capture
- Nextflow will look for this file after the process completes
- The file is automatically added to a channel (for downstream processes)

**Important:** The filename in `output:` must match the filename created in `script:`

```nextflow
output:
path 'result.txt'        // Nextflow expects this file

script:
"""
echo "..." > result.txt  // Script must create this file
"""
```

</details>

### Step 2: Run the Pipeline

```bash
nextflow run pipelines/02_hello_redirect.nf
```

**Expected Output:**

```
N E X T F L O W  ~  version 24.04.4

Launching `pipelines/02_hello_redirect.nf` [determined_hopper] DSL2 - revision: 5ff76c72d0

executor >  local (1)
[1a/e8c8c0] process > hello [100%] 1 of 1 ✔
```

**Notice:** No output is printed! That's because the result is in a file, not stdout.

### Step 3: Find Your Output

<details>
<summary>Where did the file go?</summary>

**The Work Directory:**

Nextflow stores all process outputs in the `work/` directory. Let's explore it:

```bash
tree -a work
```

**Output:**
```
work
└── 1a
    └── e8c8c0a1b2c3d4e5f6g7h8i9j0k1l2m3
        ├── .command.begin
        ├── .command.err
        ├── .command.log
        ├── .command.out
        ├── .command.run
        ├── .command.sh
        ├── .exitcode
        └── result.txt        ← Your output file!

2 directories, 8 files
```

**Structure:**
- `work/`: Main directory for all process executions
- `1a/`: First two characters of the process hash
- `e8c8c0.../`: Full unique hash for this specific execution
- `result.txt`: Your output file
- `.command.*`: Nextflow's internal files

</details>

### Understanding the Work Directory

<details>
<summary>What are all these .command files?</summary>

Each process execution creates several files:

**Your Files:**
- **`result.txt`**: The output file your process created

**Nextflow's Files:**
- **`.command.sh`**: The actual shell script Nextflow generated and ran
  - Look inside to see exactly what was executed!
- **`.command.run`**: Wrapper script that sets up the environment
- **`.command.out`**: Standard output (stdout) from the process
- **`.command.err`**: Standard error (stderr) from the process
- **`.command.log`**: Combined log of stdout and stderr
- **`.exitcode`**: Exit status (0 = success, non-zero = error)
- **`.command.begin`**: Timestamp when process started

**Why is this useful?**
- **Debugging**: Check `.command.err` if something fails
- **Reproducibility**: `.command.sh` shows exactly what ran
- **Verification**: `.exitcode` confirms success/failure

</details>

### Step 4: View the Output

Let's read the file using the hash from the Nextflow output:

```bash
# Use the hash from your output (e.g., [1a/e8c8c0])
cat work/1a/e8c8c0*/result.txt
```

**Output:**
```
Welcome to the world of Nextflow!
```

**Pro tip:** You can also use:
```bash
find work -name result.txt -exec cat {} \;
```

### Key Takeaways

**You've learned:**
- Use `output: path 'filename'` to create file outputs
- The filename in `output:` must match what the script creates
- All process outputs go to the `work/` directory
- Each process gets a unique subdirectory with a hash
- The work directory contains debugging artifacts (`.command.*` files)
- You can inspect these files to understand what happened

## 4. Use publishDir to save output files

Open and read the `3_hello_publishdir.nf` pipeline:

```bash
cat pipelines/3_hello_publishdir.nf
```

### Run the pipeline

```bash
nextflow run 2025-nextflow-workshop/pipelines/3_hello_publishdir.nf
```

After running, you should see the output file in the `output` directory.

<details>
<summary>Click to view the script</summary>

```nextflow
#!/usr/bin/env nextflow

/*
* Use echo to print a message to the screen
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
```
</details>

### Explanation of key lines in `pipelines/3_hello_publishdir.nf`

- `publishDir 'output', mode: 'copy'`: Specifies that output files should be copied to the 'output' directory.

## 5. Using input values

Open and read the `4_hello_input.nf` pipeline:

```bash
cat pipelines/4_hello_input.nf
```

### Run the pipeline

```bash
nextflow run 2025-nextflow-workshop/pipelines/4_hello_input.nf
```

The custom greeting will be saved to the output file.

<details>
<summary>Click to view the script</summary>

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

### Explanation of key lines in `pipelines/4_hello_input.nf`

- `input: val welcome`: Defines an input value that will be used in the process.
- `echo "$welcome" > result.txt`: Uses the input value in the script.
- `hello("Hello, welcome to the world of Nextflow!")`: Passes a string value to the process.

## 6. Using parameters

Open and read the `5_hello_default.nf` pipeline:

```bash
cat pipelines/5_hello_default.nf
```

### Run the pipeline with default parameters

```bash
nextflow run 2025-nextflow-workshop/pipelines/5_hello_default.nf
```

<details>
<summary>Click to view the script</summary>

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

### Explanation of key lines in `pipelines/5_hello_default.nf`

- `params.welcome = "Hello, welcome to the world of Nextflow!"`: Defines a default parameter value.
- `hello(params.welcome)`: Uses the parameter in the workflow.

You can override this parameter when running the pipeline:

```bash
nextflow run 2025-nextflow-workshop/pipelines/5_hello_default.nf --welcome "Custom greeting!"
```

## 6. Clean up

Remove work files:

```bash
nextflow clean -f pipelines/hello.nf -profile local
```
