@testset "Mesh" begin
    # Need some Nodes
    node1 = Node{2}(1,   Vec{2}((2.3, 4.5)), [1,7,9], 3)
    node3 = Node{2}(3,   Vec{2}((2.3, 4.5)), [1,7,9], 3)
    node13 = Node{2}(13, Vec{2}((2.3, 4.5)), [1,7,9], 3)
    node18 = Node{2}(18, Vec{2}((2.3, 4.5)), [1,7,9], 3)
    node21 = Node{2}(21,   Vec{2}((2.3, 4.5)), [1,7,9], 3)
    node23 = Node{2}(23,   Vec{2}((2.3, 4.5)), [1,7,9], 3)

    # Test Full Construction
    element = Element(11, [node1, node3, node13, node18], [12,17,81], 3)
    element2 = Element(12, [node1, node3, node21, node23], [212,217,281], 3)

    # Create a Mesh
    mesh = Mesh((Node)[node1, node3, node13, node18, node21, node23], [element, element2])

    initialize!(mesh)

    @test mesh.nodes[2].id == 3
    @test mesh.elements[2].id == 12

    @test mesh.node_to_elem_map[3] == [element, element2]
end
