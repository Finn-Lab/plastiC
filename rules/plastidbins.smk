# generate depth file
rule jgi_depth:
	input:
		bamout = OUTPUTDIR+"{samplename}/mapping/reads2assembly/alignment.bam"
	output:
		jgidepth = OUTPUTDIR+"{samplename}/binning/metabat_depth.txt"
	conda:
		"../envs/plastiC.yml"
	shell:
		"jgi_summarize_bam_contig_depths --outputDepth {output.jgidepth} {input.bamout}"

# bin using metabat
rule metabat_binning:
	input:
		seqs = ASSEMBLYDIR+"{samplename}/"+ASSEMBLYNAME,
		jgidepth = OUTPUTDIR+"{samplename}/binning/metabat_depth.txt"
	params:
		bin_prefix = OUTPUTDIR+"{samplename}/binning/bins/bin"
	output:
		#unbinned_seqs_holder = OUTPUTDIR+"{samplename}/binning/bins/bin.unbinned.fa",
		metabat2_log = OUTPUTDIR+"{samplename}/binning/metabat2.log"
	conda:
		"../envs/plastiC.yml"
	shell:
		"metabat2 -i {input.seqs} -a {input.jgidepth} -o {params.bin_prefix} -s 50000 --unbinned > {output.metabat2_log}"

# scan bins for plastid reads and select ones that are likely plastid based on seq lengths
rule fetch_plastid_bins:
	input:
		plastid_seqs = OUTPUTDIR+"{samplename}/tiara/plastid_scaffolds.fasta",
		metabat2_log = OUTPUTDIR+"{samplename}/binning/metabat2.log"
	params:
		bindir = directory(OUTPUTDIR+"{samplename}/binning/bins/"),
		plastidbindir = directory(OUTPUTDIR+"{samplename}/plastidbins/"),
		#plastidbinfiles = directory(OUTPUTDIR+"{samplename}/plastidbins/bins/"),
		#minplastidbinsize = lambda wc: str(MINPLASTIDCONTENT)
	output:
		plastidbinstats = OUTPUTDIR+"{samplename}/plastidbins/plastid_bin_stats.csv"
	conda:
		"../envs/plastiC.yml"
	shell:
		"python3 scripts/plastidbinner.py -b {params.bindir} -p {input.plastid_seqs} -o {params.plastidbindir} -d {params.plastidbindir}"
