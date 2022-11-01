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

#if [ `ls -1 ${plastidbindir} | wc -l | xargs` -e 0 ];
#then
  #touch ${keggcountdir}/noplastid_keggid_counts.txt
#fi

if [ `ls ${keggoutdir}/*.csv 2> /dev/null` ];
then
  for SAMPLE in ${keggoutdir}/*.csv

  do
    #echo ${SAMPLE}
    sample=`basename ${SAMPLE}`
    #echo ${sample}
    sample=${sample%_kegg.csv}

    cut -f 2 ${SAMPLE} | cut -f 2 -d '~' > ${keggcountdir}/${sample}_keggid_counts.txt

  done
else
  touch ${keggcountdir}/noplastid_keggid_counts.txt
fi
