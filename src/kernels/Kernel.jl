"""
    A Kernel represents one (or more) volume integral terms in the weak form of a PDE

    All Kernels _must_ have a member variable named `u` that is of type Variable.
    That `Variable` is the one being operated on by this Kernel
"""
abstract Kernel
    #u::Variable

"""
    Required to be overrdien!

    Inherited types should fill in the Residual vector
"""
function computeResidual!(residual::Vector{Float64}, kernel::Kernel)
    throw(MethodError(computeResidual!, residual, kernel))
end

"""
    Should be overridden!

    Inherited types should fill in the Jacobian vector

    Computes the derivative of the residual for `kernel` WRT the variable `v`
    and stores it in `jacobian`
"""
function computeJacobian!(jacobian::Matrix{Float64}, kernel::Kernel, v::Variable)
end

"""
    Compute both simultaneously.

    Overridden versions can be more efficient
"""
function computeResidualAndJacobian!(residual::Vector{Float64}, jacobian::Matrix{Float64}, kernel::Kernel)
    computeResidual!(residual, kernel)
    computeJacobian!(jacobian, kernel, kernel.u)
end
