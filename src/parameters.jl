"""
    BoolParameterDomain <: AbstractDomain

A domain to store boolean values. It is used to generate random parameters.
"""
struct BoolParameterDomain <: AbstractDomain end
generate_parameters(_, _, ::Val{:bool}) = BoolParameterDomain()
Base.rand(rng::AbstractRNG, ::BoolParameterDomain) = rand(rng, Bool)
Base.rand(domain::BoolParameterDomain) = rand(default_rng(), domain)

"""
    DimParameterDomain <: AbstractDomain

A domain to store dimensions. It is used to generate random parameters.
"""
struct DimParameterDomain <: AbstractDomain
    dimensions::Vector{Int}
end
function generate_parameters(_, domains, ::Val{:dim})
    arity = length(domains)
    arity > 0 || throw(ArgumentError("a dimension parameter requires at least one domain"))
    return DimParameterDomain(filter(dimension -> arity % dimension == 0, 1:arity))
end
Base.rand(rng::AbstractRNG, domain::DimParameterDomain) = rand(rng, domain.dimensions)
Base.rand(domain::DimParameterDomain) = rand(default_rng(), domain)

"""
    IdParameterDomain <: AbstractDomain

A domain to store ids. It is used to generate random parameters.
"""
struct IdParameterDomain <: AbstractDomain
    max_id::Int
end
generate_parameters(_, domains, ::Val{:id}) = IdParameterDomain(length(domains))
Base.rand(rng::AbstractRNG, domain::IdParameterDomain) = rand(rng, 1:domain.max_id)
Base.rand(domain::IdParameterDomain) = rand(default_rng(), domain)

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
function fake_automaton(rng::AbstractRNG, d)
    l = length(d)
    words = Set{Vector{eltype(first(d))}}()
    for _ = 1:l
        push!(words, map(domain -> rand(rng, domain), d))
    end
    return FakeAutomaton(words)
end

fake_automaton(d) = fake_automaton(default_rng(), d)

"""
    LanguageParameterDomain <: AbstractDomain

A domain to store languages. It is used to generate random parameters.
"""
struct LanguageParameterDomain{L<:AbstractVector} <: AbstractDomain
    languages::L
end

function _sample_symbols(rng::AbstractRNG, value_domain; count::Int = 6)
    values = get_domain(value_domain)
    finite_size = try
        length(values)
    catch
        nothing
    end
    !isnothing(finite_size) && finite_size <= 32 && return collect(values)
    return unique([rand(rng, value_domain) for _ = 1:count])
end

function _random_automaton(rng::AbstractRNG, domains, profile::Symbol)
    accepted_word = map(value_domain -> rand(rng, value_domain), domains)
    alphabet =
        unique(vcat((_sample_symbols(rng, value_domain) for value_domain in domains)...))
    state_count = rand(rng, 4:max(4, min(10, length(domains)+1)))
    transitions = Dict{Tuple{Int,Any},Int}()
    for state = 1:state_count, symbol in alphabet
        transitions[(state, symbol)] = rand(rng, 1:state_count)
    end

    state = 1
    for symbol in accepted_word
        destination = get!(transitions, (state, symbol)) do
            rand(rng, 1:state_count)
        end
        state = destination
    end
    target_fraction = profile === :sparse ? 0.2 : profile === :balanced ? 0.4 : 0.7
    finish_count = clamp(round(Int, target_fraction * state_count), 1, state_count - 1)
    finish = Set(randperm(rng, state_count)[1:finish_count])
    push!(finish, state)
    return ConstraintCommons.Automaton(transitions, 1, finish)
end

