rule tiara:
    input:
        seqs=ASSEMBLYDIR + "{samplename}/" + ASSEMBLYNAME,
    params:
        tiaraout=directory(OUTPUTDIR + "{samplename}/working/tiara"),
    output:
        plastidseqs=OUTPUTDIR + "{samplename}/working/tiara/plastid_scaffolds.fasta",
    singularity:
        "quay.io://biocontainers/tiara"
    shell:
        "bash scripts/tiara_classifier.sh -i {input.seqs} -o {params.tiaraout}"
