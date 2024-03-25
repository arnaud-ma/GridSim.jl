module GridSim

export firstday, gamerules, newgame # constructor
export rules, grid_indexes, game_rng, seedof, gridsize  # accessors
export nextday!, days, endless_days # computation
export neigh_disk, neigh_cylinder, neigh_torus # cellfuncs
export enlarge, enlarge! # visualize
export count_values, most_commons, most_common # stats

include("cellfuncs/neighbors.jl")
include("game.jl")
include("utils.jl")

end
