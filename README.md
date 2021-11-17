# ignore
c'est ce qu'on ne veut pas actualiser dans github : les data, les résultats.
On ne veut synchroniser que les codes 
* : wildcard ("joker") c'est pour dire "tout", on ne veut pas synchroniser ce qui est à l'intérieur du dossier

#Bouger un fichier
mv nom_du_fichier.sh nom_du_dossier/

#Créer un dossier
touch nom_du_fichier.sh

On télécharge les données SRA (sequence read archive) avec fasq-dump (download_data.sh)
J'ai au début ajouté X 100 dans le fasq-dump pour vérifier que les fichiers se téléchargeaient dans le bon dossier (télécharge les 100 premiers éléments par SRR)

Pour les prochains jours: fastqc va permettre d'évaluer la qualité : certains read de mauvaise qualité peuvent s'apparier au mauvais endroit
--> on va enlever les parties des reads de mauvaises qualités
--> multiqc pour visualier

Téléchargement du génomede C.elegans trouvé sur ensembl avec le logiciel wget






