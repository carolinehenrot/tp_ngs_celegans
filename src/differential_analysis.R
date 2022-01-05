library("tximport")

paths=c(paste0(c("SRR5564864","SRR5564865","SRR5564866","SRR5564855","SRR5564856","SRR5564857"),"_quant")) #on crée un vecteur avec le nom de chaque échantillon et les données par transcrit
fullpaths=file.path("processed_data/quants",paths,"quant.sf") #on fait tableau avec pour chaque transcrit les valeurs des vecteurs précédents

tx2gn <- read.table("~/mydatalocal/tp_ngs_celegans/data/tx2gn.csv", h=T, sep=',', as.is=T)
data=tximport(fullpaths,"salmon",tx2gene = tx2gn) #par défaut salmon prend les ID des transrits, ici on lui de prendre les gènes

#par(mfrow=c(1,2)) #affichage sur une ligne 2 colonnes
plot(log1p(data$counts[,1]), log1p(data$counts[,4])) #les données sont très étalées: on utilise fonction log1p
plot(log1p(data$counts[,5]), log1p(data$counts[,4])) 

plot(log1p(data$counts[,2]), log1p(data$counts[,5]))
plot(log1p(data$counts[,3]), log1p(data$counts[,2]))

logdat <- log1p(data$counts)

head(which(logdat[,5]>10 & logdat[,2]<9)) #on sélectionne des points différemment exprimés entre WT / mutants

for(i in c(466, 1008, 12197)){ #on reprend les numéros des gènes qui sont ressortis précédemment
  boxplot(logdat[i, ]~rep(c("mut", "wt"), e=3), main = rownames(logdat)[i]) #on différencie les wt et les mutants. rep= repeat, e= each
}

library(DESeq2)
colData=data.frame(paths,factor(rep(c("Alg2","WT"),e=3), levels=c("WT","Alg2")))
colnames(colData)=c("sample","treatment") #création du vecteur avec les valeurs des échantillons et traitement
dp=DESeqDataSetFromMatrix(round(data$counts),colData = colData,design=~treatment) #round: arrondit à l'unité
exit=DESeq(dp,test="Wald")
#exit=DESeq(dp, test="LRT", reduced=~1)


res=results(exit)
exp_diff_up=results$padj<0.05 & results$log2FoldChange> 1.5 #je discrimine les pvalues significatives à 0,05 --> gènes exprimés différemment entre wt et arg2
#même si c'est significativement différent on veut de grosses différences (potentiellement un rôle biologique quoi)
exp_diff_down=results$padj<0.05 & results$log2FoldChange< -1.5 #gènes downrégulés chez le mutant

par(mfrow=c(1,1), pty='s')
plotMA(res, ylim=c(-12,12)) #scatter plot on the y-axis vs the mean of normalized counts on the x-axis.

genesofinterest_up=na.omit(rownames(exit)[exp_diff_up])
#on crée un sous-tableau des valeurs de exit pour lesquelles on a exp_diff=True (et na.omit compte les NA, non applicables, comme des FALSE )
genesofinterest_down=na.omit(rownames(exit)[exp_diff_down])

#GO_up_ltr = file("results/fGO_up_ltr.data", "w") #w: write car on crée fichier d'écriture
#cat(genesofinterest_up,sep='\n', file = GO_up)
#GO_down_ltr = file("results/fGO_down_ltr.data", "w") #w: write car on crée fichier d'écriture
#cat(genesofinterest_down,sep='\n', file = GO_down)

GO_up_wald = file("results/fGO_up.data", "w") #w: write car on crée fichier d'écriture
cat(genesofinterest_up,sep='\n', file = GO_up_wald)
GO_down_wald = file("results/fGO_down.data", "w") #w: write car on crée fichier d'écriture
cat(genesofinterest_down,sep='\n', file = GO_down_wald)
