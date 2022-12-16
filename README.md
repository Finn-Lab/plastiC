# plastiC
A [Snakemake](https://snakemake.readthedocs.io/en/stable/getting_started/installation.html) workflow for recovery and characterization of plastid genomes from metagenomic datasets. 

# Installation & Setup
1. Install [conda](https://conda.io/projects/conda/en/latest/user-guide/install/index.html).  

2. Create a new environment with Snakemake installed Snakemake](https://snakemake.readthedocs.io/en/stable/getting_started/installation.html).  
Example:  
`conda create -n snakemake -c bioconda snakemake`

3. Clone *plastiC* repository.  
Example:  
`git clone --recursive https://github.com/escamero/plastiC.git`
  
4. Download databases (described below).

# Databases
*plastiC* requires databases for taxonomic source classification (using [CAT](https://github.com/dutilh/CAT) and for completeness estimation.  
Please download the following and provide links to the paths to these databases in the as instructed `config.yml`. 

**CAT Databases**  
Please visit https://github.com/dutilh/CAT for database installation and preparation instructions provided. 

**Uniprot**

# Configuration

# Running
After the above steps have been completed, samples can now be run to identify plastid genomes. The first step is to activate your `conda` environment.  
Example:  
`conda activate snakemake`  

The value for `-j` should be adjusted to reflect the number of cores available. The `-k` flag may be removed if users desire the workflow to stop if an independent job fails.  
Example:  
`snakemake --use-conda -k -j 2`

*plastiC* can also be executed on a cluster. The specifications (e.g., memory, cores) for cluster execution can be adjusted in the `cluster.yml` file.  
Note: Exact submission command may need to bea djusted depending on your system.  
Example:  
`snakemake --use-conda -k -j 2 --cluster-config cluster.yml --cluster 'bsub -n {cluster.nCPU} -M {cluster.mem} -o {cluster.output}'`

# Output  
For each sample, three dictories will be created: `logs`, `working` and `plastids`. Final outputs regarding
plastid information can be found in the `plastids` directory. The `working` directory contains intermediate files
from analyses required for identification and characterziation of plastid genomes but can be removed if users desire.   

