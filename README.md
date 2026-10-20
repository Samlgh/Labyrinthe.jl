# Le Labyrinthe des Malicieux

Projet réalisé en **Julia**, avec une interface web développée avec **WGLMakie** et **Bonito**.
Le jeu consiste à guider un personnage à travers un labyrinthe généré aléatoirement pour atteindre la sortie, en utilisant les flèches du clavier.

## 1. Environnement Julia et packages

On a un environnement virtuel Julia (`venv`) avec :

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
- **`models/`** : contient les modèles 3D, matériaux et textures. RESTE LES 2 AUTRES MODES, A VOIR AVEC HANNAH.

## 5. Exécution sur un autre pc

Après avoir téléchargé le projet et installé Julia, il suffit d'exécuter ces deux commandes dans le dossier principal :

**Installation (une fois) :**

`julia --project=. installer.jl`

**Lancement :**

`julia --project=. main.jl`

Puis ouvrir le lien : **http://127.0.0.1:8766**.


## 6. Ce qu'il reste à faire

- Rendre le projet plus modulaire et mieux structuré, en respectant au max les conventions de programmation de Julia :
Mieux organiser le code en séparant les différentes fonctionnalités et en utilisant des struct pour représenter les éléments du jeu, avec des mutable struct lorsque leurs attributs doivent être modifiés.
Respecter les conventions de nommage Julia : par exemple, renommer Modele_affichage en ModeleAffichage.
Mieux représenter la génération du labyrinthe : par exemple, utiliser une structure LabyrintheKruskal plutôt que fonction creer_lab().
Distinguer les fonctions internes des fonctions principales : par exemple, renommer charger_modele(chemin) en _charger_modele(chemin) pour dire qu'elle est destinée à un usage interne.
- Améliorer le Design du menu
- EFFECTUER DES TESTS UNITAIRES
- REDIGER LE RAPPORT HTML (avec Quarto ou un notebook Julia)
- FAIRE LA PRESENTATION HTML (avec KaimonSlate ou BonitoBook)
