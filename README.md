# GridSim

[![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://arnaud-ma.github.io/GridSim.jl/stable/)
[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://arnaud-ma.github.io/GridSim.jl/dev/)
[![codecov](https://codecov.io/gh/arnaud-ma/GridSim.jl/graph/badge.svg)](https://codecov.io/gh/arnaud-ma/GridSim.jl)
[![Build Status](https://github.com/arnaud-ma/GridSim.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/arnaud-ma/GridSim.jl/actions/workflows/CI.yml?query=branch%3Amain)
[![Code Style: Blue](https://img.shields.io/badge/code%20style-blue-4495d1.svg)](https://github.com/invenia/BlueStyle)

**GridSim** offers simple simulations for a particular random game, leveraging the performance and flexibility of Julia.

## Installation

In a Julia REPL:

```julia
julia> ]add https://github.com/arnaud-ma/GridSim.jl
```

## Overview

The example created in the [documentation](https://arnaud-ma.github.io/GridSim.jl/stable/example/):

<https://www.youtube.com/watch?v=aSCUlpiplb0>.

In **GridSim**, the goal is to simulate a dynamic grid of pixels according to specific rules. The game's rules are as follows:

- Each pixel on the grid has unique characteristics such as value, color, or any other attributes defined by the user.
- At each step of the simulation (referred to a day), a pixel is randomly replaced by another pixel from the grid, determined by a Julia function. The function typically considers the surrounding pixels, limited to eight (or fewer if the pixel is at the border).
- The game proceeds until the grid reaches a stable state where no pixel can be further replaced, although such a state may never be achieved.

## Usage

Refer to the [documentation](https://arnaud-ma.github.io/GridSim.jl/stable/).
