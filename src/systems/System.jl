"""
    A System is a set of variables and equations to be solved simultaneously.
"""
type System
    " The Mesh this System will use "
    mesh::Mesh

    " All of the Variables belonging to this System "
    variables::Array{Variable}

    " All of the Kernels belonging to this System "
    kernels::Array{Kernel}

    " All of the BoundaryConditions belonging to this System "
    bcs::Array{BoundaryCondition}

    " The total number of degrees of freedom "
    n_dofs::Int64

    " Whether or not initialize!() has been called for this System "
    initialized::Bool

    " The Quadrature Rule "
    q_rule::QuadratureRule

    " The Function Space "
    func_space::FunctionSpace

    " The Current FEValues "
    fe_values::FECellValues

    " A Mesh must be provided "
    System(mesh::Mesh) = (x = new(mesh,
                                  Array{Variable}(0),
                                  Array{Kernel}(0),
                                  Array{BoundaryCondition}(0),
                                  0,
                                  false,
                                  QuadratureRule{2,RefCube}(:legendre, 2),
                                  Lagrange{2, RefCube, 1}()) ;
                          x.fe_values = FECellValues(x.q_rule, x.func_space);
                          return x)
end

" Add a Variable named name to the System "
function addVariable!(sys::System, name::String)
    n_vars = length(sys.variables)

    var = Variable(n_vars+1, name)

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

    # Go over the elements and set the DoFs for the nodes (if they haven't already been set)
    # We go over elements for a couple of reasons... but the main one for now is to match
    # the way libMesh does it to make it easy to compare Jacobian/Residual matrices!

    current_dof = 1

    for elem in sys.mesh.elements
        for node in elem.nodes
            if length(node.dofs) == 0 # Only set DoFs if they haven't been set before
                node.dofs = [x for x in current_dof:((n_vars+current_dof)-1)]
                current_dof += n_vars
            end
        end
    end

    # Save off the total number of DoFs distributed
    sys.n_dofs = current_dof-1
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
    Grab all of the DoF indices for the current element for a give variable
"""
function connectedDofIndices(elem::Element, var::Variable)
    [ node.dofs[var.id] for node in elem.nodes ]
end

"""
    Reinitialize all of the data and objects in the system for the current Element
"""
function reinit!(sys::System, elem::Element, solution::Array)
    # Grab all of the coordinattes for the current element
    coords = [node.coords for node in elem.nodes]

    # Reinitialize the shape functions
    JuAFEM.reinit!(sys.fe_values, coords)

    # Reinitialize the variable values
    for var in sys.variables
        # Need to grab the dof_indices for this variable on this element
        dof_indices = connectedDofIndices(elem, var)

        # Now pull out those pieces of the solution vector
        dof_values = solution[dof_indices]

        # Recompute the Variable values
        reinit!(var, sys.fe_values, dof_indices, dof_values)
    end
end



"""
    Reinitialize all of the data and objects in the system for the current Node
"""
function reinit!(sys::System, node::Node, solution::Array)
    # Reinitialize the variable values
    for var in sys.variables
        dof_index = node.dofs[var.id]
        dof_value = solution[dof_index]

        # Recompute the Variable values
        reinit!(var, dof_index, dof_value)
    end
end
