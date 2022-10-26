usage()
{
cat << EOF
usage: $0 options

Gene prediction and KEGG annotations for plastid bins for downstream quality estimates.

OPTIONS:
      -i Plastid bin directory [REQUIRED]
      -p Prodigal output directory
      -d Uniref diamond database [REQUIRED]
      -o KEGG Output directory [REQUIRED]
      -c Kegg countd directory
EOF
}

#variables
plastidbindir=
prodigaldir=
database=
keggoutdir=
keggcountdir=

while getopts "i:p:d:o:c:h:" OPTION

do

  case ${OPTION} in
    i)
      plastidbindir=${OPTARG}
      ;;
    p)
      prodigaldir=${OPTARG}
      ;;
    d)
      database=${OPTARG}
      ;;
    o)
      keggoutdir=${OPTARG}
      ;;
    c)
      keggcountdir=${OPTARG}
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

mkdir -p ${prodigaldir}
mkdir -p ${outdir}

bash scripts/genepred.sh -i ${plastidbindir} -o ${prodigaldir}

bash scripts/diamond_blastp.sh -i ${prodigaldir}/proteins -d ${database} -o ${keggoutdir}

bash scripts/keggcounter.sh -i ${keggoutdir} -o ${keggcountdir}
