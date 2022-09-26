# snakemake workflow to recover and estimate quality of plastids recovered from metagenomic samples

import os

# file locations
configfile: "config.yaml"

ASSEMBLYDIR = config["assemblydir"]
BINDIR = config["assemblytype"]
ASSEMBLYTYPE = config["type"]
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

# tiara classification
rule tiara:
    input:
        ASSEMBLYDIR+"{samplename}/"+ASSEMBLYTYPE+".fasta"
    output:
        OUTPUTDIR+"{samplename}/tiara_output"
    env:
        "envs/plastcovery.yaml"
    shell:
        "bash scripts/tiara_classifier.sh -i {input} -o {output}"
