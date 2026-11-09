using FileIO, MeshIO, WGLMakie, Bonito, GeometryBasics
using WGLMakie.Makie: Button
using FileIO, MeshIO, WGLMakie, Bonito, GeometryBasics
using WGLMakie.Makie: Button

# Charger les modèles 3D avec leurs coordonnées de texture
function loadmodel(chemin::AbstractString)
    model = load(chemin; uvtype=Vec2f)
    return GeometryBasics.expand_faceviews(model)
end

Base.@kwdef struct Modele_affichage # Base.@kwdef permet d'affecter les valeur sans respect l'ordre 
    titre::String
    chara::String
    exit::String
    obst::String
    ground::String
    fond::String
    col_txt::String
end

# Dossier des modèles 3D
const MODELS = normpath(joinpath(@__DIR__, "..", "models"))
const TEXTURE= joinpath(MODELS, "mars", "textures")

Base.@kwdef struct Modele_affichage # Base.@kwdef permet d'affecter les valeur sans respect l'ordre 
    titre::String
    chara::String
    exit::String
    obst::String
    ground::String
    fond::String
    col_txt::String
end

const MODES = Dict(
    "nono le robot" => Modele_affichage(
        titre = "MISSION MARS - Retour au vaisseau",
        chara = joinpath(MODELS, "mars", "C1-10P_obj.obj"),
        exit = joinpath(MODELS, "mars", "UFO.obj"),
        obst = joinpath(MODELS, "mars", "Free_rock.obj"),
        ground = joinpath(MODELS, "mars", "sol_mars.obj"),
        fond = joinpath(MODELS, "fonds", "mars.png"),
        col_txt = "#ffe4c2"),

    "sheep le mouton" => Modele_affichage(
        titre = "LA FERME - Retour à la grange",
        chara = joinpath(MODELS, "prairie", "Sheep.obj"),
        exit = joinpath(MODELS, "prairie", "BigBarn.obj"),
        obst = joinpath(MODELS, "prairie", "HayStack.obj"),
        ground = joinpath(MODELS, "prairie", "sol_prairie.obj"),
        fond = joinpath(MODELS, "fonds", "prairie.png"),
        col_txt = "#E8F5D0"),

    "carine la citadine" => Modele_affichage(
        titre = "LA VILLE - Retour à la maison",
        chara = joinpath(MODELS, "ville", "voiture.obj"),
        exit = joinpath(MODELS, "ville", "maison.obj"),
        obst = joinpath(MODELS, "ville", "muret_ville.obj"),
        ground = joinpath(MODELS, "ville", "sol_ville.obj"),
        fond = joinpath(MODELS, "fonds", "ville.png"),
        col_txt = "#D6E4F5"),
)

const keymap = Dict(
    Keyboard.up => "H",
    Keyboard.down => "B",
    Keyboard.left => "R",
    Keyboard.right => "A",
)
const Mod = Union{GeometryBasics.Mesh, GeometryBasics.MetaMesh}
function view(lscene :: LScene, maze:: AbstractMatrix{<:Integer}, charmodel :: Mod ,exitmodel::Mod, obstmodel:: Mod , groundmodel::Mod)
    # Effacer les dessins de la partie précédente
    for dessin in copy(lscene.scene.plots)
        delete!(lscene, dessin)
    end
    L, C = size(maze)

    # Le ground du maze
    ground = mesh!(lscene, groundmodel)
    scale!(ground, C+1, L+1, 1)
    translate!(ground, 0, -L-1, -0.02)

    obstacles = []
    for row in 1:L, col in 1:C
        if maze[row, col] == 1
            obs = mesh!(lscene, obstmodel)     # modèle (obstmodel) -> dessin (obs)
            scale!(obs, 1, 1, 3)
            translate!(obs, col, -row, 0.02)
            push!(obstacles, obs)
        end
    end

    goal = mesh!(lscene, exitmodel)
    translate!(goal, C-1, -(L-1), 0.16)
    player = mesh!(lscene, charmodel)
    translate!(player, 2, -2, 0.04)
    center!(lscene.scene, 0.06)

    return player, goal, obstacles
end

# Faire fonctionner les touches du clavier pour le déplacement du player
function bind!(callback::Function, fig:: Figure)
    on(events(fig).keyboardbutton; priority=10) do event
        if haskey(keymap, event.key)
            if event.action == Keyboard.press
                callback(keymap[event.key])
            end
            return Consume(true)
        end
        return Consume(false)
    end
end

