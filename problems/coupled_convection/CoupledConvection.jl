" Implements a CoupledConvection operator "
type CoupledConvection <: Kernel
    u::Variable
    other_var::Variable
end

import MOOSE.computeQpResidual

function computeQpResidual(kernel::CoupledConvection, qp::Int64, i::Int64)
    u = kernel.u

    other_var = kernel.other_var

    return (other_var.grad[qp] ⋅ u.grad[qp]) * u.phi[qp][i]
#    return other_var.value[qp] * other_var.value[qp] * u.phi[qp][i]
end

import MOOSE.computeQpJacobian

function computeQpJacobian(kernel::CoupledConvection, v::Variable, qp::Int64, i::Int64, j::Int64)
    u = kernel.u

    other_var = kernel.other_var

    if u.id == v.id
        return (other_var.grad[qp] ⋅ u.grad_phi[qp][j]) * u.phi[qp][i]
    elseif other_var.id == v.id
        return (other_var.grad_phi[qp][j] ⋅ u.grad[qp]) * u.phi[qp][i]
    end

#    if other_var.id == v.id
#        return 2 * other_var.value[qp] * other_var.phi[qp][j] * u.phi[qp][i]
#    end

    return 0
end
