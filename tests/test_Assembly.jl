@testset "Assembly" begin
    mesh = buildSquare(0, 1, 0, 1, 2, 2)

    diffusion_system = System(mesh)

    u = addVariable!(diffusion_system, "u")

    diffusion_kernel = Diffusion(u)

    addKernel!(diffusion_system, diffusion_kernel)

    initialize!(diffusion_system)

    solver = JuliaDenseImplicitSolver(diffusion_system)

    initialize!(solver)

    MOOSE.assembleResidualAndJacobian(solver)

    # Correct, though I wish there were more precision.  No time right now...
    jac = [0.666667 -0.166667 0.0 -0.166667 -0.333333 0.0 0.0 0.0 0.0;
     -0.166667 1.33333 -0.166667 -0.333333 -0.333333 -0.333333 0.0 0.0 0.0;
     0.0 -0.166667 0.666667 0.0 -0.333333 -0.166667 0.0 0.0 0.0;
     -0.166667 -0.333333 0.0 1.33333 -0.333333 0.0 -0.166667 -0.333333 0.0;
     -0.333333 -0.333333 -0.333333 -0.333333 2.66667 -0.333333 -0.333333 -0.333333 -0.333333;
     0.0 -0.333333 -0.166667 0.0 -0.333333 1.33333 0.0 -0.333333 -0.166667;
     0.0 0.0 0.0 -0.166667 -0.333333 0.0 0.666667 -0.166667 0.0;
     0.0 0.0 0.0 -0.333333 -0.333333 -0.333333 -0.166667 1.33333 -0.166667;
     0.0 0.0 0.0 0.0 -0.333333 -0.166667 0.0 -0.166667 0.666667]

    for i in 1:length(jac)
        @test abs(solver.mat[i] - jac[i]) < 1e-5
    end
end
