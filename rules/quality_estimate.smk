# completeness estimate
rule binprep_completeness:
	input:
		kegg_counts_log = OUTPUTDIR+"{samplename}/quality_estimate/kegg_counts.log"
	params:
		keggcountdir = directory(OUTPUTDIR+"{samplename}/quality_estimate/kegg_counts")
	output:
		keggdataprep = OUTPUTDIR+"{samplename}/quality_estimate/comp_kegg_data.csv"
	conda:
		"envs/quality.yml"
	shell:
		"python3 scripts/kegg_prep_bin.py -kc {params.keggcountdir} -o {output.keggdataprep} -l resources/quality_estimates/training_kegg_id_list.txt"

rule completeness_estimate:
    input:
        keggdataprep = OUTPUTDIR+"{samplename}/quality_estimate/comp_kegg_data.csv"
    params:
        keggcountdir = directory(OUTPUTDIR+"{samplename}/quality_estimate/kegg_counts"),
        plastidbindir = directory(OUTPUTDIR+"{samplename}/plastidbins/bins")
    output:
        completeness = OUTPUTDIR+"{samplename}/quality_estimate/completeness_estimate.csv"
    conda:
        "envs/quality.yml"
    shell:
        "python3 scripts/quality_estimate_base.py -b {params.plastidbindir} -k {input.keggdataprep} -kc {params.keggcountdir} -o {output.completeness} -m resources/quality_estimates/completeness.model -t completeness"

# mitochondrial contamination estimate
rule binprep_mitocontam:
	input:
		kegg_counts_log = OUTPUTDIR+"{samplename}/quality_estimate/kegg_counts.log"
	params:
		keggcountdir = directory(OUTPUTDIR+"{samplename}/quality_estimate/kegg_counts")
	output:
		keggdataprep = OUTPUTDIR+"{samplename}/quality_estimate/mitocontam_kegg_data.csv"
	conda:
		"envs/quality.yml"
	shell:
		"python3 scripts/kegg_prep_bin.py -kc {params.keggcountdir} -o {output.keggdataprep} -l resources/quality_estimates/mitochloro1_id_list.txt"

rule mitocontam_estimate:
    input:
        keggdataprep = OUTPUTDIR+"{samplename}/quality_estimate/mitocontam_kegg_data.csv"
    params:
        keggcountdir = directory(OUTPUTDIR+"{samplename}/quality_estimate/kegg_counts"),
        plastidbindir = directory(OUTPUTDIR+"{samplename}/plastidbins/bins")
    output:
        completeness = OUTPUTDIR+"{samplename}/quality_estimate/mitocontam_estimate.csv"
    conda:
        "envs/quality.yml"
    shell:
        "python3 scripts/quality_estimate_base.py -b {params.plastidbindir} -k {input.keggdataprep} -kc {params.keggcountdir} -o {output.completeness} -m resources/quality_estimates/mitochloromodel1_defgbr.model -t mito_contam"
