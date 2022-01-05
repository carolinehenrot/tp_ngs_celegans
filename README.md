# TP NGS 2021 Nématode

# Contexte

C.elegans est un organisme modèle très utilisé et étudié dans de nombreux domaines (l'immunité, l'embryogénèse, la génétique...). Un de ses avantages est son cycle de génération très rapide et de sa facilité de maintien au laboratoire.

Notre TP se base sur les données de Brown et al. (2017), qui se sont intéressés aux protéines argonautes de C.elegans. Ces protéines enzymatiques intéragissent avec de petits ARN non codants (miARNs), les utilisant comme guide leur permettant de reconnaître des ARNs cibles qui sont alors silencés ou dégradés. Chez C.elegans, 25 protéines argonautes sont connues. ALG-1 et ALG-2 notamment ont des rôles identifiés dans la régulation de l'expression génétique au cours du développement. Les auteurs dans leur étude s'intéressent particulièrement à ALG-5, appartenant à la même famille que ALG-1 et ALG-2 (famille AGO), mais dont le rôle au cours du développement n'est pas connu. 
Dans cette étude, Brown et al. étudient l'effet de mutations pour Alg-1, Alg-2 et Alg-5 sur le transcriptome de C.elegans d'une part, mettant en évidence les gènes régulés par comparaison avec les WT. D'autres part, il séquencent les miRNA avec qui les protéines argonautes intéragissent pour ces régulations.

Pour ce TP, nous nous sommes intéressés à la premirère partie, c'est-à-dire que nous avons reproduit leur analyse transcriptomique. Pour cela, nous avons repris leurs données de séquençage des cDNA. Ces données ont été obtenues par séquençage Illumina, après extraction des ARNs totaux, déplétion des ARN ribosomaux et rétro-transcription.
Nous avons tout d'abord cherché à voir si nous retrouvions leurs résultats, puis nous avons cherché à évaluer l'impact des variations développementales sur l'analyse de ces données.


# Première session du TP : téléchargement et cleaning des données, mapping et quantification des transcrits 
##  Création de l'environnement github et gitignore
Nous avons tout d'abord créé l'environnement github et choisi quoi mettre dans les commit.

