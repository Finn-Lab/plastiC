# completeness estimate
rule binprep_completeness:
    input:
        kegg_counts_log=OUTPUTDIR
        + "{samplename}/working/quality_estimate/kegg_counts.log",
    params:
        keggcountdir=directory(
            OUTPUTDIR + "{samplename}/working/quality_estimate/kegg_counts"
        ),
    output:
        keggdataprep=OUTPUTDIR
        + "{samplename}/working/quality_estimate/comp_kegg_data.csv",
    conda:
        "../envs/plastiC.yml"
    shell:
        "python3 scripts/kegg_prep_bin.py -kc {params.keggcountdir} -o {output.keggdataprep} -l resources/quality_estimates/kegg_order.txt"


rule completeness_estimate:
    input:
        keggdataprep=OUTPUTDIR
        + "{samplename}/working/quality_estimate/comp_kegg_data.csv",
    params:
        keggcountdir=directory(
            OUTPUTDIR + "{samplename}/working/quality_estimate/kegg_counts"
        ),
        plastidbindir=directory(OUTPUTDIR + "{samplename}/plastids/bins"),
    output:
        completeness=OUTPUTDIR
        + "{samplename}/working/quality_estimate/completeness_estimate.csv",
    conda:
        "../envs/plastiC.yml"
    shell:
        "python3 scripts/quality_estimate_base.py -b {params.plastidbindir} -k {input.keggdataprep} -kc {params.keggcountdir} -o {output.completeness} -m resources/quality_estimates/completeness.model -t completeness"
