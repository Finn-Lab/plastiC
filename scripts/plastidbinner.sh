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

EOF
}

#variables
assembly=
mappedreads=
binningdir=
tiaradir=

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

bash metabat_binning.sh -i ${assembly} -m ${mappedreads} -o ${binningdir}

bash plastidbinscan.sh -i ${tiaradir} -b ${binningdir}/bin 
