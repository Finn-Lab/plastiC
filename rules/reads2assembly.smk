# generate bam file (reads 2 assembly)
rule reads2assembly:
    input:
        forwardreads = READDIR+"{samplename}/{samplename}_1.fastq.gz",
        reversereads = READDIR+"{samplename}/{samplename}_2.fastq.gz",
        seqs = ASSEMBLYDIR+"{samplename}/spades_output/"+ASSEMBLYTYPE+".fasta"
    output:
        bamout = OUTPUTDIR+"{samplename}/mapping/reads2assembly/alignment.bam"
    conda:
        "envs/mapping.yml"
    shell:
        "bash scripts/readmap2assembly.sh -1 {input.forwardreads} -2 {input.reversereads} -a {input.seqs} -o {output.bamout}"