using Colors: distinguishable_colors, RGB
using Random: AbstractRNG, Xoshiro, RandomDevice

# --------------------------------------------------------------------
# ------------------------------- FIRST DAY --------------------------
# --------------------------------------------------------------------

const Couple = Tuple{Int,Int}

"""
    nb_territories(grid_size::Tuple{Int,Int}, terr_size::Tuple{Int,Int})

Return the number of territories in the grid for each axis.
"""
function nb_territories(grid_size::Couple, terr_size::Couple)
    igrid, jgrid = grid_size
    iterr, jcterr = terr_size

    nbplayers_row, rem_row = divrem(igrid, iterr)
    nbplayers_col, rem_col = divrem(jgrid, jcterr)

    if rem_row != 0 || rem_col != 0
        nice_isize, nice_jsize = igrid - rem_row, jgrid - rem_col
        msg = "The size of the big rectangle must be a multiple of the size of the small rectangles."
        suggested = "Suggested size : ($(nice_isize), $(nice_jsize))"
        throw(ArgumentError("$msg\n$suggested\n"))
    end
    return (nbplayers_row, nbplayers_col)
end

"""
    firstday_with_nbterr(grid_size::Tuple{Int,Int}, territory_size::Tuple{Int,Int}, fill::Vector{V})

Same as [`firstday`](@ref) but with the number of territories returned as well.
"""
function firstday_with_nbterr(
    grid_size::Couple, territory_size::Couple, fill::Vector{V}
) where {V}
    nbterr_row, nbterr_col = nb_territories(grid_size, territory_size)
    nbterr = nbterr_row * nbterr_col

    if length(fill) < nbterr
        msg = "The length of the fill vector must be greater than the number of territories."
        throw(ArgumentError("$msg\nNumber of territories : $nbterr\n"))
    end

    row_size, col_size = territory_size
    output = Matrix{V}(undef, grid_size)
    n = 1
    for i in 0:nbterr_row-1, j in 0:nbterr_col-1
        min_i, max_i = i * row_size + 1, (i + 1) * row_size
        min_j, max_j = j * col_size + 1, (j + 1) * col_size
        output[min_i:max_i, min_j:max_j] .= fill[n]
        n += 1
    end
    return output, n
end


function firstday(
    grid_size::Couple, territory_size::Couple, fill::Vector{V}
) where {V}
    return firstday_with_nbterr(grid_size, territory_size, fill)[1]
end

function firstday(grid_size, territory_size, fill::Type{T}=Int) where {T<:Real}
    size = prod(nb_territories(grid_size, territory_size))
    return firstday(grid_size, territory_size, collect(T, 1:size))
end

function firstday(grid_size, territory_size, fill::Type{RGB})
    size = prod(nb_territories(grid_size, territory_size))
    colors = distinguishable_colors(size)
    return firstday(grid_size, territory_size, colors)
end

# --------------------------------------------------------------------
# ------------------------------- GAME RULES -------------------------
# --------------------------------------------------------------------


struct GameRules
    grid_size::Couple
    grid_indexes::Matrix{Couple}
    cellfunc::Function
    rng::AbstractRNG
    seed::Union{Nothing,Integer}
end

function _gamerules(grid_size, cellfunc, rng::AbstractRNG)
    isize, jsize = grid_size
    grid_indexes = collect(Iterators.product(1:isize, 1:jsize))
    return GameRules(grid_size, grid_indexes, cellfunc, rng, nothing)
end

function _gamerules(grid_size, cellfunc, rng::Integer)
    isize, jsize = grid_size
    grid_indexes = collect(Iterators.product(1:isize, 1:jsize))
    return GameRules(grid_size, grid_indexes, cellfunc, Xoshiro(rng), rng)
end

function _gamerules(grid_size, cellfunc, rng::Nothing)
    seed = rand(RandomDevice(), UInt64)
    _gamerules(grid_size, cellfunc, seed)
end

function gamerules(grid_size::Couple, cellfunc::Function; rng=nothing)
    _gamerules(grid_size, cellfunc, rng)
end

