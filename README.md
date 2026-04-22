# ctDNA-analysis-from-the-Evidence

**Clinical Utility of Molecular Residual Disease Detection in Early-Stage Resected EGFR-Mutated Non-Small Cell Lung Cancer: Biomarker Analyses from the EVIDENCE Trial**

> Reference scripts and reproducible analysis code for MRD detection in ctDNA sequencing data and comprehensive statistical analysis with publication-ready visualizations.

---

## Repository Contents

This repository contains two integrated analysis modules for the EVIDENCE trial study:

1. **[MRD Calling](./MRD%20calling)** - Molecular Residual Disease detection from circulating tumor DNA
2. **[Figure Plot](./figure%20plot)** - Statistical analysis and publication-ready visualizations


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
| Genome | hg19/GRCh37 | Must use GRCh37 reference coordinates |
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

#### Complete Example
```bash
./mrd_workflow \
  --bam path/to/sample.bam \
  --variant path/to/sample.variants.txt \
  --reference /ref/ucsc.hg19.fasta \
  --outdir ./results \
  --sample patient_123 \
  --threads 8 \
  --min-depth 5000 \
  --min-af 0.0001
```

### Input Formats

#### BAM File Format
- **Standard alignment format** for sequencing reads
- Must be indexed (`.bai` file required)
- Aligned to **hg19/GRCh37**
- Includes quality scores and alignment metrics

**Requirements:**
```bash
# Index BAM file if not already indexed
samtools index sample.bam
```

#### Variant File Format
Tab-separated text file with tumor-derived variants.

**Example: `demo.variant.txt`**
```
chromosome    position    ref_allele    alt_allele    gene_name    notes
chr1          12345       A             T             EGFR         mutation_1
chr7          55000       G             C             EGFR         mutation_2
chr19         100         C             G             TP53         mutation_3
```

**Required Columns:**
- `chromosome` - Genomic coordinate (format: `chr1`, `chr2`, etc.)
- `position` - Genomic position
- `ref_allele` - Reference allele
- `alt_allele` - Alternate allele
- `gene_name` - Gene annotation (optional)

#### Reference Genome
- **File format:** FASTA
- **Build:** GRCh37/hg19
- **Filename:** `ucsc.hg19.fasta`
- Must match BAM alignment reference exactly

### Output Files

#### 1. Site-Level Output (`<sample>.site.txt`)

**Purpose:** Detailed information on detected variants in the sample

**Structure:**
```
chromosome  position  ref_allele  alt_allele  gene    allele_freq    ref_count  alt_count  quality  confidence
chr1        12345     A           T           EGFR    0.0008         999        1          48.5     0.92
chr7        55000     G           C           EGFR    0.0005         1999       1          42.1     0.88
```

**Columns:**
- `chromosome` - Genomic location
- `position` - Variant position
- `ref_allele` / `alt_allele` - Variant details
- `gene` - Gene annotation
- `allele_freq` - Estimated allele frequency
- `ref_count` / `alt_count` - Supporting reads
- `quality` - Quality score
- `confidence` - Detection confidence (0-1)

#### 2. MRD Status Output (`<sample>.mrd.txt`)

**Purpose:** Clinical MRD determination and summary statistics

**Structure:**
```
sample_id     mrd_status    tumor_fraction    p_value     variant_count    confidence    interpretation
patient_123   detected      0.050             0.0001      5                 0.95          MRD Positive
patient_456   not_detected  <0.00001          0.45        0                 0.05          MRD Negative
```

**Columns:**
- `sample_id` - Patient identifier
- `mrd_status` - Overall MRD call (detected/not_detected)
- `tumor_fraction` - Estimated ctDNA fraction (%)
- `p_value` - Statistical significance
- `variant_count` - Number of detected variants
- `confidence` - Overall confidence score
- `interpretation` - Clinical interpretation

### Parameters Reference

| Parameter | Flag | Type | Default | Description |
|-----------|------|------|---------|-------------|
| Input BAM | `--bam` | path | Required | Aligned sequencing data |
| Variants | `--variant` | path | Required | Tumor variants file |
| Reference | `--reference` | path | Required | Reference genome (hg19) |
| Output Dir | `--outdir` | path | `./output` | Output directory |
| Sample ID | `--sample` | string | Required | Sample identifier |
| Min Depth | `--min-depth` | int | 10000 | Minimum coverage |
| Min AF | `--min-af` | float | 0.0001 | Minimum allele frequency |
| Threads | `--threads` | int | 4 | Parallel threads |
| Verbose | `--verbose` | flag | false | Detailed output |

### Pipeline Steps

The workflow executes the following analysis steps:

1. **Input Validation**
   - BAM file index verification
   - Variant file parsing
   - Reference genome compatibility check

2. **Read Processing**
   - BAM file reading
   - Quality filtering (MAPQ, baseQ)
   - Duplicate handling

