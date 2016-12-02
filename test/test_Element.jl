@testset "Element" begin
    # Need some Nodes
    node1 = Node{2}(1,   Vec{2}((2.3, 4.5)), [1,7,9], 3)
    node3 = Node{2}(3,   Vec{2}((2.3, 4.5)), [1,7,9], 3)
    node13 = Node{2}(13, Vec{2}((2.3, 4.5)), [1,7,9], 3)
    node18 = Node{2}(18, Vec{2}((2.3, 4.5)), [1,7,9], 3)

    # Test Full Construction
    element = Element(11, [node1, node3, node13, node18], [12,17,81], 3)

    @test element.id == 11
    @test element.nodes[2].id == 3
    @test element.dofs == [12,17,81]

    # Test DofObject Interface
    @test dofs(element) == [12,17,81]
    @test processor_id(element) == 3
end
