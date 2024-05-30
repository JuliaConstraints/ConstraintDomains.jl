@testset "Aqua.jl" begin
    import Aqua
    import ConstraintDomains
    import Dictionaries

    # TODO: Fix the broken tests and remove the `broken = true` flag
    Aqua.test_all(
        ConstraintDomains;
        ambiguities = (broken = true,),
        deps_compat = false,
        piracies = (broken = false,),
    )

    @testset "Ambiguities: ConstraintDomains" begin
        # Aqua.test_ambiguities(ConstraintDomains;)
    end

    @testset "Piracies: ConstraintDomains" begin
        Aqua.test_piracies(ConstraintDomains;)
    end

    @testset "Dependencies compatibility (no extras)" begin
        Aqua.test_deps_compat(
            ConstraintDomains;
            check_extras = false,            # ignore = [:Random]
        )
    end
end
