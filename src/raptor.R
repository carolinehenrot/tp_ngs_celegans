#on installe raptor
# limma dependecy
BiocManager::install("limma")
install.packages("pls")
devtools::install_github("LBMC/RAPToR", build_vignettes = TRUE)
devtools::install_github("LBMC/wormRef")


library(RAPToR)
library(limma)


paths=c("SRR5564864","SRR5564865","SRR5564866","SRR5564855","SRR5564856","SRR5564857")
fullpaths=file.path("processed_data/quants",paths,"quant.sf") #concaténation avec file.path très pratique
tx2gn <- read.table("data/tx2gn.csv", h=T, sep=',', as.is=T)
data=tximport(fullpaths,'quants', tx2gene = tx2gn)#tx2gene c'est pour transformer les noms de transcripts en noms de gènes
colnames(data$abundance)=c("alg-2 (rep1)","alg-2(rep2)","alg-2 (rep3)","WT (rep1)","WT (rep2)","WT (rep3)")

colData=data.frame(paths,factor(c("Alg2","Alg2","Alg2","WT","WT","WT"),levels = c("WT", "Alg2"))) #levels permet de dire qu'on va comparer Alg2 par rapport à WT et pas l'inverse
colnames(colData)=c("sample","treatment")
data$normlog=normalizeBetweenArrays(data$abundance,method = "quantile")
data$normlog=log1p(data$normlog)

ref=prepare_refdata("Cel_larval_YA","wormRef",n.inter=600)

pseudoage_data=ae(data$normlog,refdata = ref$interpGE, ref.time_series = ref$time.series)

plot(pseudoage_data, groups = colData$treatment, show.boot_estimates = T)