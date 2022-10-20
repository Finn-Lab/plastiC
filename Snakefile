# snakemake workflow to recover and estimate quality of plastids recovered from metagenomic samples

import os

# file locations
configfile: "config.yaml"

ASSEMBLYDIR = config["assemblydir"]
BINDIR = config["bindir"]
ASSEMBLYTYPE = config["assemblytype"]
OUTPUTDIR = config["outputdir"]
READDIR = config["readdir"]

def getsample_names(dir):
    filelist = os.listdir(config["assemblydir"])
    samplenames = []

    for file in filelist:
        samplename = file.split(".")[0]
        samplenames.append(samplename)

    return samplenames

SAMPLENAMES = getsample_names(config["assemblydir"])

for sample in SAMPLENAMES:
    if not os.path.exists(OUTPUTDIR+sample+"/logs"):
        os.makedirs(OUTPUTDIR+sample+"/logs")

if not os.path.exists(OUTPUTDIR+"/summary/logs"):
    os.makedirs(OUTPUTDIR+"/summary/logs")


rule all:
    input:
    	expand(OUTPUTDIR+"{samplename}/binning/metabat_depth.txt", samplename = SAMPLENAMES),
    	expand(OUTPUTDIR+"{samplename}/plastidbins/plastid_bins.tsv", samplename = SAMPLENAMES)

# generate bam file (reads 2 assembly)
rule reads2assembly:
    input:
        forwardreads = READDIR+"{samplename}/{samplename}_1.fastq.gz",
        reversereads = READDIR+"{samplename}/{samplename}_2.fastq.gz",
        seqs = ASSEMBLYDIR+"{samplename}/spades_output/"+ASSEMBLYTYPE+".fasta"
    output:
        bamout = OUTPUTDIR+"{samplename}/mapping/reads2assembly/alignment.bam"
    conda:
        "envs/mapping.yml"
    shell:
        "bash scripts/readmap2assembly.sh -1 {input.forwardreads} -2 {input.reversereads} -a {input.seqs} -o {output.bamout}"

# generate depth file
rule jgi_depth:
	input:
		bamout = OUTPUTDIR+"{samplename}/mapping/reads2assembly/alignment.bam"
	output:
		jgidepth = OUTPUTDIR+"{samplename}/binning/metabat_depth.txt"
	conda:
		"envs/binner.yml"
	shell:
		"jgi_summarize_bam_contig_depths --outputDepth {output.jgidepth} {input.bamout}"

rule metabat_binning:
    input:
        seqs = ASSEMBLYDIR+"{samplename}/spades_output/"+ASSEMBLYTYPE+".fasta",
    	jgidepth = OUTPUTDIR+"{samplename}/binning/metabat_depth.txt"
    output:
        bin_prefix = OUTPUTDIR+"{samplename}/binning/bins/bin",
        unbinned_seqs_holder = OUTPUTDIR+"{samplename}/binning/bins/bin.unbinned.fa"
    conda:
        "envs/binner.yml"
    shell:
        "metabat2 -i {input.seqs} -a {input.jgidepth} -o {output.bin_prefix} -s 50000 --unbinned"

rule plastid_bin_scan:
    input:
        plastid_seqs = OUTPUTDIR+"{samplename}/tiara/plastid_scaffolds.fasta",
        unbinned_seqs_holder = OUTPUTDIR+"{samplename}/binning/bins/bin.unbinned.fa"
    params:
        bindir = directory(OUTPUTDIR+"{samplename}/binning/bins"),
        plastidbindir = directory(OUTPUTDIR+"{samplename}/plastidbins")
    output:
        plastidbinset = OUTPUTDIR+"{samplename}/plastidbins/plastid_bins.tsv"
    shell:
        "bash scripts/plastidbinscan.sh -i {input.plastid_seqs} -b {params.bindir} -o {params.plastidbindir}"
#
#    params:
#        bindir = directory(OUTPUTDIR+"{samplename}/binning/bins"),
#        tiaraoutdir = directory(OUTPUTDIR+"{samplename}/tiara"),
#        plastidbindir = directory(OUTPUTDIR+"{samplename}/plastidbins")
#    output:
#        plastidbins = OUTPUTDIR+"{samplename}/plastidbins/plastid_bins.tsv"
#    conda:
#        "envs/binner.yml"
#    shell:
#        "bash scripts/plastidbinner.sh -a {input.seqs} -m {input.bamout} -b {params.bindir} -t {params.tiaraoutdir} -p {params.plastidbindir}"
