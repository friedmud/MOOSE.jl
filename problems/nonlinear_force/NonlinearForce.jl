" Implements a NonlinearSource operator "
type NonlinearForce <: Kernel
    u::Variable
end

import MOOSE.computeQpResidual

@inline function computeQpResidual(kernel::NonlinearForce, qp::Int64, i::Int64)
    u = kernel.u

    return -u.value[qp] * u.value[qp] * u.phi[qp][i]
end

import MOOSE.computeQpJacobian

@inline function computeQpJacobian(kernel::NonlinearForce, v::Variable, qp::Int64, i::Int64, j::Int64)::Float64
    u = kernel.u

    if u.id == v.id
        return -2 * u.value[qp] * v.phi[qp][j] * u.phi[qp][i]
    end

    return 0
end

import MOOSE.coupledVars

@inline function coupledVars(kernel::NonlinearForce)::Array{Variable}
    return [kernel.u]
end
