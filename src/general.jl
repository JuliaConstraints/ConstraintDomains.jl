Base.eltype(::D) where {T, D <: Union{DiscreteDomain{T}, ContinuousDomain{T}}} = T

function Base.convert(::Intervals, d::RangeDomain{T}) where {T <: Real}
    @info "in convert" d
    a, b = extrema(get_domain(d))
    return domain((a, true), (b, true))
end

function Base.convert(::RangeDomain, d::Intervals{T}) where {T <: Real}
    @info "in convert" d
    i = get_domain(d)[1]
    a = value(i, :a) + (closed(i, :a) ? 0 : 1)
    b = value(i, :b) - (closed(i, :b) ? 0 : 1)
    return domain(a:b)
end