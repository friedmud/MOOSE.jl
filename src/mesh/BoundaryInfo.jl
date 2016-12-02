type ElemSidePair
    element::Element
    side::Int64
end

type BoundaryInfo
    "Unique IDs for sidesets"
    sidesets::Array{Int64}

    "Unique IDs for nodesets"
    nodesets::Array{Int64}

    "Map a sideset ID into an array of element/sides"
    side_list::Dict{Int64, Array{ElemSidePair}}

    "Map a nodeset ID to Nodes"
    node_list::Dict{Int64, Array{Node}}

    BoundaryInfo() = new([], [], Dict{Int64, Array{ElemSidePair}}(), Dict{Int64, Array{Node}}())
end
