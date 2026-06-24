# ctDNA-analysis-from-the-Evidence

**Clinical Utility of Molecular Residual Disease Detection in Early-Stage Resected EGFR-Mutated Non-Small Cell Lung Cancer: Biomarker Analyses from the EVIDENCE Trial**

> Reference scripts and reproducible analysis code for MRD detection in ctDNA sequencing data and comprehensive statistical analysis with publication-ready visualizations.

---

## Reproducibility Statement

The analyses in this repository are designed with two layers of reproducibility:

**(i) Fully open** — All statistical analyses, tables, and publication-ready figures presented in the manuscript can be reproduced directly from the deposited variant input lists using the R/Python scripts provided in the [Figure Plot](#2-figure-plot-module) module. No proprietary software is required at this layer.

**(ii) Executable level** — MRD status calls and ctDNA content estimates can be reproduced from plasma-derived BAM files using the compiled MinerVa Prime executable deposited in this repository (see [MRD Calling Module](#1-mrd-calling-module)). The compiled binary is provided to ensure reproducibility of MRD calling; however, the underlying source code is proprietary and subject to patent restrictions, and is **not publicly available.**

Preprocessing steps from plasma FASTQ files to BAM files are not included in this repository and should be performed independently using standard alignment and preprocessing pipelines. In addition, variant inputs derived from tumor tissue sequencing and the reference genome FASTA files are required and should be prepared separately by the user according to standard practices.

Any further requests for code or data access may be directed to the corresponding author.

---

## Repository Contents

This repository contains two integrated analysis modules for the EVIDENCE trial study:

1. **[MRD Calling](./MRD%20calling)** - generation of MRD status and ctDNA content estimates from circulating tumor DNA sequencing data.
2. **[Figure Plot](./figure%20plot)** - statistical analyses, manuscript figures, supplementary figures, and tables.


## 1. MRD Calling Module

### Overview

The MRD calling module implements the **MinerVa Prime** framework for personalized panel-based molecular residual disease detection in circulating cell-free DNA (cfDNA). This approach identifies tumor-derived variants in plasma samples with high sensitivity.

**Key Features:**
- Cython-compiled for high performance
- Personalized variant panel approach
- Automatic background error modeling
- Statistical significance testing
- Publication-ready output formats

### Quick Start

```bash
# 1. Install dependencies
cd MRD\ calling/
pip install -r requirements.txt

# 2. Setup environment
export LD_LIBRARY_PATH=/usr/local/lib:$LD_LIBRARY_PATH
chmod +x mrd_workflow

# 3. Run demo analysis
./mrd_workflow \
  --bam input/demo.bam \
  --variant input/demo.variant.txt \
  --reference ucsc.hg19.fasta \
  --outdir output \
  --sample demo
```

### Requirements

| Component | Version | Notes |
|-----------|---------|-------|
| Python | 3.9.0+ | Compatibility with earlier versions may vary |
| Genome | hg19 | Must use hg19 reference coordinates |
| OS | Linux/Unix | Windows not officially supported |
| RAM | 4-8 GB | Depends on BAM file size and variant count |

### Installation

#### 1. Install Python Dependencies
```bash
pip install -r requirements.txt
```

Required packages:
- `numpy` - Numerical operations
- `scipy` - Statistical functions
- `pandas` - Data manipulation
- `pysam` - BAM/SAM file handling
- `cython` - For compiled extensions

#### 2. Configure Environment
```bash
export LD_LIBRARY_PATH=/usr/local/lib:$LD_LIBRARY_PATH
```

This ensures Cython-compiled libraries load correctly.

#### 3. Make Workflow Executable
```bash
chmod +x mrd_workflow
```

### Usage

#### Basic Command
```bash
./mrd_workflow --bam <BAM_FILE> --variant <VARIANT_FILE> \
  --reference <FASTA> --outdir <OUTPUT_DIR> --sample <SAMPLE_ID>
```


### Input Formats

#### BAM File Format
- **Standard alignment format** for sequencing reads
- Must be indexed (`.bai` file required)
- Aligned to **hg19**
- Includes quality scores and alignment metrics

**Requirements:**
```bash
# Index BAM file if not already indexed
samtools index sample.bam
```

#### Reference Genome
- **File format:** FASTA
- **Build:** hg19
- **Filename:** `ucsc.hg19.fasta`
- Must match BAM alignment reference exactly

### Output Files

#### 1. Site-Level Output (`<sample>.site.txt`)

**Purpose:** Detailed information on detected variants in the sample

#### 2. MRD Status Output (`<sample>.mrd.txt`)

**Purpose:** Clinical MRD determination and summary statistics

### Troubleshooting

**Issue:** Command not found
```bash
# Solution: Make workflow executable
chmod +x mrd_workflow
```

**Issue:** Library loading errors
```
OSError: libXXX.so: cannot open shared object file
```
```bash
# Solution: Check LD_LIBRARY_PATH
export LD_LIBRARY_PATH=/usr/local/lib:$LD_LIBRARY_PATH
```

**Issue:** Invalid BAM file error
```bash
# Solution: Verify BAM indexing
samtools index input/sample.bam
# Verify alignment reference matches hg19
samtools view -H input/sample.bam | grep SQ
```

---

## 2. Figure Plot Module

### Overview

The figure plot module contains **complete reproducible analysis code** for all manuscript figures, tables, and statistical analyses. All scripts are self-contained and can be run independently or in sequence.

**Key Features:**
- Publication-ready visualizations
- Kaplan-Meier survival analysis
- Comprehensive statistical testing
- Multiple subgroup analyses
- Supplementary figures and tables


### Requirements

| Software | Version | Purpose |
|----------|---------|---------|
| R | 4.0.0+ | Statistical analysis |
| RStudio | (optional) | Interactive development |

### R Package Installation

#### Install from CRAN
```R
install.packages(c(
  "tidyverse",      # Data manipulation
  "data.table",     # Fast data handling
  "survival",       # Survival analysis
  "survminer",      # Survival plotting
  "ggplot2",        # Visualization
  "ggpubr",         # Publication themes
  "gridExtra",      # Multi-panel plots
  "rstatix",        # Statistics
  "RColorBrewer",   # Color palettes
  "viridis"         # Color schemes
))
```

#### Install Bioconductor Packages
```R
# If not already installed
if (!require("BiocManager", quietly = TRUE))
  install.packages("BiocManager")

BiocManager::install("ComplexHeatmap")
```

### Data Files

All input data located in `data/` directory:


### Scripts and Analyses
run R code in Rstudio



### Data Flow
```
Raw cfDNA sequencing data
        ↓
[Alignment to reference genome]
        ↓
BAM files + tumor variants
        ↓
    [MRD Calling Module]
        ↓
MRD status + tumor fraction
        ↓
    [Figure Plot Module]
        ↓
Statistical analysis
        ↓
Publication-ready figures & tables
```

---



## Support & Issues

For questions about:
- **MRD calling:** Check troubleshooting section above
- **Figure generation:** Review script comments and data formats
- **Methods:** Refer to manuscript methods section
- **Technical issues:** Create an issue on GitHub repository

---


## License

This repository is provided for research and educational purposes.

---


