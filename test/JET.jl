@testset "Code linting (JET.jl)" begin
    JET.test_package(ConstraintDomains; target_defined_modules=true)
end
