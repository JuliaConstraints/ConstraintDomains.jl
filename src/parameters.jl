"""
    BoolParameterDomain <: AbstractDomain

A domain to store boolean values. It is used to generate random parameters.
"""
struct BoolParameterDomain <: AbstractDomain end
generate_parameters(_, ::Val{:bool}) = BoolParameterDomain()
Base.rand(::BoolParameterDomain) = rand(Bool)

"""
    DimParameterDomain <: AbstractDomain

A domain to store dimensions. It is used to generate random parameters.
"""
struct DimParameterDomain <: AbstractDomain
    max_dimendion::Int
end
generate_parameters(d, ::Val{:dim}) = DimParameterDomain(floor(Int, √(length(d))))
Base.rand(d::DimParameterDomain) = rand(1:d.max_dimendion)

"""
    IdParameterDomain <: AbstractDomain

A domain to store ids. It is used to generate random parameters.
"""
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
    for _ = 1:l
        push!(words, map(rand, d))
    end
    return FakeAutomaton(words)
end

"""
    LanguageParameterDomain <: AbstractDomain

A domain to store languages. It is used to generate random parameters.
"""
struct LanguageParameterDomain <: AbstractDomain
    automata::Vector{FakeAutomaton}
end
function generate_parameters(d, ::Val{:language})
    return LanguageParameterDomain(map(_ -> fake_automaton(d), d))
end
Base.rand(d::LanguageParameterDomain) = rand(d.automata)

"""
    OpParameterDomain{T} <: AbstractDomain

A domain to store operators. It is used to generate random parameters.
"""
struct OpParameterDomain{T} <: AbstractDomain
    ops::T
end
generate_parameters(_, ::Val{:op}) = OpParameterDomain([<, ≤, ==, ≥, >])
Base.rand(d::OpParameterDomain) = rand(d.ops)

"""
    PairVarsParameterDomain{T} <: AbstractDomain

A domain to store values paired with variables. It is used to generate random parameters.
"""
struct PairVarsParameterDomain{T} <: AbstractDomain
    pair_vars::T
end
function generate_parameters(d, ::Val{:pair_vars})
    return PairVarsParameterDomain(hcat(map(_ -> d, 1:length(d))...))
end
Base.rand(d::PairVarsParameterDomain) = map(rand, d.pair_vars)

"""
    ValParameterDomain{T} <: AbstractDomain

A domain to store one value. It is used to generate random parameters.
"""
struct ValParameterDomain{T} <: AbstractDomain
    val::T
end
generate_parameters(d, ::Val{:val}) = ValParameterDomain(d[rand(1:length(d))])
Base.rand(d::ValParameterDomain) = d.val |> rand

"""
    ValsParameterDomain{T} <: AbstractDomain

A domain to store values. It is used to generate random parameters.
"""
struct ValsParameterDomain{T} <: AbstractDomain
    vals::T
end
function generate_parameters(d, ::Val{:vals})
    l = length(d)
    inds(k) = sample(1:l, k; replace = false)
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
