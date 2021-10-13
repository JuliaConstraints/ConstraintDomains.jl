module ConstraintDomains

# NOTE - Reexport.jl
using Reexport

@reexport using PatternFolds

# Imports
using Dictionaries

# Functions exports
export AbstractDomain, ContinuousDomain, DiscreteDomain, RangeDomain, DiscreteSet
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
