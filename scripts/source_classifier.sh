usage()
{
cat << EOF
usage: $0 options

Taxonomic classification of plastid bins using CAT
OPTIONS:
      -i  Plastid bin directory [REQUIRED]
      -d  Database folder [REQUIRED]
      -t  Taxonomy folder [REQUIRED]
      -o  Output Directory [REQUIRED]

EOF
}

#variables
plastidbindir=
databasedir=
taxonomydir=
outputdir=

while getopts "i:d:t:o:h:" OPTION

do

  case ${OPTION} in
    i)
      plastidbindir=${OPTARG}
      ;;
    d)
      databasedir=${OPTARG}
      ;;
    t)
      taxonomydir=${OPTARG}
      ;;
    o)
      outputdir=${OPTARG}
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

if [`ls -1 ${keggcountdir}/*.csv | wc -l | xargs` -gt 0];
then
  CAT bins -b ${plastidbindir} -d ${databasedir} -t ${taxonomydir} -o ${outputdir}/out.BAT -s .fa --force

  CAT add_names -i ${outputdir}/out.BAT.bin2classification.txt -o ${outputdir}/out.BAT.plastid_source_taxonomy_predictions.txt -t ${taxonomydir} --only_official --exclude_scores
else
  echo -e "# bin\tclassification\treason\tlineage\tlineage scores\tsuperkingdom\tphylum\t\class\torder\tfamily\tgenus\tspecies" > ${outputdir}/out.BAT.plastid_source_taxonomy_predictions.txt
  bin=`echo -e "noplastid"`
  classification=`echo -e "N/A"`
  reason=`echo -e "N/A"`
  lineage=`echo -e "N/A"`
  lineage_scores=`echo -e "N/A"`
  superkingdom=`echo -e "N/A"`
  phylum=`echo -e "N/A"`
  class=`echo -e "N/A"`
  order=`echo -e "N/A"`
  family=`echo -e "N/A"`
  genus=`echo -e "N/A"`
  species=`echo -e "N/A"`
  echo -e "${bin}\t${classification}\t${reason}\t${lineage}\t${lineage_scores}\t${superkingdom}\t${phylum}\t${class}\t${order}\t${family}\t${genus}\t${species}" >> ${outputdir}/out.BAT.plastid_source_taxonomy_predictions.txt

fi
