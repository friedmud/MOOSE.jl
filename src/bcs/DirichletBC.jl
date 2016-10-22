" Boundary condition expressing `u = value` at a set of nodes "
type DirichletBC <: NodalBC
    " The variable the BC will be applied to "
    u::Variable

    " The boundary ID to apply this BC to "
    bids::Array{Int64}

    " The value on the boundary "
    value::Float64
end

function computeResidual!(residual::Vector{Float64}, bc::DirichletBC)
    u = bc.u

    residual[1] = u.nodal_value - bc.value
end

function computeJacobian!(jacobian::Matrix{Float64}, bc::DirichletBC, v::Variable)
    u = bc.u

    # There is only one degree of freedom here, and the shape function is of value 1
    # at the node.
    if v.id == u.id
        jacobian[1,1] = 1.
    end
end
