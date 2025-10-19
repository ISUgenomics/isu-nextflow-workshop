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

## Manual echo on the command line

```bash
echo 'Welcome to the world of Nextflow!'
```

<pre>
Welcome to the world of Nextflow!
</pre>

This prints a greeting directly in the shell. Next, we'll automate this using Nextflow.

## 1. Load the module

```bash
module load nextflow
module list
```

## 2. Inspect the pipeline script

Open and read the `1_hello_screen.nf` pipeline:

```bash
cat pipelines/1_hello_screen.nf
```

You should see a simple DSL2 script that prints a greeting.

### Run the pipeline

```bash
nextflow run 2025-nextflow-workshop/pipelines/1_hello_screen.nf
```

<details>
<summary>Click to view the script</summary>

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

### Explanation of key lines in `pipelines/1_hello_screen.nf`

- `#!/usr/bin/env nextflow`: Declares the script as an executable Nextflow pipeline.
- `process hello { ... }`: Defines a process named `hello` that encapsulates a computational step.
- `output:`: Specifies the outputs; here `stdout` captures the standard output into the `result` channel.
- `script: """ ... """`: Contains the shell commands to execute within the process (echoing the greeting).
- `workflow { ... }`: Starts the workflow block where channels and processes are orchestrated.
- `hello()`: Runs the `hello` process.
- `.view`: A method that prints the output of a process to the terminal.

Expected output: 

```
 N E X T F L O W   ~  version 24.04.4

Launching `hello.nf` [maniac_albattani] DSL2 - revision: 91b2c7c409

executor >  local (1)
[9c/4c931d] hello [100%] 1 of 1 ✔
Hello Nextflow World!
```
The greeting should appear on your terminal.

## 3. Redirect output to a file

Open and read the `2_hello_redirect.nf` pipeline:

```bash
cat pipelines/2_hello_redirect.nf
```

You should see a simple DSL2 script that redirects the greeting to a file.

<details>
<summary>Click to view the script</summary>

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

### Explanation of key lines in `pipelines/2_hello_redirect.nf`

- `output:`: Specifies the outputs; here `path 'result.txt'` redirects the standard output into the `result.txt` file.
- `script: """ ... """`: Contains the shell commands to execute within the process (echoing the greeting and redirecting it to a file).

### Run the pipeline locally

```bash
nextflow run 2025-nextflow-workshop/pipelines/2_hello_redirect.nf
``` 

Expected output:

```
N E X T F L O W  ~  version 24.04.4

Launching `2025-nextflow-workshop/pipelines/2_hello_redirect.nf` [determined_hopper] DSL2 - revision: 5ff76c72d0

executor >  local (1)
[1a/e8c8c0] process > hello [100%] 1 of 1 ✔
```

The greeting should appear in the `result.txt` file. 

```bash
tree -a work
```

<details>
<summary>Click to view the output</summary>

```
work
└── 35
    └── 61942df7892fb8f5adfc02f431cf46
        ├── .command.begin
        ├── .command.err
        ├── .command.log
        ├── .command.out
        ├── .command.run
        ├── .command.sh
        ├── .exitcode
        └── result.txt

3 directories, 8 files
```
</details>

### Understanding the `work` directory contents

After running a pipeline, Nextflow creates a `work/` directory with a subfolder for each process execution. Inside each of these folders you’ll find:

- `.command.begin`: # TODO
- `.command.sh`: The generated shell script that Nextflow runs.
- `.command.run`: A wrapper script that launches the process.
- `.command.out`: Captured standard output from the process.
- `.command.err`: Captured standard error from the process.
- `.command.log`: # TODO
- `.exitcode`: The process exit status code.
- `result.txt`: The actual output file produced by the process.

These artifacts help with debugging, reproducibility, and understanding exactly what happened during each process run.

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
