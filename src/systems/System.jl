include("Variable.jl")

"""
    A System is a set of variables and equations to be solved simultaneously.
"""
type System
    " All of the Variables belonging to this System "
    variables::Array{Variable}

    " The total number of degrees of freedom "
    n_dofs::Int64

    " Default Constructor "
    System() = new(Array{Variable}(0))
end

" Add a Variable named name to the System "
function addVariable!(system::System, name::String)
    n_vars = length(system.variables)

    var = Variable(n_vars+1, name)

    push!(system.variables, var)

    return var
end
