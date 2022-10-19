usage()
{
cat << EOF
usage: $0 options

Bin metagenomic assemblies using metabat and a reduced bin size threshold to account for small sized plastid genomes.

OPTIONS:
      -i  Input metagenomic assembly, either contigs.fasta or scaffolds.fasta [REQUIRED]
      -m Mapped reads alignment bam [REQUIRED]

EOF
}

#variables
assembly=
mappedreads=

while getopts "i:m:h:" OPTION

do

  case ${OPTION} in
    i)
      assembly=${OPTARG}
      ;;
    b)
      mappedreads=${OPTARG}
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

runMetaBat.sh --unbinned -s 50000 ${mappedreads} ${ALIGNMENT.bam}
