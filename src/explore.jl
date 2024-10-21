struct ExploreSettings
    complete_search_limit::Int
    max_samplings::Int
    search::Symbol
    solutions_limit::Int
end

"""
    ExploreSettings(domains;
                    complete_search_limit = 10^6,
                    max_samplings = sum(domain_size, domains),
                    search = :flexible,
                    solutions_limit = floor(Int, sqrt(max_samplings)))

Create an `ExploreSettings` object to configure the exploration of a search space composed of a collection of domains.

# Arguments
- `domains`: A collection of domains to be explored.
- `complete_search_limit`: An integer specifying the maximum limit for complete search iterations. Default is 10^6.
- `max_samplings`: An integer specifying the maximum number of samplings. Default is the sum of domain sizes.
- `search`: A symbol indicating the type of search to perform. Default is `:flexible`.
- `solutions_limit`: An integer specifying the limit on the number of solutions. Default is the floor of the square root of `max_samplings`.

# Returns
- `ExploreSettings` object with the specified settings.
"""
function ExploreSettings(
    domains;
    complete_search_limit=10^6,
    max_samplings=sum(domain_size, domains; init=0),
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

mutable struct Explorer{F1<:Function,D<:AbstractDomain,F2<:Union{Function,Nothing},T}
    concepts::Dict{Int,Tuple{F1,Vector{Int}}}
    domains::Dict{Int,D}
    objective::F2
    settings::ExploreSettings
    state::ExplorerState{T}

    function Explorer(
        concepts,
        domains,
        objective=nothing;
        settings=ExploreSettings(domains),
    )
        F1 = isempty(concepts) ? Function : Union{map(c -> typeof(c[1]), concepts)...}
        D = isempty(domains) ? AbstractDomain : Union{map(typeof, domains)...}
        F2 = typeof(objective)
        T = isempty(domains) ? Real : Union{map(eltype, domains)...}
        d_c = Dict(enumerate(concepts))
        d_d = Dict(enumerate(domains))
        return new{F1,D,F2,T}(d_c, d_d, objective, settings, ExplorerState{T}())
    end
end

function Explorer()
    concepts = Vector{Tuple{Function,Vector{Int}}}()
    domains = Vector{AbstractDomain}()
    objective = nothing
    settings = ExploreSettings(domains)
    return Explorer(concepts, domains, objective; settings)
end

function Base.push!(explorer::Explorer, concept::Tuple{Function,Vector{Int}})
    max_key = maximum(keys(explorer.concepts); init=0)
    explorer.concepts[max_key+1] = concept
    return max_key + 1
end

function delete_concept!(explorer::Explorer, key::Int)
    delete!(explorer.concepts, key)
    return nothing
end

function Base.push!(explorer::Explorer, domain::AbstractDomain)
    max_key = maximum(keys(explorer.domains); init=0)
    explorer.domains[max_key+1] = domain
    return max_key + 1
end

function delete_domain!(explorer::Explorer, key::Int)
    delete!(explorer.domains, key)
    return nothing
end

set!(explorer::Explorer, objective::Function) = explorer.objective = objective

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
function _explore!(explorer, f, ::Val{:partial};)
    sl = explorer.settings.solutions_limit
    ms = explorer.settings.max_samplings

    solutions = explorer.state.solutions
    non_sltns = explorer.state.non_solutions
    domains = explorer.domains |> values

    for _ = 1:ms
        length(solutions) ≥ sl && length(non_sltns) ≥ sl && break
        config = map(rand, domains)
        update_exploration!(explorer, f, config)
    end
    return nothing
end

function _explore!(explorer, f, ::Val{:complete})
    C = Base.Iterators.product(map(d -> get_domain(d), explorer.domains |> values)...)
    foreach(c -> update_exploration!(explorer, f, c, :complete), C)
    return nothing
end

function explore!(explorer::Explorer)
    c =
        x -> all([
            f(isempty(vars) ? x : @view x[vars]) for
            (f, vars) in explorer.concepts |> values
        ])
    s = explorer.settings
    search = s.search
    if search == :flexible
        search = s.max_samplings < s.complete_search_limit ? :complete : :partial
    end
    return _explore!(explorer, c, Val(search))
end

"""
    explore(domains, concept; settings = ExploreSettings(domains), parameters...)

Search (a part of) a search space and return a pair of vectors of configurations: `(solutions, non_solutions)`. The exploration behavior is determined based on the `settings`.

# Arguments
- `domains`: A collection of domains to be explored.
- `concept`: The concept representing the constraint to be targeted.
- `settings`: An optional `ExploreSettings` object to configure the exploration. Default is `ExploreSettings(domains)`.
- `parameters...`: Additional parameters for the `concept`.

# Returns
- A tuple of sets: `(solutions, non_solutions)`.
"""
function explore(domains, concept; settings=ExploreSettings(domains), parameters...)
    f = x -> concept(x; parameters...)
    explorer = Explorer([(f, Vector{Int}())], domains; settings)
    explore!(explorer)
    return explorer.state.solutions, explorer.state.non_solutions
end

function _check!(explorer, configurations)
    g =
        x -> all([
            f(isempty(vars) ? x : @view x[vars]) for
            (f, vars) in explorer.concepts |> values
        ])
    foreach(c -> update_exploration!(explorer, g, c, :complete), configurations)
    return nothing
end

## SECTION - Test Items
@testitem "Exploration" tags = [:exploration] begin
    domains = [domain([1, 2, 3, 4]) for i = 1:4]
    X, X̅ = explore(domains, allunique)
    @test length(X) == factorial(4)
    @test length(X̅) == 4^4 - factorial(4)

    explorer = ConstraintDomains.Explorer()
end
