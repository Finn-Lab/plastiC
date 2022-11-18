rule tiara:
    input:
        seqs = ASSEMBLYDIR+"{samplename}/spades_output/"+ASSEMBLYNAME
    output:
        tiaraout = OUTPUTDIR+"{samplename}/tiara/tiara.out"
    conda:
        "envs/tiara.yaml"
    shell:
        "bash scripts/tiara_classifier.sh -i {input.seqs} -o {output.tiaraout}"
