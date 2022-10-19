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
        readmaps = expand(OUTPUTDIR+"{samplename}/mapping/reads2assembly/alignment.bam", samplename = SAMPLENAMES)

# tiara classification
#rule tiara:
    #input:
        #seqs = ASSEMBLYDIR+"{samplename}/spades_output/"+ASSEMBLYTYPE+".fasta"
    #params:
    	#tiaraoutdir = directory(OUTPUTDIR+"{samplename}/tiara")
    #output:
        #tiaraout = OUTPUTDIR+"{samplename}/tiara/tiara_out.txt"
        #tiaraplastids = OUTPUTDIR+"{samplename}/tiara/out.txt"
    #conda:
        #"envs/tiara.yaml"
    #shell:
        #"bash scripts/tiara_classifier.sh -i {input.seqs} -o {output.tiaraout}"

# generate bam file (reads 2 assembly)
rule reads2assembly:
    input:
        forwardreads = READDIR+"{samplename}_1.fastq.gz"
        reversereads = READDIR+"${samplename}_2.fastq.gz"
        seqs = ASSEMBLYDIR+"{samplename}/spades_output"+ASSEMBLYTYPE+".fasta"
    output:
        bamout = OUTPUTDIR+"{samplename}/mapping/reads2assembly/alignment.bam"
    conda:
        "envs/mapping.yml"
    shell:
        "bash scripts/reads2assembly.sh -1 {input.forwardreads} -2 {input.reversereads} -a {input.seqs} -o {output.bamout}"

# binning
#rule metabat_bin:
#    input:
#        seqs = ASSEMBLYDIR+"{samplename}/spades_output"+ASSEMBLYTYPE+".fasta"
#        bam = OUTPUTDIR+"{samplename}/mapping/reads2assembly/alignment.bam"
#    conda:
#        "envs/binner.yml"
#    shell:
#        "runMetaBat.sh --unbinned -s 50000 {input.seqs} {input.bam}"
#
# identify plastid containing bins
#rule find_plastid_bin:
#    input:
#        tiaraout = OUTPUTDIR+"{samplename}/tiara
#        bindir = OUTPUTDIR+
#    shell:
#        "bash scripts/plastidbinscan.sh -i {input.tiaraout} -b {input.bindir}"

# filter plastid bins
#rule qc_filter_plastid_bins:
#    input:
#    shell:
#        "bash scripts/plastidbinstats.sh "

# MAG quality estimation
#rule mag_quality_estimate:

# dereplicate HQ MAGs
#rule dereplicate:

# source classification dereplicated genomes
#rule tax_classify:
