# Public API

## Index

```@index
Pages = ["public.md"]
```

## Game rules

```@docs
gamerules
```

This package already implements three rules:

- `neigh_disk` : Selects the neighbors of the value, edges are not linked
- `neigh_cylinder` : Selects the neighbors of the value, only bottom and top are linked
- `neigh_torus` : Selects the neighbors of the value, all edges are linked

## Game creation

```@docs
newgame
```

## Game iteration

```@docs
nextday!
```

```@docs
days
```

```@docs
endless_days
```

## Accessors

You can access some properties of the game, for both game and iterator objects.

```@docs
firstday
rules
seedof
game_rng
gridsize
grid_indexes
```

## Visualization

Here is some utilities to modify the esthetic of the game grids.

```@docs
enlarge
enlarge!
```

## Stats utilities

```@docs
count_values
most_common
most_commons
```
