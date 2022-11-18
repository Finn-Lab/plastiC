# marker search
rule rrna_search:
    input:
        kegg_log = OUTPUTDIR+"{samplename}/quality_estimate/kegg_out.log"
    params:
        nucldir = directory(OUTPUTDIR+"{samplename}/plastidbins"),
        protdir = directory(OUTPUTDIR)+"{samplename}/prodigal"),
        markerdir = directory(OUTPUTDIR+"{samplename}/markersearch")
    output:
        markersearchlog = OUTPUTDIR+"{samplename}/markersearch/search.out"
    conda:
        "envs/markersearch.yml"
    shell:
        "bash scripts/barrnap.sh -n {params.nucldir} -p {params.protdir} -m resources/markergene_scan/rbcL/ref_rbcL_hmm -o {params.markerdir} > {output.markersearchlog}"
