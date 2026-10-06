using GLMakie
using FileIO
using MeshIO

function afficher_labyrinthe(zone, labyrinthe, modele_robot, modele_vaisseau, modele_rocher, modele_sol)
    # Effacer les dessins de la partie précédente
    for dessin in copy(zone.scene.plots)
        delete!(zone, dessin)
    end
    L, C = size(labyrinthe)

    # Le sol, les rochers de l'arrièere plan est dans sol_mars.obj
    sol = mesh!(zone, modele_sol)
    scale!(sol, C+1, L+1, 1)
    translate!(sol, 0, -L-1, -0.02)

    # Un rocher sur chaque case contenant un mur
    for ligne in 1:L
        for colonne in 1:C
            if labyrinthe[ligne, colonne] == 1
                rocher = mesh!(zone, modele_rocher)
                translate!(rocher, colonne, -ligne, 0.02)
            end
        end
    end

    vaisseau = mesh!(zone, modele_vaisseau)
    translate!(vaisseau, C-1, -(L-1), 0.16)
    robot = mesh!(zone, modele_robot)
    translate!(robot, 2, -2, 0.04)
    center!(zone.scene)
    zoom!(zone.scene, 0.75)
    return robot, vaisseau
end

function affichage_3D()
    modele_robot = load("models/C1-10P_obj.obj")
    modele_vaisseau = load("models/UFO.obj")
    modele_rocher = load("models/Free_rock.obj")
    modele_sol = load("models/sol_mars.obj")

    fig = Figure(size=(1100, 800), backgroundcolor="#281914")
    Label(fig[1, 1], "MISSION MARS — Retour au vaisseau", fontsize=28, color="#ffe4c2")
    zone = LScene(fig[2, 1], show_axis=false)
    cam3d!(zone.scene, eyeposition=(0, -1, 2))

    labyrinthe = creer_lab(10, 10)
    robot, vaisseau = afficher_labyrinthe(zone, labyrinthe, modele_robot, modele_vaisseau, modele_rocher, modele_sol)

    fenetre = display(fig)
    zoom!(zone.scene, 0.75)
    wait(fenetre)
end
