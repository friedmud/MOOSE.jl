"""
    A System is a set of variables and equations to be solved simultaneously.

    The parameterization is for the type used for Variable values.
    This controls whether or not automatic diffentiation is used.

    If T = Float64: Then Variable values are just POD.
                    In this case `computeQpJacobian` statements will be used to form the Jacobian

    If T = Dual{X, Float64}: Then Variable values are automatically differentiated types
                             In this case the Jacobians of Residuals will be automatically
                             computed using the partials of the Dual numbers
"""
type System{T}
    " The Mesh this System will use "
    mesh::Mesh

    " All of the Variables belonging to this System "
    variables::Array{Variable{T}}

    " All of the Kernels belonging to this System "
    kernels::Array{Kernel}

    " All of the BoundaryConditions belonging to this System "
    bcs::Array{BoundaryCondition}

    " The total number of degrees of freedom "
    n_dofs::Int64

    " Number of local degrees of freedom "
    local_n_dofs::Int64

    " The first DOF on this processor "
    first_local_dof::Int64

    " The last DOF on this processor "
    last_local_dof::Int64

    " A list of DoFs that need to be ghosted to this processor.  These are DoFs which are off-processor, but we need their values for Assembly. "
    ghosted_dofs::Set{Int64}

    " Whether or not initialize!() has been called for this System "
    initialized::Bool

    " The Quadrature Rule "
    q_rule::QuadratureRule

    " The Function Space "
    func_space::FunctionSpace

    " The Current FEValues "
    fe_values::FECellValues

    " Number of local dofs connected to each local dof.  Must call `generateSparsity!()` to fill "
    local_dof_sparsity::Array{Int32}

    " Number of non-local dofs connected to each local dof. Must call `generateSparsity!()` to fill "
    off_proc_dof_sparsity::Array{Int32}

    " A Mesh must be provided "
    System(mesh::Mesh) = (x = new(mesh,
                                  Array{Variable}(0),
                                  Array{Kernel}(0),
                                  Array{BoundaryCondition}(0),
                                  0,
                                  0,
                                  0,
                                  0,
                                  Set{Int64}(),
                                  false,
                                  QuadratureRule{2,RefCube}(:legendre, 2),
                                  Lagrange{2, RefCube, 1}()) ;
                          x.fe_values = FECellValues(x.q_rule, x.func_space);
                          return x)
end

" Add a Variable named name to the System "
function addVariable!{T}(sys::System{T}, name::String)
    n_vars = length(sys.variables)

    var = Variable{T}(n_vars+1, name)

    push!(sys.variables, var)

    return var
end


" Add a Kernel to the System "
function addKernel!(sys::System, kernel::Kernel)
    push!(sys.kernels, kernel)
end

" Add a BC to the System "
function addBC!(sys::System, bc::BoundaryCondition)
    push!(sys.bcs, bc)
end

