# snakemake workflow to recover and estimate quality of plastids recovered from metagenomic samples

import os

# file locations
configfile: "config.yaml"

ASSEMBLYDIR = config["assemblydir"]
#BINDIR = config["bindir"]
ASSEMBLYNAME = config["assemblyname"]
OUTPUTDIR = config["outputdir"]
READDIR = config["readdir"]
MINPLASTIDCONTENT = config["min_plastid_content"]
CATDBDIR = config["catdbdir"]
CATTAXDIR = config["cattaxdir"]
UNIREFDMND = config["unirefdb"]
MAPREQUIRE = config["maprequire"]

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

include: "rules/tiara.smk"

if MAPREQUIRE == True:
    include: "rules/reads2assembly.smk"
include: "rules/plastidbins.smk"
include: "rules/kegg.smk"
include: "rules/quality_estimate.smk"
include: "rules/sourceclassify.smk"
include: "rules/markersearch.smk"
include: "rules/samplesummary.smk"

rule all:
    input:
    	#expand(OUTPUTDIR+"{samplename}/binning/metabat_depth.txt", samplename = SAMPLENAMES),
    	#expand(OUTPUTDIR+"{samplename}/plastidbins/bin_stats.tsv", samplename = SAMPLENAMES),
        #expand(OUTPUTDIR+"{samplename}/quality_estimate/completeness_estimate.csv", samplename = SAMPLENAMES),
        #expand(OUTPUTDIR+"{samplename}/quality_estimate/mitocontam_estimate.csv", samplename = SAMPLENAMES),
        expand(OUTPUTDIR+"{samplename}/plastidinfo.csv", samplename = SAMPLENAMES),
        expand(OUTPUTDIR+"{samplename}/markersearch/search.out", samplename = SAMPLENAMES)

    	#expand(OUTPUTDIR+"{samplename}/quality_estimate/quality_estimate.csv", samplename = SAMPLENAMES)

        #expand(OUTPUTDIR+"{samplename}/CAT_classification/out.BAT.plastid_source_taxonomy_predictions.txt", samplename = SAMPLENAMES)
		#expand(OUTPUTDIR+"{samplename}/quality_estimate/diamond.log", samplename = SAMPLENAMES)
