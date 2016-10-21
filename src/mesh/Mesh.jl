include("Node.jl")
include("Element.jl")
include("BoundaryInfo.jl")

type Mesh
    nodes::Array{Node}
    elements::Array{Element}
    boundary_info::BoundaryInfo

    Mesh() = new(Array{Node}(), Array{Element}(), BoundaryInfo())
    Mesh(nodes::Array{Node}, elements::Array{Element}) = new(nodes, elements, BoundaryInfo())
end
