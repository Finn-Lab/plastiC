usage()
{
cat << EOF
usage: $0 options

Calculate bin statistics on potential plastid bins.

OPTIONS:
      -i Bin directory [REQUIRED]

EOF
}

#variables
bindir=


while getopts "i:h:" OPTION

do

  case ${OPTION} in
    i)
      bindir=${OPTARG}
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

plastidseqid=plastid_bins.tsv

echo -e "bin_id\ttotal_contig_count\tbinsize_nt\tplastid_contig_count\tplastid_total_size_nt\tplastid_contig_count_percent\tplastid_sizent_percent" > bin_stats.tsv

binstats=bin_stats.tsv

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

  echo -e "${bin}\t${totalcontig}\t${binsize}\t${plastidcount}\t${plastidlength}\t${plastidpercent}\t${plastid_length_percent}" >> bin_stats.tsv

done