function _random_mdd(rng::AbstractRNG, domains, profile::Symbol)
    accepted_word = map(value_domain -> rand(rng, value_domain), domains)
    levels = Vector{Dict{Tuple{Int,Any},Int}}(undef, length(domains))
    current_nodes = [1]
    accepted_node = 1
    next_node = 2
    max_width = max(1, min(6, ceil(Int, sqrt(length(domains)))))

    for level in eachindex(domains)
        width = level == lastindex(domains) ? 1 : rand(rng, 1:max_width)
        following_nodes = collect(next_node:(next_node+width-1))
        next_node += width
        transitions = Dict{Tuple{Int,Any},Int}()
        symbols = _sample_symbols(rng, domains[level])
        target_prevalence = profile === :sparse ? 0.10 : profile === :balanced ? 0.50 : 0.85
        per_level_density = target_prevalence^(1 / length(domains))
        density = clamp(per_level_density + 0.06 * (rand(rng) - 0.5), 0.10, 0.995)
        for source in current_nodes, symbol in symbols
            rand(rng) <= density || continue
            transitions[(source, symbol)] = rand(rng, following_nodes)
        end
        accepted_destination = rand(rng, following_nodes)
        transitions[(accepted_node, accepted_word[level])] = accepted_destination
        levels[level] = transitions
        current_nodes = following_nodes
        accepted_node = accepted_destination
    end
    return ConstraintCommons.MDD(levels)
end

function _language_prevalence(rng::AbstractRNG, language, domains; samples::Int = 128)
    accepted = count(1:samples) do _
        word = map(value_domain -> rand(rng, value_domain), domains)
        ConstraintCommons.accept(language, word)
    end
    return accepted / samples
end

function _profile_band(profile::Symbol)
    profile === :sparse && return (0.01, 0.25)
    profile === :balanced && return (0.20, 0.80)
    profile === :dense && return (0.70, 0.99)
    throw(ArgumentError("unknown language-density profile: $profile"))
end

function _profiled_language(rng::AbstractRNG, domains, kind::Symbol, profile::Symbol)
    lower, upper = _profile_band(profile)
    target = (lower + upper) / 2
    best = nothing
    best_distance = Inf
    best_target_distance = Inf
    for _ = 1:24
        candidate =
            kind === :automaton ? _random_automaton(rng, domains, profile) :
            _random_mdd(rng, domains, profile)
        prevalence = _language_prevalence(rng, candidate, domains)
        distance =
            prevalence < lower ? lower - prevalence :
            prevalence > upper ? prevalence - upper : 0.0
        target_distance = abs(prevalence - target)
        if distance < best_distance ||
           (distance == best_distance && target_distance < best_target_distance)
            best = candidate
            best_distance = distance
            best_target_distance = target_distance
        end
        iszero(distance) && return candidate
    end
    return best
end

function generate_parameters(rng::AbstractRNG, domains, ::Val{:language})
    isempty(domains) &&
        throw(ArgumentError("a language requires at least one word position"))
    count = clamp(length(domains), 6, 12)
    profiles = (:sparse, :balanced, :dense)
    languages = ConstraintCommons.AbstractLanguage[
        _profiled_language(
            rng,
            domains,
            isodd(index) ? :automaton : :mdd,
            profiles[mod1(index, length(profiles))],
        ) for index = 1:count
    ]
    return LanguageParameterDomain(languages)
end
Base.rand(rng::AbstractRNG, domain::LanguageParameterDomain) = rand(rng, domain.languages)
Base.rand(domain::LanguageParameterDomain) = rand(default_rng(), domain)

"""
    OpParameterDomain{T} <: AbstractDomain

A domain to store operators. It is used to generate random parameters.
"""
struct OpParameterDomain{T} <: AbstractDomain
    ops::T
end
generate_parameters(_, _, ::Val{:op}) = OpParameterDomain([<, ≤, ==, ≥, >])
Base.rand(rng::AbstractRNG, domain::OpParameterDomain) = rand(rng, domain.ops)
Base.rand(domain::OpParameterDomain) = rand(default_rng(), domain)

"""
    PairVarsParameterDomain{T} <: AbstractDomain

A domain to store values paired with variables. It is used to generate random parameters.
"""
struct PairVarsParameterDomain{T} <: AbstractDomain
    pair_vars::T
end
function generate_parameters(_, domains, ::Val{:pair_vars})
    return PairVarsParameterDomain(hcat(map(_ -> domains, 1:length(domains))...))
end
function Base.rand(rng::AbstractRNG, domain::PairVarsParameterDomain)
    return map(value_domain -> rand(rng, value_domain), domain.pair_vars)
end
Base.rand(domain::PairVarsParameterDomain) = rand(default_rng(), domain)

