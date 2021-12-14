#Jour 1
## ignore
c'est ce qu'on ne veut pas actualiser dans github : les data, les résultats.
On ne veut synchroniser que les codes 
* : wildcard ("joker") c'est pour dire "tout", on ne veut pas synchroniser ce qui est à l'intérieur du dossier

#Bouger un fichier
mv nom_du_fichier.sh nom_du_dossier/

#Créer un dossier
touch nom_du_fichier.sh

On télécharge les données SRA (sequence read archive) avec fasq-dump (download_data.sh)
J'ai au début ajouté X 100 dans le fasq-dump pour vérifier que les fichiers se téléchargeaient dans le bon dossier (télécharge les 100 premiers éléments par SRR)

Pour les prochains jours: fastqc va permettre d'évaluer la qualité : certains read de mauvaise qualité peuvent s'apparier au mauvais endroit. analyse qualité avec trimmomatic
--> on va enlever les parties des reads de mauvaises qualités
et les débuts et fin de read sont souvent de plus mauvaise qualité ()
--> multiqc pour visualier

Téléchargement du génomede C.elegans trouvé sur ensembl avec le logiciel wget

#Jour 2
  #Téléchargemet
Reprise du téléchargement arreté hier. utilisation de parallel-fastq-dump qui va plus vite

    parallel-fastq-dump --threads 6 -s $SRR --split-3 --gzip --outdir data

  #Fastqc
Création de fichier fastqc qui permet de visualiser la qualité des données

#Multiqsec 
le faire sur le dossier processed data

#Salmon
on fait tout d'abord une indexation : on prémache le génome pour que ce soit plus facile après de faire du mapping
on crée un index du transcriptome ce qui va faciliter le mapping avec celegans_index
Quand on regarde les données quant de salmon:
- TPM: transcript per million, indique l'abondance relative des transcrits. Vu que Salmon ne fait pas des comptages absolus mais compare les données avec le pr-mapping c'est plus précis qu'il renvoie ces valeurs relatives)
- Nbr de reads mapped on each transcripts

#tximport
regroupe les données quants issues de salmon par gènes dans un tableau (longueur transcrit, counts...)
je visualise les résutats avec plot:
- soit vulcano plot par exemple mutant vs wt. on utilse log1P car les données sont très étalées
(des gènes bcp plus exprimés que les autres --> applatis le graphe)
- soit box plot pour des gènes intéressants identifiés sur le vulcano
on les sépare en faisant un petit gating avec head. 
puis ont les plot en fonction de mut/ wt par gène