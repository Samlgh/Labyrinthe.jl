using  FileIO, MeshIO, WGLMakie, Bonito, Base64, GeometryBasics

include("structure.jl")
include("jeu.jl")
include("interface.jl")

function interface_menue()
    WGLMakie.activate!(; use_html_widgets = true)

    chemin = "/home/hannah/cqls/samir/models/font_inter.png"
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
    on(btn.clicks) do _
        n_lignes   = tryparse(Int, something(nl.stored_string[], ""))
        n_colonnes = tryparse(Int, something(nc.stored_string[], ""))
        p          = menu.selection[]

        if isnothing(n_lignes) || isnothing(n_colonnes) || isnothing(p)
            message.text[] = "Remplis tous les champs (n'oublie pas Entrée) !"
            return
        end
        if n_lignes < 5 || n_colonnes < 5
            message.text[] = "Il faut au moins 5 lignes et 5 colonnes."
            return
        end
        message.text[] = "Jeu lancé dans une autre fenêtre..."
        isready(canal) || put!(canal, (n_lignes, n_colonnes, p))
    end

    app = App() do
        style = Bonito.Styles(
            Bonito.CSS("body",
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
        return DOM.div(style, fig)
    end
    display(app)                                
    n_lignes, n_colonnes, nom = take!(canal)       
    jeu = affichage_3D(n_lignes, n_colonnes, MODES[nom])
    display(jeu)                                   
    wait(Condition())
end
