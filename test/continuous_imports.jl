@testitem "Continuous bounds and conversions use the declared interval types" default_imports=false begin
    using Test
    import ConstraintDomains
    import Intervals

    @test ConstraintDomains.Interval === Intervals.Interval
    @test ConstraintDomains.Closed === Intervals.Closed
    @test ConstraintDomains.Intervals <: ConstraintDomains.ContinuousDomain

    discrete = ConstraintDomains.domain(-3:2:5)
    continuous = convert(ConstraintDomains.Intervals,discrete)
    interval = only(ConstraintDomains.get_domain(continuous))
    @test interval isa Intervals.Interval{Int,Intervals.Closed,Intervals.Closed}
    @test (first(interval),last(interval)) == (-3,5)
    @test -3 in continuous && 5 in continuous
    @test -4 ∉ continuous && 6 ∉ continuous
    @test 0 in continuous && 0 ∉ discrete
    @test ConstraintDomains.domain_size(continuous) == 8
    restored = convert(ConstraintDomains.RangeDomain,continuous)
    @test ConstraintDomains.get_domain(restored) == -3:5

    point = convert(ConstraintDomains.Intervals,ConstraintDomains.domain(7:7))
    @test 7 in point && 6 ∉ point && 8 ∉ point
    @test ConstraintDomains.domain_size(point) == 0

    semiopen = ConstraintDomains.domain(Intervals.Interval{Float64,Intervals.Open,Intervals.Closed}(-1.5,2.5))
    @test -1.5 ∉ semiopen && 2.5 in semiopen
    @test 0.0 in semiopen
    @test ConstraintDomains.domain_size(semiopen) == 4.0
end
