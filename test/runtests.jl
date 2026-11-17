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
@testset "optimalpath" begin
    maze = testmaze()
    @test optimalpath(maze.grid, (2, 2), (4, 4)) == [(2,2), (2,3), (2,4), (3,4), (4,4)]  # test du début
    @test optimalpath(maze.grid, (2, 4), (4, 4)) == [(2,4), (3,4), (4,4)]                # test du milieu
    @test optimalpath(maze.grid, (4, 4), (4, 4)) == [(4, 4)]                             # test de fin

    open = [1 1 1 1 1;
            1 2 0 0 1;
            1 0 0 0 1;
            1 0 0 3 1;
            1 1 1 1 1]
    path = optimalpath(open, (2, 2), (4, 4))
    @test length(path) == 5
    @test first(path) == (2, 2)
    @test last(path) == (4, 4)
    for k in 1:length(path)-1
        (r1, c1), (r2, c2) = path[k], path[k+1]
        @test abs(r1 - r2) + abs(c1 - c2) == 1   # un pas à la fois
        @test open[r2, c2] != 1                  # aucun mur traversé
    end

    # la grille n'est pas modifiée
    maze = testmaze()
    optimalpath(maze.grid, (2, 2), (4, 4))
    @test maze.grid == testmaze().grid

    # sortie inaccessible
    blocked = [1 1 1 1 1;
               1 2 0 1 1;
               1 1 1 1 1;
               1 1 1 3 1;
               1 1 1 1 1]
    @test isempty(optimalpath(blocked, (2, 2), (4, 4)))
end

@testset "optimalmoves" begin
    maze = testmaze()
    @test optimalmoves(maze.grid, (2, 2), (4, 4)) == 4
    @test optimalmoves(maze.grid, (2, 4), (4, 4)) == 2
    @test optimalmoves(maze.grid, (4, 4), (4, 4)) == 0
end