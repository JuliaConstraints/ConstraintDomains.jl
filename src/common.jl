"""
    AbstractDomain
An abstract super type for any domain type. A domain type `D <: AbstractDomain` must implement the following methods to properly interface `AbstractDomain`.
- `Base.∈(val, ::D)`
- `Base.rand(::D)`
- `Base.length(::D)` that is the number of elements in a discrete domain, and the distance between bounds or similar for a continuous domain
Addtionally, if the domain is used in a dynamic context, it can extend
- `add!(::D, args)`
- `delete!(::D, args)`
- `set_domain!(::D, args)`
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

# Generic fallback methods
Base.in(value, ::D) where D <: AbstractDomain = false
Base.rand(::D) where D <: AbstractDomain = @error "rand is not defined" d
Base.length(::D) where D <: AbstractDomain = 0
Base.isempty(d::D) where D <: AbstractDomain = length(d) == 0

domain_size(d::D) where D <: AbstractDomain = length(d)

