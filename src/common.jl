"""
    AbstractDomain
An abstract super type for any domain type. A domain type `D <: AbstractDomain` must implement the following methods to properly interface `AbstractDomain`.
- `Base.∈(val, ::D)`
- `Base.rand(::D)`
- `Base.length(::D)` that is the number of elements in a discrete domain, and the distance between bounds or similar for a continuous domain
Addtionally, if the domain is used in a dynamic context, it can extend
- `add!(::D, args)`
- `delete!(::D, args)`
where `args` depends on `D`'s structure
"""
abstract type AbstractDomain end

"""
    EmptyDomain
A struct to handle yet to be defined domains.
"""
struct EmptyDomain <: AbstractDomain end

"""
    domain()
Construct an [`EmptyDomain`](@ref).
"""
domain() = EmptyDomain()

domain(values...) = domain(collect(values))

"""
    Base.in(value, d <: AbstractDomain)
Fallback method for `value ∈ d` that returns `false`.
"""
Base.in(value, ::D) where {D<:AbstractDomain} = false

"""
    Base.rand(d <: AbstractDomain)
Fallback method for `length(d)` that return `0`.
"""
Base.length(::D) where {D<:AbstractDomain} = 0

"""
    Base.isempty(d <: AbstractDomain)
Fallback method for `isempty(d)` that return `length(d) == 0` which default to `0`.
"""
Base.isempty(d::D) where {D<:AbstractDomain} = length(d) == 0

"""
    domain_size(d <: AbstractDomain)
Fallback method for `domain_size(d)` that return `length(d)`.
"""
domain_size(d::D) where {D<:AbstractDomain} = length(d)

"""
    get_domain(::AbstractDomain)
Access the internal structure of any domain type.
"""
get_domain(d::D) where {D<:AbstractDomain} = d.domain

"""
    to_domains(args...)

Convert various arguments into valid domains format.
"""
to_domains(domain_sizes::Vector{Int}) = map(ds -> domain(0:ds), domain_sizes)

function to_domains(X, ds::Int=δ_extrema(X) + 1)
    d = domain(0:ds-1)
    return fill(d, length(first(X)))
end

to_domains(X, ::Nothing) = to_domains(X)

"""
    Base.rand(d::Union{Vector{D},Set{D}, D}) where {D<:AbstractDomain}

Extends `Base.rand` to (a collection of) domains.
"""
Base.rand(d::AbstractDomain) = rand(get_domain(d))

Base.rand(d::Union{Vector{D},Set{D}}) where {D<:AbstractDomain} = map(rand, d)

function Base.rand(d::V) where {D<:AbstractDomain,U<:Union{Vector{D},Set{D}},V<:AbstractVector{U}}
    return map(rand, d)
end

"""
    Base.string(D::Vector{<:AbstractDomain})
    Base.string(d<:AbstractDomain)

Extends the `string` method to (a vector of) domains.
"""
function Base.string(D::Vector{<:AbstractDomain})
    return replace(
        "[$(prod(d -> string(d) * ',', D)[1:end-1])]",
        " " => "",
    )
end
Base.string(d::AbstractDomain) = replace(string(d.domain), " " => "")

## SECTION - Test Items
@testitem "EmptyDomain" tags = [:domains, :empty] begin
    ed = domain()
    @test domain_size(ed) == 0 == length(ed)
    @test isempty(ed)
    @test π ∉ ed
end
