type Mesh
    nodes::Array{Node}
    elements::Array{Element}
    boundary_info::BoundaryInfo

    # Map Node IDs to the elements they are connected to
    node_to_elem_map::Dict{Int64, Array{Element}}

    Mesh() = new(Array{Node}(), Array{Element}(), BoundaryInfo(), Dict{Int64, Array{Element}}())
    Mesh(nodes::Array{Node}, elements::Array{Element}) = new(nodes, elements, BoundaryInfo(), Dict{Int64, Array{Element}}())
end
