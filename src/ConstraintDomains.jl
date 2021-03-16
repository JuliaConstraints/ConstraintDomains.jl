module ConstraintDomains

# Imports
using Dictionaries: Dictionary
using PatternFolds: Interval, value

# Functions exports
export domain
export domain_size
export add!, delete!

# Includes
include("utils.jl")
include("common.jl")
include("continuous.jl")
include("discrete.jl")

end
