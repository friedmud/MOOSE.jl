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

    " A Mesh must be provided "
    System(mesh::Mesh) = new(mesh, Array{Variable}(0))
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
function initialize!(system::System, )
    # Go through each node in
end
