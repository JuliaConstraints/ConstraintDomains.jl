module ConstraintDomains

# SECTION - Imports
import ConstraintCommons: ConstraintCommons, δ_extrema
import PatternFolds: PatternFolds, Interval, Closed
import Random: AbstractRNG, default_rng, randperm
import StatsBase: sample
import TestItems: @testitem

# Exports
export AbstractDomain
export ArbitraryDomain
export ContinuousDomain
export DiscreteDomain
export Explorer, ExploreSettings
export RangeDomain
export SequenceDecisionDomain
export SetDecisionDomain
export SetDomain

export add!
export arbitrary_domain
export delete!
export domain
export domain_size
export explore, explore!
export generate_parameters
export get_domain
export intersect_domains
export merge_domains
export sequence_domain
export set_decision_domain
export to_domains

# Includes
include("common.jl")
include("continuous.jl")
include("discrete.jl")
include("general.jl")
include("explore.jl")
include("parameters.jl")

end
