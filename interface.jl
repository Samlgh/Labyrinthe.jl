using  FileIO, MeshIO, WGLMakie, Bonito, Base64
include("structure.jl")

# (EtatJeu, creer_lab et deplacement! restent définis comme dans ton projet) MULTIDISPACHING, REGARDER LES TEST UNITAIRE 

const dossier_models   = "/home/hannah/cqls/samir/models"
const dossier_textures = joinpath(dossier_models, "textures")

Base.@kwdef struct Modele_affichage  # Base.@kwdef permet d'affecter les valeur sans respect l'ordre 
    titre:: String 
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
        modele_obs   = joinpath(dossier_models, "Free_rock.obj"),
        modele_sol   = joinpath(dossier_models, "sol_mars.obj"),
        coul_texte = "#ffe4c2", coul_fond = "#281914"),

    "sheep le mouton" => Modele_affichage(
        titre = "LA PRAIRIE - Retour à l'enclos",
        modele_perso = joinpath(dossier_models, "C1-10P_obj.obj"),
        modele_sorti = joinpath(dossier_models, "UFO.obj"),
        modele_obs   = joinpath(dossier_models, "Free_rock.obj"),
        modele_sol   = joinpath(dossier_models, "sol_mars.obj"),
        coul_texte = "#E8F5D0", coul_fond = "#1B3A1B"),

    "carine la citadine" => Modele_affichage(
        titre = "LA VILLE - Retour à la maison",
        modele_perso = joinpath(dossier_models, "C1-10P_obj.obj"),
        modele_sorti = joinpath(dossier_models, "UFO.obj"),
        modele_obs   = joinpath(dossier_models, "Free_rock.obj"),
        modele_sol   = joinpath(dossier_models, "sol_mars.obj"),
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

    # Tous les rochers en un seul objet
    positions = [Point3f(colonne, -ligne, 0.02)
                 for ligne in 1:L, colonne in 1:C
                 if labyrinthe[ligne, colonne] == 1]

    marker = modele_rocher isa GeometryBasics.MetaMesh ? modele_rocher.mesh : modele_rocher
    meshscatter!(zone, positions, marker = marker, markersize = Vec3f(1, 1, 3))

    vaisseau = mesh!(zone, modele_vaisseau)
    translate!(vaisseau, C-1, -(L-1), 0.16)
    robot = mesh!(zone, modele_robot)
    translate!(robot, 2, -2, 0.04)
    center!(zone.scene)
    zoom!(zone.scene, 0.75)
    return robot, vaisseau
end


# function direction_clavier(fig)
#     if ispressed(fig, Keyboard.up)
#         return "H"
#     elseif ispressed(fig, Keyboard.down)
#         return "B"
#     elseif ispressed(fig, Keyboard.left)
#         return "R"
#     elseif ispressed(fig, Keyboard.right)
#         return "A"
#     else
#         return ""
#     end
# end

function direction_depuis_evenement(event)
    if event.action in (Keyboard.press, Keyboard.repeat)
        return get(touche_clavier, event.key, "")
    end
    return ""
end

function brancher_clavier!(quand_direction, fig)
    on(events(fig).keyboardbutton) do event
        direction = direction_depuis_evenement(event)
        if direction != ""
            quand_direction(direction)
        end
        return Consume(false)
    end
end

function affichage_3D(l::Int, c::Int, aff::Modele_affichage)
    fig = Figure(size = (1100, 800), backgroundcolor = aff.coul_fond)

    m = (perso  = FileIO.load(aff.modele_perso),
         sortie = FileIO.load(aff.modele_sorti),
         obs    = FileIO.load(aff.modele_obs),
         sol    = FileIO.load(aff.modele_sol))

    Label(fig[1, 1], aff.titre, fontsize = 28, color = aff.coul_texte)
    zone = LScene(fig[2, 1], show_axis = false)
    cam3d!(zone.scene, eyeposition = (0, -1, 2))
    info = Label(fig[3, 1], "Coups : 0", fontsize = 20, color = aff.coul_texte)

    lab = Ref(creer_lab(l, c)) 
   #println(lab)

    robot, vaisseau = afficher_labyrinthe(zone, lab[], m.perso, m.sortie, m.obs, m.sol)
    etat = EtatJeu((2, 2), 0, false)

    brancher_clavier!(fig) do direction
        avant = etat.position
        lab[], ligne, colonne = deplacement!(etat.position, lab[], direction)
        if (ligne, colonne) != avant
            etat.position = (ligne, colonne)
            etat.coups += 1
            translate!(robot, colonne, -ligne, 0.04)
            info.text[] = "Coups : $(etat.coups)"
        end
    end

    return App() do
        DOM.div(fig)
    end
end


