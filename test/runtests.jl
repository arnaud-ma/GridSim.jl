using GridSim
using Test

# using Documenter: doctest
# # uncomment to run doctests (only do this locally, because it already runs on github actions)
# doctest(GridSim)

const test = [
    "aqua",
    "game",
    "utils",
]


@testset "GridSim" begin
    @testset "Test $t" for t in test
        include("$t.jl")
    end
end
