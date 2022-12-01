usage()
{
cat << EOF
usage: $0 options

Scan previously generated bins for putative plastid bins based on Tiara contig classifications.

OPTIONS:
      -i  Output directory from Tiara [REQUIRED]
      -b Bin directory [REQUIRED]
      -o Plastid bin list [REQUIRED]

EOF
}

#variables
tiaradir=
binningdir=
plastidbindir=

while getopts "i:b:o:h:" OPTION

do

  case ${OPTION} in
    i)
      tiaradir=${OPTARG}
      ;;
    b)
      binningdir=${OPTARG}
      ;;
    o)
      plastidbindir=${OPTARG}
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

mkdir -p ${plastidbindir}

touch ${tiaradir}

grep ">" ${tiaradir} >> ${plastidbindir}/plastidseqid.txt
plastidseqlist=${plastidbindir}/plastidseqid.txt

for CONTIG in `cat $plastidseqlist`

do
  #grep ${CONTIG} ${binningdir}/* >> ${plastidbindir}/plastid_binning.tsv
  binidpath=`grep ${CONTIG} ${binningdir}/* | sed 's/:>.*$//g'`
  echo -e "${CONTIG}\t${binidpath}" >> ${plastidbindir}/plastid_binning.tsv

done

sort -o ${plastidbindir}/plastid_bins.tsv ${plastidbindir}/plastid_binning.tsv

rm ${plastidbindir}/plastid_binning.tsv