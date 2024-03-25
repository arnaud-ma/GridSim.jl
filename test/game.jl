using GridSim: newgame, firstday, nextday!, neigh_disk
using IterTools: nth
using Colors: RGB
using ColorTypes: N0f8
using Random: Xoshiro

const seed = 1

const result_collect = [
    convert.(Int8, v) for v in
    [[1 1 2 2; 1 1 2 2; 3 3 4 4; 3 3 4 4], [1 2 2 2; 1 1 2 2; 3 3 4 4; 3 3 4 4], [1 1 2 2; 1 2 4 4; 1 2 3 4; 3 4 4 4], [2 1 2 2; 2 1 2 2; 1 1 4 4; 4 4 4 4], [1 2 1 2; 1 1 1 2; 4 1 4 2; 1 4 4 4], [1 2 2 1; 4 4 1 2; 1 4 4 4; 1 4 4 4], [2 1 2 2; 4 1 4 4; 4 1 4 4; 4 4 4 4], [1 1 2 4; 1 4 4 2; 4 4 4 4; 4 4 4 4], [1 1 2 4; 1 1 4 2; 4 4 4 4; 4 4 4 4], [1 1 1 4; 1 4 4 4; 4 1 4 4; 4 4 4 4], [1 4 4 1; 4 1 1 4; 1 4 1 4; 1 4 4 4], [4 4 4 4; 4 1 4 4; 4 4 4 4; 1 4 1 4], [4 4 4 4; 4 4 4 4; 4 1 4 4; 4 1 4 4], [4 4 4 4; 1 4 1 4; 1 4 4 4; 1 4 4 4], [1 1 4 4; 4 4 4 4; 4 1 4 4; 1 4 4 4], [1 1 4 4; 4 1 4 4; 1 4 4 4; 1 4 4 4], [1 1 4 4; 4 1 1 4; 1 4 4 4; 1 4 4 4], [4 4 4 4; 1 1 4 4; 4 4 4 1; 1 1 4 4], [1 4 4 4; 4 4 1 4; 4 4 1 4; 4 4 1 4], [4 4 4 4; 4 4 4 4; 4 4 4 4; 4 4 4 1], [4 4 4 4; 4 4 4 4; 4 4 4 4; 4 4 4 4], [4 4 4 4; 4 4 4 4; 4 4 4 4; 4 4 4 4], [4 4 4 4; 4 4 4 4; 4 4 4 4; 4 4 4 4]]
]

const size_grid = (4, 4)
const size_terr = (2, 2)

@testset "GridSim.jl" begin
    @testset "Invalid game creation" begin
        @test_throws ArgumentError newgame((4, 4), (2, 3), neigh_disk, Int8)
        @test_throws ArgumentError newgame(size_grid, size_terr, neigh_disk, [1, 2])
    end

    game = newgame(size_grid, size_terr, neigh_disk, Int8, rng=seed)
    rng_xosh = Xoshiro(seed)

    @testset "Valid game creation" begin
        game_colors = newgame(size_grid, size_terr, neigh_disk, RGB, rng=seed)
        @test typeof(firstday(game_colors)) == Array{RGB{N0f8},2}

        first_day = firstday(size_grid, size_terr, Int8)
        rules = gamerules(size_grid, neigh_disk, rng=Xoshiro(seed))
        game0 = newgame(first_day, rules)
        @test game0 == game
        @test firstday(game) == result_collect[1]
        @test typeof(firstday(game)) == Array{Int8,2}
        @test size(firstday(game)) == size_grid
        @test seedof(game) == seed
        @test repr(game) == "GridSim.Game{Matrix{Int8}}(Int8[1 1 2 2; 1 1 2 2; 3 3 4 4; 3 3 4 4], GridSim.GameRules($(size_grid), neigh_disk, $rng_xosh, $seed))"
    end

    @testset "Game progression" begin
        alldays = collect(days(game))
        @test alldays == result_collect
        @test collect(days(game)) == result_collect # check that it's reproducible
        @test seedof(days(game)) == seed

        @test alldays[end] == result_collect[end]
        @test all(isa.(alldays[end], Int8))

        @test collect(days(game, 10)) == result_collect[1:10]
    end

    @testset "Endless days" begin
        @test nth(endless_days(game), 10) == result_collect[10]
        X = Matrix{Int8}[]
        for (i, day) in enumerate(endless_days(game))
            push!(X, day)
            if i == length(result_collect) + 1
                break
            end
        end
        @test X[end] == result_collect[end]
        @test X[end] == X[end-1]
    end
end