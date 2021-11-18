#! /bin/bash

cd ~/mydatalocal/tp_ngs_celegans/data
wget http://ftp.ensembl.org/pub/release-104/fasta/caenorhabditis_elegans/cdna/Caenorhabditis_elegans.WBcel235.cdna.all.fa.gz #télécharge le fichier du lien

#Pour dézipper le fichier téléchargé
cd ~/mydatalocal/tp_ngs_celegans/data
gunzip Caenorhabditis_elegans.WBcel235.cdna.all.fa.gz

