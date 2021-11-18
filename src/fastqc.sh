#! /bin/bash

#cd ~/mydatalocal/tp_ngs_celegans/data
#for SRR in "SRR5564866_1.fastq.gz SRR5564866_2.fastq.gz"
#do
 # fastqc $SRR --outdir ~/mydatalocal/tp_ngs_celegans/results
#done

#multiqsec 
#cd ~/mydatalocal/tp_ngs_celegans/results
#multiqsec results/


#fastqc pour les données trimmées
cd ~/mydatalocal/tp_ngs_celegans/results
SRR_list="SRR5564855 SRR5564856 SRR5564857 SRR5564864 SRR5564865 SRR5564866"

for file in ~/mydatalocal/tp_ngs_celegans/processed_data/trimming/*_paired.fq.gz
do
  fastqc $file --outdir ~/mydatalocal/tp_ngs_celegans/results/trimming_fastqc
done