module ConstraintDomains

# Imports
using Dictionaries
using PatternFolds

# Functions exports
export AbstractDomain
export domain
export domain_size
export get_domain
export add!, delete!

# Includes
include("utils.jl")
include("common.jl")
include("continuous.jl")
include("discrete.jl")

end
