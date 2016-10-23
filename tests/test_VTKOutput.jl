@testset "VTKOutput" begin
    mesh = buildSquare(0, 1, 0, 1, 2, 2)

    diffusion_system = System(mesh)

    u = addVariable!(diffusion_system, "u")

    diffusion_kernel = Diffusion(u)
    addKernel!(diffusion_system, diffusion_kernel)

    left_boundary = DirichletBC(u, [4], 0.0)
    addBC!(diffusion_system, left_boundary)

    right_boundary = DirichletBC(u, [2], 1.0)
    addBC!(diffusion_system, right_boundary)

    initialize!(diffusion_system)

    solver = JuliaDenseImplicitSolver(diffusion_system)

    solve!(solver)

    out = VTKOutput()

    rm("test_out.vtu", force=true)

    output(out, solver, "test_out")

    @test isfile("test_out.vtu")
end
