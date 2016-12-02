@testset "Node" begin
    # Test full construction
    node = Node{2}(12, Vec{2}((2.3, 4.5)), [1,7,9], 2)

    @test node.id == 12
    @test node.coords == [2.3, 4.5]
    @test node.dofs == [1,7,9]

    # Test DofObject interface
    @test dofs(node) == [1,7,9]
    @test processor_id(node) == 2
end
