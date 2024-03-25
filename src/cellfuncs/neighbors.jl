# There is a lot of (very clever) ways to compute the neighbors of a pixel in a matrix,
# but nothing is faster than simple (and a lot of) `if` statements (at least in Julia).

#! format: off
# TODO argument to choose if the value itself is considered a neighbor

# Edge on all sides
Base.@propagate_inbounds function neigh_disk(M, size_M, row, col)

    end_rows, end_cols = size_M

    # In a corner of the matrix
    if row == 1 && col == 1
        # top left corner
        return [              #    ⤬ ⤬ ⤬
            M[1, 1], M[1, 2], #    ⤬ ⧆ ✓
            M[2, 1], M[2, 2]  #    ⤬ ✓ ✓
        ]

    elseif row == 1 && col == end_cols
        # top right corner
        return [                    #    ⤬ ⤬ ⤬
            M[1, col-1], M[1, col], #    ✓ ⧆ ⤬
            M[2, col-1], M[2, col]  #    ✓ ✓ ⤬
        ]

    elseif row == end_rows && col == 1
        # bottom left corner
        return [                      #    ⤬ ✓ ✓
            M[row-1, 1], M[row-1, 2], #    ⤬ ⧆ ✓
            M[row, 1], M[row, 2]      #    ⤬ ⤬ ⤬
        ]

    elseif row == end_rows && col == end_cols
        # bottom right corner
        return [                            #    ✓ ✓ ⤬
            M[row-1, col-1], M[row-1, col], #    ✓ ⧆ ⤬
            M[row, col-1], M[row, col]      #    ⤬ ⤬ ⤬
        ]

        # -------

        # On an edge of the matrix (but not in a corner)
    elseif row == 1
        # top edge
        return [                                 #   ⤬ ⤬ ⤬
            M[1, col-1], M[1, col], M[1, col+1], #   ✓ ⧆ ✓
            M[2, col-1], M[2, col], M[2, col+1]  #   ✓ ✓ ✓
        ]

    elseif row == end_rows
        # bottom edge
        return [                                             #   ✓ ✓ ✓
            M[row-1, col-1], M[row-1, col], M[row-1, col+1], #   ✓ ⧆ ✓
            M[row, col-1], M[row, col], M[row, col+1],       #   ⤬ ⤬ ⤬
        ]

    elseif col == 1
        # left edge
        return [
            M[row-1, 1], M[row-1, 2], #   ⤬ ✓ ✓
            M[row, 1], M[row, 2],     #   ⤬ ⧆ ✓
            M[row+1, 1], M[row+1, 2]  #   ⤬ ✓ ✓
        ]

    elseif col == end_cols
        # right edge
        return [
            M[row-1, col-1], M[row-1, col], #   ✓ ✓ ⤬
            M[row, col-1], M[row, col],     #   ✓ ⧆ ⤬
            M[row+1, col-1], M[row+1, col]  #   ✓ ✓ ⤬
        ]


        # --------
        # in the middle of the matrix
    else
        return [
            M[row-1, col-1], M[row-1, col], M[row-1, col+1], #  ✓ ✓ ✓
            M[row, col-1], M[row, col], M[row, col+1],       #  ✓ ⧆ ✓
            M[row+1, col-1], M[row+1, col], M[row+1, col+1]  #  ✓ ✓ ✓
        ]
    end
end

