using ConstraintDomains
using Dictionaries
using Test

@testset "ConstraintDomains.jl" begin

    d1 = domain([4,3,2,1])
    d2 = domain([4,3,2,1]; type=:indices)
    domains = Dictionary(1:2, [d1, d2])

    # get
    @test _get(d2, 2) == 3
    for d in domains
    # constructors and ∈
        for x in [1,2,3,4]
            @test x ∈ d
        end
    # length
        @test _length(d) == 4
    # draw and ∈
        @test _draw(d) ∈ d
    # add!
        _add!(d, 5)
        @test 5 ∈ d
    # delete!
        _delete!(d, 5)
        @test 5 ∉ d
    end

end
