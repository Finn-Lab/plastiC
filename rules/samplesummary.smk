# summary per sample
rule summary_per_sample:
    input:
        completeness = OUTPUTDIR+"{samplename}/quality_estimate/completeness_estimate.csv",
        #contamination = OUTPUTDIR+"{samplename}/quality_estimate/mitocontam_estimate.csv",
        taxonomy = OUTPUTDIR+"{samplename}/CAT_classification/out.BAT.plastid_source_taxonomy_predictions.txt"
    params:
        plastidbindir = directory(OUTPUTDIR+"{samplename}/plastidbins/bins")
    output:
        summary = OUTPUTDIR+"{samplename}/plastidinfo.csv"
    conda:
        "../envs/plastiC.yml"
    shell:
        "python3 scripts/summarysample.py  -comp {input.completeness} -t {input.taxonomy} -b {params.plastidbindir} -o {output.summary}"
