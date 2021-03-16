"""
    ContinuousDomain{T <: Real} <: AbstractDomain
An abstract supertype for all continuous domains.
"""
abstract type ContinuousDomain{T <: Real} <: AbstractDomain end

"""
    Intervals{T <: Real} <: ContinuousDomain{T}
An encapsuler to store a vector of `PatternFolds.Interval`. Dynamic changes to `Intervals` are not handled yet.
"""
struct Intervals{T <: Real} <: ContinuousDomain{T}
    intervals::Vector{Interval{T}}
end

"""
    domain(a::Tuple{T, Bool}, b::Tuple{T, Bool}) where {T <: Real}
    domain(intervals::Vector{Tuple{Tuple{T, Bool},Tuple{T, Bool}}}) where {T <: Real}
Construct a domain of continuous interval(s).
```julia
d1 = domain((0., true), (1., false)) # d1 = [0, 1)
d2 = domain([ # d2 = [0, 1) ∪ (3.5, 42]
    (0., true), (1., false),
    (3.5, false), (42., true),
])
"""
function domain(intervals::Vector{Tuple{Tuple{T, Bool},Tuple{T, Bool}}}) where {T <: Real}
    return Intervals(map(i -> Interval(i...), intervals))
end
domain(a::Tuple{T, Bool}, b::Tuple{T, Bool}) where {T <: Real} = domain([(a,b)])

"""
    get_domain(itv::Intervals)
Access the list of intervals of `itv`.
"""
get_domain(itv::Intervals) = itv.intervals

"""
    Base.length(itv::Intervals)
Return the sum of the length of each interval in `itv`.
"""
Base.length(itv::Intervals) = sum(size, get_domain(itv); init = 0)

"""
    Base.rand(itv::Intervals)
    Base.rand(itv::Intervals, i)
Return a random value from `itv`, specifically from the `i`th interval if `i` is specified.
"""
Base.rand(itv::Intervals, i) = rand(get_domain(itv)[i])
function Base.rand(itv::Intervals)
    r = length(itv) * rand()
    weight = 0.0
    for i in get_domain(itv)
        weight += size(i)
        weight > r && return rand(i)
    end
    return rand(itv, 1)
end

"""
    Base.in(x, itv::Intervals)
Return `true` if `x ∈ I` for any 'I ∈ itv`, false otherwise. `x ∈ I` is equivalent to
- `a < x < b` if `I = (a, b)`
- `a < x ≤ b` if `I = (a, b]`
- `a ≤ x < b` if `I = [a, b)`
- `a ≤ x ≤ b` if `I = [a, b]`
"""
Base.in(x, itv::Intervals) = any(i -> x ∈ i, get_domain(itv))

"""
    domain_size(itv::Intervals)
Return the difference between the highest and lowest values in `itv`.
"""
function domain_size(itv::Intervals)
    itv_min = minimum(i -> PatternFolds.value(i, :a), get_domain(itv))
    itv_max = maximum(i -> PatternFolds.value(i, :b), get_domain(itv))
    return itv_max - itv_min
end