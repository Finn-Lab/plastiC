usage()
{
cat << EOF
usage: $0 options

Calculate bin statistics on potential plastid bins.

OPTIONS:
      -i Plastid bin directory [REQUIRED]
      -db Uniref diamond database [REQUIRED]
      -o Output directory [REQUIRED]
EOF
}

#variables
plastidbindir=
database=
outdir=

while getopts "i:db:o:h:" OPTION

do

  case ${OPTION} in
    i)
      plastidbindir=${OPTARG}
      ;;
    db)
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

for BIN in ${plastidbindir}/*;

do
  bin=`basename ${BIN}`
  bin=${bin%.fa}

  diamond blastp --outfmt 6 --max-target-seqs 1 -q ${BIN} -o ${outdir}/${bin}_kegg.csv --db ${database} --query-cover 80 --subject-cover 80 --id 30 --evalue 1e-5

done
