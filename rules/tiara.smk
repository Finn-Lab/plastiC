rule tiara:
    input:
        seqs=ASSEMBLYDIR + "{samplename}/" + ASSEMBLYNAME,
    params:
        tiaraout=directory(OUTPUTDIR + "{samplename}/working/tiara"),
    output:
        plastidseqs=OUTPUTDIR + "{samplename}/working/tiara/plastid_scaffolds.fasta",
    singularity:
        "docker://quay.io/biocontainers/tiara:1.0.3"
    shell:
        "bash scripts/tiara_classifier.sh -i {input.seqs} -o {params.tiaraout}"
