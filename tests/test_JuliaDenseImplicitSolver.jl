@testset "Solver" begin
    mesh = buildSquare(0,1,0,1,2,2)

    sys = System(mesh)

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
    solve!(jdis)

    # Should be the case!
    @test jdis.solution == jdis.rhs
end
