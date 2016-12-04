@testset "System" begin
    mesh = buildSquare(0,1,0,1,2,2)

    sys = System{Float64}(mesh)

    @test sys.mesh.elements[1].id == 1

    dog = addVariable!(sys, "dog")
    cat = addVariable!(sys, "cat")

    @test dog.id == 1
    @test dog.name == "dog"

    @test cat.id == 2
    @test cat.name == "cat"

    MOOSE.initialize!(sys)

    MOOSE.findGhostedDofs!(sys)

    @test sys.n_dofs == length(mesh.nodes) * length(sys.variables)

    if MPI.Comm_size(MPI.COMM_WORLD) == 2
        if MPI.Comm_rank(MPI.COMM_WORLD) == 0
            @test sys.local_n_dofs == 12

            @test sys.ghosted_dofs == Set{Int64}()

            @test mesh.nodes[1].dofs == [1,2]
            @test mesh.nodes[3].dofs == [9,10]

            @test mesh.nodes[7].dofs == [15,16]
            @test mesh.nodes[8].dofs == [13,14]

            # Test getting the dof indices
            dog_dofs = MOOSE.connectedDofIndices(mesh.elements[1], dog)
            @test dog_dofs == [1, 3, 5, 7]
            cat_dofs = MOOSE.connectedDofIndices(mesh.elements[1], cat)
            @test cat_dofs == [2, 4, 6, 8]

            # Test reinit
            MOOSE.reinit!(sys, mesh.elements[1], ones(18))

            @test_approx_eq dog.value [1,1,1,1]
            @test_approx_eq cat.value [1,1,1,1]
        end

        if MPI.Comm_rank(MPI.COMM_WORLD) == 1
            @test sys.ghosted_dofs == Set{Int64}([7,11,8,5,6,12])

            @test sys.local_n_dofs == 6

            @test sys.first_local_dof == 13
            @test sys.last_local_dof == 18

            @test mesh.nodes[7].dofs == [15,16]
            @test mesh.nodes[8].dofs == [13,14]

            dog_dofs = MOOSE.connectedDofIndices(mesh.elements[4], dog)
            @test dog_dofs == [5, 11, 17, 13]
            cat_dofs = MOOSE.connectedDofIndices(mesh.elements[4], cat)
            @test cat_dofs == [6, 12, 18, 14]

            # Test reinit
            MOOSE.reinit!(sys, mesh.elements[4], ones(18))

            @test_approx_eq dog.value [1,1,1,1]
            @test_approx_eq cat.value [1,1,1,1]
        end
    end
end
