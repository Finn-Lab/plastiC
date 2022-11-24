# assign predicted taxonomic classification using CAT
rule plastid_source_classification:
    input:
        kegg_counts_log = OUTPUTDIR+"{samplename}/quality_estimate/kegg_counts.log",
        plastidbinstats = OUTPUTDIR+"{samplename}/plastidbins/plastid_bin_stats.csv",
        catdb = CATDBDIR,
        cattax = CATTAXDIR
    params:
        cat_outputdir = directory(OUTPUTDIR+"{samplename}/CAT_classification"),
        plastidbins = directory(OUTPUTDIR+"{samplename}/plastidbins/bins")
    output:
        plastid_source_prediction = OUTPUTDIR+"{samplename}/CAT_classification/out.BAT.plastid_source_taxonomy_predictions.txt"
    conda:
        "../envs/plastiC.yml"
    shell:
        "bash scripts/source_classifier.sh -i {params.plastidbins} -d {input.catdb} -t {input.cattax} -o {params.cat_outputdir}"
