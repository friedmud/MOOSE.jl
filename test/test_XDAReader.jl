@testset "XDAReader" begin
    mesh = readXDAMesh("data/square.xda")

    @test mesh.nodes[3].coords[1] == 0.5
    @test mesh.nodes[3].coords[2] == 0.5
end
