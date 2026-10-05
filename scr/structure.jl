# 0 = case vide
# 1 = mur / obstacle
# 2 = position du personnage
# 3 = sortie du labyrinthe

using DataStructures
using Random


function grille(l, c)
    return ones(Int, 2*l + 1, 2*c + 1)
end


function verif(ligne, colonne, L, C)
    return ligne < 1 || ligne > L || colonne < 1 || colonne > C
end


function deplacement!(position, labyrinthe, direction)
    ligne, colonne = position
    L, C = size(labyrinthe)

    nouvelle_ligne = ligne
    nouvelle_colonne = colonne

    direction = uppercase(strip(direction))

    if direction == "H" # Haut
        nouvelle_ligne -= 1

    elseif direction == "B" # Bas
        nouvelle_ligne += 1

    elseif direction == "A" # Avancer
        nouvelle_colonne += 1

    elseif direction == "R" # Reculer
        nouvelle_colonne -= 1

    else
        println("Direction inconnue")
        return labyrinthe, ligne, colonne
    end

    if verif(nouvelle_ligne, nouvelle_colonne, L, C)
        println("Pas possible : hors de la grille")
        return labyrinthe, ligne, colonne

    elseif labyrinthe[nouvelle_ligne, nouvelle_colonne] == 1
        println("Pas possible : obstacle")
        return labyrinthe, ligne, colonne
    end

    if labyrinthe[nouvelle_ligne, nouvelle_colonne] == 3
        println("Bravo c'est la sortie !")
    end

    labyrinthe[ligne, colonne] = 0

    if labyrinthe[nouvelle_ligne, nouvelle_colonne] != 3
        labyrinthe[nouvelle_ligne, nouvelle_colonne] = 2
    end

    return labyrinthe, nouvelle_ligne, nouvelle_colonne
end


function creer_lab(l, c)
    labyrinthe = grille(l, c)
    ensemble = IntDisjointSet(l * c)
    index(x, y) = (y - 1) * c + x

    for y in 1:l, x in 1:c
        labyrinthe[2*y, 2*x] = 0
    end

    murs = Tuple{Tuple{Int,Int},Tuple{Int,Int}}[]

    for y in 1:l, x in 1:c
        if x < c
            push!(murs, ((x, y), (x + 1, y)))
        end

        if y < l
            push!(murs, ((x, y), (x, y + 1)))
        end
    end

    shuffle!(murs)

    for ((x1, y1), (x2, y2)) in murs
        i1 = index(x1, y1)
        i2 = index(x2, y2)

        if !in_same_set(ensemble, i1, i2)
            union!(ensemble, i1, i2)
            labyrinthe[y1 + y2, x1 + x2] = 0
        end
    end

    # Joueur
    labyrinthe[2, 2] = 2

    # Sortie
    labyrinthe[2*l, 2*c] = 3

    return labyrinthe
end
