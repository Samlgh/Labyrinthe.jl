using FileIO, MeshIO, WGLMakie, Bonito, GeometryBasics
using WGLMakie.Makie: Button

# Charger les modèles 3D avec leurs coordonnées de texture
function charger_modele(chemin)
    modele = load(chemin; uvtype=Vec2f)
    return GeometryBasics.expand_faceviews(modele)
end

# Dossier des modèles 3D
const dossier_models = normpath(joinpath(@__DIR__, "..", "models"))
const dossier_textures = joinpath(dossier_models, "textures")

Base.@kwdef struct Modele_affichage # Base.@kwdef permet d'affecter les valeur sans respect l'ordre 
    titre::String
    modele_perso::String
    modele_sorti::String
    modele_obs::String
    modele_sol::String
    coul_texte::String
    coul_fond::String
end

const MODES = Dict(
    "nono le robot" => Modele_affichage(
        titre = "MISSION MARS - Retour au vaisseau",
        modele_perso = joinpath(dossier_models, "C1-10P_obj.obj"),
        modele_sorti = joinpath(dossier_models, "UFO.obj"),
        modele_obs = joinpath(dossier_models, "Free_rock.obj"),
        modele_sol = joinpath(dossier_models, "sol_mars.obj"),
        coul_texte = "#ffe4c2", coul_fond = "#281914"),

    "sheep le mouton" => Modele_affichage(
        titre = "LA PRAIRIE - Retour à l'enclos",
        modele_perso = joinpath(dossier_models, "C1-10P_obj.obj"),
        modele_sorti = joinpath(dossier_models, "UFO.obj"),
        modele_obs = joinpath(dossier_models, "Free_rock.obj"),
        modele_sol = joinpath(dossier_models, "sol_mars.obj"),
        coul_texte = "#E8F5D0", coul_fond = "#1B3A1B"),

    "carine la citadine" => Modele_affichage(
        titre = "LA VILLE - Retour à la maison",
        modele_perso = joinpath(dossier_models, "C1-10P_obj.obj"),
        modele_sorti = joinpath(dossier_models, "UFO.obj"),
        modele_obs = joinpath(dossier_models, "Free_rock.obj"),
        modele_sol = joinpath(dossier_models, "sol_mars.obj"),
        coul_texte = "#D6E4F5", coul_fond = "#1E2A3A"),
)

const touche_clavier = Dict(
    Keyboard.up => "H",
    Keyboard.down => "B",
    Keyboard.left => "R",
    Keyboard.right => "A",
)


function afficher_labyrinthe(zone, labyrinthe, modele_robot, modele_vaisseau, modele_rocher, modele_sol)
    # Effacer les dessins de la partie précédente
    for dessin in copy(zone.scene.plots)
        delete!(zone, dessin)
    end
    L, C = size(labyrinthe)

    # Le sol du labyrinthe
    sol = mesh!(zone, modele_sol)
    scale!(sol, C+1, L+1, 1)
    translate!(sol, 0, -L-1, -0.02)

    # Afficher les rochers avec leurs textures
    rochers = []
    for ligne in 1:L
        for colonne in 1:C
            if labyrinthe[ligne, colonne] == 1
                rocher = mesh!(zone, modele_rocher)
                scale!(rocher, 1, 1, 3)
                translate!(rocher, colonne, -ligne, 0.02)
                push!(rochers, rocher)
            end
        end
    end

    vaisseau = mesh!(zone, modele_vaisseau)
    translate!(vaisseau, C-1, -(L-1), 0.16)
    robot = mesh!(zone, modele_robot)
    translate!(robot, 2, -2, 0.04)
    center!(zone.scene, 0.06)

    return robot, vaisseau, rochers
end

