type Mesh
    nodes::Array{Node}
    local_nodes::Array{Node}
    elements::Array{Element}
    local_elements::Array{Element}
    boundary_info::BoundaryInfo

    # Map Node IDs to the elements they are connected to
    node_to_elem_map::Dict{Int64, Array{Element}}

    Mesh() = new(Array{Node}(0), Array{Node}(0), Array{Element}(0), Array{Element}(0), BoundaryInfo(), Dict{Int64, Array{Element}}())
    Mesh(nodes::Array{Node}, elements::Array{Element}) = new(nodes, Array{Node}(0), elements, Array{Element}(0), BoundaryInfo(), Dict{Int64, Array{Element}}())
end
