# 0 = case vide
# 1 = obstacle
# 2 = sortie
# 3 = joueur

using Random

# Crée une grille L x C avec des cases vides (0)
function creer_grille(L, C)
    grille = zeros(Int, L, C)
    return grille
end

# Ajoute des obstacles aléatoires dans la grille, en évitant la position du joueur et la sortie
function ajouter_obstacles(grille, joueur, sortie)
    L, C = size(grille)
    # Environ 1/3 de la grille sera des obstacles
    nb_obstacles = div(L * C, 3)
    # Nombre de cases remplies par des obstacles
    obstacles_places = 0

    while obstacles_places < nb_obstacles

        ligne = rand(1:L)
        colonne = rand(1:C)

        position = (ligne, colonne)
        # Vérifie que la case est vide et qu'elle n'est pas la position du joueur ou de la sortie
        if grille[ligne, colonne] == 0 && position != joueur && position != sortie
            grille[ligne, colonne] = 1
            obstacles_places += 1
        end
    end
end