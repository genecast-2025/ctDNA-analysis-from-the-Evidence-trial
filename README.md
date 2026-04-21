# ctDNA-analysis-from-the-Evidence

## Repository Structure

```
ctDNA-analysis-from-the-Evidence-trial/
│
├── README.md                          # Main documentation file
│
├── MRD calling/                       # Molecular Residual Disease Detection Module
│   ├── mrd_workflow                   # Executable workflow (compiled with Cython)
│   ├── requirements.txt               # Python dependencies
│   ├── ucsc.hg19.fasta               # Reference genome (hg19/GRCh37)
│   ├── input/                         # Input data directory
│   │   ├── demo.bam                   # Example BAM file
│   │   ├── demo.bam.bai               # BAM index file
│   │   └── demo.variant.txt           # Example variant file
│   ├── output/                        # Output directory
│   │   ├── demo.site.txt              # Tumor-derived variants information
│   │   └── demo.mrd.txt               # MRD detection status report
│   └── src/                           # Source code (optional)
│       ├── mrd_calling.pyx            # Cython implementation
│       ├── variant_processing.py      # Variant processing module
│       ├── depth_normalization.py     # Depth normalization module
│       └── statistical_calling.py     # Statistical calling module
│
├── figure plot/                       # Statistical Analysis & Visualization Module
│   ├── data/                          # Input data directory
│   │   ├── clinical_data.csv          # Patient demographics and clinical info
│   │   ├── mrd_results.csv            # MRD detection outcomes
│   │   ├── variant_data.csv           # Detailed variant information
│   │   ├── survival_data.csv          # Follow-up and outcome data
│   │   └── cohort_demographics.csv    # Aggregated demographics
│   │
│   ├── scripts/                       # R analysis scripts
│   │   ├── utility_functions.R        # Helper functions and themes
│   │   ├── figure1_patient_cohort.R   # CONSORT flow diagram and cohort info
│   │   ├── figure2_mrd_detection.R    # MRD detection patterns and rates
│   │   ├── figure3_clinical_outcomes.R# Clinical outcomes by MRD status
│   │   ├── figure4_survival_analysis.R# Kaplan-Meier and survival curves
│   │   ├── figure5_biomarker_associations.R # Biomarker correlations
│   │   ├── supplementary_figures.R    # Extended analyses and ROC curves
│   │   ├── statistical_analysis.R     # Statistical testing and models
│   │   └── run_all_figures.R          # Master script to run all analyses
│   │
│   ├── output/                        # Generated output directory
│   │   ├── figures/                   # Publication-ready PDF figures
│   │   │   ├── figure1_consort_flow.pdf
│   │   │   ├── figure1_demographics_table.pdf
│   │   │   ├── figure2a_detection_rates.pdf
│   │   │   ├── figure2b_tumor_fractions.pdf
│   │   │   ├── figure2c_variant_complexity.pdf
│   │   │   ├── figure2d_time_points.pdf
│   │   │   ├── figure3a_recurrence_rates.pdf
│   │   │   ├── figure3b_ttr_comparison.pdf
│   │   │   ├── figure4a_km_rfs_mrd.pdf
│   │   │   ├── figure4b_km_os_mrd.pdf
│   │   │   ├── figure5a_mutation_associations.pdf
│   │   │   ├── figure5b_tf_outcomes.pdf
│   │   │   ├── figure5c_heatmap_correlations.pdf
│   │   │   ├── supplement_s1_roc_curves.pdf
│   │   │   ├── supplement_s2_forest_plots.pdf
│   │   │   └── supplement_s3_subgroup_analysis.pdf
│   │   │
│   │   ├── tables/                    # Statistical tables
│   │   │   ├── table1_demographics.csv
│   │   │   ├── table2_mrd_detection.csv
│   │   │   ├── table3_clinical_outcomes.csv
│   │   │   ├── table4_survival_analysis.csv
│   │   │   └── table5_hazard_ratios.csv
│   │   │
│   │   └── supplementary/             # Additional analyses
│   │       ├── extended_subgroup_analysis.csv
│   │       └── sensitivity_analysis.csv
│   │
│   └── README.md                      # Figure plot module documentation
│
└── .gitignore                         # Git ignore file (BAM files, large data, etc.)

```