" Distribute the DoFs to the DofObjects "
function distributeDofs(sys::System)
    # These will be "node major"
    n_vars = length(sys.variables)

    # Find the number of dofs on each processor
    dofs_per_proc = Array{Int64}(MPI.Comm_size(MPI.COMM_WORLD))
    fill!(dofs_per_proc, 0)

    # Here's the way this works... what we want is the dof IDs for each processor to be contiguous
    # In addition, we want the dof IDs to be increasing with processor_id
    # To do that, we're going to find the total number of DoFs on each processor and communicate
    # that into a vector on every processor.  Next, we'll compute the cumsum of that vector.
    # That cumsum will give us the starting DoF ID for each processor (if we add 1 to it)
    # with one small change: the first processor needs to start at 1...
    # and the final entry in the cumsum is useless
    # So we'll do a little vector manipulation to fix that up.
    #
    # At that point we can loop over the elements and assign dof IDs for ALL dof objects
    # (Yes, even for the ones not owned by this processor)
    # We'll keep track of the current DoF ID for each processor as we go.
    # Every processor will be doing the same thing simultaneously so all processors will
    # end up with exactly the same information.
    #
    # You could attempt to parallelize this... but the gains are minimal unless you want
    # to go to a true distributed mesh.  The reason why is that you would need to add
    # a communication step... but you would still have to assign them to every node on every
    # processor anyway.  At least by doing it this way there is no communication.

    # For now we're just going to say that the number of dofs is the number of
    # local nodes * number of variables.  This would be much more complicated to do if we
    # had element degrees of freedom or higher order shape functions
    sys.local_n_dofs = n_vars * length(sys.mesh.local_nodes)

    dofs_per_proc = MPI.Allgather([sys.local_n_dofs], 1, MPI.COMM_WORLD)

    proc_current_dof = cumsum(dofs_per_proc)

    proc_current_dof .+= 1

    # The first processor is going to start at 1
    unshift!(proc_current_dof, 1)

    # Remove the last entry
    pop!(proc_current_dof)

    proc_id = MPI.Comm_rank(MPI.COMM_WORLD)

    # Set our local information
    sys.first_local_dof = proc_current_dof[proc_id + 1] # Don't forget that MPI is 0-based!
    sys.last_local_dof = sys.first_local_dof + sys.local_n_dofs - 1

    # Go over the elements and set the DoFs for the nodes (if they haven't already been set)
    # We go over elements for a couple of reasons... but the main one for now is to match
    # the way libMesh does it to make it easy to compare Jacobian/Residual matrices!
    for elem in sys.mesh.elements
        for node in elem.nodes
            node_proc_id = node.processor_id
            if length(node.dofs) == 0 # Only set DoFs if they haven't been set before
                current_dof = proc_current_dof[node.processor_id + 1] # Don't forget about 0-based indexing!

                node.dofs = [x for x in current_dof:((n_vars+current_dof)-1)]

                proc_current_dof[node.processor_id + 1] += n_vars
            end
        end
    end

    # Save off the total number of DoFs distributed
    sys.n_dofs = sum(dofs_per_proc)
end

"""
    Find all of the off-processor DoFs that we will need for Assembly
"""
function findGhostedDofs!(sys::System)
    # Basic plan:
    # 1. Loop over local elements
    # 2. Interrogate nodes connected to those elems...
    # 3. If they are off-processor then ghost their dofs

    # Note!  This doesn't create any sort of "halo"...
    # it just barely gets the info we need for Lagrange FE Assembly
    # A lot more could be done here

    proc_id = MPI.Comm_rank(MPI.COMM_WORLD)

    for elem in sys.mesh.local_elements
        for node in elem.nodes
            if node.processor_id != proc_id
                dofs = node.dofs
                for dof in node.dofs
                    push!(sys.ghosted_dofs, dof)
                end
            end
        end
    end
end

"""
    PRIVATE: Helper function
"""
function _addDofs!(sys::System, original_node::Node, other_node::Node, local_dofs::Array, off_proc_dofs::Array)
    for dof in original_node.dofs
        local_dof = (dof - sys.first_local_dof) + 1

        for other_dof in other_node.dofs
            if sys.first_local_dof <= other_dof && other_dof <= sys.last_local_dof
                local_dofs[local_dof] += 1
            else
                off_proc_dofs[local_dof] += 1
            end
        end
    end
end

