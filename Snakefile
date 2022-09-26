# snakemake workflow to recover and estimate quality of plastids recovered from metagenomic samples

import os

# file locations
configfile: "config.yaml"

ASSEMBLYDIR = config["assemblydir"]
BINDIR = config["bindir"]
ASSEMBLYTYPE = config["assemblytype"]
OUTPUTDIR = config["outputdir"]


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
        tiaraplastids = expand(OUTPUTDIR+"{samplename}/tiara/tiara_out.txt", samplename = SAMPLENAMES)

# tiara classification
rule tiara:
    input:
        seqs = ASSEMBLYDIR+"{samplename}/spades_output/"+ASSEMBLYTYPE+".fasta"
    #params:
    	#tiaraoutdir = directory(OUTPUTDIR+"{samplename}/tiara")
    output:
        tiaraout = OUTPUTDIR+"{samplename}/tiara/tiara_out.txt"
        #tiaraplastids = OUTPUTDIR+"{samplename}/tiara/out.txt"
    conda:
        "envs/tiara.yaml"
    shell:
        "bash scripts/tiara_classifier.sh -i {input.seqs} -o {output.tiaraout}"
