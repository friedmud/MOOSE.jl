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
    Build lists of local elements and nodes
"""
function buildNodeAndElemLists(mesh::Mesh)
    proc_id = MPI.Comm_rank(MPI.COMM_WORLD)

    for elem in mesh.elements
        if elem.processor_id == proc_id
            push!(mesh.local_elements, elem)
        end
    end

    for node in mesh.nodes
        if node.processor_id == proc_id
            push!(mesh.local_nodes, node)
        end
    end
end

"""
    Called after adding all of the nodes and elements to the mesh.
    Partitions the mesh and assigns processor IDs
"""
function initialize!(mesh::Mesh)
    buildNodeToElemMap!(mesh)

    if MPI.Comm_size(MPI.COMM_WORLD) <= 2
        partition!(mesh, SimplePartitioner)
    else
        partition!(mesh, MetisPartitioner)
    end

    buildNodeAndElemLists(mesh)
end
