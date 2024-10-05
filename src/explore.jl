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

Create settings for the exploration of a search space composed by a collection of domains.

# Arguments
- `domains`: A collection of domains representing the search space.
- `complete_search_limit`: Maximum size of the search space for complete search.
- `max_samplings`: Maximum number of samples to take during partial search.
- `search`: Search strategy (`:flexible`, `:complete`, or `:partial`).
- `solutions_limit`: Maximum number of solutions to store.

# Returns
An `ExploreSettings` object.

# Example
```julia
domains = [domain([1, 2, 3]), domain([4, 5, 6])]
settings = ExploreSettings(domains, search = :complete)
```
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
end

"""
Explorer(concepts, domains, objective = nothing; settings = ExploreSettings(domains))

Create an Explorer object for searching a constraint satisfaction problem space.

# Arguments
- `concepts`: A collection of tuples, each containing a concept function and its associated variable indices.
- `domains`: A collection of domains representing the search space.
- `objective`: An optional objective function for optimization problems.
- `settings`: An `ExploreSettings` object to configure the exploration process.

# Returns
An `Explorer` object ready for exploration.

# Example
```julia
domains = [domain([1, 2, 3]), domain([4, 5, 6])]
concepts = [(sum, [1, 2])]
objective = x -> x[1] + x[2]
explorer = Explorer(concepts, domains, objective)
```
"""
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
    return Explorer{F1,D,F2,T}(d_c, d_d, objective, settings, ExplorerState{T}())
end

function Explorer()
    concepts = Vector{Tuple{Function,Vector{Int}}}()
    domains = Vector{AbstractDomain}()
    objective = nothing
    settings = ExploreSettings(domains)
    return Explorer(concepts, domains, objective; settings)
end

"""
    push!(explorer::Explorer, concept::Tuple{Function,Vector{Int}})

Add a new concept to the `Explorer` object.

# Arguments
- `explorer`: The `Explorer` object to modify.
- `concept`: A tuple containing a concept function and its associated variable indices.

# Returns
The key (index) of the newly added concept.

# Example
```julia
explorer = Explorer()
key = push!(explorer, (sum, [1, 2]))
```
"""
function Base.push!(explorer::Explorer, concept::Tuple{Function,Vector{Int}})
    max_key = maximum(keys(explorer.concepts); init=0)
    explorer.concepts[max_key+1] = concept
    return max_key + 1
end

"""
    delete_concept!(explorer::Explorer, key::Int)

Remove a concept from the `Explorer` object by its key.

# Arguments
- `explorer`: The `Explorer` object to modify.
- `key`: The key (index) of the concept to remove.

# Returns
Nothing. The `Explorer` object is modified in-place.

# Example
```julia
explorer = Explorer([(sum, [1, 2])], [domain([1, 2, 3])])
delete_concept!(explorer, 1)
```
"""
function delete_concept!(explorer::Explorer, key::Int)
    delete!(explorer.concepts, key)
    return nothing
end

"""
    push!(explorer::Explorer, domain::AbstractDomain)

Add a new domain to the `Explorer` object.

# Arguments
- `explorer`: The `Explorer` object to modify.
- `domain`: An `AbstractDomain` object to add to the search space.

# Returns
The key (index) of the newly added domain.

# Example
```julia
explorer = Explorer()
key = push!(explorer, domain([1, 2, 3]))
```
"""
function Base.push!(explorer::Explorer, domain::AbstractDomain)
    max_key = maximum(keys(explorer.domains); init=0)
    explorer.domains[max_key+1] = domain
    return max_key + 1
end

"""
    delete_domain!(explorer::Explorer, key::Int)

Remove a domain from the `Explorer` object by its key.

# Arguments
- `explorer`: The `Explorer` object to modify.
- `key`: The key (index) of the domain to remove.

# Returns
Nothing. The `Explorer` object is modified in-place.

# Example
```julia
explorer = Explorer([], [domain([1, 2, 3])])
delete_domain!(explorer, 1)
```
"""
function delete_domain!(explorer::Explorer, key::Int)
    delete!(explorer.domains, key)
    return nothing
end

"""
    set!(explorer::Explorer, objective::Function)

Set the objective function for the `Explorer` object.

# Arguments
- `explorer`: The `Explorer` object to modify.
- `objective`: A function to use as the objective for optimization.

# Returns
Nothing. The `Explorer` object is modified in-place.

# Example
```julia
explorer = Explorer()
set!(explorer, x -> sum(x))
```
"""
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

Internals of the `explore!` function. Behavior is automatically adjusted on the kind of exploration: `:flexible`, `:complete`, `:partial`.
"""
function _explore!(explorer, f, ::Val{:partial})
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

"""
    explore!(explorer::Explorer)

Perform exploration on the search space defined by the `Explorer` object.

This function explores the search space according to the settings specified in the `Explorer` object.
It updates the `Explorer`'s state with found solutions and non-solutions.

# Arguments
- `explorer`: An `Explorer` object containing the problem definition and exploration settings.

# Returns
Nothing. The `Explorer`'s state is updated in-place.

# Example
```julia
explorer = Explorer(concepts, domains)
explore!(explorer)
println("Solutions found: ", length(explorer.state.solutions))
```
"""
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

Explore a search space defined by domains and a concept.

# Arguments
- `domains`: A collection of domains representing the search space.
- `concept`: The concept function defining the constraint.
- `settings`: An `ExploreSettings` object to configure the exploration process.
- `parameters`: Additional parameters to pass to the concept function.

# Returns
A tuple containing two sets: (solutions, non_solutions).

# Example
```julia
domains = [domain([1, 2, 3]), domain([4, 5, 6])]
solutions, non_solutions = explore(domains, allunique)
```
"""
function explore(domains, concept; settings=ExploreSettings(domains), parameters...)
    f = x -> concept(x; parameters...)
    explorer = Explorer([(f, Vector{Int}())], domains; settings)
    explore!(explorer)
    return explorer.state.solutions, explorer.state.non_solutions
end

## SECTION - Test Items
@testitem "Exploration" tags = [:exploration] begin
    domains = [domain([1, 2, 3, 4]) for i = 1:4]
    X, X̅ = explore(domains, allunique)
    @test length(X) == factorial(4)
    @test length(X̅) == 4^4 - factorial(4)

    explorer = ConstraintDomains.Explorer()
end
