usage()
{
cat << EOF
usage: $0 options

Gene prediction on plastid bins using Prodigal.

OPTIONS:
      -i Plastid bin directory [REQUIRED]
      -o Output directory [REQUIRED]
EOF
}

#variables
plastidbindir=
outdir=

while getopts "i:d:o:h:" OPTION

do

  case ${OPTION} in
    i)
      plastidbindir=${OPTARG}
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

mkdir -p ${outdir}/proteins
mkdir -p ${outdir}/nt_genes
mkdir -p ${outdir}/prodigalout

for BIN in ${plastidbindir}/*

do
  bin=`basename $BIN`
  bin=${bin%.fa}

  prodigal -a ${outdir}/proteins/${bin}.fa -d ${outdir}/nt_genes/${bin}.fa -i ${BIN} -o ${outdir}/prodigalout/${bin}.out
done
