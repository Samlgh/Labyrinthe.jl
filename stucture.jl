# 0 = case vide
# 1 = obstacle (l,c)
# 2 = position du personnage
# 3 = sortie du labyrinthe

function grille(l, c)
    m = zeros(Int64, l, c)
    return m
end

function pos_element!(m, l, c)
    max_obs = Int(floor(3 * (l * c) / 4))
    min_obs = Int(floor((l * c) / 4))
    nbr = rand(min_obs:max_obs)

    list_obstacle = []

    for i in 1:nbr
        l_o = rand(2:l-1)
        c_o = rand(2:c-1)
        push!(list_obstacle, (l_o, c_o))
        m[l_o, c_o] = 1
    end

    m[1, 1] = 2
    m[l, c] = 3
    pos_id = (1, 1)

    return (m, list_obstacle, pos_id)
end

function verif(l_id, c_id, l_g, c_g)
    if l_id < 1 || l_id > l_g || c_id > c_g || c_id < 1
        return true
    else
        return false
    end
end

function deplacement!(pos_id, m, direction)
    l_id = pos_id[1]
    c_id = pos_id[2]
    l_g, c_g = size(m)

    new_l = l_id
    new_c = c_id

    if direction == "avancer"
        new_l = l_id + 1
    elseif direction == "reculer"
        new_l = l_id - 1
    elseif direction == "haut"
        new_c = c_id - 1
    elseif direction == "bas"
        new_c = c_id + 1
    end

    if verif(new_l, new_c, l_g, c_g) 
        println("pas possible : hors de la grille")
        return pos_id

    elseif m[new_l, new_c] == 1
        println("pas possible : obstacle")
        return pos_id

    elseif m[new_l, new_c] == 3
        println("bravo c la sortie !")
        m[new_l, new_c] = 2
        m[l_id, c_id] = 0
        return (new_l, new_c)

    else
        m[new_l, new_c] = 2
        m[l_id, c_id] = 0
        return (new_l, new_c)
    end
end