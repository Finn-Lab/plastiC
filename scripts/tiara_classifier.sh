usage()
{
cat << EOF
usage: $0 options

Machine learning classification of contigs using Tiara (https://github.com/ibe-uw/tiara).

OPTIONS:
      -i  Contig file [REQUIRED]
      -o Output directory [REQUIRED]
	  #-p Plastid file [REQUIRED]
EOF
}

#variables
contigs=
outdir=
#plastids=

while getopts "i:o:p:h:" OPTION

do

  case ${OPTION} in
    i)
      contigs=${OPTARG}
      ;;
    o)
      outdir=${OPTARG}
      ;;
    #p)
      #plastids=${OPTARG}
      #;;
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

tiara -i ${contigs} -o ${outdir} -m 1000 --tf all -t 4 -p 0.65 0.60 --probabilities

#echo "Plastid classified sequences have been stored in ${plastids}."
