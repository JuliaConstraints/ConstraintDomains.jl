module ConstraintDomains

# Imports
using Dictionaries
using PatternFolds

# Functions exports
export AbstractDomain, ContinuousDomain, DiscreteDomain, RangeDomain, DiscreteSet, Intervals
export domain
export domain_size
export get_domain
export add!, delete!
export merge_domains, intersect_domains

# Includes
include("utils.jl")
include("common.jl")
include("continuous.jl")
include("discrete.jl")
include("general.jl")

end