~/mydatalocal/tp_ngs_celegans/.gitignore
C'est ce qu'on ne veut pas actualiser dans github : les data, les résultats. On veut éviter de mettre des fichiers de grande taille, et ne synchroniser que les codes.
Pour cela, on utilise * : wildcard ("joker", c'est pour dire "tout"), cela ne synchronisera pas ce qui est à l'intérieur du dossier correspondant.


## Téléchargement des données
Les données sont téléchargées depuis la database GEO de NCBI (https://www.ncbi.nlm.nih.gov/geo), avec le code d'accession GSE98935. 
On télécharge les données SRA (sequence read archive) avec parallel-fasq-dump (script download_data.sh).
Chaque membre du groupe télécharge les trois WT (SRR5564855, SRR5564856, SRR5564857) et les mutants sont répartis entre nous. Pour ma part: je télécharge les mutants alg-2 (SRR5564864, SRR5564865, SRR5564866).

Les données sont téléchargées zippées. zcat est utile pour visualiser les premieres données téléchargées sans dézipper le fichier.

## Analyse de la qualité des données
Certains reads peuvent ête de mauvaise qualité, et s'apparier au mauvais endroit. La qualité des données est tout d'abord analysée en utilisant fastqc, et est visualisée avec multiqc. (script fastqc.sh)

Comme on peut s'y attendre, les débuts et fin de read sont souvent de plus mauvaise qualité que le reste.

On peut nettoyer les données, c'est-à-dire enlever les read de mauvaise qualité, avec la fonction trimmomatic (script trimmoatic.sh). Le trimming est fait sur les deux données par échantillons (forward et reverse), les data venant de paired-ended reads.
En argument sont rentrés les paramètres choisis pour le trimming:

ILLUMINACLIP enlève les adaptateurs qui resteraient sur les reads (ILLUMINACLIP:${adapter_path}:2:30:10:2:keepBothReads)
LEADING: enlève les bases du début du read, si la qualité est < 8 (LEADING:8)
TRAILING: enlève les bases de la fin du read, si la qualité est < 8 (TRAILING:8)
SLIDINGWINDOW: scan les read avec une fenêtre de 4 bases, et coupe quand la qualité moyenne par base < 15 (SLIDINGWINDOW:4:15)
MINLEN: enlève les reads dont le nombre de bases est < 36 (MINLEN:36)

L'analyse des données trimmées par fastqc valide que nos reads sont maintenant de bonne qualité. Notamment, il n'y a plus d'adapteurs à la fin des reads comme auparavant.


## Mapping et quantification des transcrits avec Salmon
### Téléchargement du transcriptome de référence
Le transcriptome de C.elegans est téléchargé à partir de la base de données ensembl (https://www.ensembl.org/index.html), en utilisant le logiciel wget (script download_genome.sh). Le fichier est dézippé avec gunzip. 


### Mapping et quantification des transcrits
Nous utilisons le logiciel Salmon, qui permet de quantifier les transcrits à partir de données RNAseq. Il a la partiularité de faire une étape de pseudo-mapping, avec tout d'abord une étape d'indexation du génome (script salmon.sh).
On crée un index celegans_index du transcriptome, puis on réalise le mapping en utilisant cet index créé. Cela permet un mapping plus rapide. Salmon corrige également des biais classiques comme ceux liés à des enrichissement en GC. Le mapping prend en compte les données forward et reverse pour chaque read.

Quand on regarde les données quant de salmon, plusieurs indications nous sont données:
- TPM: transcript per million, indique l'abondance relative des transcrits. (Etant donné que Salmon ne fait pas de comptages absolus, mais qu'il compare les données avec le pré-mapping, c'est plus précis qu'il renvoie ces valeurs relatives)
- Nbr de reads mapped on each transcripts

D'après nos analyses, le mapping est d'environ 80%.
______
# 2ème semaine de TP : analyse d'expresion différentielle et étude de l'impact du développement

## Analyse d'expression différentielle

La foncion tximport regroupe les données quants issues de salmon par gènes dans un tableau (longueur transcrit, counts...)
On visualise les résutats avec plot:
- soit avec des vulcano plot, par exemple mutant vs wt (en utilsant log1P car les données sont très étalées en raison de gènes beaucoup plus exprimés que les autres).
- soit avec des box plot pour des gènes intéressants (avec une différence d'expression marquée) identifiés sur le vulcano plot. Pour cela, on les sépare en faisant un petit gating avec la fonction head, puis ont les plot en fonction du groupe mut/ wt.

On sélectionne les gènes significativement différemment exprimés entre alg2 et wt, avec une p-value <0,05 après un test de Wald. Mais on ne s'arrête pas à la p-value, car c'est un potentiel effet biologique qui nous intéresse. On veut une différence significative, mais aussi que les écarts d'expression soient assez différents. On met pour cela un seuil avec log2FoldChange > ou < 1,5 pour des gènes respectivement surexprimés (exp_diff_up) ou sous-exprimés (exp_diff_down) chez le mutant comparé au WT.

On crée ainsi une liste de True, False et NA. On fait compter les NA comme des False avec na.omit

Nous avons ensuite analysé les deux listes de gènes obtenus dans Wormbase. Etonnamment, pour les Alg2 mutés, la majorité des gènes significativement uprégulés sont impliqués dans la formation de la cuticule. Il est possible que cette différence vienne du fait qu'Alg-2 inhibe des gènes de développement. Les auteurs ne mentionnent pas cette catégorie de gènes très présents dans mon analyse. Pour les autres catégorie et notamment celles les gènes downrégulés, les catégories sont proches de celles trouvées dans le papier d'origine.

## Etude de l'imapact du développement
Il est aussi important de considérer que C.elegans a un développement très rapide, avec un transcriptome changeant drastiquement en quelques heures. On estime ainsi qu'en 1 heure, 10 000 gènes sont exprimés différemment au cours du développement. De plus, les mutants pour les protéines argonautes ont un développement qui est ralenti en général. Les auteurs ont néanmoins essayé de comparer des individus aux mêmes stades de développement, notamment par observation phénotypique des C.elegans au microscope. Cependant, c'est une étape délicate et qui peut être imprécise. 
Il est possible ainsi qu'une part des différences d'expression obtenues (notamment pour les gènes de synthèse de cuticule par exemple) viennent d'un biais expérimental, si les mutants et les alg-2 n'étaient pas tout à fait aux mêmes stades. Les profils d'expression différentielles viennent-ils seulement de la mutation ? Pour essayer de répondre à cette question, nous avons utilisé le logiciel Raptor pour déterminer les âges biologiques des individus WT et mutants à partir de leurs transcriptomes. 

### Estimation d'âge biologique
Le logiciel raptor utilise des séries temporelles de profils d'expression de gènes disponibles en ligne comme référence.
On a tout d'abord pu déterminer les âges biologiques obtenus ave le logiciel.
Pour alg-2: les WT sont plus vieux de plusieurs jours, il y a donc une différence de développement.

#### Détermination de l'impact du développement sur les données transcriptomiques
getrefTP: permet d'obtenir l'estimation de la différence d'expression pour les expression de référence correspondant aux âges biologiques déterminés pour les WT et Alg-2
refCompare : permet de comparer les différences mesurées et estimées par la fonction précédentes. Cela permet de déterminer l'importance relative du facteur développemental sur les différences observées entre WT et mutant.

Ainsi, le contexte biologique ne suffit pas à expliquer les différences d'expression observées entre WT et mutant alg-2. Il y a un impact dudéveloppement qui est mis en évidence graphiquement.

# Conclusion
Ainsi, les auteurs ont comparé des échantillons qui avaient des âges sensiblement différents. Quelques jours d'âge biologique de différence s'avère important chez C.elegans pour qui le temps de développement est très rapide. Le développement est un biais à garder en tête pour des études transcriptomiques chez ce modèle. Bien sûr, les auteurs ne se sont pas arrêtés aux transcriptomes pour leurs études et l'analyse des miRNA impliqués est donc très importante pour tirer des conclusion sur les gènes cibles des protéines argonautes. 
C'était aussi le cas pour alg-1. Cependant, on peut noter que pour les autres mutants alg-5, les mutants et les WT étaients d'âges similaires. Il y a un biais développement moins important pour eux. Par ailleurs, le fait que l'on avait trouvé moins de gènes significativement différemment exprimés pour alg-5 par rapport à alg-1 et alg-2 est cohérent avec nos résultats.

