"""
    DiscreteDomain{T <: Number} <: AbstractDomain
An abstract supertype for discrete domains (set, range).
"""
abstract type DiscreteDomain{T} <: AbstractDomain end

"""
    SetDomain{T <: Number} <: DiscreteDomain{T}
Domain that stores discrete values as a set of (unordered) points.
"""
struct SetDomain{T} <: DiscreteDomain{T}
    domain::Set{T}
end
SetDomain(values) = SetDomain(Set(values))

"""
    RangeDomain
A discrete domain defined by a `range <: AbstractRange{Real}`. As ranges are immutable in Julia, changes in `RangeDomain` must use `set_domain!`.
"""
struct RangeDomain{T<:Real,R<:AbstractRange{T}} <: DiscreteDomain{T}
    domain::R
end

"""
    ArbitraryDomain{T} <: DiscreteDomain{T}

Ordered finite domain for arbitrary values, including non-numeric and non-hashable values.
The vector representation also gives deterministic neighborhood order.
"""
struct ArbitraryDomain{T, V <: AbstractVector{T}} <: DiscreteDomain{T}
    domain::V
end

function ArbitraryDomain(elements)
    values = collect(elements)
    allunique(values) || throw(ArgumentError("an arbitrary domain cannot contain duplicates"))
    return ArbitraryDomain{eltype(values), typeof(values)}(values)
end

"""Construct an ordered finite domain for arbitrary decision values."""
arbitrary_domain(elements) = ArbitraryDomain(elements)

"""Finite domain whose atomic values are complete set decisions."""
struct SetDecisionDomain{S <: AbstractSet, V <: AbstractVector{S}} <: DiscreteDomain{S}
    domain::V
end

"""Construct a finite domain whose atomic values are complete set decisions."""
function set_decision_domain(decisions)
    values = [copy(value) for value in decisions]
    all(value -> value isa AbstractSet, values) ||
        throw(ArgumentError("set decisions must be sets"))
    allunique(values) || throw(ArgumentError("a set decision domain cannot contain duplicates"))
    S = eltype(values)
    return SetDecisionDomain{S, typeof(values)}(values)
end

"""Finite domain whose atomic values are complete sequence decisions."""
struct SequenceDecisionDomain{S <: AbstractVector, V <: AbstractVector{S}} <:
       DiscreteDomain{S}
    domain::V
end

"""Construct a finite domain whose atomic values are complete sequence decisions."""
function sequence_domain(decisions)
    values = [copy(value) for value in decisions]
    all(value -> value isa AbstractVector, values) ||
        throw(ArgumentError("sequence decisions must be vectors"))
    allunique(values) ||
        throw(ArgumentError("a sequence decision domain cannot contain duplicates"))
    S = eltype(values)
    return SequenceDecisionDomain{S, typeof(values)}(values)
end

"""
    domain(values)
    domain(range::R) where {T <: Real, R <: AbstractRange{T}}
Construct either a `SetDomain` or a `RangeDomain`.
```julia
d1 = domain(1:5)
d2 = domain([53.69, 89.2, 0.12])
d3 = domain([2//3, 89//123])
d4 = domain(4.3)
d5 = domain(1,42,86.9)
```
"""
domain(values) = SetDomain(values)
domain(range::R) where {T<:Real,R<:AbstractRange{T}} = RangeDomain{T,R}(range)

"""
    Base.length(d::D) where D <: DiscreteDomain
Return the number of points in `d`.
"""
Base.length(d::D) where {D<:DiscreteDomain} = length(get_domain(d))

"""
    Base.rand(d::D) where D <: DiscreteDomain
Draw randomly a point in `d`.
"""
Base.rand(d::D) where {D<:DiscreteDomain} = rand(get_domain(d))

"""
    Base.in(value, d::D) where D <: DiscreteDomain
Return `true` if `value` is a point of `d`.
"""
Base.in(value, d::D) where {D<:DiscreteDomain} = value ∈ get_domain(d)

"""
    domain_size(d::D) where D <: DiscreteDomain
Return the maximum distance between two points in `d`.
"""
domain_size(d::DiscreteDomain{T}) where {T <: Number} = δ_extrema(get_domain(d))
domain_size(d::DiscreteDomain) = length(d)

