using FileIO, MeshIO, WGLMakie, Bonito, GeometryBasics
using WGLMakie.Makie: Button

# Charger les modèles 3D avec leurs coordonnées de texture
function loadmodel(path::AbstractString)
    model = load(path; uvtype=Vec2f)
    return GeometryBasics.expand_faceviews(model)
end

# Dossier des modèles 3D
const MODELS = normpath(joinpath(@__DIR__, "..", "models"))
const TEXTURE = joinpath(MODELS, "mars", "textures")

Base.@kwdef struct DisplayTheme # Base.@kwdef permet d'affecter les valeurs sans respecter l'ordre
    title::String
    character::String
    exit::String
    obstacle::String
    ground::String
    background::String
    textcolor::String
end

const MODES = Dict(
    "nono le robot" => DisplayTheme(
        title = "MISSION MARS - Retour au vaisseau",
        character = joinpath(MODELS, "mars", "C1-10P_obj.obj"),
        exit = joinpath(MODELS, "mars", "UFO.obj"),
        obstacle = joinpath(MODELS, "mars", "Free_rock.obj"),
        ground = joinpath(MODELS, "mars", "sol_mars.obj"),
        background = joinpath(MODELS, "fonds", "mars.png"),
        textcolor = "#ffe4c2"),

    "sheep le mouton" => DisplayTheme(
        title = "LA FERME - Retour à la grange",
        character = joinpath(MODELS, "prairie", "Sheep.obj"),
        exit = joinpath(MODELS, "prairie", "BigBarn.obj"),
        obstacle = joinpath(MODELS, "prairie", "HayStack.obj"),
        ground = joinpath(MODELS, "prairie", "sol_prairie.obj"),
        background = joinpath(MODELS, "fonds", "prairie.png"),
        textcolor = "#E8F5D0"),

    "carine la citadine" => DisplayTheme(
        title = "LA VILLE - Retour à la maison",
        character = joinpath(MODELS, "ville", "voiture.obj"),
        exit = joinpath(MODELS, "ville", "maison.obj"),
        obstacle = joinpath(MODELS, "ville", "muret_ville.obj"),
        ground = joinpath(MODELS, "ville", "sol_ville.obj"),
        background = joinpath(MODELS, "fonds", "ville.png"),
        textcolor = "#D6E4F5"),
)

const KEYMAP = Dict(
    Keyboard.up => :up,
    Keyboard.down => :down,
    Keyboard.left => :left,
    Keyboard.right => :right,
)

const MeshModel = Union{GeometryBasics.Mesh, GeometryBasics.MetaMesh}

function view(lscene::LScene, grid::AbstractMatrix{<:Integer}, charmodel::MeshModel, exitmodel::MeshModel, obstaclemodel::MeshModel, groundmodel::MeshModel)
    # Effacer les dessins de la partie précédente
    for drawing in copy(lscene.scene.plots)
        delete!(lscene, drawing)
    end
    nrows, ncols = size(grid)

    # Le sol du labyrinthe
    ground = mesh!(lscene, groundmodel)
    scale!(ground, ncols+1, nrows+1, 1)
    translate!(ground, 0, -nrows-1, -0.02)

    obstacles = []
    for row in 1:nrows, col in 1:ncols
        if grid[row, col] == 1
            obstacle = mesh!(lscene, obstaclemodel)     # modèle (obstaclemodel) -> dessin (obstacle)
            scale!(obstacle, 1, 1, 3)
            translate!(obstacle, col, -row, 0.02)
            push!(obstacles, obstacle)
        end
    end

    goal = mesh!(lscene, exitmodel)
    translate!(goal, ncols-1, -(nrows-1), 0.16)
    player = mesh!(lscene, charmodel)
    translate!(player, 2, -2, 0.04)
    center!(lscene.scene, 0.06)

    return player, goal, obstacles
end

# Faire fonctionner les touches du clavier pour le déplacement du player
function bind!(callback::Function, fig::Figure)
    on(events(fig).keyboardbutton; priority=10) do event
        if haskey(KEYMAP, event.key)
            if event.action == Keyboard.press
                callback(KEYMAP[event.key])
            end
            return Consume(true)
        end
        return Consume(false)
    end
end

