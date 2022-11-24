# Rapport didson Vilaine

Code pour créer le rapport didson 

<img src="/image/didson.png" alt="didson" width="150"/>


Le suivi des dévalaisons d'argentées sur la Vilaine est effectué à l'aide d'un radar multi-faisceau didson.
Le bilan des migrations requiert la compilation des fichiers texte et des données de comptage, les saisies indépendantes
dans le cahier et les fichiers textes de mesure de taille des anguilles réalisés lors des dépouillement sont introduits
dans une base de données postgreSQL. Le programme sql permet de vérifier de la cohérence des deux sources et donc fournit
une procédure pour assurer la qualité des données de suivi.
Les données du barrage sont téléchargées dans un fichier par 30 minutes correspondant au temps d'enregistrement des fichiers 
didson. Elles permettent le recalcul du débit sur chaque volet / vanne du barrage et de recalculer la répartion des anguille
et d'extrapoler les données à partir des lecture sur le faisceau du didson qui ne représente qu'une faible part des dévalaisons possibles.
Les analyses sont effectuées dans les différents chunks (code) du rapport sweave dans l'onglet rapport.

![Anguille en migration au droit du didson](/image/ang1.png)

Voir issue #1 pour les instructions pour créer un nouveau rapport.
