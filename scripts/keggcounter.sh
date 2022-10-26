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

for SAMPLE in ${keggoutdir}/*.csv

do
  #echo ${SAMPLE}
  sample=`basename ${SAMPLE}`
  #echo ${sample}
  sample=${sample%_kegg.csv}

  cut -f 2 ${SAMPLE} | cut -f 2 -d '~' > ${keggcountdir}/${sample}_keggid_counts.txt

done
