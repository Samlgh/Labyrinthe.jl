module Labyrinthe

# Charger les fichiers du projet
include("structure.jl")
include("jeu.jl")
include("interface.jl")
include("interface_web.jl")

export EtatJeu, creer_lab, deplacement!, chemin_optimal, coups_optimaux
export Modele_affichage, MODES, affichage_3D, interface_menue, mode_jeu

end