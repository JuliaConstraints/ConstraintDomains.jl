module ConstraintDomains

# Imports
import Dictionaries: Dictionary
import Base: ∈

export domain, AbstractDomain, EmptyDomain
export ContinuousDomain, ContinuousInterval, ContinuousIntervals
export DiscreteDomain, SetDomain, IndicesDomain
export _length, _get, _draw, ∈, _delete!, _get_domain, _add!
export _domain_size

### Abstract Domain supertype
abstract type AbstractDomain end

# Includes
include("empty.jl")
include("continuous.jl")
include("discrete.jl")
include("range.jl")

end
