using ConstraintDomains
using Documenter

makedocs(;
    modules=[ConstraintDomains],
    authors="Jean-François Baffier",
    repo="https://github.com/JuliaConstraints/ConstraintDomains.jl/blob/{commit}{path}#L{line}",
    sitename="ConstraintDomains.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", nothing) == "true",
        canonical="https://JuliaConstraints.github.io/ConstraintDomains.jl",
        assets = ["assets/favicon.ico"; "assets/github_buttons.js"; "assets/custom.css"],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/JuliaConstraints/ConstraintDomains.jl.git",
    devbranch="dev"
)