3. **Variant Detection**
   - Position-specific read counting
   - Background error estimation
   - Depth normalization

4. **Statistical Testing**
   - Binomial testing per variant
   - Multi-variant integration
   - FDR correction

5. **Reporting**
   - Site-level output generation
   - MRD status determination
   - Report file creation

### Quality Control

Built-in QC metrics:

**Sequencing Depth:**
- Total coverage assessment
- Per-position depth metrics
- Uniformity analysis

**Read Quality:**
- Base quality distribution
- Mapping quality statistics
- Strand bias assessment

**Variant Metrics:**
- Allele frequency estimates
- Confidence scores
- Background error rates

### Performance

| Metric | Typical Value |
|--------|---------------|
| Runtime per sample | 5-30 minutes |
| Memory requirement | 4-8 GB RAM |
| BAM file size | ~5-10 GB |
| Processing speed | 1-2 million reads/minute |

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

**Issue:** Low sensitivity / missing variants
```bash
# Solutions:
# 1. Reduce minimum AF threshold
./mrd_workflow --min-af 0.00005
# 2. Verify variant file format
head -20 input/variants.txt
# 3. Check sequencing depth
samtools depth input/sample.bam | awk '{sum+=$3} END {print "Average depth:", sum/NR}'
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

### Quick Start

```bash
# 1. Load data and run all analyses
cd figure\ plot/
R CMD BATCH scripts/run_all_figures.R

# 2. Or run interactively
R
source("scripts/run_all_figures.R")
```

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

#### clinical_data.csv
Patient demographics and baseline characteristics
```
patient_id, age, gender, smoking_status, stage, egfr_mutation, treatment
pt_001, 65, Female, Never, IB, L858R, adjuvant_TKI
pt_002, 58, Male, Former, IIA, 19del, adjuvant_TKI
```

#### mrd_results.csv
MRD detection outcomes from the MRD calling pipeline
```
patient_id, time_point, mrd_status, tumor_fraction, p_value, variant_count
pt_001, baseline, detected, 0.045, 0.0001, 4
pt_001, 3mo, not_detected, 0.00001, 0.35, 0
```

#### survival_data.csv
Patient follow-up and clinical outcomes
```
patient_id, months_to_recurrence, recurrence_status, overall_survival, vital_status
pt_001, 12, Yes, 28, Alive
pt_002, 6, Yes, 15, Deceased
```

#### variant_data.csv
Detailed variant information
```
patient_id, variant_id, gene, chromosome, position, allele_freq, functional_impact
pt_001, var_001, EGFR, chr7, 55000, 0.045, p.L858R
pt_001, var_002, TP53, chr17, 7000, 0.032, p.R175H
```

### Scripts and Analyses

#### Main Analysis Scripts

| Script | Output | Content |
|--------|--------|---------|
| `figure1_patient_cohort.R` | Figure 1, Table 1 | CONSORT flow, cohort demographics |
| `figure2_mrd_detection.R` | Figure 2A-D | MRD detection rates, tumor fractions |
| `figure3_clinical_outcomes.R` | Figure 3 | Recurrence rates by MRD status |
| `figure4_survival_analysis.R` | Figure 4A-B | Kaplan-Meier curves (RFS, OS) |
| `figure5_biomarker_associations.R` | Figure 5 | Biomarker correlations and heatmaps |

#### Supporting Scripts

| Script | Purpose |
|--------|---------|
| `utility_functions.R` | Themes, functions, color definitions |
| `statistical_analysis.R` | Statistical tests, p-values, CIs |
| `supplementary_figures.R` | Extended analyses, ROC curves |
| `run_all_figures.R` | Master script to run all analyses |

### Running Analyses

#### Run All Figures
```R
# Automatically generates all figures and tables
source("scripts/run_all_figures.R")
```

#### Run Individual Figure
```R
# Generate only Figure 1
source("scripts/figure1_patient_cohort.R")
```

#### Custom Analysis
```R
# Load utility functions and data
source("scripts/utility_functions.R")
library(tidyverse)
library(survival)

# Load data
clinical_data <- read.csv("data/clinical_data.csv")
mrd_results <- read.csv("data/mrd_results.csv")

