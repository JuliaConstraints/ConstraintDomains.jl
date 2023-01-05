Base.eltype(::D) where {T, D <: Union{DiscreteDomain{T}, ContinuousDomain{T}}} = T

function Base.convert(::Type{Intervals}, d::RangeDomain{T}) where {T <: Real}
    a, b = extrema(get_domain(d))
    return domain(Float64(a)..Float64(b))
end

function Base.convert(::Type{RangeDomain}, d::Intervals{T}) where {T <: Real}
    i = get_domain(d)[1]
    a = Int(i.first)
    b = Int(i.last)
    return domain(a:b)
end
