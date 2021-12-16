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
data=tximport(fullpaths,'salmon', tx2gene = tx2gn)#tx2gene c'est pour transformer les noms de transcripts en noms de gènes
colnames(data$abundance)=c("alg-2 (rep1)","alg-2(rep2)","alg-2 (rep3)","WT (rep1)","WT (rep2)","WT (rep3)")

colData=data.frame(paths,factor(c("Alg2","Alg2","Alg2","WT","WT","WT"),levels = c("WT", "Alg2"))) #levels permet de dire qu'on va comparer Alg2 par rapport à WT et pas l'inverse
colnames(colData)=c("sample","treatment")
data$normlog=normalizeBetweenArrays(data$abundance,method = "quantile")
data$normlog=log1p(data$normlog)

ref=prepare_refdata("Cel_larv_YA","wormRef",n.inter=600)

pseudoage_data=ae(data$normlog,refdata = ref$interpGE, ref.time_series = ref$time.series)

plot(pseudoage_data, groups = colData$treatment, show.boot_estimates = T)


getrefTP <-function(ref, ae_obj, ret.idx = TRUE){
  # function to get the indices/GExpr of the reference matching sample age estimates.
  idx <- sapply(ae_obj$age.estimates[,1],function(t) which.min(abs(ref$time.series - t))) #sapply(list, function)
  if(ret.idx)
    return(idx)
  return(ref$interpGE[,idx])
}

refCompare <-function(samp, ref, ae_obj, fac){
  # function to compute the reference changes and the observed changes
  ovl <- format_to_ref(samp, getrefTP(ref, ae_obj, ret.idx = FALSE)) #on ne prend pas les gènes pas utilisés par RAPTOR
  lm_samp <- lm(t(ovl$samp)~fac) #ovl: overlapp #logfold change pour les samples WT et agl2
  lm_ref <- lm(t(ovl$ref)~fac) #logfold change des références (si c'est zéro: pas de différence d'exp entre les stades de dev)
  return(list(samp=lm_samp, ref=lm_ref, ovl_genelist=ovl$inter.genes))
}

comparaison=refCompare(log1p(data$abundance),ref,pseudoage_data,colData$treatment)
par(pty="s")
plot(comparaison$ref$coefficients[2,],comparaison$samp$coefficients[2,],ylim=c(-5,5),xlim=c(-5,5))

#je mets en rouge les gènes significativement - exprimés et en vert + exprimés
plot(comparaison$ref$coefficients[2,],comparaison$samp$coefficients[2,],
     ylim=c(-5,5),xlim=c(-5,5),col=1, pch=16) #pch=16: des points pleins

c~mydatalocal/tp_ngs_celegans/results
upgenes=read.table("~/mydatalocal/tp_ngs_celegans/results/fGO_up.data")$V1 #read.table: dataframe, $V1: première colonne
downgenes=read.table("~/mydatalocal/tp_ngs_celegans/results/fGO_down.data")$V1

points(comparaison$ref$coefficients[2, comparaison$ovl_genelist %in% upgenes], #je rajoute des points par dessus le plot
      comparaison$samp$coefficients[2,comparaison$ovl_genelist %in% upgenes],col=3, pch=16)
points(comparaison$ref$coefficients[2, comparaison$ovl_genelist %in% downgenes],
       comparaison$samp$coefficients[2,comparaison$ovl_genelist %in% downgenes],col=2, pch=16)
