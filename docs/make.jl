using ConstraintDomains
using Documenter

makedocs(;
    modules=[ConstraintDomains],
    authors="Jean-François Baffier",
    repo="https://github.com/JuliaConstraints/ConstraintDomains.jl/blob/{commit}{path}#L{line}",
    sitename="ConstraintDomains.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://JuliaConstraints.github.io/ConstraintDomains.jl",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/JuliaConstraints/ConstraintDomains.jl",
)