function view(rows::Int, cols::Int, theme::Modele_affichage; back=nothing) 
    if rows < 2 || cols < 2 || rows > 20 || cols > 20
        error("Choisissez entre 2 et 20 rows et cols.")
    end

    WGLMakie.activate!(; use_html_widgets=false)

    charannage = loadmodel(theme.chara)
    exitmodel = loadmodel(theme.exit)
    obstmodel = loadmodel(theme.obst)
    ground = loadmodel(theme.ground)

    # La map et tous les boutons
    police = WGLMakie.Makie.assetpath("fonts", "NotoSans-Regular.ttf")
    fig = Figure(size=(1100, 800), backgroundcolor=:transparent, fonts=(regular=police,))

    haut = GridLayout(fig[1, 0:4])
    Label(haut[1, 1:2], theme.titre, fontsize=28, color=theme.col_txt)
    menu = Button(haut[2, 1], label="Retour au menu", buttoncolor="#d6a477")
    recenter = Button(haut[2, 2], label="recenter", buttoncolor="#d6a477")

    lscene = LScene(fig[2, 1:3], show_axis=false)
    cam3d!(lscene.scene, eyeposition=(0, -1, 2))

    gauche = GridLayout(fig[2, 0], height=260, valign=:center)
    Label(gauche[1, 1], "Nombre de coups", color=theme.col_txt, fontsize=17)
    score = Label(gauche[2, 1], "0", color="#d6a477", fontsize=32)
    Label(gauche[3, 1], "Nb. coups min", color=theme.col_txt, fontsize=17)
    bestlabel = Label(gauche[4, 1], "0", color="#d6a477", fontsize=32)
    nouveau = Button(gauche[5, 1], label="Nouvelle partie", buttoncolor="#d6a477")

    droite = GridLayout(fig[2, 4], height=130, valign=:center)
    hint = Button(droite[1, 1], label="hint +1", buttoncolor="#d6a477", height=42)
    togglepath = Button(droite[2, 1], label="togglepath", buttoncolor="#d6a477", height=42)

    colsize!(fig.layout, 0, 155)
    colsize!(fig.layout, 4, 125)
    colgap!(fig.layout, 12)
    rowsize!(fig.layout, 2, Auto(false))

    bas = GridLayout(fig[3, 0:4])
    message = Label(bas[1, 1:5], "Rejoignez la sortie !", color=theme.col_txt, fontsize=18)
    Label(bas[2, 1:5], "Déplacements : Avancer (→), Reculer (←), Haut (↑), Bas (↓) | Souris : tourner | Molette : zoomer", color=:white, fontsize=14)

    maze = creer_lab(rows, cols)
    etat = EtatJeu((2, 2), 0, false)
    optimal = coups_optimaux(maze, (2, 2), (2*rows, 2*cols))
    player, goal, obstacles = view(lscene, maze, charannage, exitmodel, obstmodel, ground)

    # Chemin de la togglepath optimale
    montrer_solution = false
    points_solution = Observable(Point3f[])
    lines!(lscene, points_solution, color=:cyan, linewidth=5)


    # Afficher les coups et vérifier la victoire et la togglepath
    function refresh!()
        score.text[] = string(etat.coups)
        bestlabel.text[] = string(optimal)

        if etat.victoire
            message.text[] = "VICTOIRE ! Vous avez rejoint la sortie."
            montrer_solution = false
        else
            message.text[] = "Rejoignez la sortie !"
        end

        points = Point3f[]

        if montrer_solution
            chemin = chemin_optimal(maze, etat.position, (2*rows, 2*cols))

            for (row, col) in chemin
                push!(points, Point3f(col, -row, 0.06))
            end
        end

        points_solution[] = points

        if montrer_solution
            togglepath.label[] = "Masquer"
        else
            togglepath.label[] = "togglepath"
        end
    end


    #Déplacer le player
    function move!(direction)
        if direction == "" || etat.victoire
            return
        end

        ancienne_position = etat.position
        maze, row, col = deplacement!(etat.position, maze, direction)

        if (row, col) == ancienne_position
            return
        end

        etat.position = (row, col)
        etat.coups += 1

        # Tourner/Rotation du player en fct de la direction
        if direction == "H"
            rotate!(player, Vec3f(0,0,1), 0)
        elseif direction == "A"
            rotate!(player, Vec3f(0,0,1), -pi/2)
        elseif direction == "B"
            rotate!(player, Vec3f(0,0,1), pi)
        elseif direction == "R"
            rotate!(player, Vec3f(0,0,1), pi/2)
        end

        translate!(player, col, -row, 0.04)

        # Le player disparaît à la sortie
        L, C = size(maze)
        if row == L-1 && col == C-1
            etat.victoire = true
            player.visible[] = false
        end

        refresh!()
    end


    # Avancer d'une case avec hint +1
    function hint!()
        if etat.victoire
            return
        end

        chemin = chemin_optimal(maze, etat.position, (2*rows, 2*cols))

        if length(chemin) < 2
            return
        end

        row, col = etat.position
        prochaine_ligne, prochaine_colonne = chemin[2]

        if prochaine_ligne < row
            move!("H")
        elseif prochaine_ligne > row
            move!("B")
        elseif prochaine_colonne < col
            move!("R")
        else
            move!("A")
        end
    end


    # Afficher ou masquer la togglepath
    function togglepath!()
        if etat.victoire
            return
        end

        montrer_solution = !montrer_solution
        refresh!()
    end


    # On remet la caméra au départ
    function recenter!()
        cam3d!(lscene.scene, eyeposition=(0, -1, 2))
        center!(lscene.scene, 0.06)
    end


    # Nouveau maze
    function restart!()
        maze = creer_lab(rows, cols)
        etat.position = (2, 2)
        etat.coups = 0
        etat.victoire = false
        montrer_solution = false
        optimal = coups_optimaux(maze, (2, 2), (2*rows, 2*cols))

        # Replacer les obstacles
        L, C = size(maze)
        numero = 1
        for row in 1:L, col in 1:C
            if maze[row, col] == 1
                translate!(obstacles[numero], col, -row, 0.02)
                numero += 1
            end
        end

        # Remettre le player au départ
        translate!(player, 2, -2, 0.04)
        rotate!(player, Vec3f(0,0,1), 0)
        player.visible[] = true

        recenter!()
        refresh!()
    end


    #Retourne à l'accueil
    function home!()
        if back !== nothing
            back()
        else
            message.text[] = "Le menu n'est pas encore relié."
        end
    end

    # Relie les boutons
    on(recenter.clicks) do _
        recenter!()
    end

    on(nouveau.clicks) do _
        restart!()
    end

    on(menu.clicks) do _
        home!()
    end

    on(hint.clicks) do _
        hint!()
    end

    on(togglepath.clicks) do _
        togglepath!()
    end

    bind!(move!, fig)

    refresh!()

    return fig
end