"""
    Generate Sparsity information
"""
function generateSparsity!(sys::System)
    # Basic plan:
    # 1. Loop over local nodes
    # 2. Add up local dofs on each node as local nonzeros
    # 3. Use node_to_elem_map to get all elems connected to the node
    # 4. Go over nodes connected to those elements and add up the number of local and off-processor dofs

    proc_id = MPI.Comm_rank(MPI.COMM_WORLD)

    local_dofs = Array{Int32}(sys.local_n_dofs)
    fill!(local_dofs, 0)
    off_proc_dofs = Array{Int32}(sys.local_n_dofs)
    fill!(off_proc_dofs, 0)

    for node in sys.mesh.local_nodes
        # Couple all of the dofs on this node to eachother
        _addDofs!(sys, node, node, local_dofs, off_proc_dofs)

        connected_elems = sys.mesh.node_to_elem_map[node.id]

        visited_nodes = Set{Int64}()

        push!(visited_nodes, node.id)

        for elem in connected_elems
            for other_node in elem.nodes
                if !(other_node.id in visited_nodes)
                    _addDofs!(sys, node, other_node, local_dofs, off_proc_dofs)
                    push!(visited_nodes, other_node.id)
                end
            end
        end
    end

    sys.local_dof_sparsity = local_dofs
    sys.off_proc_dof_sparsity = off_proc_dofs
end

"""
    Should be called after all Variables have been added to the System and before
    a `Solver` is created.

    The main purpose of this function is to distribute the DoFs across the mesh.
"""
function initialize!(sys::System)
    distributeDofs(sys)

    # Set a flag that this System is initialized
    sys.initialized = true
end

"""
    Grab all of the DoF indices for the current element for a given variable
"""
function connectedDofIndices(elem::Element, var::Variable)
    [ node.dofs[var.id] for node in elem.nodes ]
end

"""
    Create the vector of dof_values from the dof_indices and solution vector

    Specialization for Float64
"""
function dofValues!(dof_values::Array, sys::System{Float64}, solution::AbstractArray, var::Variable, dof_indices::Array)
    resize!(dof_values, length(dof_indices))
    dof_values[:] = solution[dof_indices]
end

"""
    Create the vector of dof_values from the dof_indices and solution vector

    Specialization for Dual
"""
function dofValues!{N,T}(dof_values::Array, sys::System{Dual{N,T}}, solution::AbstractArray, var::Variable, dof_indices::Array)
    resize!(dof_values, length(dof_indices))

    values = solution[dof_indices]

    n_vars = length(sys.variables)
    n_dofs_per_var = length(dof_indices)
    total_n_dofs = n_vars * n_dofs_per_var

    @assert total_n_dofs <= N

    partial_offset = ((var.id - 1) * n_dofs_per_var)

    for i in 1:n_dofs_per_var
        dof_values[i] = dualVariable(values[i], partial_offset + i, N)
    end
end


"""
    Reinitialize all of the data and objects in the system for the current Element
"""
function reinit!{T}(sys::System{T}, elem::Element, solution::AbstractArray)
    # Grab all of the coordinattes for the current element
    coords = [node.coords for node in elem.nodes]

    # Reinitialize the shape functions
    JuAFEM.reinit!(sys.fe_values, coords)

    # Reinitialize the variable values
    for var in sys.variables
        # Need to grab the dof_indices for this variable on this element
        dof_indices = connectedDofIndices(elem, var)

        # Now pull out those pieces of the solution vector
        dof_values = Array{T}(0)
        dofValues!(dof_values, sys, solution, var, dof_indices)

        # Recompute the Variable values
        reinit!(var, sys.fe_values, dof_indices, dof_values)
    end
end

" Helper function for getting a Float64 dof_value at a Node "
function dofValue(solution::AbstractArray, var::Variable{Float64}, dof_index::Int64)
    return solution[dof_index]
end

" Helper function for getting a Dual dof_value at a Node "
function dofValue{N,T}(solution::AbstractArray, var::Variable{Dual{N,T}}, dof_index::Int64)
    return dualVariable(solution[dof_index], var.id, N)
end

"""
    Reinitialize all of the data and objects in the system for the current Node
"""
function reinit!{T}(sys::System{T}, node::Node, solution::AbstractArray)
    # Reinitialize the variable values
    for var in sys.variables
        dof_index = node.dofs[var.id]
        dof_value = dofValue(solution, var, dof_index)

        # Recompute the Variable values
        reinit!(var, dof_index, dof_value)
    end
end