function Base.show(io::IO, rules::GameRules)
    print(io, "GridSim.GameRules($(rules.grid_size), $(rules.cellfunc), $(rules.rng), $(rules.seed))")
end


function Base.:(==)(rules1::GameRules, rules2::GameRules)
    return rules1.grid_size == rules2.grid_size &&
           rules1.cellfunc == rules2.cellfunc &&
           rules1.rng == rules2.rng
end

# --------------------------------------------------------------------
# ------------------------------- GAME -------------------------------
# --------------------------------------------------------------------

struct Game{T<:AbstractMatrix}
    first_day::T
    rules::GameRules
end

firstday(game::Game) = game.first_day
rules(game::Game) = game.rules
grid_indexes(game::Game) = game.rules.grid_indexes
game_rng(game::Game) = game.rules.rng
seedof(game::Game) = game.rules.seed
gridsize(game::Game) = game.rules.grid_size

function newgame(first_day, rules::GameRules)
    return Game(first_day, rules)
end

function newgame(first_day, cellfunc; rng=nothing)
    rules = gamerules(size(first_day), cellfunc, rng=rng)
    return Game(first_day, rules)
end

function newgame(grid_size, territory_size, cellfunc, fill; rng=nothing)
    rules = gamerules(grid_size, cellfunc, rng=rng)
    return Game(firstday(grid_size, territory_size, fill), rules)
end

function Base.:(==)(game1::Game{T}, game2::Game{Q}) where {T,Q}
    return T == Q && game1.first_day == game2.first_day && game1.rules == game2.rules
end

# --------------------------------------------------------------------
# --------------------------- COMPUTE DAYS ---------------------------
# --------------------------------------------------------------------


struct DaysIterator{T}
    game::Game{T}
    maxdays::Union{Integer,Nothing}
    stop_check::Union{Integer,Nothing}
    copydays::Bool
    rng::AbstractRNG

    function DaysIterator(game::Game{T}, maxdays, stop_check, copydays, rng) where {T}
        !isnothing(maxdays) && maxdays < 1 && throw(DomainError(maxdays, "maxdays <= 0"))
        !isnothing(stop_check) && stop_check < 1 && throw(DomainError(stop_check, "stop_check <= 0"))
        new{T}(game, maxdays, stop_check, copydays, copy(rng))
    end
end


function days(game, maxdays; stop_check=1, copydays=true)
    return DaysIterator(game, maxdays, stop_check, copydays, game_rng(game))
end

function days(game; stop_check=1, copydays=true)
    return DaysIterator(game, nothing, stop_check, copydays, game_rng(game))
end

Base.IteratorSize(::DaysIterator) = Base.SizeUnknown()
Base.eltype(iter::DaysIterator{T}) where {T} = T

firstday(iter::DaysIterator) = firstday(iter.game)
rules(iter::DaysIterator) = rules(iter.game)
grid_indexes(iter::DaysIterator) = grid_indexes(iter.game)
game_rng(iter::DaysIterator) = iter.rng
seedof(iter::DaysIterator) = seedof(iter.game)


"""
	nextday!(game, oldday, newday)

Compute the next game day in the `newday` matrix (inplace), based on the `oldday` matrix
that is the day just before.

# Example

```jldoctest
julia> game = newgame((4, 4), (2, 2), neigh_disk, Int, rng=1);

julia> new_day = similar(firstday(game));

julia> nextday!(game, firstday(game), new_day)

julia> new_day
4×4 Matrix{Int64}:
 1  2  2  2
 1  1  2  2
 3  3  4  4
 3  3  4  4
```
"""
function nextday!(game::Union{Game{T},DaysIterator{T}}, oldday::T, newday::T) where {T}
    game_size = rules(game).grid_size
    func = rules(game).cellfunc
    rng = game_rng(game)

    #! We can't use threads here because the rand function will not be
    #! used in the same order for each cell, so the result will be different
    #! from one run to another, even with the same seed.
    for (i, j) in grid_indexes(game)
        @inbounds newday[i, j] = rand(rng, func(oldday, game_size, i, j))
    end
end

hasunique_value(A::AbstractArray) = size(unique(A), 1) == 1


