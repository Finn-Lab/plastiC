usage()
{
cat << EOF
usage: $0 options

Count KEGGs from kegg output.

OPTIONS:
      -n Plastid bin (Nucleic acids fasta) [REQUIRED]
      -p Plastid bin proteins (Amino acid fasta) [REQUIRED]
      -o Output directory [REQUIRED]
EOF
}

#variables
plastidnuc=
plastidprot=
outdir=

while getopts "n:p:o:h:" OPTION

do

  case ${OPTION} in
    n)
      plastidnuc=${OPTARG}
      ;;
    p)
      plastidprot=${OPTARG}
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


barrnap --outseq ${outdir}/rrna.fasta ${plastidnuc}
