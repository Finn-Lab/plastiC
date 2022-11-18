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
