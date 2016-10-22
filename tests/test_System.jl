@testset "System" begin
    mesh = buildSquare(0,1,0,1,2,2)

    sys = System(mesh)

    @test sys.mesh.elements[1].id == 1

    dog = addVariable!(sys, "dog")
    cat = addVariable!(sys, "cat")

    @test dog.id == 1
    @test dog.name == "dog"

    @test cat.id == 2
    @test cat.name == "cat"

    initialize!(sys)

    @test sys.n_dofs == length(mesh.nodes) * length(sys.variables)

    @test mesh.nodes[1].dofs == [1,2]
    @test mesh.nodes[3].dofs == [5,6]

    # Test getting the dof indices
    dog_dofs = MOOSE.connectedDofIndices(mesh.elements[1], dog)
    @test dog_dofs == [1, 7, 9, 3]
    cat_dofs = MOOSE.connectedDofIndices(mesh.elements[1], cat)
    @test cat_dofs == [2, 8, 10, 4]

    dog_dofs = MOOSE.connectedDofIndices(mesh.elements[4], dog)
    @test dog_dofs == [9, 15, 17, 11]
    cat_dofs = MOOSE.connectedDofIndices(mesh.elements[4], cat)
    @test cat_dofs == [10, 16, 18, 12]

    # Test reinit
    MOOSE.reinit!(sys, mesh.elements[1], ones(18))

    @test_approx_eq dog.value [1,1,1,1]
    @test_approx_eq cat.value [1,1,1,1]
end
