# 0 = case vide
# 1 = mur
# 2 = joueur
# 3 = sortie

using DataStructures
using Random


# Crée une grille remplie de murs
function grille(l, c)
    return ones(Int, 2*l + 1, 2*c + 1)
end

# Vérifie si une position sort de la grille
function verif(ligne, colonne, L, C)
    return ligne < 1 || ligne > L || colonne < 1 || colonne > C
end

# Déplace le joueur
function deplacement!(position, labyrinthe, direction)
    ligne, colonne = position
    L, C = size(labyrinthe)
    nouvelle_ligne = ligne
    nouvelle_colonne = colonne
    direction = uppercase(strip(direction))
    if direction == "H"
        nouvelle_ligne -= 1
    elseif direction == "B"
        nouvelle_ligne += 1
    elseif direction == "A"
        nouvelle_colonne += 1
    elseif direction == "R"
        nouvelle_colonne -= 1
    else
        println("Direction inconnue")
        return labyrinthe, ligne, colonne
    end

    # Vérifier qu'on reste dans la grille
    if verif(nouvelle_ligne, nouvelle_colonne, L, C)
        println("Pas possible : out of the grille")
        return labyrinthe, ligne, colonne
    end

    # Vérifier qu'il n'y a pas de mur
    if labyrinthe[nouvelle_ligne, nouvelle_colonne] == 1
        println("Pas possible : obstacle")
        return labyrinthe, ligne, colonne
    end

    # Ancienne case du joueur
    labyrinthe[ligne, colonne] = 0

    # Si la nouvelle case n'est pas la sortie, on place le joueur dessus
    if labyrinthe[nouvelle_ligne, nouvelle_colonne] != 3
        labyrinthe[nouvelle_ligne, nouvelle_colonne] = 2
    end

    return labyrinthe, nouvelle_ligne, nouvelle_colonne
end

# Création du labyrinthe avec Kruskal
function creer_lab(l, c)
    # Grille remplie de murs
    labyrinthe = grille(l, c)

    # Ensemble disjoint utilisé par Kruskal
    ensemble = IntDisjointSet(l * c)

    # Donne un numéro à chaque cellule
    index(x, y) = (y - 1) * c + x

    # Création des cellules vides
    for y in 1:l
        for x in 1:c
            labyrinthe[2*y, 2*x] = 0
        end
    end

    # Liste des murs entre les cellules
    murs = Tuple{
        Tuple{Int,Int},
        Tuple{Int,Int}
    }[]

    for y in 1:l
        for x in 1:c
            # Voisin à droite
            if x < c
                push!(murs, ((x, y), (x + 1, y)))
            end

            # Voisin en dessous
            if y < l
                push!(murs, ((x, y), (x, y + 1)))
            end
        end
    end

    # Mélange aléatoire des murs
    shuffle!(murs)

    # Algorithme de Kruskal
    for ((x1, y1), (x2, y2)) in murs
        i1 = index(x1, y1)
        i2 = index(x2, y2)
        
        # Si les cellules ne sont pas déjà reliées
        if !in_same_set(ensemble, i1, i2)
            # On les relie
            union!(ensemble, i1, i2)
            # On enlève le mur entre elles
            labyrinthe[y1 + y2, x1 + x2] = 0
        end
    end

    # Joueur
    labyrinthe[2, 2] = 2

    # Sortie
    labyrinthe[2*l, 2*c] = 3

    return labyrinthe
end
