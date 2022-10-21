usage()
{
cat << EOF
usage: $0 options

Scan bins for plastid sequences and select bins composed of mostly plastids.

OPTIONS:
      -a Assembly file
      -m Mapping file
      -b Binning directory
      -t Tiara output directory
	    -p Plastidbin directory
      -s Plastid bin size threshold to keep
EOF
}

#variables
binningdir=
tiaradir=
plastidbindir=
minbinsize=

while getopts "a:b:t:p:s:h:" OPTION

do

  case ${OPTION} in
    b)
      binningdir=${OPTARG}
      ;;
    t)
      tiaradir=${OPTARG}
      ;;
    p)
	    plastidbindir=${OPTARG}
	    ;;
    s)
      minbinsize=${OPTARG}
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

bash scripts/plastidbinscan.sh -i ${tiaradir} -b ${binningdir} -o ${plastidbindir}

bash scripts/plastidbinstats.sh -i ${binningdir} -o ${plastidbindir} -s ${minbinsize}
