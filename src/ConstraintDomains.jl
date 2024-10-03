module ConstraintDomains

# SECTION - Imports
import ConstraintCommons: ConstraintCommons, δ_extrema
import PatternFolds: PatternFolds, Interval, Closed
import StatsBase: sample
import TestItems: @testitem

# Exports
export AbstractDomain
export ContinuousDomain
export DiscreteDomain
export ExploreSettings
export RangeDomain
export SetDomain

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
