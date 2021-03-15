"""
    δ_extrema(x)
Compute both the difference between the maximum and the minimum of `x`.
"""
function δ_extrema(x)
    δ_min, δ_max = extrema(x)
    return δ_max - δ_min
end

# Simply extend set constructor to accept tuple of entries
Base.Set(x...) = Set(x)

# Type simplification
const TI{T} = Tuple{Tuple{T, Bool},Tuple{T, Bool}}
