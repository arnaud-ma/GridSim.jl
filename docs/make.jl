using GridSim
using Documenter

DocMeta.setdocmeta!(GridSim, :DocTestSetup, :(using GridSim); recursive=true)

# Set the environment variable to avoid line wrapping in the terminal
ENV["COLUMNS"] = 1000

makedocs(;
    modules=[GridSim],
    authors="arnaud-ma <84045859+arnaud-ma@users.noreply.github.com> and contributors",
    repo="https://github.com/arnaud-ma/GridSim.jl/blob/{commit}{path}#{line}",
    sitename="GridSim.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://arnaud-ma.github.io/GridSim.jl",
        edit_link="main",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
        "Getting Started" => "starting.md",
        "Example" => "example.md",
        "API Reference" => ["Public API" => "lib/public.md", "Private API" => "lib/private.md"],
        "License" => "license.md",
    ],
)

deploydocs(;
    repo="github.com/arnaud-ma/GridSim.jl",
    devbranch="main",
)
