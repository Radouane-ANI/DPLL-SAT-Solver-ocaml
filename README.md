\# Solveur DPLL en OCaml

Ce projet implémente l'algorithme **DPLL (Davis-Putnam-Logemann-Loveland)** en OCaml pour la résolution du problème de satisfiabilité booléenne (SAT).

\## Description
L'algorithme DPLL est une amélioration de la méthode de résolution par retour sur trace (backtracking) du problème SAT. Il intègre plusieurs heuristiques d'optimisation, notamment :
- \*\*Élimination des clauses unitaires\*\* : si une clause ne contient qu'un seul littéral, elle doit être vraie.
- \*\*Propagation des littéraux purs\*\* : un littéral qui apparaît toujours avec la même polarité dans toutes les clauses peut être directement attribué.
- \*\*Branchement récursif\*\* : sélection d'un littéral pour essayer d'attribuer une valeur et explorer les deux possibilités.

\## Structure du code

\### Fonctions principales
- \`simplifie\` : applique la simplification des clauses en mettant un littéral à vrai.
- \`solveur_split\` : implémente un solveur basique par séparation.
- \`pur\` : identifie un littéral pur dans l'ensemble des clauses.
- \`unitaire\` : détecte une clause unitaire.
- \`solveur_dpll_rec\` : implémente l'algorithme DPLL récursif avec simplifications optimisées.
- \`print_modele\` : affiche le modèle trouvé ou indique que le problème est insatisfiable.

\### Jeux de tests intégrés
Le projet inclut plusieurs ensembles de clauses SAT en exemple :
- \`exemple_3_12\`
- \`exemple_7_2\`
- \`exemple_7_4\`
- \`exemple_7_8\`
- \`systeme\`
- \`coloriage\`

\## Utilisation
\### Compilation et exécution
Pour compiler et exécuter le programme, utilisez les commandes suivantes :
\```sh
make
./dpll "fichier"
\```

\### Entrée
Le programme attend un fichier DIMACS en entrée, contenant une instance du problème SAT.

\### Sortie
Le programme affiche :
- \`SAT\` suivi d'une interprétation satisfaisante si la formule est satisfiable.
- \`UNSAT\` si la formule est insatisfiable.

\## Exemple
Avec un fichier d'entrée \`exemple.cnf\` :
\```sh
./dpll exemple.cnf
\```
Sortie possible :
\```
SAT
1 -2 3 0
\```

\## Dépendances
Aucune dépendance externe n'est requise, OCaml standard suffit.

\## Auteurs
- \*\*Ton Nom\*\*

\## Licence
Ce projet est sous licence MIT.


