struct RangeDomain{T <: Real} <: AbstractDomain
    range::AbstractRange{T}
end

_length(rd::RangeDomain) = length(rd.range)

_draw(rd::RangeDomain) = rand(rd.range)

∈(value, rd::RangeDomain) = value ∈ rd.range

_domain_size(rd::RangeDomain) = extrema(rd.range)

domain(range::AbstractRange) = RangeDomain(range)