"""
    DiscreteDomain{T <: Number} <: AbstractDomain
An abstract supertype for discrete domains (set, range).
"""
abstract type DiscreteDomain{T <: Number} <: AbstractDomain end

"""
    SetDomain{T <: Number} <: DiscreteDomain{T}
Domain that stores discrete values as a set of (unordered) points.
"""
struct SetDomain{T <: Number} <: DiscreteDomain{T}
    points::Set{T}
end
SetDomain(values) = SetDomain(Set(values))

"""
    RangeDomain
A discrete domain defined by a `range <: AbstractRange{Real}`. As ranges are immutable in Julia, changes in `RangeDomain` must use [`set_domain!`](@ref).
"""
struct RangeDomain{T <: Real, R <: AbstractRange{T}} <: DiscreteDomain{T}
    range::R
end

"""
    domain(values)
    domain(range::R) where {T <: Real, R <: AbstractRange{T}}
Construct either a [`SetDomain`](@ref) or a [RangeDomain](@ref).
```julia
d1 = domain(1:5)
d2 = domain([53.69, 89.2, 0.12])
d3 = domain([2//3, 89//123])
d4 = domain(4.3)
```
"""
domain(values) = SetDomain(values)
domain(range::R) where {T <: Real, R <: AbstractRange{T}} = RangeDomain{T, R}(range)

get_domain(d::RangeDomain) = d.range
get_domain(d::SetDomain) = d.points

set_domain!(d::RangeDomain, r) = d.range = r
set_domain!(d::SetDomain, points) = d.points = points

Base.length(d::D) where D <: DiscreteDomain = length(get_domain(d))
Base.rand(d::D) where D <: DiscreteDomain = rand(get_domain(d))
Base.in(value, d::D) where D <: DiscreteDomain = value ∈ get_domain(d)

domain_size(d::D) where D <: DiscreteDomain = δ_extrema(get_domain(d))

add!(d::SetDomain, val) = !(value ∈ d) && push!(d.points, val)
delete!(d::SetDomain, value) = pop!(get_domain(d), value)
