# Arguments
args = commandArgs(trailingOnly=TRUE)
countMatrix <- args[1]
project <- args[2]
sample.matching <- args[3]

sample <- as.character(read.table("sample.matching.txt")[,2])

# Read Input data
ori.table <- as.matrix(read.csv(countMatrix, header=T, row.name=1, sep='\t'))

## count table generation
Gene <- row.names(ori.table)
countMatrix <- cbind(Gene, ori.table)
colnames(countMatrix) <- c("ENSEMBL",sample)

## Normalization table generation
cpmMatrix <- apply(ori.table, 2, function(x) (x/sum(x)*1000000))
cpmMatrix <- cbind(Gene, cpmMatrix)
colnames(cpmMatrix) <- c("ENSEMBL",sample)

write.table(as.data.frame(countMatrix), paste0(project,".Counts.table.txt"), quote=F, row.names=F, sep='\t')
write.table(as.data.frame(cpmMatrix), paste0(project,".CPMNorm.table.txt"), quote=F, row.names=F, sep='\t')

# Env cleaning
rm(list=ls())