### Directory Purpose Overview

| Directory | Purpose | File Types |
|-----------|---------|-----------|
| **MRD calling/** | Molecular residual disease detection pipeline | Python, Cython, BAM, FASTA |
| **MRD calling/input/** | Input data for MRD workflow | BAM, TXT, FASTA |
| **MRD calling/output/** | MRD calling results | TXT (site, MRD status) |
| **figure plot/data/** | Source data for statistical analysis | CSV |
| **figure plot/scripts/** | R analysis and visualization code | R |
| **figure plot/output/figures/** | Generated publication figures | PDF |
| **figure plot/output/tables/** | Statistical results tables | CSV, TXT |

---

## Overview
Reference scripts and analysis code for the study:
**"Clinical Utility of Molecular Residual Disease Detection in Early-Stage Resected EGFR-Mutated Non-Small Cell Lung Cancer: Biomarker Analyses from the EVIDENCE Trial"**

This repository contains two main components:
1. **MRD Calling**: Molecular Residual Disease detection using MinerVa Prime personalized panel approach
2. **Figure Plot**: Reproducible analysis code and visualization for manuscript figures

---

## 1. MRD Calling

### Overview
This section contains compiled, executable algorithms and methods for detecting Molecular Residual Disease (MRD) in circulating tumor DNA (ctDNA). The implementation uses the MinerVa Prime framework based on personalized panel sequencing reference.

### System Requirements and Dependencies

#### Environment
- **Python**: 3.9.0 or compatible version
- **Genome Reference**: hg19/GRCh37 (human genome build 37)
- **Operating System**: Linux/Unix-based systems recommended

#### Python Dependencies
The following packages are required (see `requirements.txt`):
```
numpy
scipy
pandas
pysam
cython
```

### Installation Instructions

#### Step 1: Install Python Dependencies
```bash
pip install -r requirements.txt
```

#### Step 2: Set Environment Variables
```bash
export LD_LIBRARY_PATH=/usr/local/lib:$LD_LIBRARY_PATH
```

This ensures that compiled Cython libraries are properly loaded at runtime.

#### Step 3: Make Workflow Executable
```bash
chmod +x mrd_workflow
```

### Running the MRD Calling Pipeline

#### Quick Start
To run the application with default settings:
```bash
./mrd_workflow
```

#### Full Analysis with Sample Data
```bash
./mrd_workflow \
  --bam input/demo.bam \
  --variant input/demo.variant.txt \
  --reference ucsc.hg19.fasta \
  --outdir output \
  --sample demo
```

### Input Data Format

#### BAM File (`--bam`)
- **Format**: Binary Alignment Map format
- **Content**: Aligned sequencing reads from ctDNA sample
- **Requirements**: 
  - Must be indexed (`.bai` file present)
  - Aligned to hg19/GRCh37 reference
  - Include quality scores and alignment information

#### Variant File (`--variant`)
- **Format**: Tab-separated text file
- **Example**: See `input/demo.variant.txt`
- **Required Columns**:
  - Chromosome (e.g., chr1, chr2)
  - Position (genomic coordinates)
  - Reference allele
  - Alternate allele
  - Gene name (optional)
  - Variant class/type

#### Reference Genome (`--reference`)
- **Format**: FASTA format
- **Build**: hg19/GRCh37
- **File**: `ucsc.hg19.fasta`
- **Note**: Must match the BAM alignment reference

### Output Files

#### 1. Site-level Output (`output/{sample}.site.txt`)
**Description**: Tumor-derived Variants Information

**Contents**:
- Detected variant positions
- Allele frequency (AF) per variant
- Read count information (reference and alternate)
- Variant quality metrics
- Detection confidence scores
- Gene and functional annotation

**Use Case**: Identifies specific tumor-derived variants present in the ctDNA sample

#### 2. MRD Status Output (`output/{sample}.mrd.txt`)
**Description**: MRD Detection and Status Report

**Contents**:
- Overall MRD status (detected/not detected)
- Aggregate tumor fraction estimate
- Combined detection p-value
- Variant-level detection calls
- Clinical interpretation flags
- Quality assessment metrics

**Use Case**: Provides clinical-grade MRD classification for patient samples

### Algorithm Details

The workflow implements the following key steps:

1. **Read Alignment Processing**
   - BAM file reading and validation
   - Quality filtering
   - Duplicate marking

2. **Variant Detection**
   - Position-specific read counting
   - Background error rate estimation
   - Depth normalization

3. **MRD Calling**
   - Multi-variant integration
   - Statistical significance testing
   - Tumor fraction estimation
   - Confidence score calculation

4. **Report Generation**
   - Quality control metrics
   - Clinical interpretation
   - Output file generation

### Parameters and Options

| Parameter | Flag | Description | Default |
|-----------|------|-------------|---------|
| BAM file | `--bam` | Input BAM file path | Required |
| Variant file | `--variant` | Input variant file path | Required |
| Reference | `--reference` | Reference genome FASTA file | Required |
| Output directory | `--outdir` | Output directory path | `output/` |
| Sample ID | `--sample` | Sample identifier for outputs | Required |
| Min depth | `--min-depth` | Minimum coverage requirement | 10000 |
| Min AF | `--min-af` | Minimum allele frequency threshold | 0.0001 |
| Threads | `--threads` | Number of parallel threads | 4 |

### Example Workflow

```bash
# 1. Prepare your data
cd /path/to/project
mkdir -p input output

# 2. Copy your files
cp /path/to/sample.bam input/
cp /path/to/sample.variants.txt input/

# 3. Run the analysis
./mrd_workflow \
  --bam input/sample.bam \
  --variant input/sample.variants.txt \
  --reference ucsc.hg19.fasta \
  --outdir output \
  --sample sample_id \
  --threads 8 \
  --min-depth 5000

# 4. Review outputs
ls -lah output/
cat output/sample_id.mrd.txt
```

### Quality Control

The pipeline includes built-in QC metrics:

- **Sequencing Depth**: Total and per-position coverage
- **Read Quality**: Base quality and mapping quality scores
- **Variant Metrics**: 
  - Allele frequency estimates
  - Background error rates
  - Strand bias assessment
- **Statistical Validation**: p-values and confidence intervals

### Troubleshooting

| Issue | Solution |
|-------|----------|
| "Command not found" | Run `chmod +x mrd_workflow` first |
| Library loading errors | Verify `LD_LIBRARY_PATH` is set correctly |
| Invalid BAM file | Ensure BAM is indexed and aligned to hg19 |
| Missing variants in output | Check variant file format matches specification |
| Low sensitivity | Increase coverage or reduce `--min-af` threshold |

### Performance Considerations

- **Runtime**: 5-30 minutes per sample (depends on depth and variant count)
- **Memory**: 4-8 GB RAM recommended
- **Storage**: ~5-10 GB per BAM file

---

## 2. Figure Plot

### Overview
This section contains source data and R code for reproducing all analyses and figures reported in the manuscript. All visualizations are publication-ready and fully reproducible.

### Repository Structure

```
figure_plot/
├── data/
│   ├── clinical_data.csv
│   ├── mrd_results.csv
│   ├── variant_data.csv
│   ├── survival_data.csv
│   └── cohort_demographics.csv
├── scripts/
│   ├── figure1_patient_cohort.R
│   ├── figure2_mrd_detection.R
│   ├── figure3_clinical_outcomes.R
│   ├── figure4_survival_analysis.R
│   ├── figure5_biomarker_associations.R
│   ├── supplementary_figures.R
│   ├── statistical_analysis.R
│   └── utility_functions.R
├── output/
│   ├── figures/
│   ├── tables/
│   └── supplementary/
└── README.md
```

### System Requirements

#### Software
- **R**: Version 4.0.0 or higher
- **RStudio**: Recommended for interactive analysis

#### R Packages
The following packages are required:
```R
# Data manipulation
library(tidyverse)
library(data.table)
library(dplyr)

# Statistical analysis
library(survival)
library(survminer)
library(rstatix)
library(stats)

# Visualization
library(ggplot2)
library(ggpubr)
library(gridExtra)
library(ComplexHeatmap)

# Additional utilities
library(cowplot)
library(scales)
library(RColorBrewer)
library(viridis)
```

### Installation

#### Install R Packages
```R
# Install CRAN packages
install.packages(c(
  "tidyverse", "data.table", "dplyr",
  "survival", "survminer", "rstatix",
  "ggplot2", "ggpubr", "gridExtra",
  "ComplexHeatmap", "cowplot", "scales",
  "RColorBrewer", "viridis"
))

# Install Bioconductor packages if needed
BiocManager::install("ComplexHeatmap")
```

#### Source Utility Functions
```R
source("scripts/utility_functions.R")
```

### Data Files

#### 1. Clinical Data (`data/clinical_data.csv`)
**Description**: Patient demographics and clinical characteristics

**Columns**:
- Patient ID
- Age at diagnosis
- Gender
- Smoking status
- Stage at diagnosis
- EGFR mutation type
- Treatment regimen
- Baseline clinical parameters

#### 2. MRD Results (`data/mrd_results.csv`)
**Description**: MRD detection outcomes from the pipeline

**Columns**:
- Patient ID
- MRD status (detected/not detected)
- Tumor fraction (%)
- Detection p-value
- Variant count
- Confidence score
- Time point

#### 3. Variant Data (`data/variant_data.csv`)
**Description**: Detailed variant information

**Columns**:
- Patient ID
- Variant ID
- Gene name
- Chromosome
- Position
- EGFR mutation status
- Allele frequency
- Functional impact

#### 4. Survival Data (`data/survival_data.csv`)
**Description**: Patient follow-up and outcome information

**Columns**:
- Patient ID
- Time to recurrence (months)
- Recurrence status (yes/no)
- Overall survival (months)
- Vital status
- Last follow-up date
- Censoring information

#### 5. Cohort Demographics (`data/cohort_demographics.csv`)
**Description**: Aggregated demographic statistics

**Columns**:
- Demographic parameter
- N total
- N MRD positive
- N MRD negative
- P-value
- Summary statistics

### Figure Descriptions

#### Figure 1: Patient Cohort and Study Flow
**Script**: `figure1_patient_cohort.R`

**Content**:
- CONSORT diagram showing patient enrollment and screening
- Cohort demographics table
- Key inclusion/exclusion criteria
- Sample collection timeline

**Outputs**:
- `figure1_consort_flow.pdf`
- `table1_demographics.pdf`

#### Figure 2: MRD Detection Rates and Characteristics
**Script**: `figure2_mrd_detection.R`

**Content**:
- MRD detection rates by clinical subgroup
- Distribution of tumor fractions
- Variant count and complexity analysis
- Time point-specific detection patterns

**Outputs**:
- `figure2a_detection_rates.pdf`
- `figure2b_tumor_fractions.pdf`
- `figure2c_variant_complexity.pdf`
- `figure2d_time_points.pdf`

#### Figure 3: Clinical Outcomes and MRD Association
**Script**: `figure3_clinical_outcomes.R`

**Content**:
- Recurrence rates by MRD status
- Time to recurrence analysis
- Clinical outcome cross-tabulation
- Subgroup outcome analysis

**Outputs**:
- `figure3a_recurrence_rates.pdf`
- `figure3b_ttr_comparison.pdf`
- `figure3_outcomes_table.pdf`

#### Figure 4: Survival Analysis
**Script**: `figure4_survival_analysis.R`

**Content**:
- Kaplan-Meier survival curves (MRD status)
- Log-rank test results
- Recurrence-free survival (RFS) curves
- Overall survival (OS) curves
- Multivariate hazard analysis

**Outputs**:
- `figure4a_km_rfs_mrd.pdf`
- `figure4b_km_os_mrd.pdf`
- `figure4_survival_table.pdf`

#### Figure 5: Biomarker Associations
**Script**: `figure5_biomarker_associations.R`

**Content**:
- MRD status association with EGFR mutations
- Tumor fraction vs. clinical outcomes
- Variant complexity vs. prognosis
- Heatmap of biomarker correlations

**Outputs**:
- `figure5a_mutation_associations.pdf`
- `figure5b_tf_outcomes.pdf`
- `figure5c_heatmap_correlations.pdf`

#### Supplementary Figures
**Script**: `supplementary_figures.R`

**Content**:
- Sensitivity and specificity analysis
- ROC curves for MRD predictions
- Forest plots for hazard ratios
- Additional subgroup analyses
- Methodological validation plots

**Outputs**:
- `supplement_s1_roc_curves.pdf`
- `supplement_s2_forest_plots.pdf`
- `supplement_s3_subgroup_analysis.pdf`

### Running Analysis Scripts

#### Option 1: Run Individual Figures
```R
# Run Figure 1
source("scripts/figure1_patient_cohort.R")

# Run Figure 2
source("scripts/figure2_mrd_detection.R")

# Run all figures
for (fig_num in 1:5) {
  script <- paste0("scripts/figure", fig_num, "*.R")
  source(script)
}
```

#### Option 2: Run Master Script (if available)
```R
# Run all analyses in sequence
source("scripts/run_all_figures.R")
```

#### Option 3: Interactive R Markdown Documents
If R Markdown files are provided:
```bash
Rscript -e "rmarkdown::render('analysis.Rmd')"
```

### Statistical Analysis

#### Key Statistical Tests

1. **Chi-square Test**: Categorical associations
   ```R
   chisq.test(mrd_status, clinical_outcome)
   ```

2. **Log-rank Test**: Survival curve comparison
   ```R
   survdiff(Surv(time, event) ~ mrd_status, data=data)
   ```

3. **Cox Proportional Hazards**: Multivariate survival analysis
   ```R
   coxph(Surv(time, event) ~ mrd_status + age + stage, data=data)
   ```

4. **Kaplan-Meier Curves**: Survival estimation
   ```R
   survfit(Surv(time, event) ~ mrd_status, data=data)
   ```

#### Significance Level
- **Alpha**: 0.05 (two-tailed)
- **Confidence Intervals**: 95%

### Output Files and Organization

#### Figures Directory
All generated PDF figures are saved in `output/figures/`
- High resolution (300 dpi) suitable for publication
- Editable vector format

#### Tables Directory
Publication-ready tables in `output/tables/`
- CSV format for supplementary materials
- HTML format for web viewing
- LaTeX format for manuscript integration

#### Supplementary Materials
Additional analyses in `output/supplementary/`

### Reproducing Results

#### Complete Workflow
```R
# 1. Load data
source("scripts/utility_functions.R")
clinical_data <- read.csv("data/clinical_data.csv")
mrd_results <- read.csv("data/mrd_results.csv")
survival_data <- read.csv("data/survival_data.csv")

# 2. Data preparation
combined_data <- merge(clinical_data, mrd_results, by="patient_id")
combined_data <- merge(combined_data, survival_data, by="patient_id")

# 3. Run all figures
source("scripts/figure1_patient_cohort.R")
source("scripts/figure2_mrd_detection.R")
source("scripts/figure3_clinical_outcomes.R")
source("scripts/figure4_survival_analysis.R")
source("scripts/figure5_biomarker_associations.R")
source("scripts/supplementary_figures.R")

# 4. Generate statistical summary
source("scripts/statistical_analysis.R")
```

### Customization and Extension

#### Modify Color Schemes
```R
# In utility_functions.R
custom_colors <- list(
  mrd_positive = "#d62728",
  mrd_negative = "#2ca02c",
  age_groups = brewer.pal(4, "Set1")
)
```

#### Add New Analyses
```R
# Create new_analysis.R with your code
source("scripts/utility_functions.R")
# Your analysis code here
```

#### Adjust Plot Parameters
```R
# In individual figure scripts
plot_theme <- theme_pubr() +
  theme(
    axis.text = element_text(size=12),
    legend.position = "right",
    plot.title = element_text(size=14, face="bold")
  )
```

### Troubleshooting

| Issue | Solution |
|-------|----------|
| Missing packages | Run `install.packages()` for required packages |
| Data file not found | Check working directory with `getwd()` |
| Plot dimensions wrong | Adjust `ggsave(width=, height=)` parameters |
| Memory issues with large data | Use `data.table::fread()` for faster loading |
| Font rendering issues | Check R graphics device: `dev.list()` |

---

## Integration: From MRD Calling to Figure Plot

### Complete Workflow

```bash
# Step 1: Run MRD calling analysis
cd MRD_calling/
./mrd_workflow \
  --bam input/sample.bam \
  --variant input/sample.variants.txt \
  --reference ucsc.hg19.fasta \
  --outdir output \
  --sample sample_id

# Step 2: Extract results for R analysis
cp output/sample_id.mrd.txt ../figure_plot/data/

# Step 3: Run figure generation
cd ../figure_plot/
Rscript -e "source('scripts/run_all_figures.R')"

# Step 4: Review outputs
ls -R output/
```

### Data Flow Diagram

```
Raw sequencing data (BAM)
         ↓
Tumor variants (VCF/TXT)
         ↓
[MRD Calling Pipeline]
         ↓
MRD status + tumor fractions
         ↓
[Figure/Statistical Analysis]
         ↓
Publication-ready figures & tables
         ↓
Manuscript & supplement materials
```

---

## Citation

If you use this code or data, please cite:

**"Clinical Utility of Molecular Residual Disease Detection in Early-Stage Resected EGFR-Mutated Non-Small Cell Lung Cancer: Biomarker Analyses from the EVIDENCE Trial"**

[Journal name, Authors, Year]

---

## License

This repository contains reference implementations and analysis code from the EVIDENCE Trial study.

---

## Support and Questions

For questions about the analysis methods, data interpretation, or reproducibility issues, please refer to the methods section of the published manuscript or contact the corresponding author.

---

## Version History

- **v1.0** (2025-10): Initial release with complete MRD calling and figure generation pipelines

---

## Appendix: File Formats Reference

### BAM Format
- Binary format for sequence alignment
- Contains read sequences, quality scores, and alignment information
- Indexed with `.bai` files for random access

### VCF/Variant Text Format
```
chr1	12345	rs123	A	T	.	PASS	DP=1000;AF=0.001	GT	0/1
chr1	23456	rs456	G	C	.	PASS	DP=5000;AF=0.0005	GT	0/1
```

### FASTA Reference Format
```
>chr1
ACGTACGTACGTACGTACGTACGTACGTACGT...
>chr2
TGCATGCATGCATGCATGCATGCATGCATGCA...
```

### Output Format (site.txt)
```
chr	pos	ref	alt	gene	af	ref_count	alt_count	quality
chr1	12345	A	T	EGFR	0.001	999	1	50.5
chr1	23456	G	C	EGFR	0.0005	4995	2	45.2
```

### Output Format (mrd.txt)
```
sample_id	mrd_status	tumor_fraction	p_value	variant_count	confidence_score	interpretation
sample_1	detected	0.05	0.001	5	0.95	MRD Positive
sample_2	not_detected	0.00001	0.25	0	0.05	MRD Negative
```

---

**Last Updated**: April 2025
**Repository**: https://github.com/genecast-2025/ctDNA-analysis-from-the-Evidence-trial
