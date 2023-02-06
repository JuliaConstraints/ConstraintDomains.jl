var documenterSearchIndex = {"docs":
[{"location":"","page":"Home","title":"Home","text":"CurrentModule = ConstraintDomains","category":"page"},{"location":"#ConstraintDomains","page":"Home","title":"ConstraintDomains","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"","category":"page"},{"location":"","page":"Home","title":"Home","text":"Modules = [ConstraintDomains]","category":"page"},{"location":"#ConstraintDomains.AbstractDomain","page":"Home","title":"ConstraintDomains.AbstractDomain","text":"AbstractDomain\n\nAn abstract super type for any domain type. A domain type D <: AbstractDomain must implement the following methods to properly interface AbstractDomain.\n\nBase.∈(val, ::D)\nBase.rand(::D)\nBase.length(::D) that is the number of elements in a discrete domain, and the distance between bounds or similar for a continuous domain\n\nAddtionally, if the domain is used in a dynamic context, it can extend\n\nadd!(::D, args)\ndelete!(::D, args)\n\nwhere args depends on D's structure\n\n\n\n\n\n","category":"type"},{"location":"#ConstraintDomains.ContinuousDomain","page":"Home","title":"ConstraintDomains.ContinuousDomain","text":"ContinuousDomain{T <: Real} <: AbstractDomain\n\nAn abstract supertype for all continuous domains.\n\n\n\n\n\n","category":"type"},{"location":"#ConstraintDomains.DiscreteDomain","page":"Home","title":"ConstraintDomains.DiscreteDomain","text":"DiscreteDomain{T <: Number} <: AbstractDomain\n\nAn abstract supertype for discrete domains (set, range).\n\n\n\n\n\n","category":"type"},{"location":"#ConstraintDomains.EmptyDomain","page":"Home","title":"ConstraintDomains.EmptyDomain","text":"EmptyDomain\n\nA struct to handle yet to be defined domains.\n\n\n\n\n\n","category":"type"},{"location":"#ConstraintDomains.ExploreSettings-Tuple{Any}","page":"Home","title":"ConstraintDomains.ExploreSettings","text":"ExploreSettings(\n    domains;\n    complete_search_limit = 10^6,\n    max_samplings = sum(domain_size, domains),\n    search = :flexible,\n    solutions_limit = floor(Int, sqrt(max_samplings)),\n)\n\nSettings for the exploration of a search space composed by a collection of domains.\n\n\n\n\n\n","category":"method"},{"location":"#ConstraintDomains.Intervals","page":"Home","title":"ConstraintDomains.Intervals","text":"Intervals{T <: Real} <: ContinuousDomain{T}\n\nAn encapsuler to store a vector of PatternFolds.Interval. Dynamic changes to Intervals are not handled yet.\n\n\n\n\n\n","category":"type"},{"location":"#ConstraintDomains.RangeDomain","page":"Home","title":"ConstraintDomains.RangeDomain","text":"RangeDomain\n\nA discrete domain defined by a range <: AbstractRange{Real}. As ranges are immutable in Julia, changes in RangeDomain must use set_domain!.\n\n\n\n\n\n","category":"type"},{"location":"#ConstraintDomains.SetDomain","page":"Home","title":"ConstraintDomains.SetDomain","text":"SetDomain{T <: Number} <: DiscreteDomain{T}\n\nDomain that stores discrete values as a set of (unordered) points.\n\n\n\n\n\n","category":"type"},{"location":"#Base.convert-Union{Tuple{T}, Tuple{Type{ConstraintDomains.Intervals}, RangeDomain{T, R} where R<:AbstractRange{T}}} where T<:Real","page":"Home","title":"Base.convert","text":"Base.convert(::Type{Union{Intervals, RangeDomain}}, d::Union{Intervals, RangeDomain})\n\nExtends Base.convert for domains.\n\n\n\n\n\n","category":"method"},{"location":"#Base.delete!-Tuple{ConstraintDomains.SetDomain, Any}","page":"Home","title":"Base.delete!","text":"Base.delete!(d::SetDomain, value)(d::SetDomain, value)\n\nDelete value from the list of points in d.\n\n\n\n\n\n","category":"method"},{"location":"#Base.eltype-Union{Tuple{D}, Tuple{T}} where {T, D<:Union{ContinuousDomain{T}, DiscreteDomain{T}}}","page":"Home","title":"Base.eltype","text":"Base.eltype(::AbstractDomain)\n\nExtend eltype for domains.\n\n\n\n\n\n","category":"method"},{"location":"#Base.in-Tuple{Any, ConstraintDomains.Intervals}","page":"Home","title":"Base.in","text":"Base.in(x, itv::Intervals)\n\nReturn true if x ∈ I for any 'I ∈ itv, false otherwise.x ∈ I` is equivalent to\n\na < x < b if I = (a, b)\na < x ≤ b if I = (a, b]\na ≤ x < b if I = [a, b)\na ≤ x ≤ b if I = [a, b]\n\n\n\n\n\n","category":"method"},{"location":"#Base.in-Union{Tuple{D}, Tuple{Any, D}} where D<:AbstractDomain","page":"Home","title":"Base.in","text":"Base.in(value, d <: AbstractDomain)\n\nFallback method for value ∈ d that returns false.\n\n\n\n\n\n","category":"method"},{"location":"#Base.in-Union{Tuple{D}, Tuple{Any, D}} where D<:DiscreteDomain","page":"Home","title":"Base.in","text":"Base.in(value, d::D) where D <: DiscreteDomain\n\nReturn true if value is a point of d.\n\n\n\n\n\n","category":"method"},{"location":"#Base.isempty-Tuple{D} where D<:AbstractDomain","page":"Home","title":"Base.isempty","text":"Base.isempty(d <: AbstractDomain)\n\nFallback method for isempty(d) that return length(d) == 0 which default to 0.\n\n\n\n\n\n","category":"method"},{"location":"#Base.length-Tuple{ConstraintDomains.Intervals}","page":"Home","title":"Base.length","text":"Base.length(itv::Intervals)\n\nReturn the sum of the length of each interval in itv.\n\n\n\n\n\n","category":"method"},{"location":"#Base.length-Tuple{D} where D<:AbstractDomain","page":"Home","title":"Base.length","text":"Base.rand(d <: AbstractDomain)\n\nFallback method for length(d) that return 0.\n\n\n\n\n\n","category":"method"},{"location":"#Base.length-Tuple{D} where D<:DiscreteDomain","page":"Home","title":"Base.length","text":"Base.length(d::D) where D <: DiscreteDomain\n\nReturn the number of points in d.\n\n\n\n\n\n","category":"method"},{"location":"#Base.rand-Tuple{AbstractDomain}","page":"Home","title":"Base.rand","text":"Base.rand(d::Union{Vector{D},Set{D}, D}) where {D<:AbstractDomain}\n\nExtends Base.rand to (a collection of) domains.\n\n\n\n\n\n","category":"method"},{"location":"#Base.rand-Tuple{ConstraintDomains.Intervals, Int64}","page":"Home","title":"Base.rand","text":"Base.rand(itv::Intervals)\nBase.rand(itv::Intervals, i)\n\nReturn a random value from itv, specifically from the ith interval if i is specified.\n\n\n\n\n\n","category":"method"},{"location":"#Base.rand-Tuple{D} where D<:DiscreteDomain","page":"Home","title":"Base.rand","text":"Base.rand(d::D) where D <: DiscreteDomain\n\nDraw randomly a point in d.\n\n\n\n\n\n","category":"method"},{"location":"#ConstraintDomains._explore-Tuple{Any, Any, Any, Val{:partial}}","page":"Home","title":"ConstraintDomains._explore","text":"_explore(args...)\n\nInternals of the explore function. Behavior is automatically adjusted on the kind of exploration: :flexible, :complete, :partial.\n\n\n\n\n\n","category":"method"},{"location":"#ConstraintDomains.add!-Tuple{ConstraintDomains.SetDomain, Any}","page":"Home","title":"ConstraintDomains.add!","text":"add!(d::SetDomain, value)\n\nAdd value to the list of points in d.\n\n\n\n\n\n","category":"method"},{"location":"#ConstraintDomains.domain-Tuple{Any}","page":"Home","title":"ConstraintDomains.domain","text":"domain(values)\ndomain(range::R) where {T <: Real, R <: AbstractRange{T}}\n\nConstruct either a SetDomain or a RangeDomain.\n\nd1 = domain(1:5)\nd2 = domain([53.69, 89.2, 0.12])\nd3 = domain([2//3, 89//123])\nd4 = domain(4.3)\n\n\n\n\n\n","category":"method"},{"location":"#ConstraintDomains.domain-Tuple{}","page":"Home","title":"ConstraintDomains.domain","text":"domain()\n\nConstruct an EmptyDomain.\n\n\n\n\n\n","category":"method"},{"location":"#ConstraintDomains.domain-Union{Tuple{Array{Intervals.Interval{T, L, R}, 1}}, Tuple{R}, Tuple{L}, Tuple{T}} where {T<:Real, L, R}","page":"Home","title":"ConstraintDomains.domain","text":"domain(a::Tuple{T, Bool}, b::Tuple{T, Bool}) where {T <: Real}\ndomain(intervals::Vector{Tuple{Tuple{T, Bool},Tuple{T, Bool}}}) where {T <: Real}\n\nConstruct a domain of continuous interval(s). ```julia d1 = domain((0., true), (1., false)) # d1 = [0, 1) d2 = domain([ # d2 = 0, 1) ∪ (3.5, 42, (1., false),     (3.5, false), (42., true), ])\n\n\n\n\n\n","category":"method"},{"location":"#ConstraintDomains.domain_size-Tuple{ConstraintDomains.Intervals}","page":"Home","title":"ConstraintDomains.domain_size","text":"domain_size(itv::Intervals)\n\nReturn the difference between the highest and lowest values in itv.\n\n\n\n\n\n","category":"method"},{"location":"#ConstraintDomains.domain_size-Tuple{D} where D<:AbstractDomain","page":"Home","title":"ConstraintDomains.domain_size","text":"domain_size(d <: AbstractDomain)\n\nFallback method for domain_size(d) that return length(d).\n\n\n\n\n\n","category":"method"},{"location":"#ConstraintDomains.domain_size-Tuple{D} where D<:DiscreteDomain","page":"Home","title":"ConstraintDomains.domain_size","text":"domain_size(d::D) where D <: DiscreteDomain\n\nReturn the maximum distance between two points in d.\n\n\n\n\n\n","category":"method"},{"location":"#ConstraintDomains.explore-Tuple{Any, Any}","page":"Home","title":"ConstraintDomains.explore","text":"explore(domains, concept, param = nothing; search_limit = 1000, solutions_limit = 100)\n\nSearch (a part of) a search space and returns a pair of vector of configurations: (solutions, non_solutions). If the search space size is over search_limit, then both solutions and non_solutions are limited to solutions_limit.\n\nBeware that if the density of the solutions in the search space is low, solutions_limit needs to be reduced. This process will be automatic in the future (simple reinforcement learning).\n\nArguments:\n\ndomains: a collection of domains\nconcept: the concept of the targeted constraint\nparam: an optional parameter of the constraint\nsol_number: the required number of solutions (half of the number of configurations), default to 100\n\n\n\n\n\n","category":"method"},{"location":"#ConstraintDomains.get_domain-Tuple{D} where D<:AbstractDomain","page":"Home","title":"ConstraintDomains.get_domain","text":"get_domain(::AbstractDomain)\n\nAccess the internal structure of any domain type.\n\n\n\n\n\n","category":"method"},{"location":"#ConstraintDomains.intersect_domains-Union{Tuple{I2}, Tuple{I1}, Tuple{I1, I2}} where {I1<:Intervals.Interval, I2<:Intervals.Interval}","page":"Home","title":"ConstraintDomains.intersect_domains","text":"intersect_domains(d₁, d₂)\n\nCompute the intersections of two domains.\n\n\n\n\n\n","category":"method"},{"location":"#ConstraintDomains.merge_domains-Tuple{RangeDomain, RangeDomain}","page":"Home","title":"ConstraintDomains.merge_domains","text":"merge_domains(d₁::AbstractDomain, d₂::AbstractDomain)\n\nMerge two domains of same nature (discrete/contiuous).\n\n\n\n\n\n","category":"method"},{"location":"#ConstraintDomains.size-Tuple{I} where I<:Intervals.Interval","page":"Home","title":"ConstraintDomains.size","text":"Base.size(i::I) where {I <: Interval}\n\nDefines the size of an interval as its span.\n\n\n\n\n\n","category":"method"},{"location":"#ConstraintDomains.to_domains-Tuple{Vector{Int64}}","page":"Home","title":"ConstraintDomains.to_domains","text":"to_domains(args...)\n\nConvert various arguments into valid domains format.\n\n\n\n\n\n","category":"method"}]
}
