# Calcule le chemin optimal jusqu'à la sortie
function optimalpath(grid, start, goal)
    nrows, ncols = size(grid)

    # File des cases à explorer
    queue = [start]

    # Garde la case précédente de chaque position
    previous = fill((0, 0), nrows, ncols)

    # Tant que la file n'est pas vide, on explore les cases
    while !isempty(queue)
        row, col = popfirst!(queue)

        # Si on atteint la sortie, on stop
        if (row, col) == goal
            break
        end

        # Les quatre voisins possibles
        neighbors = [
            (row - 1, col),
            (row + 1, col),
            (row, col - 1),
            (row, col + 1)
        ]

        # Exploration des voisins, si la case est valide et non visitée.
        for (r, c) in neighbors
            if 1 <= r <= nrows && 1 <= c <= ncols && grid[r, c] != 1 && previous[r, c] == (0, 0) && (r, c) != start
                previous[r, c] = (row, col)
                push!(queue, (r, c))
            end
        end
    end

    # Reconstruction du chemin
    path = []
    position = goal

    # On remonte de la sortie jusqu'au départ
    while position != start
        pushfirst!(path, position)
        row, col = position
        position = previous[row, col]
    end

    # Ajoute le départ au début du chemin
    pushfirst!(path, start)

    return path
end


# Calcule le nombre minimal de déplacements
function optimalmoves(grid, start, goal)
    path = optimalpath(grid, start, goal)
    return length(path) - 1
end


function play()
    return menu()
end
