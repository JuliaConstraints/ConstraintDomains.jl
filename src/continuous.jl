## Abstract Continuous Domain
abstract type ContinuousDomain{T <: Real} <: AbstractDomain end

# Continuous Interval structure
struct ContinuousInterval{TA <: Real, TB <: Real} <: ContinuousDomain{Union{TA,TB}}
    a::Tuple{TA, Bool}
    b::Tuple{TB, Bool}
end

# Continuous Intervals
struct Intervals{T <: Real} <: ContinuousDomain{T}
    intervals::Set{ContinuousInterval{T}}
end

lesser(a::Tuple, x) = a[2] ? a[1] ≤ x : a[1] < x
greater(b::Tuple, x) = b[2] ? b[1] ≥ x : b[1] > x

_length(ci::ContinuousInterval) = ci.b[1] - ci.a[1]
_get_domain(ci::ContinuousInterval) = (ci.a, ci.b)
get_bounds(ci) = ci.a[1], ci.b[1]
_draw(ci::ContinuousInterval) = rand() * _length(ci) + ci.a[1]
∈(x, ci::ContinuousInterval) = lesser(ci.a, x) && greater(ci.b, x)

_domain(::Val{:continuous}, a, b) = ContinuousInterval(a , b)
function _domain(::Val{:continuous}, a::TA, b::TB) where {TA <: Real, TB <: Real}
    return _domain(Val(:continuous), (a, true), (b, true))
end

_domain_size(ci::ContinuousInterval) = ci.b[1] - ci.a[1]

domain(; a, b) = _domain(Val(:continuous), a, b)