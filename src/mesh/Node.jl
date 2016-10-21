include("DofObject.jl")

"Represents a point in physical space"
type Node <: DofObject
    "A unique ID for the Node"
    id::Int64

    "x,y,z coordinates"
    coords::Array{Float64}

    "Degrees of freedom assigned to this Node"
    dofs::Array{Int64}
end

import Base.show

function show(io::IO, node::Node)
    println("Node: ", node.id)
    println("  Coords: ", node.coords)
    println("  Dofs: ", node.dofs)
end
