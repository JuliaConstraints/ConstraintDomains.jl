module ConstraintDomains

# SECTION - Imports
using Dictionaries
using PatternFolds

# Exports
export AbstractDomain
export ContinuousDomain
export DiscreteDomain
export DiscreteSet
export ExploreSettings
export RangeDomain

export add!
export δ_extrema
export delete!
export domain
export domain_size
export explore
export get_domain
export intersect_domains
export merge_domains
export to_domains

# Includes
include("utils.jl")
include("common.jl")
include("continuous.jl")
include("discrete.jl")
include("general.jl")
include("explore.jl")

end
