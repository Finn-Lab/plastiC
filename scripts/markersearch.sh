usage()
{
cat << EOF
usage: $0 options

Count KEGGs from kegg output.

OPTIONS:
      -n Plastid bin (Nucleic acids fasta) [REQUIRED]
      -p Plastid bin proteins (Amino acid fasta) [REQUIRED]
      -m HMM DB [REQUIRED]
      -o Output directory [REQUIRED]
EOF
}

#variables
plastidnuc=
plastidprot=
hmmdb=
outdir=

while getopts "n:p:m:o:h:" OPTION

do

  case ${OPTION} in
    n)
      plastidnuc=${OPTARG}
      ;;
    p)
      plastidprot=${OPTARG}
      ;;
    m)
      hmmdb=${OPTARG}
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

mkdir -p ${outdir}/rrna

mkdir -p ${outdir}/rbcl/hmmscan
hmmdir=${outdir}/rbcl/hmmscan

echo -e "Identifying rRNA genes..."
echo -e ${plastidnuc}

for NUCL in ${plastidnuc}/*.fa

do
  sample=`basename ${NUCL}`
  sample=${sample%.fasta}

  barrnap --outseq ${outdir}/${sample}_rrna.fasta ${NUCL}
done

echo -e "rRNA gene identification finished."

echo -e "Searching for rbcL..."

ls ${plastidprot}

for PROT in ${plastidprot}/*.fa

do

  prot=`basename ${PROT}`
  prot=${prot%.fa}

  hmmscan -o ${hmmdir}/${prot}_hmm.out --domtblout ${hmmdir}/${prot}_hmm.domtbl ${hmmdb} ${PROT}

done
echo -e "Search for rbcL finished."
