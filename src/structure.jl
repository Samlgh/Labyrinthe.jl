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

# Vrai si la case est hors de la grille
function isoutside(row::Int, col::Int, nrows::Int, ncols::Int)
    return row < 1 || row > nrows || col < 1 || col > ncols
end

# Déplace le joueur et renvoie sa nouvelle position
function applymove!(grid::Matrix{Int}, position::Tuple{Int,Int}, direction::Symbol)
    row, col = position
    nrows, ncols = size(grid)

    newrow = row
    newcol = col

    if direction == :up
        newrow -= 1
    elseif direction == :down
        newrow += 1
    elseif direction == :right
        newcol += 1
    elseif direction == :left
        newcol -= 1
    else
        return row, col
    end

    if isoutside(newrow, newcol, nrows, ncols)
        return row, col
    elseif grid[newrow, newcol] == 1
        return row, col
    end

    grid[row, col] = 0

    if grid[newrow, newcol] != 3
        grid[newrow, newcol] = 2
    end
    return newrow, newcol
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