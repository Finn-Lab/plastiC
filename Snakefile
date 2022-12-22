# snakemake workflow to recover and estimate quality of plastids recovered from metagenomic samples

import os


# file locations
configfile: "config.yaml"


ASSEMBLYDIR = config["assemblydir"]
ASSEMBLYNAME = config["assemblyname"]
OUTPUTDIR = config["outputdir"]
MAPREQUIRE = config["maprequire"]

if MAPREQUIRE == True:
    READDIR = config["readdir"]

if MAPREQUIRE == False:
    MAPBAMDIR = config["mapbamdir"]
    MAPBAM = config["mapbamfile"]

MINPLASTIDCONTENT = config["min_plastid_content"]

CATDBDIR = config["catdbdir"]
CATTAXDIR = config["cattaxdir"]
UNIREFDMND = config["unirefdb"]


def getsample_names(dir):
    filelist = os.listdir(config["assemblydir"])
    samplenames = []

    for file in filelist:
        samplename = file.split(".")[0]
        samplenames.append(samplename)

    return samplenames


SAMPLENAMES = getsample_names(config["assemblydir"])

for sample in SAMPLENAMES:
    if not os.path.exists(OUTPUTDIR + sample + "/logs"):
        os.makedirs(OUTPUTDIR + sample + "/logs")

    if not os.path.exists(OUTPUTDIR + sample + "/working"):
        os.makedirs(OUTPUTDIR + sample + "/working")


include: "rules/tiara.smk"


if MAPREQUIRE == True:

    include: "rules/reads2assembly.smk"


if MAPREQUIRE == False:

    include: "rules/nomapreq.smk"


include: "rules/plastidbins.smk"


include: "rules/kegg.smk"


include: "rules/quality_estimate.smk"


include: "rules/sourceclassify.smk"


include: "rules/markersearch.smk"


include: "rules/samplesummary.smk"


rule all:
    input:
        expand(
            OUTPUTDIR + "{samplename}/plastids/plastidinfo.csv", samplename=SAMPLENAMES
        ),
        expand(
            OUTPUTDIR + "{samplename}/plastids/markersearch/rRNA_fasta.out",
            samplename=SAMPLENAMES,
        ),
        expand(
            OUTPUTDIR + "{samplename}/plastids/markersearch/rbcL_fasta.out",
            samplename=SAMPLENAMES,
        ),
