struct BoolParameterDomain <: AbstractDomain end
generate_parameters(_, ::Val{:bool}) = BoolParameterDomain()
Base.rand(::BoolParameterDomain) = rand(Bool)
struct DimParameterDomain <: AbstractDomain
    max_dimendion::Int
end
generate_parameters(d, ::Val{:dim}) = DimParameterDomain(floor(Int, √(length(d))))
Base.rand(d::DimParameterDomain) = rand(1:d.max_dimendion)

struct IdParameterDomain <: AbstractDomain
    max_id::Int
end
generate_parameters(d, ::Val{:id}) = IdParameterDomain(length(d))
Base.rand(d::IdParameterDomain) = rand(1:d.max_id)

"""
    FakeAutomaton{T} <: ConstraintCommons.AbstractAutomaton

A structure to generate pseudo automaton enough for parameter exploration.
"""
struct FakeAutomaton{T} <: ConstraintCommons.AbstractAutomaton
    words::Set{T}
end

"""
    ConstraintCommons.accept(fa::FakeAutomaton, word)

Implement the `accept` methods for `FakeAutomaton`.
"""
ConstraintCommons.accept(fa::FakeAutomaton, word) = word ∈ fa.words

"""
    fake_automaton(d)

Construct a `FakeAutomaton`.
"""
function fake_automaton(d)
    l = length(d)
    words = Set{Vector{eltype(first(d))}}()
    for _ in 1:max(l, rand(1:l^2))
        push!(words, map(rand, d))
    end
    return FakeAutomaton(words)
end

struct LanguageParameterDomain <: AbstractDomain
    automata::Vector{FakeAutomaton}
end
function generate_parameters(d, ::Val{:language})
    return LanguageParameterDomain(map(_ -> fake_automaton(d), d))
end
Base.rand(d::LanguageParameterDomain) = rand(d.automata)

struct OpParameterDomain{T} <: AbstractDomain
    ops::T
end
generate_parameters(_, ::Val{:op}) = OpParameterDomain([<, ≤, ==, ≥, >])
Base.rand(d::OpParameterDomain) = rand(d.ops)

struct PairVarsParameterDomain{T} <: AbstractDomain
    pair_vars::T
end
generate_parameters(d, ::Val{:pair_vars}) = PairVarsParameterDomain(d)
Base.rand(d::PairVarsParameterDomain) = map(rand, d.pair_vars)

struct ValParameterDomain{T} <: AbstractDomain
    val::T
end
generate_parameters(d, ::Val{:val}) = ValParameterDomain(d[rand(1:length(d))])
Base.rand(d::ValParameterDomain) = d.val |> rand

struct ValsParameterDomain{T} <: AbstractDomain
    vals::T
end
function generate_parameters(d, ::Val{:vals})
    l = length(d)
    inds(k) = sample(1:l, k; replace=false)
    k = rand(1:l)
    return ValsParameterDomain(hcat(map(_ -> d[inds(k)], 1:l)...))
end
Base.rand(d::ValsParameterDomain) = map(rand, d.vals)

generate_parameters(d, param) = generate_parameters(d, Val(param))

"""
    generate_parameters(d<:AbstractDomain, param)

Generates random parameters based on the domain `d` and the kind of parameters `param`.
"""
generate_parameters(d::AbstractDomain, param) = generate_parameters([d], param)

"""
    Base.rand(fa::FakeAutomaton)

Extends `Base.rand`. Currently simply returns `fa`.
"""
Base.rand(fa::FakeAutomaton) = fa

# TODO - Add test items
