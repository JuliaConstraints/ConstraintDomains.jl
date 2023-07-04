module ConstraintDomains

# SECTION - Imports
using ConstraintCommons
using Dictionaries
using PatternFolds
using StatsBase
using TestItemRunner
using TestItems

# Exports
export AbstractDomain
export ContinuousDomain
export DiscreteDomain
export DiscreteSet
export ExploreSettings
export RangeDomain

export add!
export delete!
export domain
export domain_size
export explore
export generate_parameters
export get_domain
export intersect_domains
export merge_domains
export to_domains

# Includes
include("common.jl")
include("continuous.jl")
include("discrete.jl")
include("general.jl")
include("explore.jl")
include("parameters.jl")

end
