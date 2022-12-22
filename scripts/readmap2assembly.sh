usage()
{
cat << EOF
usage: $0 options

Map reads to metagenomic assembly.
OPTIONS:
      -1 Forward reads [REQUIRED]
      -2 reverse reads [REQUIRED]
      -a Metagenomic assembly [REQUIRED]
      -o Output directory path [REQUIRED]

EOF
}

#variables
forwardreads=
reversereads=
assembly=
bamoutput=

while getopts "1:2:a:o:h:" OPTION

do

  case ${OPTION} in
    1)
      forwardreads=${OPTARG}
      ;;
    2)
      reversereads=${OPTARG}
      ;;
    a)
      assembly=${OPTARG}
      ;;
    o)
      bamoutput=${OPTARG}
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

echo -e "Generating bwa index..."
bwa index "${assembly}"

echo -e "Mapping reads to assembly..."
bwa mem -t 16 "${assembly}" "${forwardreads}" "${reversereads}" | samtools sort -o "${bamoutput}"

samtools index "${bamoutput}"

echo -e "Mapping complete"
