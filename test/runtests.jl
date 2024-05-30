using Test
using TestItemRunner

@testset "Package tests: ConstraintDomains" begin
    include("Aqua.jl")
    include("TestItemRunner.jl")
end
