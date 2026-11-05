using FileIO, MeshIO, WGLMakie, Bonito, Base64, GeometryBasics
using WGLMakie.Makie: Menu, Textbox

function interface_menue(lancer_partie)
    WGLMakie.activate!(; use_html_widgets = true)

    ### chemin general pour l'image de fond ###
    chemin = joinpath(dossier_models, "font_inter.png")
    img_uri = "data:image/png;base64," * base64encode(read(chemin))

    fig = Figure(size = (1100, 800), backgroundcolor = "#F1EDE4")
    g = fig[1, 1] = GridLayout()

    Label(g[1, 1], "Bienvenue sur le labyrinthe des Malicieux",
        color = :black, font = :bold, fontsize = 33, halign = :center)

    nl = Textbox(g[2, 1],
        placeholder = "Entre le nombre de lignes, puis Entrée...",
        width = 450, fontsize = 20, textcolor = "#281914",
        boxcolor = "#F8F5EF", bordercolor = "#281914",
        cornerradius = 8, validator = Int)

    nc = Textbox(g[3, 1],
        placeholder = "Entre le nombre de colonnes, puis Entrée...",
        width = 450, fontsize = 20, textcolor = "#281914",
        boxcolor = "#F8F5EF", bordercolor = "#281914",
        cornerradius = 8, validator = Int)

    menu = Menu(g[4, 1],
        options = ["nono le robot", "sheep le mouton", "carine la citadine"],
        prompt = "Choisis ton personnage...",
        width = 450, fontsize = 20, textcolor = "#281914",
        cell_color_inactive_even = "#F8F5EF",
        cell_color_inactive_odd = "#EFEBE3",
        cell_color_hover = "#D9CFBC",
        cell_color_active = "#B5ADA3",
        selection_cell_color_inactive = "#F8F5EF",
        dropdown_arrow_color = "#281914")

    btn = Makie.Button(g[5, 1],
        label = "Lancer", width = 200, height = 45, fontsize = 24,
        buttoncolor = "#281914", buttoncolor_hover = "#4A3028",
        buttoncolor_active = "#6B463A", labelcolor = "#F1EDE4",
        labelcolor_hover = :white, labelcolor_active = :white,
        cornerradius = 10)

    message = Label(g[6, 1], "", color = "#8B1A1A", fontsize = 20)
    rowgap!(g, 20)

    # Le clic dépose les paramètres dans un canal ; le jeu démarre en dehors du callback
    canal = Channel{Tuple{Int,Int,String}}(1)
    # on évite de lancer deux parties par un double clicc
    chargement = false

    on(btn.clicks) do _
        if chargement
            return
        end
        # MODIF : on lit les valeurs sans appuyer sur Entrée
        n_lignes = tryparse(Int, strip(nl.displayed_string[]))
        n_colonnes = tryparse(Int, strip(nc.displayed_string[]))
        p = menu.selection[]

        if isnothing(n_lignes) || isnothing(n_colonnes) || isnothing(p)
            message.text[] = "Remplis tous les champs !"
            return
        end
        if n_lignes < 5 || n_colonnes < 5
            message.text[] = "Il faut au moins 5 lignes et 5 colonnes."
            return
        end
        ### On limite la taille pour pas abuser, et on vérif le personnage ###
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

    style = Bonito.Styles(
        Bonito.CSS(".accueil",
            "margin" => "0",
            "min-height" => "100vh",
            "display" => "flex",
            "justify-content" => "center",
            "align-items" => "center",
            "background-color" => "#EFEBE3",
            "background-image" => "url('$img_uri')",
            "background-size" => "cover",
            "background-position" => "center"
        )
    )
    return DOM.div(style, DOM.div(fig; style="width:1100px;flex-shrink:0;"); class="accueil")
end


# Passer du menu au jeu et revenir au menu
function creer_page()
    # Contient l'écran affiché dans le navigateur
    page = Observable{Any}(nothing)

    function afficher_menu!()
        page[] = interface_menue(lancer_partie!)
        return nothing
    end

    function lancer_partie!(lignes, colonnes, personnage)
        # Récupérer le thème choisi
        aff = MODES[personnage]
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
            display:flex;
            align-items:center;
            justify-content:center;
            background-color:$(aff.coul_fond);
        """

        page[] = DOM.div(contenu; style = style_page)
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