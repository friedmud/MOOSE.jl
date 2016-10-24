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

    initialize!(sys)

    @test sys.n_dofs == length(mesh.nodes) * length(sys.variables)

    @test mesh.nodes[1].dofs == [1,2]
    @test mesh.nodes[3].dofs == [9,10]

    # Test getting the dof indices
    dog_dofs = MOOSE.connectedDofIndices(mesh.elements[1], dog)
    @test dog_dofs == [1, 3, 5, 7]
    cat_dofs = MOOSE.connectedDofIndices(mesh.elements[1], cat)
    @test cat_dofs == [2, 4, 6, 8]

    dog_dofs = MOOSE.connectedDofIndices(mesh.elements[4], dog)
    @test dog_dofs == [5, 11, 17, 13]
    cat_dofs = MOOSE.connectedDofIndices(mesh.elements[4], cat)
    @test cat_dofs == [6, 12, 18, 14]

    # Test reinit
    MOOSE.reinit!(sys, mesh.elements[1], ones(18))

    @test_approx_eq dog.value [1,1,1,1]
    @test_approx_eq cat.value [1,1,1,1]
end


@testset "SystemFD" begin
    mesh = buildSquare(0,1,0,1,2,2)

    sys = System{Dual{8, Float64}}(mesh)

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
    @test mesh.nodes[3].dofs == [9,10]

    # Test getting the dof indices
    dog_dofs = MOOSE.connectedDofIndices(mesh.elements[1], dog)
    @test dog_dofs == [1, 3, 5, 7]
    cat_dofs = MOOSE.connectedDofIndices(mesh.elements[1], cat)
    @test cat_dofs == [2, 4, 6, 8]

    dog_dofs = MOOSE.connectedDofIndices(mesh.elements[4], dog)
    @test dog_dofs == [5, 11, 17, 13]
    cat_dofs = MOOSE.connectedDofIndices(mesh.elements[4], cat)
    @test cat_dofs == [6, 12, 18, 14]

    # Test reinit
    MOOSE.reinit!(sys, mesh.elements[1], ones(18))

    @test_approx_eq dog.value [1,1,1,1]
    @test_approx_eq cat.value [1,1,1,1]

    @test partials(dog.value[1])[1] == dog.phi[1][1]
    @test partials(dog.value[1])[2] == dog.phi[1][2]
    @test partials(dog.value[1])[3] == dog.phi[1][3]
    @test partials(dog.value[1])[4] == dog.phi[1][4]

    @test partials(dog.value[1])[5] == 0.
    @test partials(dog.value[1])[6] == 0.
    @test partials(dog.value[1])[7] == 0.
    @test partials(dog.value[1])[8] == 0.


    @test partials(cat.value[1])[1] == 0.
    @test partials(cat.value[1])[2] == 0.
    @test partials(cat.value[1])[3] == 0.
    @test partials(cat.value[1])[4] == 0.

    @test partials(cat.value[1])[5] == cat.phi[1][1]
    @test partials(cat.value[1])[6] == cat.phi[1][2]
    @test partials(cat.value[1])[7] == cat.phi[1][3]
    @test partials(cat.value[1])[8] == cat.phi[1][4]
end
