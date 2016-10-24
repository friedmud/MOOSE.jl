function testAssembly(diffusion_system::System)
    u = addVariable!(diffusion_system, "u")

    diffusion_kernel = Diffusion(u)

    addKernel!(diffusion_system, diffusion_kernel)

    initialize!(diffusion_system)

    solver = JuliaDenseImplicitSolver(diffusion_system)

    initialize!(solver)

    MOOSE.assembleResidualAndJacobian(solver, diffusion_system)

    # From MOOSE
    jac = [0.666666666667 -0.166666666667 -0.333333333333 -0.166666666667 0 0 0 0 0 ;
           -0.166666666667 1.33333333333 -0.333333333333 -0.333333333333 -0.166666666667 -0.333333333333 0 0 0 ;
           -0.333333333333 -0.333333333333 2.66666666667 -0.333333333333 -0.333333333333 -0.333333333333 -0.333333333333 -0.333333333333 -0.333333333333 ;
           -0.166666666667 -0.333333333333 -0.333333333333 1.33333333333 0 0 -0.333333333333 -0.166666666667 0 ;
           0 -0.166666666667 -0.333333333333 0 0.666666666667 -0.166666666667 0 0 0 ;
           0 -0.333333333333 -0.333333333333 0 -0.166666666667 1.33333333333 -0.333333333333 0 -0.166666666667 ;
           0 0 -0.333333333333 -0.333333333333 0 -0.333333333333 1.33333333333 -0.166666666667 -0.166666666667 ;
           0 0 -0.333333333333 -0.166666666667 0 0 -0.166666666667 0.666666666667 0 ;
           0 0 -0.333333333333 0 0 -0.166666666667 -0.166666666667 0 0.666666666667 ]

    for i in 1:length(jac)
        @test abs(solver.mat[i] - jac[i]) < 1e-5
    end
end


@testset "Assembly" begin
    mesh = buildSquare(0, 1, 0, 1, 2, 2)

    diffusion_system = System{Float64}(mesh)

    testAssembly(diffusion_system)
end


@testset "AssemblyFD" begin
    mesh = buildSquare(0, 1, 0, 1, 2, 2)

    diffusion_system = System{Dual{4, Float64}}(mesh)

    testAssembly(diffusion_system)
end
