args = commandArgs(trailingOnly=TRUE)
tab <- args[1] 

require('org.Mm.eg.db')
keytypes(org.Mm.eg.db)

tab <- read.table(tab, header=T, sep='\t')
lookup <- as.character(tab[,"ENSEMBL"])

merge_table <- unique(AnnotationDbi::select(
  org.Mm.eg.db,
  keytype = 'ENSEMBL',
  columns = c('ENSEMBL','SYMBOL'),
  keys = lookup))

library(dplyr)


# left join
joined.table <- left_join(tab,merge_table,by="ENSEMBL")

tab <- args[1] 
tab <- unlist(strsplit(tab, ".", fixed = T))
write.table(as.data.frame(joined.table),paste0(tab[1],".",tab[2],".ENSEMBL.GeneSymbol.",tab[3],".",tab[4]),quote=F, row.names=F, sep='\t')
