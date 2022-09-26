# snakemake workflow to evaluate algal chloroplast genome recovery

import os

# file locations
configfile: "config.yaml"

INPUTDIR = config["inputdir"]
OUTPUTDIR = config["outputdir"]
SEED = config["seed_db"]

def getsample_names(dir):
    filelist = os.listdir(config["inputdir"])
    samplenames = []

    for file in filelist:
        samplename = file.split(".")[0]
        samplenames.append(samplename)

    return samplenames

SAMPLENAMES = getsample_names(config["inputdir"])

rule all:
    input:
        assemblydir = expand(OUTPUTDIR+"{samplename}/{samplename}_chloromap_coverage.tsv", samplename = SAMPLENAMES)

# subsample reference chloroplast genomes
rule chlorochop:
    input:
        INPUTDIR+"{samplename}.fasta"
    output:
        fwd = OUTPUTDIR+"{samplename}/forward_reads.fasta",
        rvr = OUTPUTDIR+"{samplename}/reverse_reads.fasta"
    shell:
        "python3 scripts/chlorochop.py {input} {output.fwd} {output.rvr}"

# reformat fasta files into fastq files
rule fastq_gen:
    input:
        fwd = OUTPUTDIR+"{samplename}/forward_reads.fasta",
        rvr = OUTPUTDIR+"{samplename}/reverse_reads.fasta"
    output:
        fwd_fastq = OUTPUTDIR+"{samplename}/forward_reads.fastq",
        rvr_fastq = OUTPUTDIR+"{samplename}/reverse_reads.fastq"
    conda:
        "envs/getorganelle_env.yml"
    shell:
        "reformat.sh in={input.fwd} in2={input.rvr} out={output.fwd_fastq} out2={output.rvr_fastq}"

# get_organelle chloroplast assembly
rule get_organs:
    input:
        fwd_fastq = OUTPUTDIR+"{samplename}/forward_reads.fastq",
        rvr_fastq = OUTPUTDIR+"{samplename}/reverse_reads.fastq",
    output:
        assemblydir = directory(OUTPUTDIR+"{samplename}/"+SEED)
    conda:
        "envs/getorganelle_env.yml"
    shell:
        "get_organelle_from_reads.py -1 {input.fwd_fastq} -2 {input.rvr_fastq} -t 1 -o {output.assemblydir} -F other_pt -R 10"

# map re-assembled genome to original reference fasta
rule chloromap:
    input:
        assemblydir = directory(OUTPUTDIR+"{samplename}/"+SEED),
        reference_chloro = INPUTDIR+"{samplename}.fasta"
    output:
        chloromap_sam = OUTPUTDIR+"{samplename}/{samplename}_chloromap.sam"
    conda:
        "envs/mapping_env.yml"
    shell:
        "minimap2 -a {input.reference_chloro} {input.reassembled_chloro} > {output.chloromap_sam}

# convert sam to bam
rule sam2bam:
    input:
        chloromap_sam = OUTPUTDIR+"{samplename}/{samplename}_chloromap.sam"
    output:
        chloromap_bam = OUTPUTDIR+"{samplename}/{samplename}_chloromap.bam"
    conda:
        "envs/mapping_env.yml"
    shell:
        "samtools view -o {output.chloromap_bam} -bS {input.chloromap_sam}"

# sort bam
rule sorted_bam:
    input:
        chloromap_bam = OUTPUTDIR+"{samplename}/{samplename}_chloromap.bam"
    output:
        chloromap_sorted = OUTPUTDIR+"{samplename}/{samplename}_chloromap_sorted.bam"
    conda:
        "envs/mapping_env.yml"
    shell:
        "samtools sort {input.chloromap_bam} -o {output.chloromap_sorted}"

# generate coverage of re-assembly
rule get_coverage:
    input:
        chloromap_sorted = OUTPUTDIR+"{samplename}/{samplename}_chloromap_sorted.bam"
    output:
        chloromap_coverage = OUTPUTDIR+"{samplename}/{samplename}_chloromap_coverage.tsv"
    conda:
        "envs/mapping_env.yml"
    shell:
        "samtools coverage -o {output.chloromap_coverage} {input.chloromap_sorted}"
