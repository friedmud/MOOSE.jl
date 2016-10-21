@testset "Node" begin
    # Test full construction
    node = Node(12, [2.3, 4.5], [1,7,9])

    @test node.id == 12
    @test node.coords == [2.3, 4.5]
    @test node.dofs == [1,7,9]

    # Test DofObject interface
    @test dofs(node) == [1,7,9]
end
