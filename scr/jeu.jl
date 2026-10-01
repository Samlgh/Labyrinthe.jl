# Parcours en largeur (BFS)
# Calcule le nombre minimal de déplacements
function coups_optimaux(labyrinthe, depart, sortie)
    L, C = size(labyrinthe)

    # File des cases à explorer
    file = [depart]

    # -1 = case pas encore visitée
    distances = fill(-1, L, C)

    ligne_depart, colonne_depart = depart

    distances[ligne_depart, colonne_depart] = 0

    while !isempty(file)
        # Première case de la file
        position = popfirst!(file)

        ligne, colonne = position

        # Si on atteint la sortie
        if position == sortie
            return distances[ligne, colonne]
        end

        # Les quatre voisins possibles
        voisins = [
            (ligne - 1, colonne),
            (ligne + 1, colonne),
            (ligne, colonne - 1),
            (ligne, colonne + 1)
        ]

        for voisin in voisins
            l, c = voisin
            # Vérifie que la case est dans la grille, ce n'est pas un muret qu'elle n'a pas encore été visitée
            if 1 <= l <= L && 1 <= c <= C && labyrinthe[l, c] != 1 && distances[l, c] == -1
                distances[l, c] = distances[ligne, colonne] + 1
                push!(file, voisin)
            end
        end
    end

    # Aucun chemin trouvé
    return -1
end


function mode_jeu()
    println("Welcome dans le labyrinthe :")
    println()

    print("Lignes : ")
    l = parse(Int, readline())

    print("Colonnes : ")
    c = parse(Int, readline())

    # Création du labyrinthe
    labyrinthe = creer_lab(l, c)

    # Position du joueur
    ligne_joueur = 2
    colonne_joueur = 2

    # Position de la sortie
    sortie = (2*l, 2*c)

    # Nombre optimal de coups
    optimal = coups_optimaux(labyrinthe, (ligne_joueur, colonne_joueur), sortie)

    # Compteur de coups
    coups = 0

    println()
    println("Labyrinthe créé : ", l, " x ", c)
    println()

    display(labyrinthe)

    println()
    println("0 = passage")
    println("1 = mur")
    println("2 = joueur")
    println("3 = sortie")

    println()
    println("Nombre optimal de coups : ", optimal)

    # Tant que le joueur n'est pas à la sortie
    while ligne_joueur != 2*l || colonne_joueur != 2*c
        println()
        println("A = droite | R = gauche | H = haut | B = bas") 
        println()

        direction = readline()

        ancienne_ligne = ligne_joueur
        ancienne_colonne = colonne_joueur

        labyrinthe,
        ligne_joueur,
        colonne_joueur = deplacement!((ligne_joueur, colonne_joueur), labyrinthe, direction)

        # On compte uniquement si le joueur a bougé
        if ligne_joueur != ancienne_ligne || colonne_joueur != ancienne_colonne
            coups += 1
        end

        println()

        display(labyrinthe)

        println()
        println("Position : ", (ligne_joueur, colonne_joueur))

        println("Coups : ", coups)
        println("Optimal : ", optimal)
    end

    println()
    println("Partie terminée !")
    println("Nombre de coups : ", coups)
    println("Nombre optimal : ", optimal)
end
