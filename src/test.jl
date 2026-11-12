using Labyrinthe
using Test

# tests sur le fichier structure
@testset "Maze" begin
    maze = Maze(4, 6)
    @test maze.rows == 4
    @test maze.cols == 6
    @test size(maze.grid) == (9, 13)
end

@testset "isoutside" begin
    @test Labyrinthe.isoutside(0, 1, 5, 5)
    @test Labyrinthe.isoutside(1, 6, 5, 5)
    @test !Labyrinthe.isoutside(1, 1, 5, 5)
    @test !Labyrinthe.isoutside(5, 5, 5, 5)
end

function testmaze()
    return Maze(2, 2, [1 1 1 1 1;
                       1 2 0 0 1;
                       1 1 1 0 1;
                       1 1 1 3 1;
                       1 1 1 1 1])
end #fonction de transition 

@testset "applymove!" begin
    # le personnage ne peut pas bouger (murs)
    maze = testmaze()
    @test applymove!(maze.grid, (2, 2), :up) == (2, 2)
    @test applymove!(maze.grid, (2, 2), :left) == (2, 2)
    @test applymove!(maze.grid, (2, 2), :down) == (2, 2)
    @test maze.grid == testmaze().grid     # la grille n'a pas changé

    # le personnage bouge
    maze = testmaze()
    @test applymove!(maze.grid, (2, 2), :right) == (2, 3)
    @test maze.grid[2, 2] == 0
    @test maze.grid[2, 3] == 2

    maze = testmaze()
    @test applymove!(maze.grid, (2, 4), :down) == (3, 4)
    @test applymove!(maze.grid, (2, 4), :up) == (2, 4)   # mur au-dessus

    # le personnage atteint la sortie sans l'écraser
    maze = testmaze()
    @test applymove!(maze.grid, (3, 4), :down) == (4, 4)
    @test maze.grid[4, 4] == 3

    # direction inconnue
    maze = testmaze()
    @test applymove!(maze.grid, (2, 2), :autre) == (2, 2)
end

@testset "generategrid" begin
    grid = generategrid(5, 5)
    @test size(grid) == (11, 11)
    @test grid[2, 2] == 2
    @test grid[10, 10] == 3
    @test all(grid[1, :] .== 1)      # bordure haute
    @test all(grid[end, :] .== 1)    # bordure basse
    @test all(grid[:, 1] .== 1)      # bordure gauche
    @test all(grid[:, end] .== 1)    # bordure droite
end


# tests sur le fichier jeu
