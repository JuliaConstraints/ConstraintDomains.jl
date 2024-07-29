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
    complete_search_limit = 10^6,
    max_samplings = sum(domain_size, domains),
    search = :flexible,
    solutions_limit = floor(Int, sqrt(max_samplings)),
)
    return ExploreSettings(complete_search_limit, max_samplings, search, solutions_limit)
end

"""
    _explore(args...)

Internals of the `explore` function. Behavior is automatically adjusted on the kind of exploration: `:flexible`, `:complete`, `:partial`.
"""
function _explore(domains, f, s, ::Val{:partial})
    solutions = Set{Vector{Int}}()
    non_sltns = Set{Vector{Int}}()

    sl = s.solutions_limit

    for _ = 1:s.max_samplings
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
function explore(domains, concept; settings = ExploreSettings(domains), parameters...)
    f = x -> concept(x; parameters...)
    return _explore(domains, f, settings, Val(settings.search))
end

## SECTION - Test Items
@testitem "Exploration" tags = [:exploration] begin
    domains = [domain([1, 2, 3, 4]) for i = 1:4]
    X, X̅ = explore(domains, allunique)
    @test length(X) == factorial(4)
    @test length(X̅) == 4^4 - factorial(4)
end
