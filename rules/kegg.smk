# diamond blastp kegg search
rule diamond_blastp:
    input:
        plastidbinstats=OUTPUTDIR + "{samplename}/plastids/plastid_bin_stats.csv",
        unirefdb=UNIREFDMND,
    params:
        plastidbindir=directory(OUTPUTDIR + "{samplename}/plastids/bins"),
        keggoutdir=directory(
            OUTPUTDIR + "{samplename}/working/quality_estimate/diamond_blastp"
        ),
        prodigaldir=directory(OUTPUTDIR + "{samplename}/working/prodigal"),
    output:
        kegg_log=OUTPUTDIR + "{samplename}/working/quality_estimate/kegg_out.log",
    singularity:
        "docker://quay.io/microbiome-informatics/plastic_env:v0.1.2"
    shell:
        "bash scripts/kegg_output.sh -i {params.plastidbindir} -p {params.prodigaldir} -d {input.unirefdb} -o {params.keggoutdir} > {output.kegg_log}"


rule kegg_counter:
    input:
        kegg_log=OUTPUTDIR + "{samplename}/working/quality_estimate/kegg_out.log",
    params:
        keggoutdir=directory(
            OUTPUTDIR + "{samplename}/working/quality_estimate/diamond_blastp"
        ),
        keggcountdir=directory(
            OUTPUTDIR + "{samplename}/working/quality_estimate/kegg_counts"
        ),
    output:
        kegg_counts_log=OUTPUTDIR
        + "{samplename}/working/quality_estimate/kegg_counts.log",
    shell:
        "bash scripts/keggcounter.sh -i {params.keggoutdir} -o {params.keggcountdir} > {output.kegg_counts_log}"
