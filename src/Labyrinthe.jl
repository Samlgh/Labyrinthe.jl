module Labyrinthe

# Charger les fichiers du projet
include("structure.jl")
include("jeu.jl")
include("interface.jl")
include("interface_web.jl")

export GameState, Maze, generategrid, applymove!, optimalpath, optimalmoves
export DisplayTheme, MODES, view, menu, play

end