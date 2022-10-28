usage()
{
cat << EOF
usage: $0 options

Download references using the ezdirect NCBI dataset tool.

OPTIONS:
      -i List of accessions (text file) [REQUIRED]
      -o Output directory [REQUIRED]
EOF
}

#variables
accessionlist=
refdir=

while getopts "i:o:h:" OPTION

do

  case ${OPTION} in
    i)
      accessionlist=${OPTARG}
      ;;
    o)
      refdir=${OPTARG}
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

for i in `cat $accession_list`

do

  efetch -format fasta_cds_aa -db nucleotide -id $i > ${refdir}/${i}_prots.fasta

done
