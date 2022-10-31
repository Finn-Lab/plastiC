usage()
{
cat << EOF
usage: $0 options

OPTIONS:


EOF
}

#variables
keggcountdir=
outfile=
keggidlist=
qualityestimate=
model=
while getopts "kc:o:l:q:m:h:" OPTION

do

  case ${OPTION} in
    kc)
      keggcountdir=${OPTARG}
      ;;
    o)
      outfile=${OPTARG}
      ;;
    l)
      keggidlist=${OPTARG}
      ;;
    q)
      qualityestimate=${OPTARG}
      ;;
    m)
      model=${OPTARG}
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

python3 scripts/kegg_prep_bin.py -kc ${keggcountdir} -o ${outfile} -l ${keggidlist}

python3 scripts/quality_estimate_base.py -k ${outfile} -kc ${keggcountdir} -o ${qualityestimate} -m ${model}
