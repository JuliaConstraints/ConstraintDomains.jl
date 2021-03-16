"""
    δ_extrema(x)
Compute both the difference between the maximum and the minimum of `x`.
"""
function δ_extrema(x)
    δ_min, δ_max = extrema(x)
    return δ_max - δ_min
end
