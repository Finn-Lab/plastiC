usage()
{
cat << EOF
usage: $0 options

Scan previously generated bins for putative plastid bins based on Tiara contig classifications.

OPTIONS:
      -i  Output directory from Tiara [REQUIRED]
      -b Bin directory [REQUIRED]

EOF
}

#variables
tiaradir=
binningdir=


while getopts "i:b:h:" OPTION

do

  case ${OPTION} in
    i)
      tiaradir=${OPTARG}
      ;;
    b)
      binningdir=${OPTARG}
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

grep ">" ${tiaradir}/plastids_scaffolds.fasta >> plastidseqid.txt
plastidseqlist=plastidseqid.txt

for CONTIG in `cat $plastidseqlist`

do

  grep ${CONTIG} ${binningdir}/* >> plastid_binning.tsv

done

sort -o plastid_bins.tsv plastid_binning.tsv

rm plastid_binning.tsv
