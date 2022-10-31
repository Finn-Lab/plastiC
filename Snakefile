# snakemake workflow to recover and estimate quality of plastids recovered from metagenomic samples

import os

# file locations
configfile: "config.yaml"

ASSEMBLYDIR = config["assemblydir"]
#BINDIR = config["bindir"]
ASSEMBLYTYPE = config["assemblytype"]
OUTPUTDIR = config["outputdir"]
READDIR = config["readdir"]
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
    if not os.path.exists(OUTPUTDIR+sample+"/logs"):
        os.makedirs(OUTPUTDIR+sample+"/logs")

if not os.path.exists(OUTPUTDIR+"/summary/logs"):
    os.makedirs(OUTPUTDIR+"/summary/logs")


rule all:
    input:
    	expand(OUTPUTDIR+"{samplename}/binning/metabat_depth.txt", samplename = SAMPLENAMES),
    	expand(OUTPUTDIR+"{samplename}/plastidbins/bin_stats.tsv", samplename = SAMPLENAMES),
        expand(OUTPUTDIR+"{samplename}/quality_estimate/completeness_estimate.csv", samplename = SAMPLENAMES),
        expand(OUTPUTDIR+"{samplename}/quality_estimate/mitocontam_estimate.csv", samplename = SAMPLENAMES)

    	#expand(OUTPUTDIR+"{samplename}/quality_estimate/quality_estimate.csv", samplename = SAMPLENAMES)

        #expand(OUTPUTDIR+"{samplename}/CAT_classification/out.BAT.plastid_source_taxonomy_predictions.txt", samplename = SAMPLENAMES)
		#expand(OUTPUTDIR+"{samplename}/quality_estimate/diamond.log", samplename = SAMPLENAMES)

# generate bam file (reads 2 assembly)
rule reads2assembly:
    input:
        forwardreads = READDIR+"{samplename}/{samplename}_1.fastq.gz",
        reversereads = READDIR+"{samplename}/{samplename}_2.fastq.gz",
        seqs = ASSEMBLYDIR+"{samplename}/"+ASSEMBLYTYPE+".fasta"
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

# bin using metabat
rule metabat_binning:
    input:
        seqs = ASSEMBLYDIR+"{samplename}/"+ASSEMBLYTYPE+".fasta",
    	jgidepth = OUTPUTDIR+"{samplename}/binning/metabat_depth.txt"
    params:
    	bin_prefix = OUTPUTDIR+"{samplename}/binning/bins/bin"
    output:
        #unbinned_seqs_holder = OUTPUTDIR+"{samplename}/binning/bins/bin.unbinned.fa",
        metabat2_log = OUTPUTDIR+"{samplename}/binning/metabat2.log"
    conda:
        "envs/binner.yml"
    shell:
        "metabat2 -i {input.seqs} -a {input.jgidepth} -o {params.bin_prefix} -s 50000 --unbinned > {output.metabat2_log}"

# scan bins for plastid reads and select ones that are likely plastid based on seq lengths
rule fetch_plastid_bins:
    input:
        plastid_seqs = OUTPUTDIR+"{samplename}/tiara/plastid_scaffolds.fasta",
        metabat2_log = OUTPUTDIR+"{samplename}/binning/metabat2.log"
        #minplastidbinsize = MINPLASTIDCONTENT
    params:
        bindir = directory(OUTPUTDIR+"{samplename}/binning/bins"),
        plastidbindir = directory(OUTPUTDIR+"{samplename}/plastidbins")
    output:
        plastidbinstats = OUTPUTDIR+"{samplename}/plastidbins/bin_stats.tsv"
    shell:
        "bash scripts/plastidbinner.sh -b {params.bindir} -t {input.plastid_seqs} -p {params.plastidbindir} -s 90"

# diamond blastp kegg search
rule diamond_blastp:
    input:
        plastidbinstats = OUTPUTDIR+"{samplename}/plastidbins/bin_stats.tsv",
        unirefdb = UNIREFDMND
    params:
        plastidbindir = directory(OUTPUTDIR+"{samplename}/plastidbins/bins"),
        keggoutdir = directory(OUTPUTDIR+"{samplename}/quality_estimate/diamond_blastp"),
        prodigaldir = directory(OUTPUTDIR+"{samplename}/prodigal")
        #keggcountdir = directory(OUTPUTDIR+"{samplename}/quality_estimate/kegg_counts")
    output:
        kegg_log = OUTPUTDIR+"{samplename}/quality_estimate/kegg_out.log"
    conda:
        "envs/kegg.yml"
    shell:
        "bash scripts/kegg_output.sh -i {params.plastidbindir} -p {params.prodigaldir} -d {input.unirefdb} -o {params.keggoutdir} > {output.kegg_log}"

