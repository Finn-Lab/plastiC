# generate depth file
rule jgi_depth:
    input:
        bamout=OUTPUTDIR + "{samplename}/working/reads2assembly/alignment.bam",
    output:
        jgidepth=OUTPUTDIR + "{samplename}/working/binning/metabat_depth.txt",
    singularity:
        "quay.io://microbiome-informatics/plastic_env"
    shell:
        "jgi_summarize_bam_contig_depths --outputDepth {output.jgidepth} {input.bamout}"


# bin using metabat
rule metabat_binning:
    input:
        seqs=ASSEMBLYDIR + "{samplename}/" + ASSEMBLYNAME,
        jgidepth=OUTPUTDIR + "{samplename}/working/binning/metabat_depth.txt",
    params:
        bin_prefix=OUTPUTDIR + "{samplename}/working/binning/bins/bin",
    output:
        metabat2_log=OUTPUTDIR + "{samplename}/working/binning/metabat2.log",
    singularity:
        "quay.io://microbiome-informatics/plastic_env"
    shell:
        "metabat2 -i {input.seqs} -a {input.jgidepth} -o {params.bin_prefix} -s 50000 --unbinned > {output.metabat2_log}"


# scan bins for plastid reads and select ones that are likely plastid based on seq lengths
rule fetch_plastid_bins:
    input:
        plastid_seqs=OUTPUTDIR + "{samplename}/working/tiara/plastid_scaffolds.fasta",
        metabat2_log=OUTPUTDIR + "{samplename}/working/binning/metabat2.log",
    params:
        bindir=directory(OUTPUTDIR + "{samplename}/working/binning/bins/"),
        plastidbindir=directory(OUTPUTDIR + "{samplename}/plastids/"),
        minplastidbinsize=lambda wc: str(MINPLASTIDCONTENT),
    output:
        plastidbinstats=OUTPUTDIR + "{samplename}/plastids/plastid_bin_stats.csv",
    singularity:
        "quay.io://microbiome-informatics/plastic_env"
    shell:
        """
        python3 scripts/plastidbinner.py -b {params.bindir} -p {input.plastid_seqs} -o {params.plastidbindir} -d {params.plastidbindir} -s {params.minplastidbinsize}

	if [ "$(ls -A {params.plastidbindir}/*.fa)" ]
	then
        	mkdir -p {params.plastidbindir}/bins
        	mv {params.plastidbindir}/*.fa {params.plastidbindir}/bins
        fi
        """
