" Implements a CoupledConvection operator "
type ADCoupledConvection <: Kernel
    u::Variable
    other_var::Variable
end

import MOOSE.computeQpResidual

@inline function computeQpResidual(kernel::ADCoupledConvection, qp::Int64, i::Int64)
    u = kernel.u

    other_var = kernel.other_var

    return (other_var.grad[qp] ⋅ u.grad[qp]) * u.phi[qp][i]
end

# Specifically leaving out computeQpJacobian() to test Automatic Differentiation
# Note: Any Kernel can be used with AD, even if it defines computeQpJacobian()
# We're just leaving it out here to make _doubly_ sure that there is no way
# computeQpJacobian() is getting called!
