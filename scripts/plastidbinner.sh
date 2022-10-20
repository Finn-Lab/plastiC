usage()
{
cat << EOF
usage: $0 options

Bin assemblies using metabat2 and identify potential plastid bins.

OPTIONS:
      -a Assembly file
      -m Mapping file
      -b Binning directory
      -t Tiara output directory
	  -p Plastidbin directory
EOF
}

#variables
assembly=
mappedreads=
binningdir=
tiaradir=
plastidbindir=

while getopts "a:m:b:t:h:" OPTION

do

  case ${OPTION} in
    a)
      assembly=${OPTARG}
      ;;
    m)
      mappedreads=${OPTARG}
      ;;
    b)
      binningdir=${OPTARG}
      ;;
    t)
      tiaradir=${OPTARG}
      ;;
	p)
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

bash scripts/metabat_binning.sh -i ${assembly} -m ${mappedreads} -o ${binningdir}

bash scripts/plastidbinscan.sh -i ${tiaradir} -b ${binningdir} -o ${plastidbindir}
