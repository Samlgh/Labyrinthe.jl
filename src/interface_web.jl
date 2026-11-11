using FileIO, MeshIO, WGLMakie, Bonito, Base64, GeometryBasics
using WGLMakie.Makie: Textbox

function menu(play::Function, rows::Int=10, cols::Int=10, charac::String="nono le robot")
    WGLMakie.activate!(; use_html_widgets=false)

    fig = Figure(size=(1100, 800), backgroundcolor="#F7F4EB", figure_padding=35)
    g = fig[1, 1] = GridLayout()

    Label(g[1, 1:3], "Bienvenue sur le labyrinthe\ndes Malicieux", fontsize=36, font=:bold, color="#10394B")
    Label(g[2, 1:3], "Choisissez la taille du labyrinthe et votre charac,\npuis lancez l'aventure !", fontsize=19, color="#737D86")

    # Les dimensions de la prochaine partie
    dimensions = GridLayout(g[3, 1:3])
    Label(dimensions[1, 1], "Lignes", fontsize=20, color="#53616D")
    nl = Textbox(dimensions[1, 2], stored_string=string(rows), validator=Int, width=110, height=45, fontsize=20, boxcolor="#FFFCF6", textcolor="#10394B")
    Label(dimensions[1, 3], "Colonnes", fontsize=20, color="#53616D")
    nc = Textbox(dimensions[1, 4], stored_string=string(cols), validator=Int, width=110, height=45, fontsize=20, boxcolor="#FFFCF6", textcolor="#10394B")

    Label(g[4, 1:3], "Choisissez votre personnage", fontsize=24, font=:bold, color="#10394B")
    names = ["nono le robot", "sheep le mouton", "carine la citadine"]
    picture = ["robot.png", "mouton.png", "voiture.png"]
    choice = Observable(charac)
    buttons = []
    cards = []

    # Une carte par personnage
    for i in 1:3
        card = GridLayout(g[5, i])
        mapbackground = Box(g[5, i], color="#FFFCF6", strokecolor="#E5E1D8")
        push!(cards, mapbackground)
        path = joinpath(MODELS, "menu", picture[i])
        if isfile(path)
            frame = Axis(card[1, 1], aspect=DataAspect(), backgroundcolor=:transparent)
            image!(frame, rotr90(load(path)))
            hidedecorations!(frame)
            hidespines!(frame)
        else
            Label(card[1, 1], "", height=145)
        end
        bouton = Button(card[2, 1], label=names[i], fontsize=19, width=270, height=48, labelcolor="#10394B", buttoncolor="#ECE9E0")
        push!(buttons, bouton)
        on(bouton.clicks) do _
            choice[] = names[i]
        end
    end

    # La carte du personnage choisi devient bleue
    on(choice) do name
        for i in 1:3
            if names[i] == name
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
    notify(choice)

    btn = Button(g[6, 1:3], label="Lancer", width=290, height=58, fontsize=25, buttoncolor="#0B4B61", labelcolor=:white)
    message = Label(g[7, 1:3], "", color="#A33C35", fontsize=17)
    rowgap!(g, 18)
    colgap!(g, 22)
    rowsize!(g, 5, 215)

    # Le clic dépose les paramètres dans un canal, le jeu démarre en dehors du callback
    channel = Channel{Tuple{Int,Int,String}}(1)
    # on évite de lancer deux parties par un double clicc
    loading = false

    on(btn.clicks) do _
        if loading
            return
        end
        # on lit les valeurs sans appuyer sur Entrée
        n_rows = tryparse(Int, strip(nl.displayed_string[]))
        n_cols = tryparse(Int, strip(nc.displayed_string[]))
        p = choice[]

        if isnothing(n_rows) || isnothing(n_cols) || isnothing(p)
            message.text[] = "Remplis tous les champs !"
            return
        end
        if n_rows < 5 || n_cols < 5
            message.text[] = "Il faut au moins 5 lignes et 5 colonnes."
            return
        end
        # On limite la taille pour pas abuser, et on vérif le personnage
        if n_rows > 20 || n_cols > 20
            message.text[] = "Choisis au maximum 20 lignes et 20 colonnes."
            return
        end
        if !haskey(MODES, p)
            message.text[] = "Choisis un personnage dans la liste."
            return
        end
        message.text[] = "Chargement du labyrinthe..."
        loading = true
        isready(channel) || put!(channel, (n_rows, n_cols, p))

        # Lancer le jeu avec les choix du menu
        @async begin
            n_rows, n_cols, name = take!(channel)
            try
                play(n_rows, n_cols, name)
            catch erreur
                message.text[] = "Impossible de lancer la partie."
                println("Erreur : ", erreur)
            end
            loading = false
        end
    end

    # L'image de fond autour du menu
    path = joinpath(MODELS, "fonds", "font_inter.png")
    background = "data:image/png;base64," * base64encode(read(path))

    sign = DOM.div(fig; style="flex-shrink:0;")
    return DOM.div(sign; style="""
        min-height:100vh;
        display:flex;
        align-items:center;
        justify-content:center;
        background-image:url('$background');
        background-size:cover;
        background-position:center;
    """)
end 

# Passer du menu au jeu et revenir au menu
function view!()
    # Contient l'écran affiché dans le navigateur
    page = Observable{Any}(nothing)
    # Garder les derniers choix pendant la visite
    lastrows = 10
    lastcols = 10
    lastcharas = "nono le robot"

    function home!()
        page[] = menu(play!, lastrows, lastcols, lastcharas)
        return nothing
    end

    function play!(rows::Int, cols::Int, charac::String)
        # Récupérer le thème choisi ainsi que son fond
        aff = MODES[charac]
        bottomurl = "data:image/png;base64," * base64encode(read(aff.fond))
        # On crée le jeu et lui donne la fonction de retour au menu
        fig = view(
            rows, cols, aff;
            back = home!
        )
        contenu = DOM.div(
            fig;
            style = "width:1100px;flex-shrink:0;"
        )
         style_page = """
            min-height:100vh;
            width:100%;
            display:flex;
            align-items:center;
            justify-content:center;
            background-image:url('$bottomurl');
            background-size:cover;
            background-position:center;
            background-repeat:no-repeat;
        """

        page[] = DOM.div(contenu; style = style_page)
        lastrows = rows
        lastcols = cols
        lastcharas = charac
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
    return App(view!; title = "Le labyrinthe des Malicieux")
end
