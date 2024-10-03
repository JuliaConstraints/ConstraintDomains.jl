struct ExploreSettings
    complete_search_limit::Int
    max_samplings::Int
    search::Symbol
    solutions_limit::Int
end

"""
    ExploreSettings(
        domains;
        complete_search_limit = 10^6,
        max_samplings = sum(domain_size, domains),
        search = :flexible,
        solutions_limit = floor(Int, sqrt(max_samplings)),
    )

Settings for the exploration of a search space composed by a collection of domains.
"""
function ExploreSettings(
    domains;
    complete_search_limit=10^6,
    max_samplings=sum(domain_size, domains),
    search=:flexible,
    solutions_limit=floor(Int, sqrt(max_samplings)),
)
    return ExploreSettings(complete_search_limit, max_samplings, search, solutions_limit)
end

struct ExplorerState{T}
    best::Vector{T}
    solutions::Set{Vector{T}}
    non_solutions::Set{Vector{T}}

    ExplorerState{T}() where {T} = new{T}([], Set{Vector{T}}(), Set{Vector{T}}())
end

ExplorerState(domains) = ExplorerState{Union{map(eltype, domains)...}}()

struct Explorer{F1<:Function,D<:AbstractDomain,F2<:Union{Function,Nothing},T}
    concepts::Vector{F1}
    domains::Vector{D}
    objective::F2
    settings::ExploreSettings
    state::ExplorerState{T}

    function Explorer(concepts, domains, objective=nothing; settings=ExploreSettings(domains))
        F1 = Union{map(typeof, concepts)...}
        D = Union{map(typeof, domains)...}
        F2 = typeof(objective)
        T = Union{map(eltype, domains)...}
        return new{F1,D,F2,T}(concepts, domains, objective, settings, ExplorerState{T}())
    end
end

function update_exploration!(explorer, f, c, search=explorer.settings.search)
    solutions = explorer.state.solutions
    non_sltns = explorer.state.non_solutions
    obj = explorer.objective
    sl = search == :complete ? Inf : explorer.settings.solutions_limit

    cv = collect(c)
    if f(cv)
        if length(solutions) < sl
            push!(solutions, cv)
            obj !== nothing && (explorer.state.best = argmin(obj, solutions))
        end
    else
        if length(non_sltns) < sl
            push!(non_sltns, cv)
        end
    end
    return nothing
end

"""
    _explore(args...)

Internals of the `explore` function. Behavior is automatically adjusted on the kind of exploration: `:flexible`, `:complete`, `:partial`.
"""
function _explore!(explorer, f, ::Val{:partial})
    sl = explorer.settings.solutions_limit
    ms = explorer.settings.max_samplings

    solutions = explorer.state.solutions
    non_sltns = explorer.state.non_solutions
    domains = explorer.domains

    for _ = 1:ms
        length(solutions) ≥ sl && length(non_sltns) ≥ sl && break
        config = map(rand, domains)
        update_exploration!(explorer, f, config)
    end
    return nothing
end

function _explore!(explorer, f, ::Val{:complete})
    configurations = Base.Iterators.product(map(d -> get_domain(d), explorer.domains)...)
    foreach(c -> update_exploration!(explorer, f, c, :complete), configurations)
    return nothing
end

function _explore!(explorer::Explorer)
    c = x -> all([f(x) for f in explorer.concepts])
    s = explorer.settings
    search = s.search
    if search == :flexible
        search = s.max_samplings < s.complete_search_limit ? :complete : :partial
    end
    return _explore!(explorer, c, Val(search))
end

"""
    explore(domains, concept, param = nothing; search_limit = 1000, solutions_limit = 100)

Search (a part of) a search space and returns a pair of vector of configurations: `(solutions, non_solutions)`. If the search space size is over `search_limit`, then both `solutions` and `non_solutions` are limited to `solutions_limit`.

Beware that if the density of the solutions in the search space is low, `solutions_limit` needs to be reduced. This process will be automatic in the future (simple reinforcement learning).

# Arguments:
- `domains`: a collection of domains
- `concept`: the concept of the targeted constraint
- `param`: an optional parameter of the constraint
- `sol_number`: the required number of solutions (half of the number of configurations), default to `100`
"""
function explore(domains, concept; settings=ExploreSettings(domains), parameters...)
    f = x -> concept(x; parameters...)
    explorer = Explorer([f], domains; settings)
    _explore!(explorer)
    return explorer.state.solutions, explorer.state.non_solutions
end

## SECTION - Test Items
@testitem "Exploration" tags = [:exploration] begin
    domains = [domain([1, 2, 3, 4]) for i = 1:4]
    X, X̅ = explore(domains, allunique)
    @test length(X) == factorial(4)
    @test length(X̅) == 4^4 - factorial(4)
end
