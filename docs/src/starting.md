# Getting started

## Installation

The GridSim package is not available in the Julia package registry, but you can install it using the repository URL.

```julia
julia> ]add https://github.com/arnaud-ma/GridSim.jl.git
```

The guide assumes that you have successfully installed the package.

## Basic usage

### Creating a game

To create a game, you only need 3 informations:

1. The initial grid of cells (a matrix)
2. The function that will determine the new value of a cell at each day
3. A seed or a random number generator to generate the random values

For the initial grid, you can have any matrix of any type to the game. But we provide
a helper function to create a grid with a specific pattern: [`firstday`](@ref).

```julia
julia> using GridSim
julia> first_day = firstday((4, 4), (2, 2), Int)
4×4 Matrix{Int64}:
 1  1  2  2
 1  1  2  2
 3  3  4  4
 3  3  4  4
```

For the function rule, it **must** take the following arguments in this order:

- `::AbstractMatrix` : the matrix of the day
- `::Tuple{Int,Int}` : the size of the grid (i.e. `size(M)`)
- `::Int` : the row index of the cell
- `::Int` : the column index of the cell

However, we provide some predefined rules that you can use directly:

- `neigh_disk` : Selects the neighbors of the value, edges are not linked
- `neigh_cylinder` : Selects the neighbors of the value, only bottom and top are linked
- `neigh_torus` : Selects the neighbors of the value, all edges are linked

For the random number generator, you can either pass a seed or a random number generator (like `Random.MersenneTwister(seed)`). If a seed is provided, the `Random.Xoshiro(seed)` generator will be used.

```julia
julia> game = newgame(first_day, neigh_disk, rng=1)
```

### Running the game

You can now iterate over the game's days using the [`days`](@ref) function.

```julia
julia> for day in days(game, 3)
           println(day)
       end
[1 1 2 2; 1 3 2 2; 3 4 4 4; 3 3 4 4]
[1 1 2 2; 1 3 2 2; 3 4 4 4; 3 3 4 4]
[1 1 2 2; 1 3 2 2; 3 4 4 4; 3 3 4 4]
```

Since `days(game, args...)` is just a simple iterator, you can use any tools that work with iterators, like `collect` to
save the results in a vector, `IterTools.nth` to get the nth element, etc.

Refer to the [`days`](@ref) function documentation for more details about the options you can pass to it (like when to stop the iteration, or not create a copy of the game at each day to improve performance).

And that's it! Check the next sections for an example of how to visualize / save
the game in a file.
