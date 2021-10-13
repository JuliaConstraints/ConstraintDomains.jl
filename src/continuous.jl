"""
    ContinuousDomain{T <: Real} <: AbstractDomain
An abstract supertype for all continuous domains.
"""
abstract type ContinuousDomain{T<:Real} <: AbstractDomain end

"""
    Intervals{T <: Real} <: ContinuousDomain{T}
An encapsuler to store a vector of `PatternFolds.Interval`. Dynamic changes to `Intervals` are not handled yet.
"""
struct Intervals{T<:Real,L,R} <: ContinuousDomain{T}
    domain::Vector{Interval{T,L,R}}
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
function domain(intervals::Vector{Interval{T,L,R}}) where {T<:Real,L,R}
    return Intervals(map(i -> Interval(i), intervals))
end
domain(interval::Interval) = domain([interval])
domain(intervals::Vector{I}) where {I<:Interval} = Intervals(intervals)

"""
    Base.length(itv::Intervals)
Return the sum of the length of each interval in `itv`.
"""
Base.length(itv::Intervals) = sum(size, get_domain(itv); init=0)

"""
    Base.rand(itv::Intervals)
    Base.rand(itv::Intervals, i)
Return a random value from `itv`, specifically from the `i`th interval if `i` is specified.
"""
Base.rand(itv::Intervals, i::Int) = rand(get_domain(itv)[i])
function Base.rand(itv::Intervals{T}) where {T<:Real}
    r = length(itv) * rand()
    weight = 0.0
    result = zero(T)
    for i in get_domain(itv)
        weight += size(i)
        if weight > r
            result = rand(i)
        end
    end
    return result
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
    return maximum(last, get_domain(itv)) - minimum(first, get_domain(itv))
end

function merge_domains(d1::D, d2::D) where {D<:ContinuousDomain}
end

function intersect_domains(i₁::I1, i₂::I2) where {I1<:Interval,I2<:Interval}
    a = a_ismore(i₁, i₂) ? i₁.a : i₂.a
    b = b_isless(i₁, i₂) ? i₁.b : i₂.b
    return Interval(a, b)
end

function intersect_domains!(is::IS, i::I, new_itvls) where {IS<:Intervals,I<:Interval}
    for interval in get_domain(is)
        intersection = intersect_domains(interval, i)
        !isempty(intersection) && push!(new_itvls, intersection)
    end
end

function intersect_domains(d₁::D, d₂::D) where {T<:Real,D<:ContinuousDomain{T}}
    new_itvls = Vector{Interval{T}}()
    for i in get_domain(d₂)
        intersect_domains!(d₁, i, new_itvls)
    end
    return Intervals(new_itvls)
end

size(i::I) where {I <: Interval} = span(i)