function Base.iterate(iter::DaysIterator)

    # TODO: we mabye don't really need a copy here, find a bug that
    # cause the copy to be necessary
    first_day = copy(firstday(iter))
    second_day = first_day

    if !iter.copydays
        # we always need to have two ≠ matrix, but if copydays is true, the second day
        # is just a regular one and the copy is done in the iterate method
        second_day = similar(second_day)
    end

    nbmax = iter.maxdays
    stop_check = iter.stop_check
    must_stop_next = false
    return first_day, (first_day, second_day, nbmax, stop_check, must_stop_next)
end

function _manage_checks(iter::DaysIterator{T}, new_day::T, stop_check::Integer, must_stop_next::Bool) where {T}
    stop_check -= 1
    if stop_check == 0
        if hasunique_value(new_day)
            must_stop_next = true
        else
            stop_check = iter.stop_check
        end
    end
    return stop_check, must_stop_next
end

function Base.iterate(iter::DaysIterator{T}, state) where {T}
    old_day, new_day, nbmax, stop_check, must_stop_next = state
    must_stop_next && return nothing

    if !isnothing(iter.maxdays)
        nbmax -= 1
        nbmax == 0 && return nothing
    end

    if !isnothing(stop_check)
        stop_check, must_stop_next = _manage_checks(iter, new_day, stop_check, must_stop_next)
    end

    if iter.copydays
        new_day = similar(new_day)
    end

    nextday!(iter, old_day, new_day)
    return new_day, (new_day, old_day, nbmax, stop_check, must_stop_next)
end

"""
    endless_days(game::Game)

Alias for `days(game, stop_check=nothing, copydays=false)`, that is an iterator
that will never stop iterating over the game days.
"""
endless_days(game::Game) = days(game, nothing, stop_check=nothing, copydays=false)


# --------------------------------------------------------------------
# ------------------------------- DOCS -------------------------------
# --------------------------------------------------------------------

"""
    firstday(grid_size::Tuple{Int,Int}, territory_size::Tuple{Int,Int}, fill::Vector)
    firstday(grid_size::Tuple{Int,Int}, territory_size::Tuple{Int,Int}, fill::Type)
    firstday(game::Game)

Return the first day matrix of the game, based on the grid size, the territory size
and a vector of values to fill the territories.

The `fill` argument can also be a type value but only few ones are supported :
- `<:Real`: Fill the territories with the values `1, 2, 3, ...` of the correct type.
- `RGB`: Fill the territories with distinguishable colors.

# Example

```jldoctest
julia> firstday((4, 4), (2, 2), Int)
4×4 Matrix{Int64}:
 1  1  2  2
 1  1  2  2
 3  3  4  4
 3  3  4  4

julia> firstday((4, 4), (2, 2), Int8) # to save memory
4×4 Matrix{Int8}:
 1  1  2  2
 1  1  2  2
 3  3  4  4
 3  3  4  4

julia> firstday((4, 4), (2, 2), ["hello", "world"])
ERROR: ArgumentError: The length of the fill vector must be greater than the number of territories.
Number of territories : 4

julia> firstday((4, 4), (2, 2), ["hello", "world", "foo", "bar"])
4×4 Matrix{String}:
 "hello"  "hello"  "world"  "world"
 "hello"  "hello"  "world"  "world"
 "foo"    "foo"    "bar"    "bar"
 "foo"    "foo"    "bar"    "bar"
```
"""
function firstday end


