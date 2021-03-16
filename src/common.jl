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

"""
    Base.in(value, d <: AbstractDomain)
Fallback method for `value ∈ d` that returns `false`.
"""
Base.in(value, ::D) where D <: AbstractDomain = false

"""
    Base.rand(d <: AbstractDomain)
Fallback method for `length(d)` that return `0`.
"""
Base.length(::D) where D <: AbstractDomain = 0

"""
    Base.isempty(d <: AbstractDomain)
Fallback method for `isempty(d)` that return `length(d) == 0` which default to `0`.
"""
Base.isempty(d::D) where D <: AbstractDomain = length(d) == 0

"""
    domain_size(d <: AbstractDomain)
Fallback method for `domain_size(d)` that return `length(d)`.
"""
domain_size(d::D) where D <: AbstractDomain = length(d)

"""
    get_domain(::AbstractDomain)
Access the internal structure of any domain type.
"""
get_domain(d::D) where {D <: AbstractDomain} = d.domain