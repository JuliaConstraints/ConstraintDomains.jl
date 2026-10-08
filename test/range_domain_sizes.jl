@testitem "Numeric range domains retain their span semantics" begin
    for values in (1:1000, 1000:-3:1, 1:0, 42:42,
            range(-1., 2.; length=17), (-2//3):(1//3):(2//3))
        expected = isempty(values) ? Inf : maximum(values) - minimum(values)
        @test domain_size(domain(values)) == expected
        @test domain_size(domain(values)) == domain_size(domain(collect(values)))
    end
    @test domain_size(domain(1:1_000_000)) == 999_999
    @test length(domain(1:1_000_000)) == 1_000_000
end