rule kegg_counter:
    input:
        kegg_log = OUTPUTDIR+"{samplename}/quality_estimate/kegg_out.log"
    params:
        keggoutdir = directory(OUTPUTDIR+"{samplename}/quality_estimate/diamond_blastp"),
        keggcountdir = directory(OUTPUTDIR+"{samplename}/quality_estimate/kegg_counts")
    output:
        kegg_counts_log = OUTPUTDIR+"{samplename}/quality_estimate/kegg_counts.log"
    shell:
        "bash scripts/keggcounter.sh -i {params.keggoutdir} -o {params.keggcountdir} > {output.kegg_counts_log}"

# completeness estimate
rule binprep_completeness:
	input:
		kegg_counts_log = OUTPUTDIR+"{samplename}/quality_estimate/kegg_counts.log"
	params:
		keggcountdir = directory(OUTPUTDIR+"{samplename}/quality_estimate/kegg_counts")
	output:
		keggdataprep = OUTPUTDIR+"{samplename}/quality_estimate/comp_kegg_data.csv"
	conda:
		"envs/quality.yml"
	shell:
		"python3 scripts/kegg_prep_bin.py -kc {params.keggcountdir} -o {output.keggdataprep} -l resources/quality_estimates/training_kegg_id_list.txt"

rule completeness_estimate:
    input:
        keggdataprep = OUTPUTDIR+"{samplename}/quality_estimate/comp_kegg_data.csv"
    params:
        keggcountdir = directory(OUTPUTDIR+"{samplename}/quality_estimate/kegg_counts")
    output:
        completeness = OUTPUTDIR+"{samplename}/quality_estimate/completeness_estimate.csv"
    conda:
        "envs/quality.yml"
    shell:
        "python3 scripts/quality_estimate_base.py -k {input.keggdataprep} -kc {params.keggcountdir} -o {output.completeness} -m resources/quality_estimates/completeness.model -t completeness"


# mitochondrial contamination estimate
rule binprep_mitocontam:
	input:
		kegg_counts_log = OUTPUTDIR+"{samplename}/quality_estimate/kegg_counts.log"
	params:
		keggcountdir = directory(OUTPUTDIR+"{samplename}/quality_estimate/kegg_counts")
	output:
		keggdataprep = OUTPUTDIR+"{samplename}/quality_estimate/mitocontam_kegg_data.csv"
	conda:
		"envs/quality.yml"
	shell:
		"python3 scripts/kegg_prep_bin.py -kc {params.keggcountdir} -o {output.keggdataprep} -l resources/quality_estimates/mitochloro1_id_list.txt"

rule mitocontam_estimate:
    input:
        keggdataprep = OUTPUTDIR+"{samplename}/quality_estimate/mitocontam_kegg_data.csv"
    params:
        keggcountdir = directory(OUTPUTDIR+"{samplename}/quality_estimate/kegg_counts")
    output:
        completeness = OUTPUTDIR+"{samplename}/quality_estimate/mitocontam_estimate.csv"
    conda:
        "envs/quality.yml"
    shell:
        "python3 scripts/quality_estimate_base.py -k {input.keggdataprep} -kc {params.keggcountdir} -o {output.completeness} -m resources/quality_estimates/mitochloromodel1_defgbr.model -t mito_contam"

# assign predicted taxonomic classification using CAT
rule plastid_source_classification:
    input:
        kegg_counts_log = OUTPUTDIR+"{samplename}/quality_estimate/kegg_counts.log",
        plastidbinstats = OUTPUTDIR+"{samplename}/plastidbins/bin_stats.tsv",
        catdb = CATDBDIR,
        cattax = CATTAXDIR
    params:
        cat_outputdir = directory(OUTPUTDIR+"{samplename}/CAT_classification"),
        plastidbins = directory(OUTPUTDIR+"{samplename}/plastidbins/bins")
    output:
        plastid_source_prediction = OUTPUTDIR+"{samplename}/CAT_classification/out.BAT.plastid_source_taxonomy_predictions.txt"
    conda:
        "envs/CAT_classifier.yml"
    shell:
        "bash scripts/source_classifier.sh -i {params.plastidbins} -d {input.catdb} -t {input.cattax} -o {params.cat_outputdir}"

# summary file
#rule summary
