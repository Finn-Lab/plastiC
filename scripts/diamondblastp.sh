dir=/hps/research/finn/escameron/checkm2/universal_testing_95p/bins

mkdir -p ${dir}/kegg_out
outdir=${dir}/kegg_out
mkdir -p ${dir}/logs
logdir=${dir}/logs

for FILE in ${dir}/*

do

  sample=`basename $FILE`
  sample=${sample%.fasta}

  bsub -M 2500 -n 1 -o ${logdir}/${sample}_kegg.log "diamond blastp --outfmt 6 --max-target-seqs 1 -q ${FILE} -o ${outdir}/${sample}_kegg.csv --db /hps/research/finn/escameron/checkm2/CheckM2_database/uniref100.KO.1.dmnd --query-cover 80 --subject-cover 80 --id 30 --e-value 1e-5"

done

dir=/hps/research/finn/escameron/checkm2/universal_testing_95p
outdir=${dir}/kegg_out

mkdir -p ${dir}/kegg_counts
keggoutdir=${dir}/kegg_counts

for SAMPLE in ${outdir}/*.csv

do

  sample=`basename ${SAMPLE}`
  sample=${sample%_kegg.csv}

  cut -f 2 ${SAMPLE} | cut -f 2 -d '~' > ${keggoutdir}/${sample}_keggid.txt

done
