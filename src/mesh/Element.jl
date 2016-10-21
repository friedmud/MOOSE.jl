include("DofObject.jl")
include("Node.jl")

"""
  An element is a physical (geometrical) element in space
"""
type Element <: DofObject
    "Unique ID for the Element"
    id::Int64

    "The nodes that make up the physical position"
    nodes::Array{Node}

    "Degrees of freedom assigned to this Element"
    dofs::Array{Int64}
end


import Base.show

function show(io::IO, elem::Element)
    println("Element: ", elem.id)
    println("  Nodes: ", [node.id for node in elem.nodes])
    println("  Dofs: ", elem.dofs)
end
