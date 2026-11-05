import Pkg
Pkg.activate(@__DIR__)
Pkg.instantiate()

include("Labyrinthe.jl")
using .Labyrinthe
using Bonito

# Lancer le jeu sur le navigateur
port = 8766
serveur = Bonito.Server(mode_jeu(), "127.0.0.1", port)

println("Jeu disponible sur http://127.0.0.1:$port")
wait(serveur)   # garde le programme actif