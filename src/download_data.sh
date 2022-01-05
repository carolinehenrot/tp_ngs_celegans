#! /bin/bash

cd ~/mydatalocal/tp_ngs_celegans #je me positionne dans le bon dossier

#telechargement des donnees avec parallel-fastq-dump, plus rapide que fastq-dump
for SRR in "SRR5564855 SRR5564856 SRR5564857 SRR5564864 SRR5564865	SRR5564866"
do 
  parallel-fastq-dump --threads 6 -s $SRR --split-3 --gzip --outdir data/ #la destination des donnees est precisee apres outdir
done


#zcat SRR5564855_1.fastq.gz |head -n10 #pour afficher les premieres sequences du dossier telecharge sans decompresser les donnees
