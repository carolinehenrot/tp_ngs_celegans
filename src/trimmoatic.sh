#! /bin/bash

#DATA CLEANING (TRIMMING)
#maybe try several parameters, partition in the group
cd ~/mydatalocal/tp_ngs_celegans/data
mkdir -p trimming #ne râle pas si le fichier existe déjà
cd trimming
trimmomatic_path="/softwares/Trimmomatic-0.39/trimmomatic-0.39.jar"  #variable containing the path towards trimmomatic
adapter_path="/softwares/Trimmomatic-0.39/adapters/TruSeq3-PE.fa"
for file in ls ~/mydatalocal/tp_ngs_celegans/data/*_1.fastq.gz
do #on ne veut garder que le nom du préfixe
  prefix=${file/"_1.fastq.gz"/} #on enlève la fin du nom de file
  prefix=${prefix/"/home/rstudio/mydatalocal/tp_ngs_celegans/data/"/} #et son début
  java -jar $trimmomatic_path PE \
  ~/mydatalocal/tp_ngs_celegans/data/${prefix}_1.fastq.gz \
  ~/mydatalocal/tp_ngs_celegans/data/${prefix}_2.fastq.gz \
  ${prefix}_forward_paired.fq.gz \
  ${prefix}_forward_unpaired.fq.gz \
  ${prefix}_reverse_paired.fq.gz \
  ${prefix}_reverse_unpaired.fq.gz \
  ILLUMINACLIP:${adapter_path}:2:30:10:2:keepBothReads \
  LEADING:8 TRAILING:8 SLIDINGWINDOW:4:15 MINLEN:36
done
  
