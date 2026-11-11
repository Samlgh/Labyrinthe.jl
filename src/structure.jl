# 0 = case vide
# 1 = mur / obstacle
# 2 = position du personnage
# 3 = sortie du labyrinthe

using DataStructures
using Random

mutable struct GameState
    position::Tuple{Int, Int}
    moves::Int
    win::Bool
end

mutable struct Maze
    rows::Int
    cols::Int
    grid::Matrix{Int}
end

Maze(rows::Int, cols::Int) = Maze(rows, cols, generategrid(rows, cols))

function isinside(rows::Int, cols::Int, R::Int, C::Int)
    return rows < 1 || rows > L || cols < 1 || cols > C
end

function applymove!(position::Tuple{Int,Int}, grid::Matrix{Int}, direction::Char)
    row, col = position
    L, C = size(grid)

    newrow = row
    newcol = col

    direction = uppercase(strip(direction))

    if direction == "H" # Haut
        newrow -= 1
    elseif direction == "B" # Bas
        newrow += 1
    elseif direction == "A" # Avancer
        newcol += 1
    elseif direction == "R" # Reculer
        newcol -= 1
    else
        println("Direction inconnue")
        return grid, row, col
    end

    if isinside(newrow, newcol, L, C)
        println("Pas possible : hors de la grille")
        return grid, row, col
        
    elseif grid[newrow, newcol] == 1
        println("Pas possible : obstacle")
        return grid, row, col
    end

    if grid[newrow, newcol] == 3
        println("Bravo c'est la sortie !")
    end

    grid[row, col] = 0

    if grid[newrow, newcol] != 3
        grid[newrow, newcol] = 2
    end
    
    return grid, newrow, newcol
end

function generategrid(rows::Int, cols::Int)
    grid = ones(Int, 2rows + 1, 2cols + 1)
    sets = IntDisjointSet(rows * cols)
    cellindex(x, y) = (y - 1) * cols + x

    # Ouvrir toutes les cellules
    for y in 1:rows, x in 1:cols
        grid[2y, 2x] = 0
    end

    # Murs candidats entre cellules voisines
    walls = Tuple{Tuple{Int,Int},Tuple{Int,Int}}[]
    for y in 1:rows, x in 1:cols
        x < cols && push!(walls, ((x, y), (x + 1, y)))
        y < rows && push!(walls, ((x, y), (x, y + 1)))
    end
    shuffle!(walls)

    # Casser un mur seulement s'il relie deux zones encore séparées
    for ((x1, y1), (x2, y2)) in walls
        i1, i2 = cellindex(x1, y1), cellindex(x2, y2)
        if !in_same_set(sets, i1, i2)
            union!(sets, i1, i2)
            grid[y1 + y2, x1 + x2] = 0
        end
    end

    grid[2, 2] = 2
    grid[2rows, 2cols] = 3
    return grid
end
