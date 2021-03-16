using ConstraintDomains
using Dictionaries
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
        domains = Dictionary(1:1, [d1])

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
        end
    end

    @testset "ContinuousDomain" begin
        d1 = domain((1.0, true), (3.15, true))
        d2 = domain((-42.42, false), (5.0, false))
        d3 = domain([
            ((1.0, true), (3.15, true)),
            ((-42.42, false), (5.0, false)),
        ])
        domains = Dictionary(1:2, [d1, d2])

        for d in domains
            for x in [1, 2.3, π]
                @test x ∈ d
            end
            for x in [5.1, π^π, Inf]
                @test x ∉ d
            end
            @test rand(d) ∈ d
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
