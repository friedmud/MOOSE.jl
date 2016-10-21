include("Mesh.jl")

"Create a 2D square using Quad4 elements."
function buildSquare(xmin::Real, xmax::Real, ymin::Real, ymax::Real, n_elems_x::Integer, n_elems_y::Integer)
    # Create the Mesh
    mesh = Mesh()

    # Set the sideset / nodeset numberings:
    boundary_info = mesh.boundary_info

    boundary_info.sidesets = [1,2,3,4]
    boundary_info.nodesets = [1,2,3,4]

    for bid in [1,2,3,4]
        boundary_info.side_list[bid] = Array{ElemSidePair}(0)
        boundary_info.node_list[bid] = Array{Node}(0)
    end

    # First: create all of the Nodes
    n_nodes_x = n_elems_x + 1
    n_nodes_y = n_elems_y + 1

    nodes = Array{Node}(n_nodes_x * n_nodes_y)

    x_range = xmax - xmin
    y_range = ymax - ymin

    x_increment = x_range / n_elems_x
    y_increment = y_range / n_elems_y

    node_id = 1
    for x_idx = 1:n_nodes_x

        # x position
        x = xmin + ((x_idx-1) * x_increment)

        for y_idx = 1:n_nodes_y

            # y position
            y = ymin + ((y_idx-1) * y_increment)

            # Create the node
            node = Node(node_id, [x,y], [])

            # Save it off
            nodes[node_id] = node

            # Add this Node to any relevant nodesets...

            # Bottom
            if y_idx == 1
                push!(boundary_info.node_list[1], node)
            end

            # Right
            if x_idx == n_nodes_x
                push!(boundary_info.node_list[2], node)
            end

            # Top
            if y_idx == n_nodes_y
                push!(boundary_info.node_list[3], node)
            end

            # Left Side
            if x_idx == 1
                push!(boundary_info.node_list[4], node)
            end

            node_id += 1
        end
    end

    # Now create Elements
    elements = Array{Element}(n_elems_x * n_elems_y)

    element_id = 1

    # Idea taken from libMesh mesh_generation.C
    idx(x_idx, y_idx) = ( (y_idx-1) + (x_idx-1) * (n_nodes_y) ) + 1

    for x_idx = 1:n_elems_x
        for y_idx = 1:n_elems_y

            # Create the Element
            element = Element(element_id,
                              [nodes[idx(x_idx, y_idx)],
                               nodes[idx(x_idx+1, y_idx)],
                               nodes[idx(x_idx+1, y_idx+1)],
                               nodes[idx(x_idx, y_idx+1)]],
                              [])

            # Save it off
            elements[element_id] = element

            # Add it to any relevant sidesets...

            # Bottom
            if y_idx == 1
                push!(boundary_info.side_list[1], ElemSidePair(element, 1))
            end

            # Right
            if x_idx == n_elems_x
                push!(boundary_info.side_list[2], ElemSidePair(element, 2))
            end

            # Top
            if y_idx == n_elems_y
                push!(boundary_info.side_list[3], ElemSidePair(element, 3))
            end

            # Left Side
            if x_idx == 1
                push!(boundary_info.side_list[4], ElemSidePair(element, 4))
            end


            element_id += 1
        end
    end

    mesh.elements = elements
    mesh.nodes = nodes

    return mesh
end
