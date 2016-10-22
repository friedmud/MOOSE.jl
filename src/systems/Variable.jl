type Variable
    " Unique Identifier for the variable "
    id::Int64

    " Name of the Variable "
    name::String

    " Current values for this variable indexed by [qp] "
    value::Array{Float64,1}

    " Current gradients for this variable indexed by [qp] "
    grad::Array{Vec{2,Float64},1}

    " Current shape functions for this variable indexed by [qp][i] "
    phi::Array{Array{Float64,1}}

    " Current shape function gradients for this variable indexed by [qp][i] "
    grad_phi::Array{Array{Vec{2,Float64}},1}

    " Determinant of the Jacobian pre-multiplied by the weights "
    JxW::Array{Float64,1}

    " Current number of dofs on this element "
    n_dofs::Int64

    " Current number of quadrature points on this element "
    n_qp::Int64

    Variable(id::Int64, name::String) = new(id, name,
                                            Array{Float64}(0),
                                            Array{Vec{2,Float64}}(0),
                                            Array{Array{Float64}}(0),
                                            Array{Array{Vec{2,Float64}},1}(0),
                                            Array{Float64,1}(0),
                                            0,
                                            0)
end

" Recompute all of the data inside of a Variable for a given element "
function reinit!(var::Variable, fe_values::FECellValues, nodal_values::Array{Float64})
    var.phi = fe_values.N
    var.grad_phi = fe_values.dNdx
    var.JxW = fe_values.detJdV

    n_qp = length(fe_values.detJdV)

    var.value = [function_value(fe_values, qp, nodal_values) for qp in 1:n_qp]
    var.grad = [function_gradient(fe_values, qp, nodal_values) for qp in 1:n_qp]

    var.n_dofs = length(nodal_values)
    var.n_qp = n_qp
end
