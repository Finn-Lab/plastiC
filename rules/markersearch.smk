# marker search
rule marker_search:
    input:
        kegg_log=OUTPUTDIR + "{samplename}/working/quality_estimate/kegg_out.log",
    params:
        nucldir=directory(OUTPUTDIR + "{samplename}/plastids/bins"),
        protdir=directory(OUTPUTDIR + "{samplename}/working/prodigal/proteins"),
        markerdir=directory(OUTPUTDIR + "{samplename}/plastids/markersearch"),
    output:
        markersearchlog=OUTPUTDIR + "{samplename}/plastids/markersearch/search.out",
    conda:
        "../envs/plastiC.yml"
    shell:
        "bash scripts/markersearch.sh -n {params.nucldir} -p {params.protdir} -m resources/markergene_scan/rbcL/ref_rbcL_hmm -o {params.markerdir} > {output.markersearchlog}"


rule marker_fasta:
    input:
        markersearchlog=OUTPUTDIR + "{samplename}/plastids/markersearch/search.out",
    params:
        bindir=directory(OUTPUTDIR + "{samplename}/plastids/bins"),
        hmmscandir=directory(
            OUTPUTDIR + "{samplename}/plastids/markersearch/rbcL/hmmscan"
        ),
        fastadir=directory(OUTPUTDIR) + "{samplename}/plastids/markersearch/rbcL/fasta",
    output:
        marker_fasta=OUTPUTDIR + "{samplename}/plastids/markersearch/rbcL_fasta.out",
    conda:
        "../envs/plastiC.yml"
    shell:
        "python3 scripts/marker_query_select_multifile.py -i {params.hmmscandir} -b {params.bindir} -o {params.fastadir} > {output.marker_fasta}"


rule rrna_fasta:
    input:
        markersearchlog=OUTPUTDIR + "{samplename}/plastids/markersearch/search.out",
    params:
        rrnadir=directory(OUTPUTDIR + "{samplename}/plastids/markersearch/rrna"),
    output:
        rrna_fasta=OUTPUTDIR + "{samplename}/plastids/markersearch/rRNA_fasta.out",
    conda:
        "../envs/plastiC.yml"
    shell:
        "python3 scripts/create_rrna_fasta.py -i {params.rrnadir} > {output.rrna_fasta}"
