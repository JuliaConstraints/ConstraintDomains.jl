Base.eltype(::D) where {T, D <: Union{DiscreteDomain{T}, ContinuousDomain{T}}} = T

function Base.convert(::Type{Intervals}, d::RangeDomain{T}) where {T <: Real}
    a, b = extrema(get_domain(d))
    return domain((Float64(a), true), (Float64(b), true))
end

function Base.convert(::Type{RangeDomain}, d::Intervals{T}) where {T <: Real}
    i = get_domain(d)[1]
    a = Int(value(i, :a) + (closed(i, :a) ? 0 : 1))
    b = Int(value(i, :b) - (closed(i, :b) ? 0 : 1))
    return domain(a:b)
end
