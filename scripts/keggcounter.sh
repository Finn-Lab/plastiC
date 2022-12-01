usage()
{
cat << EOF
usage: $0 options

Count KEGGs from kegg output.

OPTIONS:
      -i KEGG Diamond blastp directory [REQUIRED]
      -o KEGG Count Output directory [REQUIRED]
EOF
}

#variables
keggoutdir=
keggcountdir=

while getopts "i:o:h:" OPTION

do

  case ${OPTION} in
    i)
      keggoutdir=${OPTARG}
      ;;
    o)
      keggcountdir=${OPTARG}
      ;;
    h)
      usage
      exit
      ;;
    ?)
      usage
      exit
      ;;
  esac

done

mkdir -p ${keggcountdir}

if [[ `ls ${keggoutdir}/*.csv 2> /dev/null` ]];
then
  for SAMPLE in ${keggoutdir}/*.csv

  do
    sample=`basename ${SAMPLE}`
    sample=${sample%_kegg.csv}
    echo -e "Generating list of present KEGGs for ${sample}..."
    cut -f 2 ${SAMPLE} | cut -f 2 -d '~' > ${keggcountdir}/${sample}_keggid_counts.txt

  done
else
  echo -e "No KEGG files found."
  touch ${keggcountdir}/noplastid_keggid_counts.txt
fi

echo -e "Generation of KEGG lists complete."