# Faire fonctionner les touches du clavier pour le déplacement du robot
function brancher_clavier!(quand_direction, fig)
    on(events(fig).keyboardbutton; priority=10) do event
        if haskey(touche_clavier, event.key)
            if event.action == Keyboard.press
                quand_direction(touche_clavier[event.key])
            end
            return Consume(true)
        end
        return Consume(false)
    end
end


function affichage_3D(lignes::Int, colonnes::Int, aff::Modele_affichage; retour_menu=nothing)
    if lignes < 2 || colonnes < 2 || lignes > 20 || colonnes > 20
        error("Choisissez entre 2 et 20 lignes et colonnes.")
    end

    WGLMakie.activate!(; use_html_widgets=false)

    modele_robot = charger_modele(aff.modele_perso)
    modele_vaisseau = charger_modele(aff.modele_sorti)
    modele_rocher = charger_modele(aff.modele_obs)
    modele_sol = charger_modele(aff.modele_sol)

    # La map et tous les boutons
    police = WGLMakie.Makie.assetpath("fonts", "NotoSans-Regular.ttf")
    fig = Figure(size=(1100, 800), backgroundcolor=aff.coul_fond, fonts=(regular=police,))

    haut = GridLayout(fig[1, 0:4])
    Label(haut[1, 1:2], aff.titre, fontsize=28, color=aff.coul_texte)
    menu = Button(haut[2, 1], label="Retour au menu", buttoncolor="#d6a477")
    cadrer = Button(haut[2, 2], label="Cadrer", buttoncolor="#d6a477")

    zone = LScene(fig[2, 1:3], show_axis=false)
    cam3d!(zone.scene, eyeposition=(0, -1, 2))

    gauche = GridLayout(fig[2, 0], height=260, valign=:center)
    Label(gauche[1, 1], "Nombre de coups", color=aff.coul_texte, fontsize=17)
    score = Label(gauche[2, 1], "0", color="#d6a477", fontsize=32)
    Label(gauche[3, 1], "Nb. coups min", color=aff.coul_texte, fontsize=17)
    minimum = Label(gauche[4, 1], "0", color="#d6a477", fontsize=32)
    nouveau = Button(gauche[5, 1], label="Nouvelle partie", buttoncolor="#d6a477")

    droite = GridLayout(fig[2, 4], height=130, valign=:center)
    indice = Button(droite[1, 1], label="Indice +1", buttoncolor="#d6a477", height=42)
    solution = Button(droite[2, 1], label="Solution", buttoncolor="#d6a477", height=42)

    colsize!(fig.layout, 0, 155)
    colsize!(fig.layout, 4, 125)
    colgap!(fig.layout, 12)
    rowsize!(fig.layout, 2, Auto(false))

    bas = GridLayout(fig[3, 0:4])
    message = Label(bas[1, 1:5], "Rejoignez la sortie !", color=aff.coul_texte, fontsize=18)
    Label(bas[2, 1:5], "Déplacements : Avancer (→), Reculer (←), Haut (↑), Bas (↓) | Souris : tourner | Molette : zoomer", color=:white, fontsize=14)

    labyrinthe = creer_lab(lignes, colonnes)
    etat = EtatJeu((2, 2), 0, false)
    optimal = coups_optimaux(labyrinthe, (2, 2), (2*lignes, 2*colonnes))
    robot, vaisseau, rochers = afficher_labyrinthe(zone, labyrinthe, modele_robot, modele_vaisseau, modele_rocher, modele_sol)

    # Chemin de la solution optimale
    montrer_solution = false
    points_solution = Observable(Point3f[])
    lines!(zone, points_solution, color=:cyan, linewidth=5)


    # Afficher les coups et vérifier la victoire et la solution
    function actualiser!()
        score.text[] = string(etat.coups)
        minimum.text[] = string(optimal)

        if etat.victoire
            message.text[] = "VICTOIRE ! Vous avez rejoint la sortie."
            montrer_solution = false
        else
            message.text[] = "Rejoignez la sortie !"
        end

        points = Point3f[]

        if montrer_solution
            chemin = chemin_optimal(labyrinthe, etat.position, (2*lignes, 2*colonnes))

            for (ligne, colonne) in chemin
                push!(points, Point3f(colonne, -ligne, 0.06))
            end
        end

        points_solution[] = points

        if montrer_solution
            solution.label[] = "Masquer"
        else
            solution.label[] = "Solution"
        end
    end


    #Déplacer le robot
    function deplacer!(direction)
        if direction == "" || etat.victoire
            return
        end

        ancienne_position = etat.position
        labyrinthe, ligne, colonne = deplacement!(etat.position, labyrinthe, direction)

        if (ligne, colonne) == ancienne_position
            return
        end

        etat.position = (ligne, colonne)
        etat.coups += 1

        # Tourner/Rotation du robot en fct de la direction
        if direction == "H"
            rotate!(robot, Vec3f(0,0,1), 0)
        elseif direction == "A"
            rotate!(robot, Vec3f(0,0,1), -pi/2)
        elseif direction == "B"
            rotate!(robot, Vec3f(0,0,1), pi)
        elseif direction == "R"
            rotate!(robot, Vec3f(0,0,1), pi/2)
        end

        translate!(robot, colonne, -ligne, 0.04)

        # Le robot disparaît à la sortie
        L, C = size(labyrinthe)
        if ligne == L-1 && colonne == C-1
            etat.victoire = true
            robot.visible[] = false
        end

        actualiser!()
    end


    # Avancer d'une case avec Indice +1
    function indice!()
        if etat.victoire
            return
        end

        chemin = chemin_optimal(labyrinthe, etat.position, (2*lignes, 2*colonnes))

        if length(chemin) < 2
            return
        end

        ligne, colonne = etat.position
        prochaine_ligne, prochaine_colonne = chemin[2]

        if prochaine_ligne < ligne
            deplacer!("H")
        elseif prochaine_ligne > ligne
            deplacer!("B")
        elseif prochaine_colonne < colonne
            deplacer!("R")
        else
            deplacer!("A")
        end
    end


    # Afficher ou masquer la solution
    function solution!()
        if etat.victoire
            return
        end

        montrer_solution = !montrer_solution
        actualiser!()
    end


    # On remet la caméra au départ
    function cadrer!()
        cam3d!(zone.scene, eyeposition=(0, -1, 2))
        center!(zone.scene, 0.06)
    end


    # Nouveau labyrinthe
    function nouvelle_partie!()
        labyrinthe = creer_lab(lignes, colonnes)
        etat.position = (2, 2)
        etat.coups = 0
        etat.victoire = false
        montrer_solution = false
        optimal = coups_optimaux(labyrinthe, (2, 2), (2*lignes, 2*colonnes))

        # Replacer les rochers
        L, C = size(labyrinthe)
        numero = 1
        for ligne in 1:L
            for colonne in 1:C
                if labyrinthe[ligne, colonne] == 1
                    translate!(rochers[numero], colonne, -ligne, 0.02)
                    numero += 1
                end
            end
        end

        # Remettre le robot au départ
        translate!(robot, 2, -2, 0.04)
        rotate!(robot, Vec3f(0,0,1), 0)
        robot.visible[] = true

        cadrer!()
        actualiser!()
    end


    #Retourne à l'accueil
    function revenir_menu!()
        if retour_menu !== nothing
            retour_menu()
        else
            message.text[] = "Le menu n'est pas encore relié."
        end
    end

    # Relie les boutons
    on(cadrer.clicks) do _
        cadrer!()
    end

    on(nouveau.clicks) do _
        nouvelle_partie!()
    end

    on(menu.clicks) do _
        revenir_menu!()
    end

    on(indice.clicks) do _
        indice!()
    end

    on(solution.clicks) do _
        solution!()
    end

    brancher_clavier!(deplacer!, fig)

    actualiser!()

    return fig
end