# No edge
Base.@propagate_inbounds function neigh_torus(M, size_M, row, col)

    end_rows, end_cols = size_M

    # in a corner of the matrix
    if row == 1 && col == 1
        # top left corner
        return [
            M[end_rows, end_cols], M[end_rows, 1], M[end_rows, 2],
            M[1, end_cols], M[1, 1], M[1, 2],
            M[2, end_cols], M[2, 1], M[2, 2]
        ]

    elseif row == 1 && col == end_cols
        # top right corner
        return [
            M[end_rows, col-1], M[end_rows, col], M[end_rows, 1],
            M[1, col-1], M[1, col], M[1, 1],
            M[2, col-1], M[2, col], M[2, 1]
        ]

    elseif row == end_rows && col == 1
        # bottom left corner
        return [
            M[row-1, end_cols], M[row-1, 1], M[row-1, 2],
            M[row, end_cols], M[row, 1], M[row, 2],
            M[1, end_cols], M[1, 1], M[1, 2]
        ]

    elseif row == end_rows && col == end_cols
        # bottom right corner
        return [
            M[row-1, col-1], M[row-1, col], M[row-1, 1],
            M[row, col-1], M[row, col], M[row, 1],
            M[1, col-1], M[1, col], M[1, 1]
        ]

        # on an edge of the matrix (but not in a corner)
    elseif row == 1
        # top edge
        return [
            M[end_rows, col-1], M[end_rows, col], M[end_rows, col+1],
            M[1, col-1], M[1, col], M[1, col+1],
            M[2, col-1], M[2, col], M[2, col+1]
        ]

    elseif row == end_rows
        # bottom edge
        return [
            M[row-1, col-1], M[row-1, col], M[row-1, col+1],
            M[row, col-1], M[row, col], M[row, col+1],
            M[1, col-1], M[1, col], M[1, col+1]
        ]

    elseif col == 1
        # left edge
        return [
            M[row-1, end_cols], M[row-1, 1], M[row-1, 2],
            M[row, end_cols], M[row, 1], M[row, 2],
            M[row+1, end_cols], M[row+1, 1], M[row+1, 2]
        ]

    elseif col == end_cols
        # right edge
        return [
            M[row-1, col-1], M[row-1, col], M[row-1, 1],
            M[row, col-1], M[row, col], M[row, 1],
            M[row+1, col-1], M[row+1, col], M[row+1, 1]
        ]

        #in the middle of the matrix
    else
        return [
            M[row-1, col-1], M[row-1, col], M[row-1, col+1],
            M[row, col-1], M[row, col], M[row, col+1],
            M[row+1, col-1], M[row+1, col], M[row+1, col+1]
        ]
    end
end

# Edge only on top and bottom
Base.@propagate_inbounds function neigh_cylinder(M, size_M, row, col)
    end_rows, end_cols = size_M

    # in a corner of the matrix
    if row == 1 && col == 1
        # top left corner
        return [                              #   ⤬ ⤬ ⤬
            M[1, end_cols], M[1, 1], M[1, 2], #   ✓ ⧆ ✓
            M[2, end_cols], M[2, 1], M[2, 2]  #   ✓ ✓ ✓
        ]

    elseif row == 1 && col == end_cols
        # top right corner
        return [                             #  ⤬ ⤬ ⤬
            M[1, col-1], M[1, col], M[1, 1], #  ✓ ⧆ ✓
            M[2, col-1], M[2, col], M[2, 1]  #  ✓ ✓ ✓
        ]

    elseif row == end_rows && col == 1
        # bottom left corner
        return [                                           #  ✓ ✓ ✓
            M[row-1, end_cols], M[row-1, 1], M[row-1, 2],  #  ✓ ⧆ ✓
            M[row, end_cols], M[row, 1], M[row, 2],        #  ⤬ ⤬ ⤬
        ]

    elseif row == end_rows && col == end_cols
        # bottom right corner
        return [                                         #  ✓ ✓ ✓
            M[row-1, col-1], M[row-1, col], M[row-1, 1], #  ✓ ⧆ ✓
            M[row, col-1], M[row, col], M[row, 1],       #  ⤬ ⤬ ⤬
        ]

        # on an edge of the matrix (but not in a corner)
    elseif row == 1
        # top edge
        return [                                 #  ⤬ ⤬ ⤬
            M[1, col-1], M[1, col], M[1, col+1], #  ✓ ⧆ ✓
            M[2, col-1], M[2, col], M[2, col+1]  #  ✓ ✓ ✓
        ]

    elseif row == end_rows
        # bottom edge
        return [                                             #  ✓ ✓ ✓
            M[row-1, col-1], M[row-1, col], M[row-1, col+1], #  ✓ ⧆ ✓
            M[row, col-1], M[row, col], M[row, col+1],       #  ⤬ ⤬ ⤬
        ]

    elseif col == 1
        # left edge
        return [
            M[row-1, end_cols], M[row-1, 1], M[row-1, 2],     #  ✓ ✓ ✓
            M[row, end_cols], M[row, 1], M[row, 2],           #  ✓ ⧆ ✓
            M[row+1, end_cols], M[row+1, 1], M[row+1, 2]      #  ✓ ✓ ✓
        ]

    elseif col == end_cols
        # right edge
        return [
            M[row-1, col-1], M[row-1, col], M[row-1, 1], #  ✓ ✓ ✓
            M[row, col-1], M[row, col], M[row, 1],       #  ✓ ⧆ ✓
            M[row+1, col-1], M[row+1, col], M[row+1, 1]  #  ✓ ✓ ✓
        ]

        # in the middle of the matrix
    else
        return [
            M[row-1, col-1], M[row-1, col], M[row-1, col+1], #  ✓ ✓ ✓
            M[row, col-1], M[row, col], M[row, col+1],       #  ✓ ⧆ ✓
            M[row+1, col-1], M[row+1, col], M[row+1, col+1]  #  ✓ ✓ ✓
        ]
    end
end
