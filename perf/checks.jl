using BenchmarkTools
using CairoMakie
using Chairmarks
using PerfChecker

@info "Defining utilities"

d_commons = Dict(
    :targets => ["ConstraintDomains"],
    :path => @__DIR__,
    :pkgs => ("ConstraintDomains", :custom, [v"0.2.5", v"0.3.0", v"0.3.10"], true),
    :seconds => 100,
    :samples => 10,
    :evals => 10,
)

## SECTION - Utilities
tags(d) = mapreduce(x -> string(x), (y, z) -> y * "_" * z, d[:tags])

function visu(x, d, ::Val{:allocs})
    mkpath(joinpath(@__DIR__, "visuals"))
    c = checkres_to_scatterlines(x, Val(:alloc))
    save(joinpath(@__DIR__, "visuals", "allocs_evolution_$(tags(d)).png"), c)

    for (name, c2) in checkres_to_pie(x, Val(:alloc))
        save(joinpath(@__DIR__, "visuals", "allocs_pie_$(name)_$(tags(d)).png"), c2)
    end
end

function visu(x, d, ::Val{:benchmark})
    mkpath(joinpath(d[:path], "visuals"))
    c = checkres_to_scatterlines(x, Val(:benchmark))
    save(joinpath(d[:path], "visuals", "bench_evolution_$(tags(d)).png"), c)

    for kwarg in [:times, :gctimes, :memory, :allocs]
        c2 = checkres_to_boxplots(x, Val(:benchmark); kwarg)
        save(joinpath(d[:path], "visuals", "bench_boxplots_$(kwarg)_$(tags(d)).png"), c2)
    end
end

function visu(x, d, ::Val{:chairmark})
    mkpath(joinpath(d[:path], "visuals"))
    c = checkres_to_scatterlines(x, Val(:chairmark))
    save(joinpath(d[:path], "visuals", "chair_evolution_$(tags(d)).png"), c)

    for kwarg in [:times, :gctimes, :bytes, :allocs]
        c2 = checkres_to_boxplots(x, Val(:chairmark); kwarg)
        save(joinpath(d[:path], "visuals", "chair_boxplots_$(kwarg)_$(tags(d)).png"), c2)
    end
end

## SECTION - Commons: benchmarks and chairmarks

@info "Running checks: Commons"

d = deepcopy(d_commons)
d[:tags] = [:common]

x = @check :benchmark d begin
    using ConstraintDomains
end begin
    ed = domain()
    domain_size(ed) == 0 == length(ed)
    isempty(ed)
    π ∉ ed
end

visu(x, d, Val(:benchmark))

x = @check :chairmark d begin
    using ConstraintDomains
end begin
    ed = domain()
    domain_size(ed) == 0 == length(ed)
    isempty(ed)
    π ∉ ed
end

visu(x, d, Val(:chairmark))

## SECTION - Continuous: benchmarks and chairmarks

@info "Running checks: Continuous"

d = deepcopy(d_commons)
d[:tags] = [:continuous]

x = @check :benchmark d begin
    using ConstraintDomains
    using Intervals
end begin
    if d[:current_version] < v"0.3.0"
        d1 = domain((1.0, true), (3.15, true))
        d2 = domain((-42.42, false), (5.0, false))
    else
        d1 = domain(1.0 .. 3.15)
        d2 = domain(Interval{Open,Open}(-42.42, 5.0))
    end
    domains = [d1, d2]
    for d in domains
        for x in [1, 2.3, π]
            x ∈ d
        end
        for x in [5.1, π^π, Inf]
            x ∉ d
        end
        rand(d) ∈ d
        rand(d, 1) ∈ d
        domain_size(d) > 0.0
    end
end

visu(x, d, Val(:benchmark))

x = @check :chairmark d begin
    using ConstraintDomains
    using Intervals
end begin
    if d[:current_version] < v"0.3.0"
        d1 = domain((1.0, true), (3.15, true))
        d2 = domain((-42.42, false), (5.0, false))
    else
        d1 = domain(1.0 .. 3.15)
        d2 = domain(Interval{Open,Open}(-42.42, 5.0))
    end
    domains = [d1, d2]
    for d in domains
        for x in [1, 2.3, π]
            x ∈ d
        end
        for x in [5.1, π^π, Inf]
            x ∉ d
        end
        rand(d) ∈ d
        rand(d, 1) ∈ d
        domain_size(d) > 0.0
    end
end

visu(x, d, Val(:chairmark))

## SECTION - Discrete: benchmarks and chairmarks

@info "Running checks: Discrete"

d = deepcopy(d_commons)
d[:tags] = [:discrete]

x = @check :benchmark d begin
    using ConstraintDomains
end begin
    d1 = domain([4, 3, 2, 1])
    d2 = domain(1)
    foreach(i -> add!(d2, i), 2:4)
    domains = [d1, d2]
    for d in domains
        for x in [1, 2, 3, 4]
            x ∈ d
        end
        length(d) == 4
        rand(d) ∈ d
        add!(d, 5)
        5 ∈ d
        delete!(d, 5)
        5 ∉ d
        domain_size(d) == 3
    end

    d3 = domain(1:5)
    d4 = domain(1:0.5:5)
    domains2 = [d3, d4]
    for d in domains2
        for x in [1, 2, 3, 4, 5]
            x ∈ d
        end
        for x in [42]
            x ∉ d
        end
        rand(d) ∈ d
    end
end

visu(x, d, Val(:benchmark))

x = @check :chairmark d begin
    using ConstraintDomains
end begin
    d1 = domain([4, 3, 2, 1])
    d2 = domain(1)
    foreach(i -> add!(d2, i), 2:4)
    domains = [d1, d2]
    for d in domains
        for x in [1, 2, 3, 4]
            x ∈ d
        end
        length(d) == 4
        rand(d) ∈ d
        add!(d, 5)
        5 ∈ d
        delete!(d, 5)
        5 ∉ d
        domain_size(d) == 3
    end

    d3 = domain(1:5)
    d4 = domain(1:0.5:5)
    domains2 = [d3, d4]
    for d in domains2
        for x in [1, 2, 3, 4, 5]
            x ∈ d
        end
        for x in [42]
            x ∉ d
        end
        rand(d) ∈ d
    end
end

visu(x, d, Val(:chairmark))

## SECTION - Explore: benchmarks and chairmarks

@info "Running checks: Explore"

d = deepcopy(d_commons)
d[:tags] = [:explore]
d[:pkgs] = ("ConstraintDomains", :custom, [v"0.3.1", v"0.3.10"], true)

# x = @check :allocs d begin
#     using ConstraintDomains
# end begin
#     domains = [domain([1, 2, 3, 4]) for i = 1:4]
#     X, X̅ = explore(domains, allunique)
#     length(X) == factorial(4)
#     length(X̅) == 4^4 - factorial(4)
# end

# visu(x, d, Val(:allocs))

x = @check :benchmark d begin
    using ConstraintDomains
end begin
    domains = [domain([1, 2, 3, 4]) for i = 1:4]
    X, X̅ = explore(domains, allunique)
    length(X) == factorial(4)
    length(X̅) == 4^4 - factorial(4)
end

visu(x, d, Val(:benchmark))

x = @check :chairmark d begin
    using ConstraintDomains
end begin
    domains = [domain([1, 2, 3, 4]) for i = 1:4]
    X, X̅ = explore(domains, allunique)
    length(X) == factorial(4)
    length(X̅) == 4^4 - factorial(4)
end

visu(x, d, Val(:chairmark))

# TODO: add more checks for parameters.jl

@info "All checks have been successfully run!"
