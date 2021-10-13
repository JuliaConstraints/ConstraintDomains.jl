using ConstraintDomains
using Dictionaries
using Intervals
using Test

@testset "ConstraintDomains.jl" begin
    @testset "EmptyDomain" begin
        ed = domain()
        @test domain_size(ed) == 0 == length(ed)
        @test isempty(ed)
        @test π ∉ ed
    end

    @testset "DiscreteDomain" begin
        d1 = domain([4,3,2,1])
        d2 = domain(1)
        foreach(i -> add!(d2, i), 2:4)
        domains = Dictionary(1:2, [d1, d2])

        for d in domains
        # constructors and ∈
            for x in [1,2,3,4]
                @test x ∈ d
            end
        # length
            @test length(d) == 4
        # draw and ∈
            @test rand(d) ∈ d
        # add!
            add!(d, 5)
            @test 5 ∈ d
        # delete!
            delete!(d, 5)
            @test 5 ∉ d
            @test domain_size(d) == 3
        end
    end

    @testset "ContinuousDomain" begin
        d1 = domain(1.0..3.15)
        d2 = domain(Interval{Open, Open}(-42.42, 5.0))
        # d3 = domain([d1, d2])
        domains = Dictionary(1:2, [d1, d2])

        for d in domains
            for x in [1, 2.3, π]
                @test x ∈ d
            end
            for x in [5.1, π^π, Inf]
                @test x ∉ d
            end
            @test rand(d) ∈ d
            @test rand(d, 1) ∈ d
            @test domain_size(d) > 0.0
        end

    end

    @testset "RangeDomain" begin
        d1 = domain(1:5)
        d2 = domain(1:.5:5)
        domains = Dictionary(1:2, [d1, d2])

        for d in domains
            for x in [1, 2, 3, 4, 5]
                @test x ∈ d
            end
            for x in [42]
                @test x ∉ d
            end
            @test rand(d) ∈ d
        end

    end
end
