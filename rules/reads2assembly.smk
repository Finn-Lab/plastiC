# generate bam file (reads 2 assembly)
rule reads2assembly:
    input:
        forwardreads = READDIR+"{samplename}/{samplename}_1.fastq.gz",
        reversereads = READDIR+"{samplename}/{samplename}_2.fastq.gz",
        seqs = ASSEMBLYDIR+"{samplename}/"+ASSEMBLYNAME
    output:
        bamout = OUTPUTDIR+"{samplename}/working/mapping/reads2assembly/alignment.bam"
    conda:
        "../envs/plastiC.yml"
    shell:
        "bash scripts/readmap2assembly.sh -1 {input.forwardreads} -2 {input.reversereads} -a {input.seqs} -o {output.bamout}"
