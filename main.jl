import Pkg
Pkg.activate(@__DIR__)

using Labyrinthe
using Bonito

# Lancer le jeu sur le navigateur
port = 8766
serveur = Bonito.Server(mode_jeu(), "127.0.0.1", port)

println("Ouvrez http://127.0.0.1:$port dans votre navigateur.")
println("Ctrl+C pour arrêter le serveur.")

try
    wait(serveur)
finally
    close(serveur)
end
