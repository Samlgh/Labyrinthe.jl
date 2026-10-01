# 0 = case vide
# 1 = mur / obstacle
# 2 = position du personnage
# 3 = sortie du labyrinthe
using DataStructures
using Random

function grille(l, c)
    return ones(Int, 2*l + 1, 2*c + 1)
end

function verif(l_id, c_id, l_g, c_g)
    return l_id < 1 || l_id > l_g || c_id < 1 || c_id > c_g
end

function deplacement!(pos_id, m, direction)
    l_id, c_id = pos_id
    l_g, c_g = size(m)

    new_l, new_c = l_id, c_id
    direction = uppercase(strip(direction))

    if direction == "H" # Haut 
        new_l -= 1
    elseif direction == "B" # Bas 
        new_l += 1
    elseif direction == "A" # Avancer 
        new_c += 1
    elseif direction == "R" # Reculer 
        new_c -= 1
    else
        println("Direction inconnue")
        return m, l_id, c_id 
    end

    if verif(new_l, new_c, l_g, c_g)
        println("Pas possible : hors de la grille")
        return m, l_id, c_id
    elseif m[new_l, new_c] == 1
        println("Pas possible : obstacle")
        return m, l_id, c_id
    end

    if m[new_l, new_c] == 3
        println("Bravo c'est la sortie !")
    end

    m[l_id, c_id] = 0
    m[new_l, new_c] = 2
    return m, new_l, new_c
end

function affichage(grille)
    l, c = size(grille)
    for y in 1:l
        for x in 1:c
            if grille[y, x] == 0
                print("  ")
            elseif grille[y, x] == 2 
                print("🤖")
            elseif grille[y, x] == 3 
                print("🚪")
            else 
                print("██")
            end 
        end
        println()   
    end
end


function creer_lab(l, c)
    m = grille(l, c)
    ens = IntDisjointSet(l * c)
    index(x, y) = (y - 1) * c + x

    for y in 1:l, x in 1:c
        m[2*y, 2*x] = 0
    end

    mur = Tuple{Tuple{Int,Int},Tuple{Int,Int}}[]
    for y in 1:l, x in 1:c
        x < c && push!(mur, ((x, y), (x + 1, y)))
        y < l && push!(mur, ((x, y), (x, y + 1)))
    end
    shuffle!(mur)

    for ((x1, y1), (x2, y2)) in mur
        i1, i2 = index(x1, y1), index(x2, y2)
        if !in_same_set(ens, i1, i2)
            union!(ens, i1, i2)
            m[y1 + y2, x1 + x2] = 0
        end
    end

    m[2, 2] = 2
    m[2*l, 2*c] = 3
    return m
end

function mode_jeu() 
    println("Rentrez les dimensions de la grille (entiers naturels) Tapez entrée:")
    print("Lignes : ")
    l = parse(Int, readline()) 
    
    print("Colonnes :")
    c = parse(Int, readline()) 
    lab = creer_lab(l,c)
    l_id, c_id = 2, 2
    while l_id != 2*l || c_id != 2*c 
        # display(lab)
        affichage(lab)
        println("Entrez A pour avancer, R pour reculer, B pour bas, H pour haut :")
        lettre = readline()
        lab, l_id, c_id = deplacement!((l_id, c_id), lab, lettre)
    end 
    
    display(lab) 
    println("Partie terminée !")
end 

