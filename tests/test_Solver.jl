
# Test the Solver interface for solve!()
type DummySolver <: Solver
end

@testset "Solver" begin
    mesh = buildSquare(0,1,0,1,2,2)

    sys = System(mesh)

    dog = addVariable!(sys, "dog")
    cat = addVariable!(sys, "cat")

    initialize!(sys)

    dummy_solver = DummySolver

    @test_throws MethodError solve!(dummy_solver)
end
