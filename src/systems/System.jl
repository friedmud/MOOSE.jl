include("Variable.jl")
include("../mesh/Mesh.jl")

"""
    A System is a set of variables and equations to be solved simultaneously.
"""
type System
    " The Mesh this System will use "
    mesh::Mesh

    " All of the Variables belonging to this System "
    variables::Array{Variable}

    " The total number of degrees of freedom "
    n_dofs::Int64

    " Whether or not initialize!() has been called for this System "
    initialized::Bool

    " A Mesh must be provided "
    System(mesh::Mesh) = new(mesh, Array{Variable}(0), 0, false)
end

" Add a Variable named name to the System "
function addVariable!(system::System, name::String)
    n_vars = length(system.variables)

    var = Variable(n_vars+1, name)

    push!(system.variables, var)

    return var
end

"""
    Should be called after all Variables have been added to the System and before
    a `Solver` is created.

    The main purpose of this function is to distribute the DoFs across the mesh.
"""
function initialize!(system::System)
    # Go through each node in the mesh and set aside DoFs.
    # These will be "node major"
    n_vars = length(system.variables)

    current_dof = 1
    for node in system.mesh.nodes
        node.dofs = [x for x in current_dof:((n_vars+current_dof)-1)]
        current_dof += n_vars
    end

    # Save off the total number of DoFs distributed
    system.n_dofs = current_dof-1

    # Set a flag that this System is initialized
    system.initialized = true
end
