# Not currently used in the package but may be useful in the future
# to make stats / visualization about many games

"""
    enlarge!(M::AbstractMatrix, container::AbstractMatrix, λ::Int)

Inplace version of [`enlarge`](@ref). The result is stored in `container`.
The `container` must be initialized with the correct size (nλ×mλ).
"""
function enlarge!(M::AbstractMatrix{T}, container::AbstractMatrix{T}, λ::Int) where {T}
    Threads.@threads for idx in CartesianIndices(M)
        i, j = Tuple(idx)
        container[(i-1)*λ+1:i*λ, (j-1)*λ+1:j*λ] .= M[i, j]
    end
end

"""
    enlarge(M::AbstractMatrix)

Enlarge a matrix by a factor λ. Each element of the matrix is repeated λ times in each
direction. If M is a n×m matrix, the result will be a nλ×mλ matrix.

# Example

```jldoctest
julia> M = [1 2; 3 4]
2×2 Matrix{Int64}:
 1  2
 3  4

julia> enlarge(M, 2)
4×4 Matrix{Int64}:
 1  1  2  2
 1  1  2  2
 3  3  4  4
 3  3  4  4
```
"""
function enlarge(M::AbstractMatrix{T}, λ::Int) where {T}
    n, m = size(M)
    container = Matrix{T}(undef, n * λ, m * λ)
    enlarge!(M, container, λ)
    return container
end

"""
    GridSim.count_values(array::AbstractArray{T}) -> Dict{T, Int}

Return a dictionary with the number of occurences of each value in the `array`.
Elements of the `array` must be hashable.

# Example

```jldoctest
julia> GridSim.count_values([1, 2, 3, 2])
Dict{Int64, Int64} with 3 entries:
  2 => 2
  3 => 1
  1 => 1
```
"""
function count_values(array::AbstractArray{T})::Dict{T,Int} where {T}
    values = unique(array)
    count_values = [count(x -> x == value, array) for value in values]
    return Dict(zip(values, count_values))
end


"""
    GridSim.most_commons(array::AbstractArray) -> Vector

Return the most frequent value in the `array`. Faster than the same function
from the StatsBase package.

# Example

```jldoctest
julia> GridSim.most_commons([1, 2, 3, 2, 1])
2-element Vector{Int64}:
 2
 1
```
"""
function most_commons(array::AbstractArray{T})::Vector{T} where {T}
    cv = count_values(array)
    [key for (key, value) in cv if value == maximum(values(cv))]
end


"""
    GridSim.most_common(array::AbstractArray{T}) -> T

Return the most frequent value in the `array`. If there are multiple values with the
maximum number of occurences, the first one is returned.

# Example

```jldoctest
julia> GridSim.most_common([1, 2, 3, 2])
2
julia> GridSim.most_common([1, 2, 3, 2, 1])
1
```
"""
function most_common(array::AbstractArray{T})::T where {T}
    values = unique(array)
    argmax(count(x -> x == value, array) for value in values)
end