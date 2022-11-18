rule tiara:
    input:

    params:
        plastid_seqs = OUTPUTDIR+"{samplename}/tiara/plastid_scaffolds.fasta",
    output:
        plastid_seqs = OUTPUTDIR+"{samplename}/tiara/plastid_scaffolds.fasta"
    conda:
        "envs/tiara.yaml"
    shell:
