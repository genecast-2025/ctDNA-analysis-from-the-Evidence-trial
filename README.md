# ctDNA-analysis-from-the-Evidence

Reference scripts for study "Clinical Utility of Molecular Residual Disease Detection in Early-Stage Resected EGFR-Mutated Non-Small Cell Lung Cancer: Biomarker Analyses from the EVIDENCE Trial"

## 1. MRD calling from input variant and bam file.
This repository contains the compiled, executable algorithms and methods described in our research paper. 
The code has been compiled using Cython.

### Quick Start
Dependencies
This document outlines the dependencies required to run the research code.

### python 3.9.0
#### hg19/GRCh37: human genome build 37

### Installation
### Install Python Dependencies
pip install -r requirements.txt

#### Set environment
export LD_LIBRARY_PATH=/usr/local/lib:$LD_LIBRARY_PATH

### Make executable
chmod +x mrd_worflow 

### Run the application
./mrd_worflow 

### Usage
Prepare input data in the required format (see input/demo.variant.txt)

### Run the analysis
./mrd_worflow --bam input/demo.bam --variant input/demo.variant.txt --reference ucsc.hg19.fasta --outdir output --sample demo


### Expected outputs
output/demo.site.txt - Tumor-derived Variants info of dectection sample
output/demo.mrd.txt - MRD status info of dectection sample


## 2. figure plot
Source data and R code for reproducing the analyses reported in the manuscript
