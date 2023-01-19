struct ExploreSettings
    complete_search_limit::Int
    max_samplings::Int
    search::Symbol
    solutions_limit::Int
end

function ExploreSettings(
    domains;
    complete_search_limit = 10^6,
    max_samplings = sum(domain_size, domains),
    search = :flexible,
    solutions_limit = floor(Int, sqrt(max_samplings)),
)
    return ExploreSettings(complete_search_limit, max_samplings, search, solutions_limit)
end

function _explore(domains, f, s, ::Val{:partial})
    solutions = Set{Vector{Int}}()
    non_sltns = Set{Vector{Int}}()

    sl = s.solutions_limit

    for _ in 1:s.max_samplings
        length(solutions) ≥ sl && length(non_sltns) ≥ sl && break
        config = map(rand, domains)
        c = f(config) ? solutions : non_sltns
        length(c) < sl && push!(c, config)
    end
    return solutions, non_sltns
end

function _explore(domains, f, ::ExploreSettings, ::Val{:complete})
    solutions = Set{Vector{Int}}()
    non_sltns = Set{Vector{Int}}()

    configurations = Base.Iterators.product(map(d -> get_domain(d), domains)...)
    foreach(
        c -> (cv = collect(c); push!(f(cv) ? solutions : non_sltns, cv)),
        configurations,
    )
    return solutions, non_sltns
end

function _explore(domains, f, s, ::Val{:flexible})
    search = s.max_samplings < s.complete_search_limit ? :complete : :partial
    return _explore(domains, f, s, Val(search))
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
function explore(
    domains,
    concept;
    settings = ExploreSettings(domains),
    parameters...
)
    f = x -> concept(x; parameters...)
    return _explore(domains, f, settings, Val(settings.search))
end
