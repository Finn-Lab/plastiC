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
      -c Kegg countd directory [REMOVED]
EOF
}

#variables
plastidbindir=
prodigaldir=
database=
keggoutdir=

while getopts "i:p:d:o:h:" OPTION

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

mkdir -p "${prodigaldir}"
mkdir -p "${keggoutdir}"

if [ `ls -1 "${plastidbindir}" | wc -l | xargs` -gt 0 ];
then
  echo -e "Preparing to perform genepredictions..."
  bash scripts/genepred.sh -i "${plastidbindir}" -o "${prodigaldir}"

  echo -e "Preparing to perform blastp search..."
  bash scripts/diamond_blastp.sh -i "${prodigaldir}"/proteins -d "${database}" -o "${keggoutdir}"
fi
