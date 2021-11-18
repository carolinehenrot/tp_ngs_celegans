#! /bin/bash

cd ~/mydatalocal/tp_ngs_celegans/data
for SRR in "SRR5564855_1.fastq.gz SRR5564855_2.fastq.gz"
do
  fastqc $SRR --outdir ~/mydatalocal/tp_ngs_celegans/results
done

#multiqsec 
#cd ~/mydatalocal/tp_ngs_celegans/results
#multiqsec results/


