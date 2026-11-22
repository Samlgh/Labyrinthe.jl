# Le Labyrinthe des Malicieux

Projet réalisé en **Julia**, avec une interface web développée avec **WGLMakie** et **Bonito**.
Le jeu consiste à guider un personnage à travers un labyrinthe généré aléatoirement pour atteindre la sortie, en utilisant les flèches du clavier.


## 1. Environnement Julia et packages

On a un environnement Julia propre au projet, avec :

- **`Project.toml`** qui contient les dépendances du projet.
- **`Manifest.toml`** qui contient les versions de chaque package

Les principales bibliothèques utilisées sont **WGLMakie, Bonito, FileIO, MeshIO, GeometryBasics et DataStructures**.

Pour installer automatiquement les dépendances, ouvrir un terminal dans le dossier principal du projet et exécuter :

`julia --project=. installer.jl`

ça active l'environnement Julia du projet et installe tout les packages nécessaires grâce à `Pkg.instantiate()`


## 2. Lancer le jeu

Toujours depuis le dossier principal du projet, exécuter :

`julia --project=. main.jl`

ça active l'environnement Julia et démarre le **serveur web Bonito**

Ouvrir ensuite l'adresse suivante dans un navigateur :

**http://127.0.0.1:8766**

Le menu d'accueil permet de choisir la taille du labyrinthe et le personnage.

Pour arrêter le serveur, il faut faire `Ctrl+C` dans le terminal.


## 3. Fonctionnement du jeu

Le projet utilise :

- **Kruskal** pour générer aléatoirement un labyrinthe.
- **BFS** pour déterminer le chemin le plus court jusqu'à la sortie.
- **WGLMakie** pour afficher le labyrinthe et les modèles 3D.
- **Bonito** pour créer et servir l'application web interactive.
- **Julia** pour gérer les déplacements, les obstacles, les compteurs et les événements...


## 4. Organisation du projet

- **`main.jl`** : démarre le serveur web Bonito.
- **`installer.jl`** : installe les dépendances Julia.
- **`src/Labyrinthe.jl`** : regroupe les fichiers dans un module Julia.
- **`src/structure.jl`** : contient la structure et la génération du labyrinthe.
- **`src/jeu.jl`** : contient les algorithmes du jeu, notamment BFS.
- **`src/interface.jl`** : gère l'affichage 3D et les interactions.
- **`src/interface_web.jl`** : gère le menu d'accueil et la navigation.
- **`models/`** : contient les modèles 3D, matériaux et textures.
- **`test/`** : contient des tests qui vérifient la structure du labyrinthe, les déplacements, la géneration de la grille et le calcul du chemin optimal.


## 5. Exécution sur un autre pc

Après avoir téléchargé le projet et installé Julia, il suffit d'exécuter ces deux commandes dans le dossier principal :

**Installation (une fois) :**

`julia --project=. installer.jl`

**Lancement :**

`julia --project=. main.jl`

Ouvrir ensuite **http://127.0.0.1:8766** dans un navigateur.


## 6. Tests unitaires

Les tests se trouvent dans `test/runtests.jl`.

Pour les lancer :

`julia --project=. -e "using Pkg; Pkg.test()"`

**Les 45 tests unitaires ont été exécutés avec succès**


## 7. Rapport et présentation

Le rapport et la présentation ont été réalisés avec **Quarto** et **Julia**. 

Pour les consulter dans un navigateur, ouvrir `rapport.html` ou `presentation.html` (d'ici le 30/11).

Le fichier `rapport.qmd` contient les explications, les exemples en Julia et les démonstrations interactives. 
Le fichier `rapport.qmd` contient ...

### Régénérer les fichiers HTML

Pour modifier ou régénérer les documents, il faut installer [Quarto](https://quarto.org/) et disposer de l'environnement Julia du projet.

Depuis le dossier principal du projet, exécuter :

```powershell
quarto render rapport.qmd
quarto render presentation.qmd
```
Sous Windows, les commandes suivantes ouvrent les fichiers HTML dans le navigateur :

```powershell
start rapport.html
start presentation.html
```
