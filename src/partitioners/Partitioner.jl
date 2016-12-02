"""
    Supertype for all Partitioners
"""
abstract Partitioner

"""
    Should be overriden by types that inherit from Partitioner
"""
function partition!(mesh::Mesh, partitioner::Partitioner)
    throw(MethodError(partition!, mesh, partitioner))
end


"""
    After a Partitioner assigns the element processor IDs
    This function should be called to assign the nodal ones

    The way this works is that the node is assigned the _lowest_
    processor ID for all of the elements connected to that node
"""
function assignNodeProcessorIDs(mesh::Mesh)
    # We require that the node_to_elem_map has been formed at this point
    @assert length(mesh.node_to_elem_map) > 0

    for node in mesh.nodes
        connected_elems = mesh.node_to_elem_map[node.id]

        min_proc_id = typemax(Int64)

        for elem in connected_elems
            if elem.processor_id < min_proc_id
                min_proc_id = elem.processor_id
            end
        end

        node.processor_id = min_proc_id
    end
end
