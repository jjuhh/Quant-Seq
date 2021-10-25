# QuantSeq  Template #

# -------------------------------------------------
project=$1 # 수주번호 혹은 final count matrix 이름
fastq_location=$2
species=$3 # Human or Mouse
sample_list=$4
# -------------------------------------------------
# 이 아래는 변경하지 않으셔도 됩니다.

scripts="/gmi-l1/_90.User_Data/juhyunk/codes/QuantSeq"

for sample in `cut -f 1 $sample_list`
do
echo $sample
sh ${scripts}/Quant-seq.wUmi.${species}.sh $sample ${fastq_location}/${sample}_1.fastq.gz
done

for i in `ls */. | grep -G "count.txt$"`
do sample=`basename ${i} .count.txt`
echo $sample
echo $sample > ${sample}.count.tmp
cut -f 2 ${sample}/${i} >> ${sample}.count.tmp
echo "Gene" > Gene.list.tmp
cut -f 1 ${sample}/${i} >> Gene.list.tmp
done

paste Gene.list.tmp *.count.tmp  | grep -vG "^__" > count.matrix.txt

Rscript ${scripts}/Normalization.CPM.R count.matrix.txt ${project} $sample_list

Rscript ${scripts}/ENSEMBL_to_GeneSymbol.${species}.R ${project}.Counts.table.txt
Rscript ${scripts}/ENSEMBL_to_GeneSymbol.${species}.R ${project}.CPMNorm.table.txt

rm *.tmp
