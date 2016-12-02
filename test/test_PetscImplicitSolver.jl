using MiniPETSc

@testset "PIS" begin
    mesh = buildSquare(0,1,0,1,2,2)

    sys = System{Float64}(mesh)

    dog = addVariable!(sys, "dog")
    cat = addVariable!(sys, "cat")

    initialize!(sys)

    pis = PetscImplicitSolver(sys)

    # Make sure it's not iniitialized by default
    @test !pis.initialized

    initialize!(pis)

    # Now it should be
    @test pis.initialized

    n_dofs = sys.n_dofs

    @test size(pis.mat) == (n_dofs, n_dofs)
    @test length(pis.rhs) == n_dofs
    @test length(pis.solution) == n_dofs

    # Put something in the matrix so we can do a solve
    # Just make it an identity matrix
    # Note: we actually want to fill the matrix with identity values
    #   not replace it with an identity matrix
    for i in 1:n_dofs
        pis.mat[i,i] = 1
    end

    for i in 1:n_dofs
        pis.rhs[i] = i
    end

    MiniPETSc.assemble!(pis.mat)
    MiniPETSc.assemble!(pis.rhs)

    # Now solve:
    solve!(pis, assemble=false)

    # Should be the case!
    for i in 1:length(pis.solution)
        @test abs(pis.solution[i] - pis.rhs[i]) < 1e-9
    end
end

function testFullSolvePIS(diffusion_system)
    u = addVariable!(diffusion_system, "u")

    diffusion_kernel = Diffusion(u)
    addKernel!(diffusion_system, diffusion_kernel)

    left_boundary = DirichletBC(u, [4], 0.0)
    addBC!(diffusion_system, left_boundary)

    right_boundary = DirichletBC(u, [2], 1.0)
    addBC!(diffusion_system, right_boundary)

    initialize!(diffusion_system)

    solver = PetscImplicitSolver(diffusion_system)

    solve!(solver)

    for i in 1:length(solver.solution)
        @test abs(solver.solution[i] - [0.0, 0.5, 0.5, 0.0, 1.0, 1.0, 0.5, 0.0, 1.0][i]) < 1e-9
    end
end

# Test a 'Full Solve' using PIS
@testset "PISFS" begin
    mesh = buildSquare(0, 1, 0, 1, 2, 2)

    diffusion_system = System{Float64}(mesh)

    testFullSolvePIS(diffusion_system)
end

# Test a 'Full Solve' using PIS and Automatic Differentiation
@testset "PISFD" begin
    mesh = buildSquare(0, 1, 0, 1, 2, 2)

    diffusion_system = System{Dual{4, Float64}}(mesh)

    testFullSolvePIS(diffusion_system)
end
