rule tiara:
	input:
		seqs = ASSEMBLYDIR+"{samplename}/"+ASSEMBLYNAME
	params:
		tiaraout = directory(OUTPUTDIR+"{samplename}/tiara")
	output:
		plastidseqs = OUTPUTDIR+"{samplename}/tiara/plastid_scaffolds.fasta"
	conda:
		"../envs/tiara.yml"
	shell:
		"bash scripts/tiara_classifier.sh -i {input.seqs} -o {params.tiaraout}"
