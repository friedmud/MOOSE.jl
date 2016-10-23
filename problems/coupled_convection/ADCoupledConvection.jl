" Implements a CoupledConvection operator "
type ADCoupledConvection <: Kernel
    u::Variable
    other_var::Variable
end

import MOOSE.computeQpResidual

function computeQpResidual(kernel::ADCoupledConvection, qp::Int64, i::Int64)
    u = kernel.u

    other_var = kernel.other_var

#    println("")
#    println("ov ", other_var.grad[qp])
#    println("u ", u.grad[qp])
#    val = other_var.grad[qp] ⋅ u.grad[qp]
#    println("mult ", val)
#    println("")

    return (other_var.grad[qp] ⋅ u.grad[qp]) * u.phi[qp][i]
end
