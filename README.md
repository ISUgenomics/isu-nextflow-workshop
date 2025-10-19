# Nextflow Workshop: Building Reproducible Computational Pipelines

**Iowa State University**  
**Genome Informatics Facility, Office of Biotechnology**

---

## Welcome!

Welcome to the Nextflow workshop! This hands-on tutorial will teach you how to build scalable, reproducible computational pipelines using Nextflow - a powerful workflow management system used across bioinformatics, data science, and computational research.

### What You'll Learn

By the end of this workshop, you'll be able to:
- Write Nextflow pipelines from scratch
- Process multiple files in parallel automatically
- Integrate any command-line tool into workflows
- Make pipelines configurable and user-friendly
- Debug and troubleshoot pipeline issues
- Build production-ready analysis workflows

### Who This Workshop Is For

This workshop is designed for researchers and students from **any computational field**:
- Bioinformatics and genomics
- Data science and machine learning
- Image processing and computer vision
- Climate modeling and simulations
- Text analysis and NLP
- Any domain requiring batch data processing

**No prior Nextflow experience required!** Basic command-line knowledge is helpful.

---

## Workshop Structure

The workshop is divided into two main tutorials:

### Part 1: Foundational Concepts ([hello.md](hello.md))

Learn Nextflow basics through simple, progressive examples:

- **[Script 01: Hello World](hello.md#script-01-hello-world---your-first-nextflow-process)** - Your first Nextflow process
- **[Script 02: Writing to Files](hello.md#script-02-writing-to-files---understanding-file-outputs)** - Understanding file outputs and work directory
- **[Script 03: Publishing Outputs](hello.md#script-03-publishing-outputs---making-results-accessible)** - Making results accessible with publishDir
- **[Script 04: Process Inputs](hello.md#script-04-process-inputs---passing-data-to-processes)** - Passing data to processes
- **[Script 05: Parameters](hello.md#script-05-parameters---making-pipelines-configurable)** - Making pipelines configurable

**Prerequisites:** Basic command-line knowledge

### Part 2: Implementation Tutorial ([implementation.md](implementation.md))

Apply your knowledge to build a real bioinformatics pipeline:

- **[Script 06: FastQC Quality Control](implementation.md#script-06-fastqc-quality-control)** - Run FastQC on multiple files in parallel
- **[Script 07: Paired-End Trimming](implementation.md#script-07-paired-end-read-trimming-with-fastp)** - Handle paired-end data with Fastp
- **[Script 08: Parallel Workflows](implementation.md#script-08-parallel-workflows)** - Run multiple processes simultaneously
- **[Script 09: Collecting Results](implementation.md#script-09-collecting-results-with-readlendist)** - Aggregate files and run custom scripts
- **[Script 10: Complete Pipeline](implementation.md#script-10-complete-multi-step-pipeline)** - Chain processes with channel transformations

**Prerequisites:** Complete Part 1 (Scripts 01-05)

---

## Quick Start

### 1. Access the HPC Cluster

Use Nova OnDemand to get a compute node:

🔗 **[Nova OnDemand](http://nova-ondemand.its.iastate.edu/)**

Login with your ISU credentials and launch VS Code Server.

### 2. Clone the Repository

```bash
cd /work/short_term/<ISU_NetID>
git clone https://github.com/ISUgenomics/isu-nextflow-workshop.git
cd isu-nextflow-workshop
```

### 3. Copy Tutorial Data

```bash
cp -a /work/short_term/workshop2_bash/01_data .
```

### 4. Load Nextflow

```bash
module load nextflow
module list
```

### 5. Start the Tutorial

**Begin with the foundational concepts:**

```bash
cat hello.md
# Or open in your editor
code hello.md
```

---

## Workshop Materials

### Tutorials

- **[hello.md](hello.md)** - Foundational concepts (Scripts 01-05)
- **[implementation.md](implementation.md)** - Real-world implementation (Scripts 06-10)

### Pipeline Scripts

All pipeline scripts are in the `pipelines/` directory:

```
pipelines/
├── 01_hello_screen.nf          # Script 01: Hello World
├── 02_hello_redirect.nf         # Script 02: File outputs
├── 03_hello_publishdir.nf       # Script 03: Publishing
├── 04_hello_input.nf            # Script 04: Process inputs
├── 05_hello_default.nf          # Script 05: Parameters
├── 06_implementation_fastqc.nf  # Script 06: FastQC
├── 07_implementation_fastp.nf   # Script 07: Fastp
├── 08_implementation_fastqc_fastp.nf  # Script 08: Parallel
├── 09_implementation_readLenDist.nf   # Script 09: Collecting
└── 10_implementation_complete.nf      # Script 10: Complete pipeline
```

---

## Instructors

**Viswanathan Satheesh**  
Genome Informatics Facility  
Office of Biotechnology  
Iowa State University

**Rick Masonbrink**  
Genome Informatics Facility  
Office of Biotechnology  
Iowa State University

**Sharu Paul Sharma**  
Genome Informatics Facility  
Office of Biotechnology  
Iowa State University

### Contact

**Email:** [gifhelp@iastate.edu](mailto:gifhelp@iastate.edu)

For questions about:
- Workshop content and materials
- Nextflow pipelines and troubleshooting
- Follow-up 

---

## Additional Resources

### Official Documentation

- [Nextflow Documentation](https://www.nextflow.io/docs/latest/index.html)
- [Nextflow Training](https://training.nextflow.io/)
- [Nextflow Patterns](https://nextflow-io.github.io/patterns/index.html)
- [nf-core Pipelines](https://nf-co.re/) - Community-curated pipelines

### Getting Help

- [Nextflow Slack](https://www.nextflow.io/slack-invite.html) - Active community
- [Nextflow GitHub](https://github.com/nextflow-io/nextflow) - Issues and discussions
- [nf-core Slack](https://nf-co.re/join) - Pipeline-specific help

### ISU Resources

- [Nova HPC Documentation](https://www.hpc.iastate.edu/guides/introduction-to-hpc-clusters)
- [Genome Informatics Facility](https://gif.biotech.iastate.edu/)
- [GIF Help](mailto:gifhelp@iastate.edu)

---

## Learning Path

```mermaid
graph LR
    A[Start Here] --> B[hello.md<br/>Scripts 01-05<br/>Foundational Concepts]
    B --> C[implementation.md<br/>Scripts 06-10<br/>Real Pipeline]
    C --> D[Build Your Own<br/>Pipeline!]
    
    style A fill:#e1f5ff,stroke:#01579b,stroke-width:2px,color:#000
    style B fill:#fff9c4,stroke:#f57f17,stroke-width:2px,color:#000
    style C fill:#c8e6c9,stroke:#2e7d32,stroke-width:2px,color:#000
    style D fill:#f8bbd0,stroke:#c2185b,stroke-width:2px,color:#000
```

---
