@testset "MetisPartitioner.jl" begin
    mesh = buildSquare(0, 1, 0, 1, 2, 2)

    MOOSE.partition!(mesh, MOOSE.MetisPartitioner)
end