"""
    ValParameterDomain{T} <: AbstractDomain

A domain to store one value. It is used to generate random parameters.
"""
struct ValParameterDomain{T} <: AbstractDomain
    val::T
end
function generate_parameters(rng::AbstractRNG, domains, ::Val{:val})
    return ValParameterDomain(rand(rng, domains))
end
Base.rand(rng::AbstractRNG, domain::ValParameterDomain) = rand(rng, domain.val)
Base.rand(domain::ValParameterDomain) = rand(default_rng(), domain)

"""
    ValsParameterDomain{T} <: AbstractDomain

A domain to store values. It is used to generate random parameters.
"""
struct ValsParameterDomain{T} <: AbstractDomain
    vals::T
end
function generate_parameters(rng::AbstractRNG, domains, ::Val{:vals})
    count = rand(rng, 1:length(domains))
    indices = sample(rng, eachindex(domains), count; replace = false)
    return ValsParameterDomain(domains[indices])
end
function Base.rand(rng::AbstractRNG, domain::ValsParameterDomain)
    return map(value_domain -> rand(rng, value_domain), domain.vals)
end
Base.rand(domain::ValsParameterDomain) = rand(default_rng(), domain)

generate_parameters(rng::AbstractRNG, domains, parameter::Symbol) =
    generate_parameters(rng, domains, Val(parameter))
generate_parameters(domains, parameter::Symbol) =
    generate_parameters(default_rng(), domains, parameter)

"""
    generate_parameters(d<:AbstractDomain, param)

Generates random parameters based on the domain `d` and the kind of parameters `param`.
"""
generate_parameters(rng::AbstractRNG, domain::AbstractDomain, parameter::Symbol) =
    generate_parameters(rng, [domain], parameter)
generate_parameters(domain::AbstractDomain, parameter::Symbol) =
    generate_parameters(default_rng(), domain, parameter)

"""
    Base.rand(fa::FakeAutomaton)

Extends `Base.rand`. Currently simply returns `fa`.
"""
Base.rand(fa::FakeAutomaton) = fa
Base.rand(::AbstractRNG, fa::FakeAutomaton) = fa

@testitem "Random constraint parameters are reproducible and shape-safe" begin
    using ConstraintCommons
    using Random
    using Test

    domains = [domain(0:5) for _ = 1:12]
    first_rng = MersenneTwister(42)
    second_rng = MersenneTwister(42)
    for parameter in (:bool, :dim, :id, :op, :pair_vars, :val, :vals)
        first_value = rand(first_rng, generate_parameters(first_rng, domains, parameter))
        second_value = rand(second_rng, generate_parameters(second_rng, domains, parameter))
        @test first_value == second_value
    end

    dimension_domain = generate_parameters(MersenneTwister(1), domains, :dim)
    @test all(dimension -> length(domains) % dimension == 0, dimension_domain.dimensions)
    @test Set(dimension_domain.dimensions) == Set((1, 2, 3, 4, 6, 12))
    @test rand(MersenneTwister(7), generate_parameters(domains, :vals)) isa AbstractVector

    first_languages = generate_parameters(MersenneTwister(91), domains, :language)
    second_languages = generate_parameters(MersenneTwister(91), domains, :language)
    @test repr(first_languages.languages) == repr(second_languages.languages)
    @test any(
        language -> language isa ConstraintCommons.Automaton,
        first_languages.languages,
    )
    @test any(language -> language isa ConstraintCommons.MDD, first_languages.languages)
    @test all(
        language ->
            ConstraintCommons.language_distance(
                language,
                [rand(MersenneTwister(3), value_domain) for value_domain in domains],
            ) >= 0,
        first_languages.languages,
    )
    prevalence_rng = MersenneTwister(812)
    prevalences = [
        count(1:512) do _
            word = map(value_domain -> rand(prevalence_rng, value_domain), domains)
            ConstraintCommons.accept(language, word)
        end / 512 for language in first_languages.languages
    ]
    @test all(prevalence -> 0 < prevalence < 1, prevalences)
    @test minimum(prevalences) < 0.30
    @test any(prevalence -> 0.30 <= prevalence <= 0.70, prevalences)
    @test maximum(prevalences) > 0.70
end
