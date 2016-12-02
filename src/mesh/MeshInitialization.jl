"""
    Build a map of node IDs to elements
"""
function buildNodeToElemMap!(mesh::Mesh)

    node_to_elem_map = mesh.node_to_elem_map

    for elem in mesh.elements
        for node in elem.nodes
            if !(node.id in keys(node_to_elem_map))
                node_to_elem_map[node.id] = Array{Element}(0)
            end

            push!(node_to_elem_map[node.id], elem)
        end
    end
end

"""
    Called after adding all of the nodes and elements to the mesh.
    Partitions the mesh and assigns processor IDs
"""
function initialize!(mesh::Mesh)
    buildNodeToElemMap!(mesh)

    partition!(mesh, SimplePartitioner)
end
