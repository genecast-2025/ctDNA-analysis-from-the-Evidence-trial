#This repository contains the compiled, executable algorithms and methods described in our research paper. 
#The code has been compiled using Cython.

#Quick Start
#Dependencies
#This document outlines the dependencies required to run the research code.

#python 3.9.0

#hg19/GRCh37: human genome build 37

#Installation
#Install Python Dependencies
pip install -r requirements.txt

#Set environment
export LD_LIBRARY_PATH=/usr/local/lib:$LD_LIBRARY_PATH

#Make executable
chmod +x mrd_worflow 

#Run the application
./mrd_worflow 

#Usage
#Prepare input data in the required format (see demo/demo.variant.txt)

#Run the analysis
#./mrd_worflow --bam demo/demo.bam --variant demo/demo.variant.txt --reference ucsc.hg19.fasta --outdir demo_result --sample demo


#Expected outputs
#demo/demo.site.txt - Tumor-derived Variants info of dectection sample
#demo/demo.mrd.txt - MRD status info of dectection sample




