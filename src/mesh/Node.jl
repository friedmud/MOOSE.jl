"Represents a point in physical space"
type Node{dim} <: DofObject
    "A unique ID for the Node"
    id::Int32

    "x,y,z coordinates"
    coords::Vec{2, Float64}

    "Degrees of freedom assigned to this Node"
    dofs::Array{Int32}
end

import Base.show

function show(io::IO, node::Node)
    println("Node: ", node.id)
    println("  Coords: ", node.coords)
    println("  Dofs: ", node.dofs)
end
