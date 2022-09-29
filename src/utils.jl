"""
    δ_extrema(x)
Compute both the difference between the maximum and the minimum of `x`.
"""
function δ_extrema(X)
    mn, mx = extrema(Iterators.flatten(X))
    return mx - mn
end

function δ_extrema(X, Y)
    mnx, mxx = extrema(Iterators.flatten(X))
    mny, mxy = extrema(Iterators.flatten(Y))
    return max(mxx, mxy) - min(mnx, mny)
end

to_domains(domain_sizes::Vector{Int}) = map(ds -> domain(0:ds), domain_sizes)

function to_domains(X, ds::Int = δ_extrema(X) + 1)
    d = domain(0:ds-1)
    return fill(d, length(first(X)))
end

to_domains(X, ::Nothing) = to_domains(X)

function oversample(X, f)
    X_true = Vector{eltype(X)}()
    X_false = Vector{eltype(X)}()

    μ = minimum(f, X)

    foreach(x -> push!(f(x) == μ ? X_true : X_false, x), X)

    b = length(X_true) > length(X_false)
    Y = reverse(b ? X_true : X_false)
    it = Iterators.cycle(b ? X_false : X_true)

    Z = Vector{eltype(X)}()
    l = length(Y)
    for (i, x) in enumerate(it)
        push!(Z, x, Y[i])
        i == l && break
    end

    return Z
end