function view(rows::Int, cols::Int, theme::DisplayTheme; back=nothing)
    if rows < 2 || cols < 2 || rows > 20 || cols > 20
        error("Choisissez entre 2 et 20 rows et cols.")
    end

    WGLMakie.activate!(; use_html_widgets=false)

    charmodel = loadmodel(theme.character)
    exitmodel = loadmodel(theme.exit)
    obstaclemodel = loadmodel(theme.obstacle)
    groundmodel = loadmodel(theme.ground)

    # La map et tous les boutons
    fontpath = WGLMakie.Makie.assetpath("fonts", "NotoSans-Regular.ttf")
    fig = Figure(size=(1100, 800), backgroundcolor=:transparent, fonts=(regular=fontpath,))

    toplayout = GridLayout(fig[1, 0:4])
    Label(toplayout[1, 1:2], theme.title, fontsize=28, color=theme.textcolor)
    menubutton = Button(toplayout[2, 1], label="Retour au menu", buttoncolor="#d6a477")
    recenterbutton = Button(toplayout[2, 2], label="recenter", buttoncolor="#d6a477")

    lscene = LScene(fig[2, 1:3], show_axis=false)
    cam3d!(lscene.scene, eyeposition=(0, -1, 2))

    leftlayout = GridLayout(fig[2, 0], height=260, valign=:center)
    Label(leftlayout[1, 1], "Nombre de coups", color=theme.textcolor, fontsize=17)
    movelabel = Label(leftlayout[2, 1], "0", color="#d6a477", fontsize=32)
    Label(leftlayout[3, 1], "Nb. coups min", color=theme.textcolor, fontsize=17)
    bestlabel = Label(leftlayout[4, 1], "0", color="#d6a477", fontsize=32)
    newgamebutton = Button(leftlayout[5, 1], label="Nouvelle partie", buttoncolor="#d6a477")

    rightlayout = GridLayout(fig[2, 4], height=130, valign=:center)
    hintbutton = Button(rightlayout[1, 1], label="Indice +1", buttoncolor="#d6a477", height=42)
    pathbutton = Button(rightlayout[2, 1], label="Solution", buttoncolor="#d6a477", height=42)

    colsize!(fig.layout, 0, 155)
    colsize!(fig.layout, 4, 125)
    colgap!(fig.layout, 12)
    rowsize!(fig.layout, 2, Auto(false))

    bottomlayout = GridLayout(fig[3, 0:4])
    message = Label(bottomlayout[1, 1:5], "Rejoignez la sortie !", color=theme.textcolor, fontsize=18)
    Label(bottomlayout[2, 1:5], "Déplacements : Avancer (→), Reculer (←), Haut (↑), Bas (↓) | Souris : tourner | Molette : zoomer", color=:white, fontsize=14)

    maze = Maze(rows, cols)
    state = GameState((2, 2), 0, false)
    bestmoves = optimalmoves(maze.grid, (2, 2), (2*maze.rows, 2*maze.cols))
    player, goal, obstacles = view(lscene, maze.grid, charmodel, exitmodel, obstaclemodel, groundmodel)

    # Chemin optimal affiché par le bouton solution
    showpath = false
    pathpoints = Observable(Point3f[])
    lines!(lscene, pathpoints, color=:cyan, linewidth=5)


    # Afficher les coups et vérifier la victoire et le chemin
    function refresh!()
        movelabel.text[] = string(state.moves)
        bestlabel.text[] = string(bestmoves)

        if state.win
            message.text[] = "VICTOIRE ! Vous avez rejoint la sortie."
            showpath = false
        else
            message.text[] = "Rejoignez la sortie !"
        end

        points = Point3f[]

        if showpath
            path = optimalpath(maze.grid, state.position, (2*maze.rows, 2*maze.cols))

            for (row, col) in path
                push!(points, Point3f(col, -row, 0.06))
            end
        end

        pathpoints[] = points

        if showpath
            pathbutton.label[] = "Masquer"
        else
            pathbutton.label[] = "Solution"
        end
    end


    # Déplacer le player
    function move!(direction::Symbol)
        if state.win
            return
        end

        previous_position = state.position
        row, col = applymove!(maze.grid, state.position, direction)

        if (row, col) == previous_position
            return
        end

        state.position = (row, col)
        state.moves += 1

        # Tourner/Rotation du player en fct de la direction
        if direction == :up
            rotate!(player, Vec3f(0,0,1), 0)
        elseif direction == :right
            rotate!(player, Vec3f(0,0,1), -pi/2)
        elseif direction == :down
            rotate!(player, Vec3f(0,0,1), pi)
        elseif direction == :left
            rotate!(player, Vec3f(0,0,1), pi/2)
        end

        translate!(player, col, -row, 0.04)

        # Le player disparaît à la sortie
        if row == 2*maze.rows && col == 2*maze.cols
            state.win = true
            player.visible[] = false
        end

        refresh!()
    end


    # Avancer d'une case avec l'indice +1
    function hint!()
        if state.win
            return
        end

        path = optimalpath(maze.grid, state.position, (2*maze.rows, 2*maze.cols))

        if length(path) < 2
            return
        end

        row, col = state.position
        nextrow, nextcol = path[2]

        if nextrow < row
            move!(:up)
        elseif nextrow > row
            move!(:down)
        elseif nextcol < col
            move!(:left)
        else
            move!(:right)
        end
    end


    # Afficher ou masquer le chemin
    function togglepath!()
        if state.win
            return
        end

        showpath = !showpath
        refresh!()
    end


    # On remet la caméra au départ
    function recenter!()
        cam3d!(lscene.scene, eyeposition=(0, -1, 2))
        center!(lscene.scene, 0.06)
    end


    # Nouveau labyrinthe
    function restart!()
        maze.grid = generategrid(maze.rows, maze.cols)
        state.position = (2, 2)
        state.moves = 0
        state.win = false
        showpath = false
        bestmoves = optimalmoves(maze.grid, (2, 2), (2*maze.rows, 2*maze.cols))

        # Replacer les obstacles
        nrows, ncols = size(maze.grid)
        index = 1
        for row in 1:nrows, col in 1:ncols
            if maze.grid[row, col] == 1
                translate!(obstacles[index], col, -row, 0.02)
                index += 1
            end
        end

        # Remettre le player au départ
        translate!(player, 2, -2, 0.04)
        rotate!(player, Vec3f(0,0,1), 0)
        player.visible[] = true

        recenter!()
        refresh!()
    end


    # Retourne à l'accueil
    function home!()
        if back !== nothing
            back()
        else
            message.text[] = "Le menu n'est pas encore relié."
        end
    end

    # Relie les boutons
    on(recenterbutton.clicks) do _
        recenter!()
    end

    on(newgamebutton.clicks) do _
        restart!()
    end

    on(menubutton.clicks) do _
        home!()
    end

    on(hintbutton.clicks) do _
        hint!()
    end

    on(pathbutton.clicks) do _
        togglepath!()
    end

    bind!(move!, fig)

    refresh!()

    return fig
end