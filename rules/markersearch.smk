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

rule marker_fasta:
    input:
        markersearchlog = OUTPUTDIR+"{samplename}/markersearch/search.out",
    params:
        bindir = directory(OUTPUTDIR+"{samplename}/plastidbins/bins"),
        hmmscandir = directory(OUTPUTDIR+"{samplename}/markersearch/rbcL/hmmscan"),
        fastadir = directory(OUTPUTDIR)+"{samplename}/markersearch/rbcL/fasta"
    output:
        marker_fasta = OUTPUTDIR+"{samplename}/markersearch/rbcL_fasta.out"
    conda:
        "../envs/plastiC.yml"
    shell:
        "python3 scripts/marker_query_select_multifile.py -i {params.hmmscandir} -b {params.bindir} -o {params.fastadir} > {output.marker_fasta}"

rule rrna_fasta:
    input:
        markersearchlog = OUTPUTDIR+"{samplename}/markersearch/search.out"
    params:
        rrnadir = directory(OUTPUTDIR+"{samplename}/markersearch/rrna")
    output:
        rrna_fasta = OUTPUTDIR+"{samplename}/markersearch/rRNA_fasta.out"
    conda:
        "../envs/plastiC.yml"
    shell:
        "python3 scripts/create_rrna_fasta.py -i {params.rrnadir} > {output.rrna_fasta}"
