generate_parameters(_, ::Val{:bool}) = domain([false, true])

generate_parameters(d, ::Val{:dim}) = domain(1:sqrt(length(d)))

generate_parameters(d, ::Val{:id}) = domain(1:length(d))

# TODO: how to generate graph/automata ?

struct FakeAutomaton{T} <: ConstraintCommons.AbstractAutomaton
    words::Set{T}
end

ConstraintCommons.accept(fa::FakeAutomaton, word) = word ∈ fa.words

function fake_automaton(d)
    l = maximum(length, d)
    words = Set{Vector{eltype(first(d))}}()
    for _ in 1:l
        # @info map(rand, d) words
        push!(words, map(rand, d))
    end
    return FakeAutomaton(words)
end

generate_parameters(d, ::Val{:language}) = fake_automaton(d)

generate_parameters(_, ::Val{:op}) = domain([<, ≤, ==, ≥, >])

generate_parameters(d, ::Val{:pair_vars}) = d

generate_parameters(d, ::Val{:val}) = rand(d)

function generate_parameters(d, ::Val{:vals})
    l = length(d)
    k = rand(1:l)
    return fill(d[1:k], l)
end

generate_parameters(d, param) = generate_parameters(d, Val(param))

generate_parameters(d::AbstractDomain, param) = generate_parameters([d], param)

Base.rand(fa::FakeAutomaton) = fa