## Abstract Continuous Domain
abstract type ContinuousDomain{T <: Real} <: AbstractDomain end

struct Intervals{T <: Real} <: ContinuousDomain{T}
    intervals::Vector{Interval{T}}
end

domain(a::Tuple{T, Bool}, b::Tuple{T, Bool}) where {T <: Real} = Intervals([Interval(a,b)])
function domain(intervals::Vector{Tuple{Tuple{T, Bool},Tuple{T, Bool}}}) where {T <: Real}
    return Intervals(map(i -> Interval(i...), intervals))
end

get_domain(itv::Intervals) = itv.intervals

Base.length(itv::Intervals) = sum(size, get_domain(itv); init = 0)

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

Base.in(x, itv::Intervals) = any(i -> x ∈ i, get_domain(itv))

function domain_size(itv::Intervals)
    itv_min = minimum(i -> PatternFolds.value(i, :a), get_domain(itv))
    itv_max = maximum(i -> PatternFolds.value(i, :b), get_domain(itv))
    return itv_max - itv_min
end