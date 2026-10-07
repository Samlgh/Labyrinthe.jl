using GLMakie, FileIO, GeometryBasics, MeshIO

#= function affiche_3D(matrice; pos_perso = (2, 2))   # (ligne, colonne)
    l, c = size(matrice)
    hauteur = 3
    maze3d = zeros(UInt8, c, l, hauteur)
    for z in 1:hauteur
        maze3d[:, :, z] = UInt8.(matrice' .== 1)    # seuls les murs
    end
    rocher = FileIO.load("/home/hannah/cqls/projet_robot/models/rocher.obj")

    fig = Figure(size = (800, 600))
    ax = Axis3(fig[1, 1], title = "Labyrinthe 3D en Julia",
               xlabel = "Colonne", ylabel = "Ligne", zlabel = "Hauteur",
               aspect = :data, yreversed = true)
    texture_img = FileIO.load("/home/hannah/cqls/projet_robot/models/textures/roche_mars_256.png")
    voxels!(ax, maze3d, color = texture_img)
    hidedecorations!(ax)
    hidespines!(ax)
    wait(display(fig))
end
 =#


    function affiche_3D(matrice; pos_perso = (2, 2))
        positions = Point3f[]
        for i in axes(matrice, 1) 
            for j in axes(matrice, 1) 
                if matrice[i,j] == 1 
                    push!(positions, Point3f(j, i, 0))
                end 
            end 
        end 
        rocher = FileIO.load("/home/hannah/cqls/projet_robot/models/rocher.obj")

        # taille d'origine du rocher → on le ramène à ~0.9 case
        pts = coordinates(rocher)
        largeur = maximum(p -> p[1], pts) - minimum(p -> p[1], pts)
        taille = 1.2 / largeur
        fig = Figure(size = (1000, 800))
        hauteur_rocher = 2.0                                  # 1.0 = hauteur d'origine
        h_modele = maximum(p -> p[3], pts) - minimum(p -> p[3], pts)
        z_rocher = taille * hauteur_rocher * h_modele / 2  

        ax = Axis3(fig[1, 1], title = "Labyrinthe 3D en Julia",aspect = :data, yreversed = true)

        meshscatter!(ax, positions, marker = rocher , markersize = Vec3f(taille, taille, taille * hauteur_rocher), color = :sienna)        
        
        # rajout du sol 
        sol = FileIO.load("/home/hannah/cqls/projet_robot/models/textures/sable_mars.png")
        texture = rotr90(FileIO.load(joinpath(@__DIR__, "models", "textures", "sable_mars.png")))
        nx, ny = size(matrice)
        z_sol = taille * hauteur_rocher * minimum(p -> p[3], pts)

        xs = [0.5, nx + 0.5]
        ys = [0.5, ny + 0.5]
        zs = fill(Float32(z_sol), 2, 2)       # à la place de zeros(2,2)    
        surface!(ax, xs, ys, zs, color = texture, shading = NoShading)


        # rajout du personnage 
        perso = FileIO.load("/home/hannah/cqls/projet_robot/models/NONO.obj")
        p = mesh!(ax, perso, color = :steelblue)
        rotate!(p, Vec3f(1, 0, 0), π/2)
        scale!(p, 0.75,  0.75,  0.75) 
        translate!(p, 2, 3, 1)  

        # rajout du vesaux 
        veseaux = FileIO.load("/home/hannah/cqls/projet_robot/models/UFO.obj")
        ves = mesh!(ax, veseaux, color = :steelblue)
        rotate!(ves, Vec3f(1, 0, 0), π/2)
        scale!(ves, 0.75,  0.75,  0.75) 
        translate!(p, 2*ny, 2*nx, 1)



        



        

        hidedecorations!(ax)
        hidespines!(ax)
        wait(display(fig))
    end


# voir le coup min faire avec theard 