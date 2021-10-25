#! /bin/sh -
PROGNAME=$0

usage() {
  cat << EOF >&2
version = v1.0.0
Usage: $PROGNAME [-f <fastq location>] [-s <species>] [-S <sample list>] [-p <project name>]

-f <fastq location>: read 1 fastq file
-s <species> : Human or mouse
-p <project name> : prefix of ouput files
-S <sample list> : Quantseq sample name and biological name

[optional]
-d <workiing directory>: working directory and output directory [default = pwd]

EOF
  exit 1
}

dir=`pwd` verbose_level=0
while getopts "f:d:s:p:S:v:h" opt; do
  case $opt in
    (f) fastq_location=$OPTARG;;
    (d) dir=$OPTARG;;
    (s) species=$OPTARG;;
    (p) project_name=$OPTARG;;
    (S) sample_list=$OPTARG;;	
    (v) verbose_level=$((verbose_level + 1));;
    # (*) usage;;
    (h) usage;;
  esac
done
shift "$((OPTIND - 1))"

echo Remaining arguments: "$@"

echo $fastq_location
echo $dir
echo $species
echo $project_name
echo $sample_list

sh /gmi-l1/_90.User_Data/juhyunk/codes/QuantSeq/Quant-seq.Template.sh $project_name $fastq_location $species $sample_list
