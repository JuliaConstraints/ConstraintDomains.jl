var documenterSearchIndex = {"docs":
[{"location":"","page":"Home","title":"Home","text":"CurrentModule = ConstraintDomains","category":"page"},{"location":"#ConstraintDomains","page":"Home","title":"ConstraintDomains","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"Currently only discrete domains are supported using the following function.","category":"page"},{"location":"","page":"Home","title":"Home","text":"ConstraintDomains.domain","category":"page"},{"location":"#ConstraintDomains.domain","page":"Home","title":"ConstraintDomains.domain","text":"domain()\n\nConstruct an EmptyDomain.\n\n\n\n\n\ndomain(a::Tuple{T, Bool}, b::Tuple{T, Bool}) where {T <: Real}\ndomain(intervals::Vector{Tuple{Tuple{T, Bool},Tuple{T, Bool}}}) where {T <: Real}\n\nConstruct a domain of continuous interval(s). ```julia d1 = domain((0., true), (1., false)) # d1 = [0, 1) d2 = domain([ # d2 = 0, 1) ∪ (3.5, 42, (1., false),     (3.5, false), (42., true), ])\n\n\n\n\n\ndomain(values)\ndomain(range::R) where {T <: Real, R <: AbstractRange{T}}\n\nConstruct either a SetDomain or a RangeDomain.\n\nd1 = domain(1:5)\nd2 = domain([53.69, 89.2, 0.12])\nd3 = domain([2//3, 89//123])\nd4 = domain(4.3)\n\n\n\n\n\n","category":"function"}]
}
