#! /bin/bash

#Indexation
cd ~/mydatalocal/tp_ngs_celegans

#on crée un index du transcriptome ce qui va faciliter le mapping
#salmon index -t data/Caenorhabditis_elegans.WBcel235.cdna.all.fa -i processed_data/celegans_index #i : donne le nom de l'index qui va être créé

#on fait le mapping sur le transcriptome en utilisant l'index créé 
cd ~/mydatalocal/tp_ngs_celegans

SRR_list="SRR5564855 SRR5564856 SRR5564857 SRR5564864 SRR5564865 SRR5564866"
for srr in $SRR_list
do
  echo "Processing sample $srr"
  salmon quant -i processed_data/celegans_index  -l A \
         -1 processed_data/trimming/${srr}_forward_paired.fq.gz \
         -2 processed_data/trimming/${srr}_reverse_paired.fq.gz \
         -p 3 --validateMappings -o processed_data/quants/${srr}_quant
#lA dit à Salmon de choisir automatiquement le type de librairie 
#1 et 2 indiquent à Salmon où trouver les fichiers forward et reverse
#p indique d'utiliser 3 threads
done