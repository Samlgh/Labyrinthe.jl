# Calcule le chemin optimal jusqu'à la sortie
function chemin_optimal(labyrinthe, depart, sortie)
    L, C = size(labyrinthe)

    # File des cases à explorer
    file = [depart]

    # Garde la case précédente de chaque position
    precedent = fill((0, 0), L, C)

    # Tant que la file n'est pas vide, on explore les cases
    while !isempty(file)
        ligne, colonne = popfirst!(file)

        # Si on atteint la sortie, on stop
        if (ligne, colonne) == sortie
            break
        end

        # Les quatre voisins possibles
        voisins = [
            (ligne - 1, colonne),
            (ligne + 1, colonne),
            (ligne, colonne - 1),
            (ligne, colonne + 1)
        ]

        # Exploration des voisins, si la case est valide et non visitée.
        for (l, c) in voisins
            if 1 <= l <= L && 1 <= c <= C && labyrinthe[l, c] != 1 && precedent[l, c] == (0, 0) && (l, c) != depart
                precedent[l, c] = (ligne, colonne)
                push!(file, (l, c))
            end
        end
    end

    # Reconstruction du chemin
    chemin = []
    position = sortie

    # On remonte de la sortie jusqu'au départ
    while position != depart
        pushfirst!(chemin, position)
        ligne, colonne = position
        position = precedent[ligne, colonne]
    end

    # Ajoute le départ au début du chemin
    pushfirst!(chemin, depart)

    return chemin
end


# Calcule le nombre minimal de déplacements
function coups_optimaux(labyrinthe, depart, sortie)
    chemin = chemin_optimal( labyrinthe, depart, sortie)
    return length(chemin) - 1
end


function mode_jeu()
    return interface_menue()
end