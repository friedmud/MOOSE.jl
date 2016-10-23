" Boundary condition expressing `u = value` at a set of nodes "
type DirichletBC <: NodalBC
    " The variable the BC will be applied to "
    u::Variable

    " The boundary ID to apply this BC to "
    bids::Array{Int64}

    " The value on the boundary "
    value::Float64
end

function computeResidual(bc::DirichletBC)
    u = bc.u

    return u.nodal_value - bc.value
end

function computeJacobian(bc::DirichletBC, v::Variable)
    u = bc.u

    if u.id == v.id
        return 1.
    end
end
