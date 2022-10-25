usage()
{
cat << EOF
usage: $0 options

Gene prediction and KEGG annotations for plastid bins for downstream quality estimates.

OPTIONS:
      -i Plastid bin directory (proteins) [REQUIRED]
      -d Uniref diamond database [REQUIRED]
      -o Output directory [REQUIRED]
EOF
}

#variables
plastidbindir=
prodigaldir=
database=
outdir=

while getopts "i:p:d:o:h:" OPTION

do

  case ${OPTION} in
    i)
      plastidbindir=${OPTARG}
      ;;
    p)
      prodigaldir=${OPTARG
      ;;
    d)
      database=${OPTARG}
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


bash genepred.sh -i ${plastidbindir} -o ${prodigaldir}

bash diamond_blastp.sh -i ${prodigaldir}/proteins -d ${database} -o ${outdir}
