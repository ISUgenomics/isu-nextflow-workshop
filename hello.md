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

## Script 03: Publishing Outputs - Making Results Accessible

**Learning Goals:**
- Learn to use `publishDir` to copy outputs to accessible locations
- Understand the difference between work directory and published directory
- Learn about different `publishDir` modes
- Make your results easy to find and share

**Building on Script 02:**

In Script 02, outputs went to the `work/` directory with cryptic hashes. That's great for Nextflow's internal management, but **terrible for humans**! Script 03 shows you how to publish outputs to user-friendly locations.

### The Problem with Work Directories

**Script 02 output location:**
```
work/1a/e8c8c0a1b2c3d4e5f6g7h8i9j0k1l2m3/result.txt
```

**Problems:**
- Hard to find (need to look up the hash)
- Changes every run (new hash each time)
- Gets deleted if you clean the work directory
- Not suitable for sharing results

**Solution:** Use `publishDir` to copy/link outputs to a permanent, accessible location!

### Step 1: Examine the Script

```bash
cat pipelines/03_hello_publishdir.nf
```

<details>
<summary>Click to see the complete script</summary>

**File:** `pipelines/03_hello_publishdir.nf`

```nextflow
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
```

</details>

### What Changed from Script 02?

<details>
<summary>The publishDir directive</summary>

**Script 02:**
```nextflow
process hello {
    output:
    path 'result.txt'
    
    script:
    """
    echo "Welcome to the world of Nextflow!" > result.txt
    """
}
```

**Script 03:**
```nextflow
process hello {
  publishDir 'output', mode: 'copy'    // NEW!

  output:
  path 'result.txt'

  script:
  """
  echo "Hello Nextflow World!" > result.txt
  """
}
```

**The only change:** Added `publishDir 'output', mode: 'copy'`

</details>

### Understanding publishDir

<details>
<summary>How publishDir works</summary>

```nextflow
publishDir 'output', mode: 'copy'
```

**What it does:**
- Takes files from the work directory
- Copies (or links) them to the specified directory
- Happens **after** the process completes successfully

**Components:**
- **`'output'`**: Target directory name
  - Can be any path: `'results'`, `'my_outputs'`, `'/absolute/path'`
  - Created automatically if it doesn't exist
- **`mode: 'copy'`**: How to publish the file

**Data Flow:**
```
Process runs → Creates result.txt in work/ → publishDir copies to output/
```

</details>

<details>
<summary>publishDir modes</summary>

**Common modes:**

1. **`mode: 'copy'`** (most common)
   - Creates a copy of the file
   - Original stays in work directory
   - Safe: deleting published file doesn't affect work directory

2. **`mode: 'symlink'`**
   - Creates a symbolic link
   - Saves disk space (no duplicate)
   - Faster than copy
   - **Warning:** If you clean work directory, link breaks!

3. **`mode: 'move'`**
   - Moves the file (removes from work directory)
   - Saves disk space
   - **Warning:** Can't resume if you delete the published file!

**Recommendation:** Use `'copy'` unless disk space is critical.

</details>

### Step 2: Run the Pipeline

```bash
nextflow run pipelines/03_hello_publishdir.nf
```

**Expected Output:**
```
N E X T F L O W  ~  version 24.04.4

Launching `pipelines/03_hello_publishdir.nf` [determined_hopper] DSL2 - revision: 5ff76c72d0

executor >  local (1)
[2b/f9d1e2] process > hello [100%] 1 of 1 ✔
```

### Step 3: Find Your Published Output

Now the output is in an easy-to-find location!

```bash
ls -la output/
```

**Output:**
```
total 8
drwxr-xr-x  3 user  group   96 Oct 19 01:30 .
drwxr-xr-x  8 user  group  256 Oct 19 01:30 ..
-rw-r--r--  1 user  group   23 Oct 19 01:30 result.txt
```

**View the file:**
```bash
cat output/result.txt
```

**Output:**
```
Hello Nextflow World!
```

**Much easier than:**
```bash
cat work/2b/f9d1e2a3b4c5d6e7f8g9h0i1j2k3l4m5/result.txt
```

### Both Locations Exist!

<details>
<summary>Work directory vs. Published directory</summary>

**After running Script 03, you have TWO copies:**

1. **Work directory** (Nextflow's internal copy):
   ```
   work/2b/f9d1e2.../result.txt
   ```
   - Used for pipeline management
   - Used for `-resume` functionality
   - Can be cleaned up later

2. **Published directory** (Your accessible copy):
   ```
   output/result.txt
   ```
   - Easy to find and share
   - Permanent location
   - Safe to use in downstream analysis

**Best Practice:** Keep work directory for development, clean it periodically. Keep published outputs permanently.

</details>

### Key Takeaways

**You've learned:**
- `publishDir` copies outputs to accessible locations
- Use `mode: 'copy'` for safety (most common)
- Published files are separate from work directory
- The work directory is still created (for resume functionality)
- Published outputs are easy to find, share, and use

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
nextflow run pipeline.nf \\
  --reads "my_data/*.fastq.gz" \\
  --output_dir "my_results" \\
  --min_quality 30 \\
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
cat implementation.md
```

**Or in your editor:**
```bash
code implementation.md
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

**Next:** [Implementation Tutorial (Scripts 06-10)](implementation.md)

In the implementation tutorial, you'll process real sequencing data and build a complete analysis pipeline.
