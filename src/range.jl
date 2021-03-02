struct RangeDomain{T <: Real, R <: AbstractRange{T}} <: AbstractDomain
    range::R
end

_length(rd::RangeDomain) = length(rd.range)

_draw(rd::RangeDomain) = rand(rd.range)

∈(value, rd::RangeDomain) = value ∈ rd.range

_domain_size(rd::RangeDomain) = extrema(rd.range)

domain(range::R) where {T <: Real, R <: AbstractRange{T}} = RangeDomain{T, R}(range)

_get_domain(d::RangeDomain) = d.range

_add!(d::AbstractDomain, value) = @debug """'add!' not implement yet for """ d
_delete!(d::AbstractDomain, value) = @debug """'delete!' not implement yet for """ d