# Your custom analysis...
```

### Key Statistical Methods

#### Survival Analysis
**Kaplan-Meier Estimation:**
```R
fit <- survfit(Surv(time, event) ~ mrd_status, data = data)
plot(fit)
```

**Log-Rank Test:**
```R
survdiff(Surv(time, event) ~ mrd_status, data = data)
```

**Cox Proportional Hazards Model:**
```R
coxph(Surv(time, event) ~ mrd_status + age + stage, data = data)
```

#### Statistical Testing
- **Categorical:** Chi-square test
- **Continuous:** Mann-Whitney U test, t-test
- **Survival:** Log-rank test, Cox regression
- **Multiple comparisons:** FDR correction

**Significance Level:** α = 0.05 (two-tailed)
**Confidence Intervals:** 95%

### Output Files

Organized in `output/` directory:

```
output/
├── figures/                     # High-resolution PDFs
│   ├── figure1_consort.pdf
│   ├── figure2a_detection_rates.pdf
│   ├── figure3_outcomes.pdf
│   ├── figure4a_km_rfs.pdf
│   ├── figure4b_km_os.pdf
│   ├── figure5_correlations.pdf
│   └── ...
│
├── tables/                      # Statistical tables
│   ├── table1_demographics.csv
│   ├── table2_mrd_outcomes.csv
│   ├── table3_survival_stats.csv
│   └── ...
│
└── supplementary/               # Extended analyses
    ├── supplement_s1_roc_curves.pdf
    ├── supplement_s2_forest_plots.pdf
    └── ...
```

**Output Specifications:**
- **Figure Resolution:** 300 dpi (publication quality)
- **Format:** PDF (vector), PNG (raster)
- **Table Format:** CSV (data), PDF (formatted)

### Customization

#### Change Color Scheme
```R
# Edit utility_functions.R
custom_colors <- list(
  mrd_positive = "#e41a1c",
  mrd_negative = "#377eb8",
  age_groups = brewer.pal(4, "Set1")
)
```

#### Modify Plot Appearance
```R
# Adjust theme in figure scripts
plot_theme <- theme_pubr() +
  theme(
    axis.text.x = element_text(angle = 45, hjust = 1),
    legend.position = "bottom",
    plot.title = element_text(size = 14, face = "bold")
  )
```

#### Add New Analysis
```R
# Create new_figure.R following the template:
source("scripts/utility_functions.R")

# Load and process data
data <- read.csv("data/clinical_data.csv")

# Generate analysis and figure
# ...
```

### Troubleshooting

| Issue | Solution |
|-------|----------|
| Missing packages | `install.packages("package_name")` |
| Data not found | Check working directory: `getwd()` |
| Memory issues | Use `data.table::fread()` instead of `read.csv()` |
| Figure quality poor | Increase `dpi` parameter in `ggsave()` |
| Knit errors in RMarkdown | Check package dependencies are installed |

---

## Integration: MRD Calling → Figure Plot

### Complete Workflow

```bash
# Step 1: Run MRD calling on all samples
cd MRD\ calling/
for bam in /data/*.bam; do
  ./mrd_workflow \
    --bam "$bam" \
    --variant /data/variants.txt \
    --reference ucsc.hg19.fasta \
    --outdir ./mrd_results \
    --sample "$(basename $bam .bam)"
done

# Step 2: Compile MRD results for R analysis
cd ../figure\ plot/data/
cat ../MRD\ calling/mrd_results/*.mrd.txt > mrd_results.csv

# Step 3: Run all statistical analyses
cd ..
R CMD BATCH scripts/run_all_figures.R

# Step 4: Review outputs
ls -lah output/figures/
```

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

## Citation

If you use this repository, please cite:

```bibtex
@article{EVIDENCE_Trial_2025,
  title={Clinical Utility of Molecular Residual Disease Detection in Early-Stage 
         Resected EGFR-Mutated Non-Small Cell Lung Cancer: Biomarker Analyses 
         from the EVIDENCE Trial},
  author={[Authors]},
  journal={[Journal]},
  year={2025}
}
```

---

## Data Availability

- **cfDNA Sequencing Data:** Deposited at [Repository name] under accession code [XXX]
- **Clinical Data:** Available upon request from corresponding author
- **Variant Calls:** Available in `MRD calling/input/` directory

---

## Support & Issues

For questions about:
- **MRD calling:** Check troubleshooting section above
- **Figure generation:** Review script comments and data formats
- **Methods:** Refer to manuscript methods section
- **Technical issues:** Create an issue on GitHub repository

---

## Contributors

Contributors listed in `CONTRIBUTORS.md`

---

## License

This repository is provided for research and educational purposes.

---

## Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.0 | 2025-10 | Initial release |
| 1.1 | 2025-11 | Added supplementary analyses |

---

## Appendix: File Format Reference

### BAM Format
- Binary Alignment/Map format (SAM equivalent)
- Contains sequencing reads with alignments
- Must be indexed with samtools for random access

### VCF/Variant Format
Standard VCF or custom tab-separated format for variants

### FASTA Reference Format
```fasta
>chr1
ACGTACGTACGTACGTACGTACGTACGTACGT...
>chr2
TGCATGCATGCATGCATGCATGCATGCATGCA...
```

### Output Formats
- **site.txt:** Tab-separated variant details
- **mrd.txt:** Tab-separated MRD status and metrics
- **PDF figures:** Vector format for publication
- **CSV tables:** Data format for supplementary materials

---

**Last Updated:** April 2025  
**Repository:** https://github.com/genecast-2025/ctDNA-analysis-from-the-Evidence-trial
