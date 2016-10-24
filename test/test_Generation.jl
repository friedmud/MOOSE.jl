@testset "buildSquare" begin
    mesh = buildSquare(0, 1, 0, 1, 2, 2)

    # Element 1
    @test mesh.elements[1].nodes[1].coords == Vec{2}((0.,0.))
    @test mesh.elements[1].nodes[2].coords == Vec{2}((0.5,0.))
    @test mesh.elements[1].nodes[3].coords == Vec{2}((0.5,0.5))
    @test mesh.elements[1].nodes[4].coords == Vec{2}((0.,0.5))

    # Element 4
    @test mesh.elements[4].nodes[1].coords == Vec{2}((0.5,0.5))
    @test mesh.elements[4].nodes[2].coords == Vec{2}((1.,0.5))
    @test mesh.elements[4].nodes[3].coords == Vec{2}((1.,1.))
    @test mesh.elements[4].nodes[4].coords == Vec{2}((.5,1.))

    # Boundary Info
    boundary_info = mesh.boundary_info

    @test boundary_info.sidesets == [1,2,3,4]
    @test boundary_info.nodesets == [1,2,3,4]

    # Sideset 1
    @test length(boundary_info.side_list[1]) == 2
    @test boundary_info.side_list[1][1].element.id == 1
    @test boundary_info.side_list[1][1].side == 1
    @test boundary_info.side_list[1][2].element.id == 2
    @test boundary_info.side_list[1][2].side == 1

    # Sideset 2
    @test length(boundary_info.side_list[2]) == 2
    @test boundary_info.side_list[2][1].element.id == 2
    @test boundary_info.side_list[2][1].side == 2
    @test boundary_info.side_list[2][2].element.id == 4
    @test boundary_info.side_list[2][2].side == 2

    # Sideset 3
    @test length(boundary_info.side_list[3]) == 2
    @test boundary_info.side_list[3][1].element.id == 3
    @test boundary_info.side_list[3][1].side == 3
    @test boundary_info.side_list[3][2].element.id == 4
    @test boundary_info.side_list[3][2].side == 3

    # Sideset 4
    @test length(boundary_info.side_list[4]) == 2
    @test boundary_info.side_list[4][1].element.id == 1
    @test boundary_info.side_list[4][1].side == 4
    @test boundary_info.side_list[4][2].element.id == 3
    @test boundary_info.side_list[4][2].side == 4
end
