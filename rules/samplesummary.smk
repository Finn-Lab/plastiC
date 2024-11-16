# summary per sample
rule summary_per_sample:
    input:
        completeness=OUTPUTDIR
        + "{samplename}/working/quality_estimate/completeness_estimate.csv",
        taxonomy=OUTPUTDIR
        + "{samplename}/working/CAT_classification/out.BAT.plastid_source_taxonomy_predictions.txt",
    params:
        plastidbindir=directory(OUTPUTDIR + "{samplename}/plastids/bins"),
    output:
        summary=OUTPUTDIR + "{samplename}/plastids/plastidinfo.csv",
    singularity:
        "quay.io://microbiome-informatics/plastic_env"
    shell:
        "python3 scripts/summarysample.py  -comp {input.completeness} -t {input.taxonomy} -b {params.plastidbindir} -o {output.summary}"
