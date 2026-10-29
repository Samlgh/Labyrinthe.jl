using FileIO, MeshIO, WGLMakie, Bonito, Base64, GeometryBasics
using WGLMakie.Makie: Textbox

function interface_menue(lancer_partie, lignes=10, colonnes=10, personnage="nono le robot")
    WGLMakie.activate!(; use_html_widgets=false)

    fig = Figure(size=(1100, 800), backgroundcolor="#F7F4EB", figure_padding=35)
    g = fig[1, 1] = GridLayout()

    Label(g[1, 1:3], "Bienvenue sur le labyrinthe\ndes Malicieux", fontsize=36, font=:bold, color="#10394B")
    Label(g[2, 1:3], "Choisissez la taille du labyrinthe et votre personnage,\npuis lancez l'aventure !", fontsize=19, color="#737D86")

    # Les dimensions de la prochaine partie
    dimensions = GridLayout(g[3, 1:3])
    Label(dimensions[1, 1], "Lignes", fontsize=20, color="#53616D")
    nl = Textbox(dimensions[1, 2], stored_string=string(lignes), validator=Int, width=110, height=45, fontsize=20, boxcolor="#FFFCF6", textcolor="#10394B")
    Label(dimensions[1, 3], "Colonnes", fontsize=20, color="#53616D")
    nc = Textbox(dimensions[1, 4], stored_string=string(colonnes), validator=Int, width=110, height=45, fontsize=20, boxcolor="#FFFCF6", textcolor="#10394B")

    Label(g[4, 1:3], "Choisissez votre personnage", fontsize=24, font=:bold, color="#10394B")
    noms = ["nono le robot", "sheep le mouton", "carine la citadine"]
    images = ["robot.png", "mouton.png", "voiture.png"]
    choix = Observable(personnage)
    boutons = []
    cartes = []

    # Une carte par personnage
    for i in 1:3
        carte = GridLayout(g[5, i])
        fond_carte = Box(g[5, i], color="#FFFCF6", strokecolor="#E5E1D8")
        push!(cartes, fond_carte)
        chemin = joinpath(dossier_models, "menu", images[i])
        if isfile(chemin)
            cadre = Axis(carte[1, 1], aspect=DataAspect(), backgroundcolor=:transparent)
            image!(cadre, rotr90(load(chemin)))
            hidedecorations!(cadre)
            hidespines!(cadre)
        else
            Label(carte[1, 1], "", height=145)
        end
        bouton = Button(carte[2, 1], label=noms[i], fontsize=19, width=270, height=48, labelcolor="#10394B", buttoncolor="#ECE9E0")
        push!(boutons, bouton)
        on(bouton.clicks) do _
            choix[] = noms[i]
        end
    end

    # La carte du personnage choisi devient bleue
    on(choix) do nom
        for i in 1:3
            if noms[i] == nom
                cartes[i].color[] = "#E5F4FF"
                cartes[i].strokecolor[] = "#0099FF"
                boutons[i].buttoncolor[] = "#CDEBFF"
                boutons[i].labelcolor[] = "#0077CF"
            else
                cartes[i].color[] = "#FFFCF6"
                cartes[i].strokecolor[] = "#E5E1D8"
                boutons[i].buttoncolor[] = "#ECE9E0"
                boutons[i].labelcolor[] = "#10394B"
            end
        end
    end
    notify(choix)

    btn = Button(g[6, 1:3], label="Lancer", width=290, height=58, fontsize=25, buttoncolor="#0B4B61", labelcolor=:white)
    message = Label(g[7, 1:3], "", color="#A33C35", fontsize=17)
    rowgap!(g, 18)
    colgap!(g, 22)
    rowsize!(g, 5, 215)

    # Le clic dépose les paramètres dans un canal, le jeu démarre en dehors du callback
    canal = Channel{Tuple{Int,Int,String}}(1)
    # on évite de lancer deux parties par un double clicc
    chargement = false

    on(btn.clicks) do _
        if chargement
            return
        end
        # on lit les valeurs sans appuyer sur Entrée
        n_lignes = tryparse(Int, strip(nl.displayed_string[]))
        n_colonnes = tryparse(Int, strip(nc.displayed_string[]))
        p = choix[]

        if isnothing(n_lignes) || isnothing(n_colonnes) || isnothing(p)
            message.text[] = "Remplis tous les champs !"
            return
        end
        if n_lignes < 5 || n_colonnes < 5
            message.text[] = "Il faut au moins 5 lignes et 5 colonnes."
            return
        end
        # On limite la taille pour pas abuser, et on vérif le personnage
        if n_lignes > 20 || n_colonnes > 20
            message.text[] = "Choisis au maximum 20 lignes et 20 colonnes."
            return
        end
        if !haskey(MODES, p)
            message.text[] = "Choisis un personnage dans la liste."
            return
        end
        message.text[] = "Chargement du labyrinthe..."
        chargement = true
        isready(canal) || put!(canal, (n_lignes, n_colonnes, p))

        # Lancer le jeu avec les choix du menu
        @async begin
            n_lignes, n_colonnes, nom = take!(canal)
            try
                lancer_partie(n_lignes, n_colonnes, nom)
            catch erreur
                message.text[] = "Impossible de lancer la partie."
                println("Erreur : ", erreur)
            end
            chargement = false
        end
    end

    # L'image de fond autour du menu
    chemin = joinpath(dossier_models, "fonds", "font_inter.png")
    image_fond = "data:image/png;base64," * base64encode(read(chemin))

    panneau = DOM.div(fig; style="flex-shrink:0;")
    return DOM.div(panneau; style="""
        min-height:100vh;
        display:flex;
        align-items:center;
        justify-content:center;
        background-image:url('$image_fond');
        background-size:cover;
        background-position:center;
    """)
end

# Passer du menu au jeu et revenir au menu
function creer_page()
    # Contient l'écran affiché dans le navigateur
    page = Observable{Any}(nothing)
    # Garder les derniers choix pendant la visite
    dernieres_lignes = 10
    dernieres_colonnes = 10
    dernier_personnage = "nono le robot"

    function afficher_menu!()
        page[] = interface_menue(lancer_partie!, dernieres_lignes, dernieres_colonnes, dernier_personnage)
        return nothing
    end

    function lancer_partie!(lignes, colonnes, personnage)
        # Récupérer le thème choisi ainsi que son fond
        aff = MODES[personnage]
        fond_uri = "data:image/png;base64," * base64encode(read(aff.fond))
        # On crée le jeu et lui donne la fonction de retour au menu
        fig = affichage_3D(
            lignes, colonnes, aff;
            retour_menu = afficher_menu!
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
            background-color:$(aff.coul_fond);
            background-image:url('$fond_uri');
            background-size:cover;
            background-position:center;
            background-repeat:no-repeat;
        """

        page[] = DOM.div(contenu; style = style_page)
        dernieres_lignes = lignes
        dernieres_colonnes = colonnes
        dernier_personnage = personnage
        return nothing
    end

    # Afficher le menu au démarrage
    afficher_menu!()

    # Retourne la page complète
    return DOM.div(
        DOM.style("body { margin: 0; }"),
        page
    )
end

# Crée l'application web
function interface_menue()
    return App(creer_page; title = "Le labyrinthe des Malicieux")
end
