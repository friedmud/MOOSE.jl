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


"""
    Should be called after all Variables have been added to the System and before
    a `Solver` is created.

    The main purpose of this function is to distribute the DoFs across the mesh.
"""
function initialize!(sys::System)
    # Go through each node in the mesh and set aside DoFs.
    # These will be "node major"
    n_vars = length(sys.variables)

    current_dof = 1
    for node in sys.mesh.nodes
        node.dofs = [x for x in current_dof:((n_vars+current_dof)-1)]
        current_dof += n_vars
    end

    # Save off the total number of DoFs distributed
    sys.n_dofs = current_dof-1

    # Set a flag that this System is initialized
    sys.initialized = true
end


"""
    Reinitialize all of the data and objects in the system for the current Element
"""
function reinit!(sys::System, elem::Element)
#    coords = Vec{2, Float64}[Vec{2}((-1, -1)),
#                             Vec{2}((1, -1)),
#                             Vec{2}((1, 1)),
#                             Vec{2}((-1, 1))]

#    reinit!(sys.fe_values, )
end
