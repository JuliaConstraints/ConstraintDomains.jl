@testset "Code linting (JET.jl)" begin
    JET.test_package(ConstraintDomains; target_modules = (ConstraintDomains,))
end
