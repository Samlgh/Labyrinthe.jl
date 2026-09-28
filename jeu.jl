# C'est la même chose pour les fct avancer, reculer, haut et bas (à un détail près)

function avancer(grille, joueur)
    L, C = size(grille)
    ligne, colonne = joueur

    nouvelle_ligne = ligne
    nouvelle_colonne = colonne + 1

    # On vérifie qu'on ne sort pas de la grille
    if nouvelle_colonne > C
        return joueur
    end

    # On vérifie qu'il n'y a pas d'obstacle
    if grille[nouvelle_ligne, nouvelle_colonne] == 1
        return joueur
    end

    # On enlève le joueur de son ancienne case
    grille[ligne, colonne] = 0

    # Nouvelle position du joueur
    nouveau_joueur = (nouvelle_ligne, nouvelle_colonne)

    # Ne pas écraser la sortie
    if grille[nouvelle_ligne, nouvelle_colonne] != 2
        grille[nouvelle_ligne, nouvelle_colonne] = 3
    end

    return nouveau_joueur
end


function reculer(grille, joueur)

    ligne, colonne = joueur

    nouvelle_ligne = ligne
    nouvelle_colonne = colonne - 1

    # On vérifie qu'on ne sort pas de la grille
    if nouvelle_colonne < 1
        return joueur
    end

    # On vérifie qu'il n'y a pas d'obstacle
    if grille[nouvelle_ligne, nouvelle_colonne] == 1
        return joueur
    end

    grille[ligne, colonne] = 0

    nouveau_joueur = (nouvelle_ligne, nouvelle_colonne)

    if grille[nouvelle_ligne, nouvelle_colonne] != 2
        grille[nouvelle_ligne, nouvelle_colonne] = 3
    end

    return nouveau_joueur
end


function haut(grille, joueur)

    ligne, colonne = joueur

    nouvelle_ligne = ligne - 1
    nouvelle_colonne = colonne

    # On vérifie qu'on ne sort pas de la grille
    if nouvelle_ligne < 1
        return joueur
    end

    # On vérifie qu'il n'y a pas d'obstacle
    if grille[nouvelle_ligne, nouvelle_colonne] == 1
        return joueur
    end

    grille[ligne, colonne] = 0

    nouveau_joueur = (nouvelle_ligne, nouvelle_colonne)

    if grille[nouvelle_ligne, nouvelle_colonne] != 2
        grille[nouvelle_ligne, nouvelle_colonne] = 3
    end

    return nouveau_joueur
end


function bas(grille, joueur)

    L, C = size(grille)

    ligne, colonne = joueur

    nouvelle_ligne = ligne + 1
    nouvelle_colonne = colonne

    # On vérifie qu'on ne sort pas de la grille
    if nouvelle_ligne > L
        return joueur
    end

    # Vérifier qu'il n'y a pas d'obstacle
    if grille[nouvelle_ligne, nouvelle_colonne] == 1
        return joueur
    end

    grille[ligne, colonne] = 0

    nouveau_joueur = (nouvelle_ligne, nouvelle_colonne)

    if grille[nouvelle_ligne, nouvelle_colonne] != 2
        grille[nouvelle_ligne, nouvelle_colonne] = 3
    end

    return nouveau_joueur
end


# Parcours en largeur et calcul de la distance optimale entre le joueur et la sortie
function distance_optimale(grille, joueur, sortie)
    L, C = size(grille)

    # File des cases à explorer
    file = [joueur]

    # aucune case n'a encore été visitée (-1 pour inconnu)
    distances = fill(-1, L, C)

    # on initialise la distance de départ du joueur à 0
    ligne_joueur, colonne_joueur = joueur
    distances[ligne_joueur, colonne_joueur] = 0

    # Tant qu'il reste des cases à explorer dans la file
    while !isempty(file)

        # On récup la première case de la file
        position = popfirst!(file)

        ligne, colonne = position

        # Si la sortie est atteinte, on retourne la distance
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
            # On vérifie que la case est dans la grille / n'est pas un obstacle / n'a pas encore été visitée
            if 1 <= l <= L && 1 <= c <= C && grille[l, c] != 1 && distances[l, c] == -1
                distances[l, c] = distances[ligne, colonne] + 1
                push!(file, voisin)
            end
        end
    end

    # Aucun chemin trouvé
    return -1
end