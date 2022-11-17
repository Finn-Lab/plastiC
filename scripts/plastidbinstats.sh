usage()
{
cat << EOF
usage: $0 options

Calculate bin statistics on potential plastid bins.

OPTIONS:
      -i Bin directory [REQUIRED]
      -o Plastid bin directory [REQUIRED]
      -s Minimum plastid content % of bin, numeric [REQUIRED]
EOF
}

#variables
bindir=
plastidbindir=
minbinsize=

while getopts "i:o:s:h:" OPTION

do

  case ${OPTION} in
    i)
      bindir=${OPTARG}
      ;;
    s)
      minbinsize=${OPTARG}
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

echo "The minimum plastid content bin size is ${minbinsize}%"
mkdir -p ${plastidbindir}/bins

plastidseqid=${plastidbindir}/plastid_bins.tsv

echo -e "bin_id\ttotal_contig_count\tbinsize_nt\tplastid_contig_count\tplastid_total_size_nt\tplastid_contig_count_percent\tplastid_sizent_percent" > ${plastidbindir}/bin_stats.tsv

binstats=${plastidbindir}/bin_stats.tsv

for BIN in ${bindir}/*

do
  bin=`basename $BIN`
  bin=${bin%.fa}

  totalcontig=`grep ">" ${BIN} | wc -l | xargs`
  binsize=`grep ">" ${BIN} | grep -o -P '(?<=_length_).*(?=_cov_)' | awk 'BEGIN{total=0} {total+=$1} END{print total}'`

  plastidcount=`grep ${BIN} ${plastidseqid} | wc -l | xargs`
  plastidlength=`grep ${BIN} ${plastidseqid} | grep -o -P '(?<=_length_).*(?=_cov_)' | awk 'BEGIN{total=0} {total+=$1} END{print total}'`

  plastidpercent=`echo "scale=2 ; 100 * ${plastidcount}/${totalcontig}" | bc`
  plastid_length_percent=`echo "scale=2 ; 100 * ${plastidlength}/${binsize}" | bc`

  echo ${plastidpercent}

  echo -e "${bin}\t${totalcontig}\t${binsize}\t${plastidcount}\t${plastidlength}\t${plastidpercent}\t${plastid_length_percent}" >> ${plastidbindir}/bin_stats.tsv

  #if [ $((plastid_length_percent)) == 0 ] ; then
  #	echo "No plastids"
  #elif [ $((plastid_length_percent%.*)) -ge $((minbinsize)) ] ; then
   # cp ${BIN} ${plastidbindir}/bins
  #fi

  awk -v pp=${plastid_length_percent} -v minsize=${minbinsize} -v BIN=${BIN} -v plastidbin=${plastidbindir}/bins \
  	'BEGIN{if (pp >= minsize){system("cp " BIN " " plastidbin) }}'

done
