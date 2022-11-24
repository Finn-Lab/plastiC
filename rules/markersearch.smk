# marker search
rule marker_search:
    input:
        kegg_log = OUTPUTDIR+"{samplename}/quality_estimate/kegg_out.log"
    params:
        nucldir = directory(OUTPUTDIR+"{samplename}/plastidbins/bins"),
        protdir = directory(OUTPUTDIR+"{samplename}/prodigal/proteins"),
        markerdir = directory(OUTPUTDIR+"{samplename}/markersearch")
    output:
        markersearchlog = OUTPUTDIR+"{samplename}/markersearch/search.out"
    conda:
        "../envs/plastiC.yml"
    shell:
        "bash scripts/markersearch.sh -n {params.nucldir} -p {params.protdir} -m resources/markergene_scan/rbcL/ref_rbcL_hmm -o {params.markerdir} > {output.markersearchlog}"
