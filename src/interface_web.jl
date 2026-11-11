using FileIO, MeshIO, WGLMakie, Bonito, Base64, GeometryBasics
using WGLMakie.Makie: Textbox

function menu(startgame::Function, rows::Int=10, cols::Int=10, character::String="nono le robot")
    WGLMakie.activate!(; use_html_widgets=false)

    fig = Figure(size=(1100, 800), backgroundcolor="#F7F4EB", figure_padding=35)
    layout = fig[1, 1] = GridLayout()

    Label(layout[1, 1:3], "Bienvenue sur le labyrinthe\ndes Malicieux", fontsize=36, font=:bold, color="#10394B")
    Label(layout[2, 1:3], "Choisissez la taille du labyrinthe et votre personnage,\npuis lancez l'aventure !", fontsize=19, color="#737D86")

    # Les dimensions de la prochaine partie
    dimensions = GridLayout(layout[3, 1:3])
    Label(dimensions[1, 1], "Lignes", fontsize=20, color="#53616D")
    rowsbox = Textbox(dimensions[1, 2], stored_string=string(rows), validator=Int, width=110, height=45, fontsize=20, boxcolor="#FFFCF6", textcolor="#10394B")
    Label(dimensions[1, 3], "Colonnes", fontsize=20, color="#53616D")
    colsbox = Textbox(dimensions[1, 4], stored_string=string(cols), validator=Int, width=110, height=45, fontsize=20, boxcolor="#FFFCF6", textcolor="#10394B")

    Label(layout[4, 1:3], "Choisissez votre personnage", fontsize=24, font=:bold, color="#10394B")
    charnames = ["nono le robot", "sheep le mouton", "carine la citadine"]
    images = ["robot.png", "mouton.png", "voiture.png"]
    selected = Observable(character)
    buttons = []
    cards = []

    # Une carte par personnage
    for i in 1:3
        card = GridLayout(layout[5, i])
        cardbackground = Box(layout[5, i], color="#FFFCF6", strokecolor="#E5E1D8")
        push!(cards, cardbackground)
        imagepath = joinpath(MODELS, "menu", images[i])
        if isfile(imagepath)
            frame = Axis(card[1, 1], aspect=DataAspect(), backgroundcolor=:transparent)
            image!(frame, rotr90(load(imagepath)))
            hidedecorations!(frame)
            hidespines!(frame)
        else
            Label(card[1, 1], "", height=145)
        end
        button = Button(card[2, 1], label=charnames[i], fontsize=19, width=270, height=48, labelcolor="#10394B", buttoncolor="#ECE9E0")
        push!(buttons, button)
        on(button.clicks) do _
            selected[] = charnames[i]
        end
    end

    # La carte du personnage choisi devient bleue
    on(selected) do name
        for i in 1:3
            if charnames[i] == name
                cards[i].color[] = "#E5F4FF"
                cards[i].strokecolor[] = "#0099FF"
                buttons[i].buttoncolor[] = "#CDEBFF"
                buttons[i].labelcolor[] = "#0077CF"
            else
                cards[i].color[] = "#FFFCF6"
                cards[i].strokecolor[] = "#E5E1D8"
                buttons[i].buttoncolor[] = "#ECE9E0"
                buttons[i].labelcolor[] = "#10394B"
            end
        end
    end
    notify(selected)

    launchbutton = Button(layout[6, 1:3], label="Lancer", width=290, height=58, fontsize=25, buttoncolor="#0B4B61", labelcolor=:white)
    message = Label(layout[7, 1:3], "", color="#A33C35", fontsize=17)
    rowgap!(layout, 18)
    colgap!(layout, 22)
    rowsize!(layout, 5, 215)

    # Le clic dépose les paramètres dans un canal, le jeu démarre en dehors du callback
    channel = Channel{Tuple{Int,Int,String}}(1)
    # On évite de lancer deux parties par un double clic
    loading = false

    on(launchbutton.clicks) do _
        if loading
            return
        end
        # On lit les valeurs sans appuyer sur Entrée
        nrows = tryparse(Int, strip(rowsbox.displayed_string[]))
        ncols = tryparse(Int, strip(colsbox.displayed_string[]))
        chosen = selected[]

        if isnothing(nrows) || isnothing(ncols) || isnothing(chosen)
            message.text[] = "Remplis tous les champs !"
            return
        end
        if nrows < 5 || ncols < 5
            message.text[] = "Il faut au moins 5 lignes et 5 colonnes."
            return
        end
        # On limite la taille pour pas abuser, et on vérifie le personnage
        if nrows > 20 || ncols > 20
            message.text[] = "Choisis au maximum 20 lignes et 20 colonnes."
            return
        end
        if !haskey(MODES, chosen)
            message.text[] = "Choisis un personnage dans la liste."
            return
        end
        message.text[] = "Chargement du labyrinthe..."
        loading = true
        isready(channel) || put!(channel, (nrows, ncols, chosen))

        # Lancer le jeu avec les choix du menu
        @async begin
            nrows, ncols, name = take!(channel)
            try
                startgame(nrows, ncols, name)
            catch err
                message.text[] = "Impossible de lancer la partie."
                showerror(stdout, err, catch_backtrace())
                println()
            end
            loading = false
        end
    end

    # L'image de fond autour du menu
    backgroundpath = joinpath(MODELS, "fonds", "font_inter.png")
    backgrounduri = "data:image/png;base64," * base64encode(read(backgroundpath))

    panel = DOM.div(fig; style="flex-shrink:0;")
    return DOM.div(panel; style="""
        min-height:100vh;
        display:flex;
        align-items:center;
        justify-content:center;
        background-image:url('$backgrounduri');
        background-size:cover;
        background-position:center;
    """)
end

# Passer du menu au jeu et revenir au menu
function app!()
    # Contient l'écran affiché dans le navigateur
    page = Observable{Any}(nothing)
    # Garder les derniers choix pendant la visite
    lastrows = 10
    lastcols = 10
    lastcharacter = "nono le robot"

    function home!()
        page[] = menu(startgame!, lastrows, lastcols, lastcharacter)
        return nothing
    end

    function startgame!(rows::Int, cols::Int, character::String)
        # Récupérer le thème choisi ainsi que son fond
        theme = MODES[character]
        backgrounduri = "data:image/png;base64," * base64encode(read(theme.background))
        # On crée le jeu et lui donne la fonction de retour au menu
        fig = view(
            rows, cols, theme;
            back = home!
        )
        content = DOM.div(
            fig;
            style = "width:1100px;flex-shrink:0;"
        )
        pagestyle = """
            min-height:100vh;
            width:100%;
            display:flex;
            align-items:center;
            justify-content:center;
            background-image:url('$backgrounduri');
            background-size:cover;
            background-position:center;
            background-repeat:no-repeat;
        """

        page[] = DOM.div(content; style = pagestyle)
        lastrows = rows
        lastcols = cols
        lastcharacter = character
        return nothing
    end

    # Afficher le menu au démarrage
    home!()

    # Retourne la page complète
    return DOM.div(
        DOM.style("body { margin: 0; }"),
        page
    )
end

# Crée l'application web
function menu()
    return App(app!; title = "Le labyrinthe des Malicieux")
end