@testset "JDIS" begin
    mesh = buildSquare(0,1,0,1,2,2)

    sys = System{Float64}(mesh)

    dog = addVariable!(sys, "dog")
    cat = addVariable!(sys, "cat")

    initialize!(sys)

    jdis = JuliaDenseImplicitSolver(sys)

    # Make sure it's not iniitialized by default
    @test !jdis.initialized

    initialize!(jdis)

    # Now it should be
    @test jdis.initialized

    n_dofs = sys.n_dofs

    @test size(jdis.mat) == (n_dofs, n_dofs)
    @test length(jdis.rhs) == n_dofs
    @test length(jdis.solution) == n_dofs

    # Put something in the matrix so we can do a solve
    # Just make it an identity matrix
    # Note: we actually want to fill the matrix with identity values
    #   not replace it with an identity matrix
    for i in 1:n_dofs
        jdis.mat[i,i] = 1
    end

    for i in 1:n_dofs
        jdis.rhs[i] = i
    end

    # Now solve:
    solve!(jdis, assemble=false)

    # Should be the case!
    @test jdis.solution == -jdis.rhs
end

function testFullSolve(diffusion_system)
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

    for i in 1:length(solver.solution)
        @test abs(solver.solution[i] - [0.0, 0.5, 0.5, 0.0, 1.0, 1.0, 0.5, 0.0, 1.0][i]) < 1e-9
    end
end

# Test a 'Full Solve' using JDIS
@testset "JDISFS" begin
    mesh = buildSquare(0, 1, 0, 1, 2, 2)

    diffusion_system = System{Float64}(mesh)

    testFullSolve(diffusion_system)
end

# Test a 'Full Solve' using JDIS and Automatic Differentiation
@testset "JDISFD" begin
    mesh = buildSquare(0, 1, 0, 1, 2, 2)

    diffusion_system = System{Dual{4, Float64}}(mesh)

    testFullSolve(diffusion_system)
end
