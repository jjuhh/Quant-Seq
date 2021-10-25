sample=$1
fastq_1=$2

mkdir ${sample}

echo -e "sample name : $sample" > ${sample}/${sample}.Quant-seq.analysis.log
echo -e "Fastq_1 file : $fastq_1" >> ${sample}/${sample}.Quant-seq.analysis.log
echo -e "Threads : $threads" >> ${sample}/${sample}.Quant-seq.analysis.log
echo -e "DATE : `date`" >> ${sample}/${sample}.Quant-seq.analysis.log

echo -e "Samtools version : `samtools --version-only`"
echo -e "htseq-count version : `htseq-count --version`"
echo -e "bbmap version : "
echo -e "STAR version : `STAR --version`"
echo -e "`umi_tools -v`"

# Files 
bbmap='/gmi-l1/_90.User_Data/juhyunk/program/bbmap'
STAR_ref='/mnt/gmi-l1/_90.User_Data/sylash92/6.Files/Reference/GRCm39/GenomeDir'
ref_gtf='/mnt/gmi-l1/_90.User_Data/sylash92/6.Files/GTF/GRCm39/mus_musculus/Mus_musculus.GRCm39.104.gtf'

# Extract the UMIs
umi_tools extract --extract-method=regex --bc-pattern "(?P<umi_1>.{6})(?P<discard_1>TATA).*" -L ${sample}/UMItools.log -I ${fastq_1} -S ${sample}/01.UMITools.${sample}_1.fastq.gz


## Trimming running ##
bbduk.sh in=${sample}/01.UMITools.${sample}_1.fastq.gz out=${sample}/02.Trimm.${sample}_1.fastq.gz \
ref=${bbmap}/resources/polyA.fa.gz,${bbmap}/resources/truseq_rna.fa.gz \
k=13 ktrim=r useshortkmers=t \
mink=5 qtrim=r trimq=10 minlength=20

# READ QC
#fastqc -o ${sample}/ -t 20 --nogroup ${sample}/02.Trimm.${sample}_1.fastq.gz
#fastqc -o ${sample}/ -t 20 --nogroup ${sample}/01.UMITools.${sample}_1.fastq.gz

# Alignments
STAR --runThreadN 10 --genomeDir ${STAR_ref} --readFilesIn ${sample}/02.Trimm.${sample}_1.fastq.gz --outFilterType BySJout \
--readFilesCommand zcat \
--outFilterMultimapNmax 20 --alignSJoverhangMin 8 \
--alignSJDBoverhangMin 1 --outFilterMismatchNmax 999 \
--outFilterMismatchNoverLmax 0.6 --alignIntronMin 20 \
--alignIntronMax 1000000 --alignMatesGapMax 1000000 \
--outSAMattributes NH HI NM MD --outSAMtype BAM SortedByCoordinate \
--outFileNamePrefix ${sample}/03.${sample}.

# mapping QC 
samtools flagstat ${sample}/03.${sample}.Aligned.sortedByCoord.out.bam > ${sample}/${sample}.flagstat

# Read indexin
samtools index ${sample}/03.${sample}.Aligned.sortedByCoord.out.bam

# Duplication
umi_tools dedup -I ${sample}/03.${sample}.Aligned.sortedByCoord.out.bam --output-stats=${sample}/04.${sample}.deduplicated -S ${sample}/04.${sample}.dedup.bam
samtools index ${sample}/04.${sample}.dedup.bam

# Gene read Counting
htseq-count -m intersection-nonempty -s yes -f bam -r pos ${sample}/04.${sample}.dedup.bam ${ref_gtf} > ${sample}/${sample}.count.txt

