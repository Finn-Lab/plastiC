usage()
{
cat << EOF
usage: $0 options

Machine learning classification of contigs using Tiara (https://github.com/ibe-uw/tiara).

OPTIONS:
      -i  Assembly file [REQUIRED]
      -o  Output [REQUIRED]

EOF
}

#variables
assembly=
outdir=

while getopts "i:o:h:" OPTION

do

  case ${OPTION} in
    i)
      assembly=${OPTARG}
      ;;
    o)
      outdir=${OPTARG}
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

echo -e "Generating contig classifications using tiara..."
tiara -i ${assembly} -o ${outdir}/tiara.out -m 1000 --tf all -t 4 -p 0.65 0.60 --probabilities

touch ${outdir}/plastid_scaffolds.fasta

echo -e "Contig classification complete."
#echo "Plastid classified sequences have been stored in ${plastids}."