"""
    gamerules(grid_size::Tuple{Int,Int}, cellfunc::Union{Function,Symbol,String}; rng=nothing)

Create a GameRules object, given the grid size, the cell function and
an optional random number generator or seed.

# Arguments

- `grid_size` : the size of the grid
- `cellfunc` : the function that will be used to determine the next value of each cell.
    It **must** take the following arguments in the same order :
    - `::AbstractMatrix` : the matrix of the day
    - `::Tuple{Int,Int}` : the size of the grid (i.e. `size(M)`)
    - `::Int` : the row index of the cell
    - `::Int` : the column index of the cell

# Keywords (optional)
- `rng::Union{AbstractRNG,Integer`} : the random number generator to use. If passed a seed
    (an integer), it will create the default julia algorithmic random number generator
    (Xoshiro) with this seed. If not provided, it will generate a random seed.


# Example

```jldoctest
julia> function cellfunc(M, grid_size, i, j)
           # Return the cell value and the value of the cell above
           # (if it exists)
           i == 1 && return [M[i, j]]
           return [M[i, j], M[i-1, j]]
       end
cellfunc (generic function with 1 method)

julia> gamerules((4, 4), cellfunc, rng=1)
GridSim.GameRules((4, 4), cellfunc, Random.Xoshiro(0xfff0241072ddab67, 0xc53bc12f4c3f0b4e, 0x56d451780b2dd4ba, 0x50a4aa153d208dd8, 0x3649a58b3b63d5db), 1)
```
"""
function gamerules end

"""
    newgame(first_day::AbstractMatrix, rules::GameRules)
    newgame(first_day::AbstractMatrix, cellfunc::Function, fill::Type; rng=nothing)
    newgame(grid_size::Tuple{Int,Int}, territory_size::Tuple{Int,Int}, cellfunc::Function, fill::Type; rng=nothing)


Create a Game object with the specified first day matrix and the rules. These two
arguments can be automatically created with the [`firstday`](@ref) and
[`gamerules`](@ref) functions, respectively. Or you can pass the arguments directly into
the constructor. See the documentation of these two functions for more details.

# Example

```jldoctest
julia> game = newgame((4, 4), (2, 2), neigh_disk, Int, rng=1)
GridSim.Game{Matrix{Int64}}([1 1 2 2; 1 1 2 2; 3 3 4 4; 3 3 4 4], GridSim.GameRules((4, 4), neigh_disk, Random.Xoshiro(0xfff0241072ddab67, 0xc53bc12f4c3f0b4e, 0x56d451780b2dd4ba, 0x50a4aa153d208dd8, 0x3649a58b3b63d5db), 1))
```
"""
function newgame end


"""
    days(game::Game[,maxdays]; stop_check=1, copydays=true)

Return an iterator over the days of the game. By default, it is a secure iterator at
the cost of performance (create a copy and check when to stop at each iteration).

Be aware that the number of days can be less than `maxdays` because it will stop
when detecting a "stable" game (i.e. when all the cells have the same value).

# Arguments
- `game::Game` : the game to iterate over
- `maxdays::Integer` : the maximum number of days to iterate over. Set to `nothing`
    to never stop, unless the game is stable and `stop_check` is not `nothing`.

# Keywords (optional)
- `stop_check::Union{Integer, Nothing}` : the number of days to wait before checking if the
    game is stable. If the game is stable, the iterator will stop. Set to `nothing` to never check.
- `copydays` : If `false`, the iterator will return the same matrix at each iteration,
    modifying it inplace. DO NOT change it to `false` if you don't know *exactly* what you are doing.

# Example

```jldoctest
julia> game = newgame((4, 4), (2, 2), neigh_disk, Int, rng=1);

julia> for day in days(game, 3)
           println(day)
       end
[1 1 2 2; 1 1 2 2; 3 3 4 4; 3 3 4 4]
[1 2 2 2; 1 1 2 2; 3 3 4 4; 3 3 4 4]
[1 1 2 2; 1 2 4 4; 1 2 3 4; 3 4 4 4]
```
"""
function days end


"""
    rules(game::Game)
    rules(iter::DaysIterator)

Return the GameRules object of the game or the iterator.
"""
function rules end

"""
    grid_indexes(game::Game)
    grid_indexes(iter::DaysIterator)

Return the grid_indexes of the game or the iterator.
"""
function grid_indexes end

"""
    game_rng(game::Game)
    game_rng(iter::DaysIterator)

Return the random number generator of the game or the iterator.
"""
function game_rng end

"""
    seedof(game::Game)
    seedof(iter::DaysIterator)

Return the seed of the game or the iterator. If the game or the iterator was created
with a random number generator (and not a seed), nothing will be returned.
"""
function seedof end


"""
    gridsize(game::Game)
    gridsize(iter::DaysIterator)

Return the grid size of the game or the iterator as a tuple.
"""
function gridsize end