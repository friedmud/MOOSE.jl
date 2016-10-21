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
end