"""
    add!(d::SetDomain, value)
Add `value` to the list of points in `d`.
"""
add!(d::SetDomain, value) = !(value ∈ d) && push!(get_domain(d), value)

"""
    Base.delete!(d::SetDomain, value)(d::SetDomain, value)
Delete `value` from the list of points in `d`.
"""
Base.delete!(d::SetDomain, value) = pop!(get_domain(d), value)


"""
    merge_domains(d₁::AbstractDomain, d₂::AbstractDomain)

Merge two domains of same nature (discrete/contiuous).
"""
function merge_domains(rd₁::RangeDomain, rd₂::RangeDomain)
    d₁ = get_domain(rd₁)
    d₂ = get_domain(rd₂)
    if step(d₁) == step(d₂) == 1
        a₁, b₁ = extrema(d₁)
        a₂, b₂ = extrema(d₂)
        a₂ < a₁ && return merge_domains(rd₂, rd₁)
        b₂ ≤ b₁ && return d₁
        a₂ ≤ b₁ + 1 && return a₁:b₂
    end
    return merge_domains(domain(Set(d₁)), rd₂)
end

@testitem "Arbitrary and compound decision domains" tags=[:domain, :discrete, :arbitrary] begin
    @enum Colour red green blue

    symbols = arbitrary_domain((:red, :green, :blue))
    colours = arbitrary_domain((red, green, blue))
    sets = set_decision_domain((Set((:a,)), Set((:a, :b)), Set((:b,))))
    sequences = sequence_domain(([:a, :b], [:b, :a]))

    @test collect(get_domain(symbols)) == [:red, :green, :blue]
    @test domain_size(symbols) == 3
    @test rand(colours) in (red, green, blue)
    @test Set((:a, :b)) in sets
    @test [:b, :a] in sequences
    @test eltype(symbols) === Symbol
    @test eltype(sets) <: AbstractSet
    @test_throws ArgumentError arbitrary_domain((:a, :a))
    @test_throws ArgumentError set_decision_domain((Set((:a,)), Set((:a,))))
    @test_throws ArgumentError sequence_domain(([:a], [:a]))
end
merge_domains(rd::RangeDomain, d::D) where {D<:DiscreteDomain} = merge_domains(d, rd)
function merge_domains(d₁::D1, d₂::D2) where {D1<:DiscreteDomain,D2<:DiscreteDomain}
    return union(get_domain(d₁), get_domain(d₂))
end

function intersect_domains(d₁::D1, d₂::D2) where {D1<:DiscreteDomain,D2<:DiscreteDomain}
    return intersect(get_domain(d₁), get_domain(d₂))
end

function to_domains(X, d::D) where {D<:DiscreteDomain}
    n::Int = length(first(X)) / domain_size(d)
    return fill(d, n)
end

Base.string(d::RangeDomain) = replace("$(d.domain[1]):$(d.domain[end])", " " => "")

Base.string(d::SetDomain) = replace(string(sort!(collect(d.domain))), " " => "")

## SECTION - Test Items
@testitem "DiscreteDomain" tags = [:domain, :discrete, :set] begin
    d1 = domain([4, 3, 2, 1])
    d2 = domain(1)
    foreach(i -> add!(d2, i), 2:4)
    domains = [d1, d2]

    for d in domains
        # constructors and ∈
        for x in [1, 2, 3, 4]
            @test x ∈ d
        end
        # length
        @test length(d) == 4
        # draw and ∈
        @test rand(d) ∈ d
        # add!
        add!(d, 5)
        @test 5 ∈ d
        # delete!
        delete!(d, 5)
        @test 5 ∉ d
        @test domain_size(d) == 3
    end
end

@testitem "RangeDomain" tags = [:domain, :discrete, :range] begin
    d1 = domain(1:5)
    d2 = domain(1:0.5:5)
    domains = [d1, d2]

    for d in domains
        for x in [1, 2, 3, 4, 5]
            @test x ∈ d
        end
        for x in [42]
            @test x ∉ d
        end
        @test rand(d) ∈ d
    end

end
