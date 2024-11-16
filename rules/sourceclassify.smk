# assign predicted taxonomic classification using CAT
rule plastid_source_classification:
    input:
        kegg_counts_log=OUTPUTDIR
        + "{samplename}/working/quality_estimate/kegg_counts.log",
        plastidbinstats=OUTPUTDIR + "{samplename}/plastids/plastid_bin_stats.csv",
        catdb=CATDBDIR,
        cattax=CATTAXDIR,
    params:
        cat_outputdir=directory(OUTPUTDIR + "{samplename}/working/CAT_classification"),
        plastidbins=directory(OUTPUTDIR + "{samplename}/plastids/bins"),
    output:
        plastid_source_prediction=OUTPUTDIR
        + "{samplename}/working/CAT_classification/out.BAT.plastid_source_taxonomy_predictions.txt",
    singularity:
        "docker://quay.io/microbiome-informatics/plastic_env"
    shell:
        "bash scripts/source_classifier.sh -i {params.plastidbins} -d {input.catdb} -t {input.cattax} -o {params.cat_outputdir}"
