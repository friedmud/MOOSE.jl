type ElemSidePair
    element::Element
    side::Int32
end

type BoundaryInfo
    "Unique IDs for sidesets"
    sidesets::Array{Int32}

    "Unique IDs for nodesets"
    nodesets::Array{Int32}

    "Map a sideset ID into an array of element/sides"
    side_list::Dict{Int32, Array{ElemSidePair}}

    "Map a nodeset ID to Nodes"
    node_list::Dict{Int32, Array{Node}}

    BoundaryInfo() = new([], [], Dict{Int32, Array{ElemSidePair}}(), Dict{Int32, Array{Node}}())
end
