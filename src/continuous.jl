## Abstract Continuous Domain
abstract type ContinuousDomain{T <: AbstractFloat} <: AbstractDomain end

# Continuous Interval structure
struct ContinuousInterval{T <: AbstractFloat} <: ContinuousDomain{T}
    start::T
    stop::T
    start_open::Bool
    stop_open::Bool
end

# Continuous Intervals
struct ContinuousIntervals{T <: AbstractFloat} <: ContinuousDomain{T}
    intervals::Vector{ContinuousInterval{T}}
end