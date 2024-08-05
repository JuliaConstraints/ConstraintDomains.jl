"""
    Base.eltype(::AbstractDomain)

Extend `eltype` for domains.
"""
Base.eltype(::D) where {T,D<:Union{DiscreteDomain{T},ContinuousDomain{T}}} = T


"""
    Base.convert(::Type{Union{Intervals, RangeDomain}}, d::Union{Intervals, RangeDomain})

Extends `Base.convert` for domains.
"""
function Base.convert(::Type{Intervals}, d::RangeDomain{T}) where {T<:Real}
    a, b = extrema(get_domain(d))
    return domain(Interval{T,Closed,Closed}(a, b))
end

function Base.convert(::Type{RangeDomain}, d::Intervals{T}) where {T<:Real}
    i = get_domain(d)[1]
    a = Int(i.first)
    b = Int(i.last)
    return domain(a:b)
end

function Base.convert(::Type{RangeDomain}, d::SetDomain)
    return domain(collect(get_domain(d)))
end
