
include("grille.jl")
include("jeu.jl")

function main()
    L = 6
    C = 8

    joueur = (1, 1)
    sortie = (L, C)

    # aucun chemin valide n'a encore été trouvé (-1 pour inconnu)
    optimal = -1

    grille = creer_grille(L, C)

    # On régénére une grille jusqu'à trouver une solution
    while optimal == -1
        grille = creer_grille(L, C)

        grille[1, 1] = 3
        grille[L, C] = 2

        ajouter_obstacles(grille, joueur, sortie)
        # Calcul de le chemin opti
        optimal = distance_optimale(grille, joueur, sortie)
    end

    coups = 0

    println("Grille de départ :")
    display(grille)

    println()
    println("Position du joueur : ", joueur)
    println("Nombre optimal de déplacements : ", optimal)
    println("Coups : ", coups)

    # Boucle de déplacement jusqu'à atteindre la sortie
    while joueur != sortie

        println()
        println("Choose une direction :")
        println("1 = avancer")
        println("2 = reculer")
        println("3 = haut")
        println("4 = bas")
        println()

        choix = readline()
        ancienne_position = joueur

        if choix == "1"
            joueur = avancer(grille, joueur)

        elseif choix == "2"
            joueur = reculer(grille, joueur)

        elseif choix == "3"
            joueur = haut(grille, joueur)

        elseif choix == "4"
            joueur = bas(grille, joueur)

        else
            println("Choix pas good")
            continue
        end

        # On compte seulement si le joueur a vraiment bougé
        if joueur != ancienne_position
            coups += 1
        else
            println("Déplacement impossible")
        end

        println()
        display(grille)

        println("Position : ", joueur)
        println("Coups : ", coups)
        println("Optimal : ", optimal)
    end

    println()
    println("Sortie atteinte")
    println("Nombre de coups : ", coups)
    println("Optimal : ", optimal)

end

main()